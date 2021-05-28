---
title: "【Swift】CSVを読み込んでCoreDataに保存（Xcode12.4、Swift 5.3.2）"
header:
  overlay_image: /assets/images/linux-freephoto.jpg
  overlay_filter: 0.5
excerpt: "CoreDataを使って、音楽アプリのアルバムとトラックをそれぞれ`Album`、`Track`エンティティとして管理しているが、それらをCSVファイルで管理できるようにしたい。手始めに、手動でCSVファイルを作り、プログラムで読み込んでそれらをCoreDataに保存させた。やってみたらスマートではないかもしれないが簡単に実装できた。"
categories:
  - System
  - Programming
tags:
  - Swift
  - CoreData
  - CSV
---

ボタンを押したらCSVファイルを読み込んでCoreDataに保存する。

![alt]({{ "/assets/images/coredata-load-csv-button.jpg" | relative_url }})

試しで作ったCSVファイルはこれ。1行目で属性名を説明代わりに入れており、最後の行はXcodeでcsvファイルを作成すると自動的に改行される。

```text
index,title
0,A1
1,A2
2,A3

```

## 実装の流れ（アルバムの場合）

1. CoreData上のデータを削除
1. `Bundle`を使ってcsvファイルのパスを取得し、まず文字列としてcsvファイルを読み込む
1. 改行位置で分割した配列を作成
1. 先頭と最後は余計なデータが付いているので削除
1. 新しいデータをCoreData上に作って、属性（Attributes）に読み取ったデータを型変換しながら代入

個人的にはあまりスマートではない印象。属性を配列の要素としてひとまず扱っているから、属性にデータを代入する際、要素番号で指定しているのって見た目ダサない？これだとCSVファイルの内容が間違っているときの対応を書くのも面倒そうだし。構造体でも使うのかねぇ……「たった2日」のLesson day 2-4でJSONファイルを読み込んでいたが、あんな感じかな、と思いつつ、とりあえず実装できているんだから賢くコーディングするのは後回し。

<!-- START MoshimoAffiliateEasyLink -->
<script type="text/javascript" src="{{ '/assets/js/affiliate/tattafutsukademasuta.js' | relative_url }}"></script>
<div id="msmaflink-ybY2M">リンク</div>
<p></p>
<!-- MoshimoAffiliateEasyLink END -->

アルバムとトラックの2つを扱っているけど、トラックはほぼアルバムそのままなのでいったん省略して、アルバムの処理について以下にコードを載せておく。こんなに`static`を使っているとアホそうな実装だと思うのはおれだけ？笑

下の中身を多少？詳しく説明していたりそもそもCoreDataの扱いを時分なりに理解した話は
{% capture target_url %}{{ site.baseurl }}{% post_url 2021-04-21-swift-coredata %}{% endcapture %}
{% for post in site.posts %}{% assign candidate_url = post.url | relative_url %}{% if candidate_url == target_url %}
[{{ post.title }}（{{ post.date | date: "%B %-d, %Y" }}）]({{ target_url }}){% break %}{% endif %}{% endfor %}
と、
{% capture target_url %}{{ site.baseurl }}{% post_url 2021-04-22-swift-coredata_and_tableview %}{% endcapture %}
{% for post in site.posts %}{% assign candidate_url = post.url | relative_url %}{% if candidate_url == target_url %}
[{{ post.title }}（{{ post.date | date: "%B %-d, %Y" }}）]({{ target_url }}){% break %}{% endif %}{% endfor %}
に書いていたりする。

参考資料は

[[Swift]CSVを読み込みRealmに保存してみる \| RE:ENGINES](https://re-engines.com/2018/06/11/swiftcsv%E3%82%92%E8%AA%AD%E3%81%BF%E8%BE%BC%E3%81%BFrealm%E3%81%AB%E4%BF%9D%E5%AD%98%E3%81%97%E3%81%A6%E3%81%BF%E3%82%8B/)

[SwiftでCSVデータを読み込んでコンソールに出力 - Qiita](https://qiita.com/motokiohkubo/items/ab150591a7ddea830b86)

```swift
import UIKit
import CoreData

class CoreDataModel {
    static func loadCSV() {
        loadAlbumsCSV()
        loadTracksCSV()
    }

    static func loadAlbumsCSV() {
        guard let path = Bundle.main.path(forResource:"Albums", ofType:"csv") else {
            print("Failed to find Albums.csv.")
            return
        }

        do {
            let csv = try String(contentsOfFile: path, encoding: String.Encoding.utf8)
            var groupedAttributesOfAlbums = csv.components(separatedBy: .newlines)

            // 余計なデータを削除
            groupedAttributesOfAlbums.removeFirst() // 先頭行のラベル
            if groupedAttributesOfAlbums.last == "" { // 末尾の空要素（csv末尾に改行のみあれば）
                groupedAttributesOfAlbums.removeLast()
            }

            // 旧データを削除
            let oldAlbums = fetchAlbums(with: nil)
            oldAlbums.forEach {delete(album: $0)}

            for groupedAttributesOfAlbum in groupedAttributesOfAlbums {
                let attributesOfAlbum = groupedAttributesOfAlbum.components(separatedBy: ",")
                let album = newAlbum()

                album.index = Int16(attributesOfAlbum[0])!
                album.title = attributesOfAlbum[1]
            }

            save()
        } catch let error as NSError {
            print("Failed to load csv: \(error).")
            return
        }
    }

    static func newAlbum() -> Album {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            abort()
        }

        let managedContext = appDelegate.persistentContainer.viewContext
        let entity = NSEntityDescription.entity(forEntityName: "Album", in: managedContext)!
        let album = Album(entity: entity, insertInto: managedContext)

        return album
    }

    static func fetchAlbums(with predicate: NSPredicate?) -> [Album] {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            abort()
        }

        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Album")
        fetchRequest.predicate = predicate
        fetchRequest.sortDescriptors = [
            NSSortDescriptor(key: "index", ascending: true)
        ]
        fetchRequest.includesSubentities = false

        do {
            let albums = try managedContext.fetch(fetchRequest) as! [Album]
            return albums
        } catch let error as NSError {
            fatalError("Could not fetch albums. \(error), \(error.userInfo)")
        }
    }

    static func save() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            abort()
        }

        appDelegate.saveContext()
    }

    static func delete(album: Album) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            abort()
        }

        let managedContext = appDelegate.persistentContainer.viewContext
        managedContext.delete(album)
    }
}
```

## 補足：省略したトラックの扱い

だいたいアルバムの処理と同じだが、特定のアルバムとリレーションをもたせた上で作成したいので、

1. CSVファイルにはアルバムのindexを属性として含めておき、
1. 上記`let album = newAlbum()`部分に該当するところより前で`let albums = fetchAlbums(with: nil)`として読み込んだアルバムデータの配列を持っておき、
1. `let track = newTrack(into: albums[Int(attributesOfTrack[ここはリレーションをもたせたいアルバムのindexを格納している要素番号])!])`で狙ったアルバムのトラックとしてデータを作成する
1. あとは属性を代入
