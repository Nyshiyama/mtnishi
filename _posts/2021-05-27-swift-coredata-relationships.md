---
title: "【Swift】CoreDataのリレーションを操作（Xcode12.4、Swift 5.3.2）"
header:
  overlay_image: /assets/images/linux-freephoto.jpg
  overlay_filter: 0.5
excerpt: "CoreDataを使って、音楽アプリのアルバムとトラックをそれぞれ`Album`、`Track`エンティティとして管理しているが、トラックを現在のアルバムから別のアルバムに移動させたくなった。"
categories:
  - System
  - Programming
tags:
  - Swift
  - CoreData
  - Relationships
---

![alt]({{ "/assets/images/xcode-xcdatamodeld-album-tracks.png" | relative_url }})
<figcaption>こんな感じで、Album1つに対してTrackが複数つながったRelationshipをもっている</figcaption>

## 調査

### removeFromEntity()とdelete()の違い

なんがねぇがと調べていたが、Album+CoreDataProperties.swiftファイル（エンティティを作ったら自動生成される）に

```swift
@objc(removeTracksObject:)
    @NSManaged public func removeFromTracks(_ value: Track)
```

というメソッドが登録されていた。remove？じゃあ以下のような`delete()`との違いは？今までCoreDataからデータを削除するのに使っていたのだが……

参考：{% capture target_url %}{{ site.baseurl }}{% post_url 2021-04-22-swift-coredata_and_tableview %}{% endcapture %}
{% for post in site.posts %}{% assign candidate_url = post.url | relative_url %}{% if candidate_url == target_url %}
[{{ post.title }}（{{ post.date | date: "%B %-d, %Y" }}）]({{ target_url }}){% break %}{% endif %}{% endfor %}

```swift
static func delete(track: Track) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            abort()
        }

        let managedContext = appDelegate.persistentContainer.viewContext
        managedContext.delete(track) // delete()を呼んだ後もsaveContext()されるまでは確定されない
    }
```

[swift - CoreData removeFrom vs delete - Stack Overflow](https://stackoverflow.com/questions/58920544/coredata-removefrom-vs-delete)にあるように

- `removeFromEntity()`はリレーションのみ削除
- `delete()`はデータ自体を削除

### 実装の雰囲気

したがって、1つの`album: Album`に対してリレーションをもっている`tracks: [Track]`に対して、`tracks[i]`のリレーションを変更する場合、移動先のアルバムを`targetAlbum: Album`として

```swift
album.removeFromTracks(tracks[i]) // 現在のAlbumとrelationshipを削除
tracks[i].index = Int16(targetAlbum.count) // （CoreData上は並び順が保存されないのでAttributeとしてindexを加えている場合、`tracks[i].index`を変更する。この場合は移動先末尾に加えられることになる。）
targetAlbum.addToTracks(tracks[i]) // 移動先のAlbumに加える
tracks.remove(at: i) // albumもちのtracksからは削除

// 移動したtracks[i]より後ろの要素分のみ、CoreDataのindexを更新する
let filteredTracks = tracks.lazy.filter({ $0.index > Int16(i) })
for (index, filteredTracks) in zip(filteredTracks.indices, filteredTracks) { // filteredTracks.enumerated()ではindexが必ず0から始まってしまうのでzip()を使う
    filteredTracks.index = Int16(index)
}
```

細かくコメントを書いたのでとくに解説はなし。

## まとめ

ググルの適当だったからか、直接リレーションを操作しているような記事には行き着かなかった。なので自分の思いつき。まあ無難な実装ではないか？
