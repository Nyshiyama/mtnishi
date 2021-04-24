---
title: "「this class is not key value coding-compliant for the key hogehoge.」エラーの解決（Xcode12.4、Swift 5.3.2）"
header:
  overlay_image: /assets/images/pc-freephoto.jpg
  overlay_filter: 0.5
excerpt: "昨日の夜に発生して一晩寝かせたらあら不思議。30分くらいで解決できた。"
categories:
  - System
  - Programming
tags:
  - Swift
  - Xcode
  - Error
---

## 解決方法

1. hogehogeとViewの接続を解除してRunできる
2. エラーメッセージに`Unknown class Fugafuga in Interface Builder file.`が出る
3. hogehogeの接続を定義していたView ControllerのCustom Class、のModuleがNoneなのをProject名（入力候補に出てくるもの）にする

## 試してガッテン

ひとまずエラーメッセージでググると

- [swift初心者:「this class is not key value coding-compliant for the key」の対処方法 - Qiita](https://qiita.com/Atsushi_/items/f7930dd00a2c2ea464cd)
- [Xcode - this class is not key value coding-compliant for the key.｜teratail](https://teratail.com/questions/245328)

問題の箇所は割とすぐにわかった。Table Viewに接続している`@IBOutlet weak var albumsTableView: UITableView!`が何か悪い。そもそもエラーメッセージに「this class is not key value coding-compliant for the key albumsTableView」って書いていたし。しかしここから昨日は進まなかった。で、今日。

- 見た目接続しているが、いったん接続を解除して再接続してもエラー
- 既存のTable Viewを削除して新しいTable Viewに接続してもエラー
- ⇧⌘KでBuild Folder削除、Xcode再起動も変わらず
- 接続を解除した状態なら⌘RでRunできる

とくに最後、接続解除した状態なら画面が描画できたが、新しいデバッグメッセージを発見。

```swift
Unknown class AlbumsViewController in Interface Builder file.
```

さっそくググってみると

→[[Xcode7] 「Unknown class xxxxx in Interface Builder file.」が出る - Qiita](https://qiita.com/eidera/items/f6fd3b1088d7bd6fe523)

ほう、たしかにNoneではないか。

![alt]({{ "/assets/images/customclassmodulenone.jpg" | relative_url }})

そもそもエラーが出るようになった原因は、怪しいものとして「別のView ControllerからTable Viewをコピーしてもってきた」か「問題となっているView ControllerのCustom Classのファイル名とクラス名を変更して一応確認できる限りは他の関連箇所も名前を変更した」だろうなとは思っていた。原因は後者にあったわけだ。

記事にしたがって対処した。

![alt]({{ "/assets/images/customclassmodulefilled.jpg" | relative_url }})

すると`@IBOutlet weak var albumsTableView: UITableView!`にfuncをつけるfixが提案されてま？となったが、⇧⌘KでBuild Folderを削除してBuildし直したら勝手に消えた。そのままRunでエラーもなし！！

## おまけ

`extension class Hogehoge {}`のみ書いたファイルで、変数を⌘+クリックするとなぜかSwiftUI用の編集メニューが現れる。`import SwiftUI`はしていない。これがエラーの原因かと一瞬疑ったぞw
