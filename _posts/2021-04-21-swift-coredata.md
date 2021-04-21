---
title: "CoreData：データの更新について（Xcode12.4、Swift 5.3.2）"
header:
  overlay_image: /assets/images/pc-freephoto.jpg
  overlay_filter: 0.5
excerpt: "昨日の続き。"
categories:
  - System
  - Programming
tags:
  - Swift
  - Xcode
  - CoreData
---

{% capture target_url %}{{ site.baseurl }}{% post_url 2021-04-20-swift %}{% endcapture %}{% for post in site.posts %}{% assign candidate_url = post.url | relative_url %}{% if candidate_url == target_url %}[{{ post.title }}（{{ post.date | date: "%B %-d, %Y" }}）]({{ target_url }}){% break %}{% endif %}{% endfor %}の続きというか、自分で実装する段になって混乱したのでそのまとめ。

## いつデータは更新したことになるのか

```swift
class CoreDataModel {
    ...（省略）

    static func loadTracks(with predicate: NSPredicate?) -> [Track] {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            abort()
        }

        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Track")
        fetchRequest.predicate = predicate
        fetchRequest.sortDescriptors = [
            NSSortDescriptor(key: "index", ascending: true)
        ]

        do {
            let tracks = try managedContext.fetch(fetchRequest) as! [Track]
            return tracks
        } catch let error as NSError {
            fatalError("Could not fetch. \(error), \(error.userInfo)")
        }
    }
}
```

上のメソッドでtracksはTrackクラスの配列として定義される（色々書いているけど要は`let tracks = なんちゃら as! [Track]`）が、それとDB上のデータは別物だと考えていた。まあ別物で正解なのだが、間にワンクッションあることを理解していなかった。

tracks -> MOC -> Database

つまりtracksを編集した結果がMOCとして一時保存されているとわかっていなかった。

なんならデータの作成が`SaveContext()`なら更新はどれ？ってググってもみんな上記のように`try managedContext.fetch(fetchRequest)`で変数を定義したらそれを編集して最後に`save()`しているだけ。`save()`と`saveContext()`の違いって何？と調べていったら自分のAppDelegate.swiftにしっかり`save()`を含めた`saveContext()`が定義されていたw

じゃあ`saveContext()`も更新に使えて、それを呼び出すまでデータは更新されないのだなと思ったら、`SaveContext()`をしていないのに`var tracks = CoreDataModel.loadTracks(with: nil)`をやり直すとなぜか編集後の結果がロードされることに戸惑った。

ずーっと格闘していたが、ようやっとワンクッションあることに気づく。

合わせて、ワンクッション置かれたデータを削除する`rollback()`も学んだ。以下はSwift 2.1だが参考になったのであげておく。

[【Swift】Core Dataの使い方。保存データの更新、削除、ロールバックを行う。(Swift 2.1、XCode 7.2) \| はじはじアプリ体験メモ](https://hajihaji-lemon.com/swift/coredata_rollback/)

みんなの常識、ぼくの非常識……、いや、上記のほとんどは{% capture target_url %}{{ site.baseurl }}{% post_url 2021-04-20-swift %}{% endcapture %}{% for post in site.posts %}{% assign candidate_url = post.url | relative_url %}{% if candidate_url == target_url %}[{{ post.title }}（{{ post.date | date: "%B %-d, %Y" }}）]({{ target_url }}){% break %}{% endif %}{% endfor %}の参考記事に載っていたのだが。

## 次回予告（笑）

何がいつ更新されたのか、問題がわかりにくかったのはUITableViewを併用していたせいもある。まだ実装自体が途中なので、明日のネタとして置いておく。上記`tracks: [Track]`とCoreDataの区別や、前者は配列なのに後者はデータに順番なんて考慮しないからその齟齬をどうやって埋めるかとか、面倒事が多い。
