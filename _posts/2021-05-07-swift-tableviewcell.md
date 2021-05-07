---
title: "Table View Cell上のImageをタップせずに編集したい（Xcode12.4、Swift 5.3.2）"
header:
  overlay_image: /assets/images/pc-freephoto.jpg
  overlay_filter: 0.5
excerpt: "色々と試したので、忘れないうちにまとめておく。"
categories:
  - System
  - Programming
tags:
  - Swift
  - Xcode
  - Table View Cell
---

基本的なファイル構成や定義は、[TableViewCellにボタン付けていろいろやる - Qiita](https://qiita.com/mzuk/items/0efc41460631c7c98c3c)にならっている。これを見る前にまずQiita記事を読もう……記事が消滅したときのために（あと忘れたときに記事まで見返すのは面倒）、必要最低限の定義を説明しておく。

- `class MyCustomCell: UITableViewCell {...}`として、セルに使うクラスを便利なものにしておく。このクラスに`@IBOutlet`でStoryboardに配置したImageとかを接続しておけば、`cell.cellImage = `みたいにアクセスしやすくなる。
- Table View CellのIdentifierは「MyCustomCell」

## やりたいこと

`cell.cellImage.isHidden = true/false`を任意のタイミングで切り替えたい。セルをタップしているいないに限らず。

## タップする場合

一応書いておく。

```swift
class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var tableView: UITableView!

    // 省略

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as! MyCustomCell
        // cellに対する処理をここに書く
}
```

## タップしない場合

### Table Viewの再描画

今の本命。下の例ではViewControllerクラスファイルが一番きれいになるので。Delegate method（`func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath)`）内部が増えるのは気にしない。

```swift
class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    // 省略

    // セル上の何かを変更したいタイミングで
    tableView.reloadData()

    // 別ファイルやクラスで実行したければ、たとえばstatic var presentTableView: UITableViewを定義しておいて
    anotherClass.presentTableView = tableView

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MyCustomCell", for: indexPath) as! MyCustomCell

        // Cellの初期設定（MyCustomCellクラスで定義したメソッド）
        cell.setCell(myCustomDatas[indexPath.row])

        // indexRow: Int = 何か数字
        // 適当にif条件をつけてセルをアップデートする・しない
        // updateCellはMyCustomCellクラスで定義したメソッド
        if indexPath.row == indexRow {
            cell.updateCell(update: true)
        } else {
            cell.updateCell(update: false)
        }

        return cell
    }
}
```

### ボタン経由

```swift
// 適当にStoryboardでボタンを配置してファイルと接続
@IBAction func testButton(_ sender: UIButton) {
    let cell = sender.superview?.superview as! MyCustomCell
    // cellに対する処理をここに書く

    // おまけ：rowを取得する
    let row = tableView.indexPath(for: cell)?.row
}
```

### IndexPath経由

```swift
// indexRow: Int = 何か数字
// indexColumn: Int = Table View Cellの列数（たいていゼロ）
let cell = tableView.cellForRow(at: [indexColumn, indexRow]) as! MyCustomCell
// cellに対する処理をここに書く
```

## 参考

今回、とくに参考としたのは星マークをつけたもの。それ以外は使えるかもって思ったけど本命ではない、けど念の為資料として残しておく。

<br>[UITableViewにUIButtonを追加する - Qiita](https://qiita.com/eito_2/items/3af91336fea43f40b4d2)
<br>[【Swift】TableViewにお気に入りボタンを実装する方法 \| yamagablog](https://ymgsapo.com/2020/06/25/swift-how-to-make-favorite-star/)
<br>★[TableViewCellにボタン付けていろいろやる - Qiita](https://qiita.com/mzuk/items/0efc41460631c7c98c3c)
<br>[Xcode - UITableViewCellの中のボタンの処理｜teratail](https://teratail.com/questions/58402)
<br>[ios - Insets to UIImageView? - Stack Overflow](https://stackoverflow.com/questions/32304349/insets-to-uiimageview)：UIImage.withAlignmentRectInsets
<br>★[セルの選択で対応する曲を再生 - 開発メモ](http://seeku.hateblo.jp/entry/2015/06/26/072712)
