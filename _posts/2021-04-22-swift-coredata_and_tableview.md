---
title: "CoreDataをTableViewで扱う（リストの並び替え、削除との連携について）（Xcode12.4、Swift 5.3.2）"
header:
  overlay_image: /assets/images/pc-freephoto.jpg
  overlay_filter: 0.5
excerpt: "用語や考え方が合ってんのかしらんけど、配列とMOCは区別をつけておかないと混乱する。"
categories:
  - System
  - Programming
tags:
  - Swift
  - Xcode
  - CoreData
  - TableView
---

先に言っておくと`CoreDataModel`は自分で定義したクラスのこと。記事中に部分的なソースコードを、記事末尾に現時点の`class CoreDataModel`ソースコードを載せておく。GitHub？まあ慌てるな。

## 配列操作とMOC操作を区別する

```swift
// Trackエンティティを定義していたとして、[Track]のインスタンスを作成
var tracks = CoreDataModel.fetchTracks(with: nil)

// tracksの処理としてindexPath.row番目の要素を削除
CoreDataModel.delete(track: tracks[indexPath.row])
tracks.remove(at: indexPath.row)
```

上記`tracks`の処理を2種類書いたが、これらは別物。上はMOC処理で、下は単なる配列処理。どちらも実行するか、間にもう一度fetch処理として`tracks = CoreDataModel.fetchTracks(with: nil)`を入れないと、整合性がとれなくなる。

### [Track]各要素のプロパティは？

「`tracks`のプロパティを編集する＝MOC処理」である。配列操作の`remove()`はなぜ区別されるのだろう。

例：`tracks.lazy.filter { $0.index > Int16(indexPath.row) }.forEach { $0.index -= 1 }`

要は、`tracks.index`というAttributeが`indexPath.row`より大きい要素に対してのみ`forEach`で操作「`各要素.index`をマイナス1する」を実行する。これでMOC上は`index`が変更したことになっている。これは昨日書いたように`CoreDataModel.save()`を実行するまでDBへ保存されないことに注意する。

## リストの並び替え

TableView上で並び替えたら、MOC上のデータも並び替わってほしい。

### 並び順を保持するindexをEntityのAttributeに追加

先出ししているが、DBは配列ではないので、本来は並び順をもたない。そこで並び順を保持する`index`をEntityのAttributeに追加する。考え方は[swift - CoreDataで並び順を保存したい - スタック・オーバーフロー](https://ja.stackoverflow.com/questions/33750/coredata%E3%81%A7%E4%B8%A6%E3%81%B3%E9%A0%86%E3%82%92%E4%BF%9D%E5%AD%98%E3%81%97%E3%81%9F%E3%81%84)に倣った。

![alt]({{ "/assets/images/xcode-entity-attribute-index.png" | relative_url }})

で、「Swift TableView 並び替え」でググったら出てくる`func tableView`を使って、リスト上に表示させている配列としての`tracks: [Track]`操作と、並び替わった配列の順番を基に`index`を再定義する。

```swift
    // 「Swift TableView 並び替え」でググったら出てくるfunc tableView
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let sourceIndexPathRow = sourceIndexPath.row
        let destinationIndexPathRow = destinationIndexPath.row
        let tmp = tracks[sourceIndexPathRow]

        // まずはtracks配列を操作
        tracks.remove(at: sourceIndexPathRow)
        tracks.insert(tmp, at: destinationIndexPathRow)
        tracksTableView.reloadData()

        // MOC側のindexを更新する
        var iFirst = sourceIndexPathRow
        var iEnd = destinationIndexPathRow

        if iFirst > iEnd {
            iFirst = destinationIndexPathRow
            iEnd = sourceIndexPathRow
        }

        for i in iFirst...iEnd {
            tracks[i].index = Int16(i)
        }
    }
```

`index`の更新があまりかっこよくないというか、実直な実装というか、もっとスマートに書けないものか……。ちなみに先述した配列操作とMOC操作の区別はここにも（見た目は分かりづらいが）生き残っており、あくまでこの時点では並び替わった`tracks`の順番に沿って`index`を再定義しただけで、MOC上の順番はまだ並び替わっていない。

そこで、`[Track]`をfetchする前に、いつも`index`昇順にソートさせればよい。別にここは`index`を再定義した直後に並び替え&Fetchをしてもよいが、実装的には慌てるこっちゃなかったのでそうしなかった。実装もスマートになるし。`CoreDataModel.fetchTracks()`の内部で、以下のように`sortDescriptors`を定義しておけば良い。

```swift
        fetchRequest.sortDescriptors = [
            NSSortDescriptor(key: "index", ascending: true)
        ]
```

## リストの削除

並び替えと似たノリになる。

```swift
// 「Swift TableView 削除」でググったら出てくるfunc tableView
func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // tracks.remove()は配列処理なので先にMOC処理が必要
            CoreDataModel.delete(track: tracks[indexPath.row])
            tracks.remove(at: indexPath.row)
            tracksTableView.reloadData()

            // MOCのindexを更新する
            tracks.lazy.filter { $0.index > Int16(indexPath.row) }.forEach { $0.index -= 1 }
        }
    }
```

”先に”MOC処理が必要である。あくまで上記実装の場合であるが、順番を逆にすると

1. `tracks[indexPath.row]`が削除される
2. `CoreDataModel.delete(track: tracks[indexPath.row])` の引数に入るものは1で要素が1つずれた`tracks`に対して調べられる
3. TableView上の削除操作と、表示しているデータで削除されるものが一致しない

`index`の更新は先述の通り、`tracks.index`というAttributeが`indexPath.row`より大きい要素に対してのみ`forEach`で操作「`各要素.index`をマイナス1する」を実行する。削除した要素より小さい要素番号に対しては`index`を更新する意味がない。

## MOC処理を確定するタイミングを操作する

まだ製作途中なので奇妙なUIだが、たとえばNavigation Controllerを使って画面を遷移させているとして、画面下の「確定」ボタンが押される前に左上のBackボタンやスワイプで親ビューに戻った場合はEdit等で行ったMOC処理結果を破棄したいとする。「確定」ボタンが押されるとMOC処理結果が確定される、つまりDBに処理結果を送信してもらう。また、それ以外の画面遷移ではMOC処理結果を保持しておいてほしい。

![alt]({{ "/assets/images/xcode-app-album-view.png" | relative_url }}){:width="300px"}

えんやこらと悩んだが、そのかいあって？実装はなかなかスマートにできたんじゃないだろうか。

上記画面が`AlbumSettingViewController`をCustom Classにしているとして、まず確定ボタンには`CoreDataModel.save()`でMOC処理結果をDBに送るのと、確定することを明示するブーリアン`isSavingTheEditedAlbum`を`true`にする。

```swift
class AlbumSettingViewController: UIViewController {
    var isSavingTheEditedAlbum = false

    // 確定ボタン
    @IBAction func saveAlbumButton(_ sender: Any) {
        CoreDataModel.save() // 編集内容を確定する
        isSavingTheEditedAlbum = true

        // これでNavigation Controllerを使って親ビューから遷移していた画面をもどせる
        _ = navigationController?.popViewController(animated: true)
    }
}
```

親ビューに戻ることを検知するDelegate methodとして、[NavigationBarの戻るボタンをハンドリングしたい - Qiita](https://qiita.com/fuwamaki/items/a5d8594086d2f813e72f)を参考に以下を定義する。

```swift
extension AlbumSettingViewController: UINavigationControllerDelegate {
    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        // 親ビューに遷移する際、アルバム内容確定ボタン経由でなければCoreDataの編集内容を保存せずに破棄する
        if viewController is ViewController && !isSavingTheEditedAlbum {
            CoreDataModel.rollback()
        }
    }
}
```

`isSavingTheEditedAlbum`でない場合、`CoreDataModel.rollback()`で変更を破棄する。`CoreDataModel.delete()`とか全部やったことが消えちゃう。

## まとめ？

以上、現時点の独学理解と実装内容をもとに現状をまとめた。下は`class CoreDataModel`のソースコードである。

## class CoreDataModelとしてメソッドを作成してまとめているが

きちゃないのできれいにするコツが知りたい。

```swift
import UIKit
import CoreData

class CoreDataModel {
    static func newTrack() -> Track {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { // TODO: いちいちsaveContext()でもう一度guardを書かずに済まないか？ -
            abort() // TODO: abort()でよい？ -
        }

        let managedContext = appDelegate.persistentContainer.viewContext
        let entity = NSEntityDescription.entity(forEntityName: "Track", in: managedContext)!
        let track = Track(entity: entity, insertInto: managedContext)

        return track
    }

    static func fetchTracks(with predicate: NSPredicate?) -> [Track] {
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

    static func save() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            abort()
        }

        appDelegate.saveContext()
    }

    static func rollback() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            abort()
        }

        let managedContext = appDelegate.persistentContainer.viewContext
        managedContext.rollback()
    }

    static func delete(track: Track) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            abort()
        }

        let managedContext = appDelegate.persistentContainer.viewContext
        managedContext.delete(track) // delete()を呼んだ後もsaveContext()されるまでは確定されない
    }
}
```
