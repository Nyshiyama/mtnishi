---
title: "NavigationBarItemの表示・非表示を制御（Xcode12.4、Swift 5.3.2）"
header:
  overlay_image: /assets/images/pc-freephoto.jpg
  overlay_filter: 0.5
excerpt: "とくに編集モードのときだけCancelボタンをBarに表示させる方法についてまとめる。"
categories:
  - System
  - Programming
tags:
  - Swift
  - Xcode
  - NavigationBarItem
---

こういうの。

![alt]({{ "/assets/images/navigationbaritemcanceltoggle.gif" | relative_url }})

実装してみた順番的には案2が先になるが、結局案1の汎用性が高いので先にそちらを示す。

## 案1：「editingのTrue/Falseに合わせてボタンを描画/nil消去」作戦

```swift
    @IBOutlet weak var albumsTableView: UITableView!
    var cancelBarButtonItem: UIBarButtonItem!

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.rightBarButtonItem = editButtonItem // setEditing()とセット
        cancelBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancelBarButtonTapped(_:))) // editingのときのみ表示
    }

    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)

        albumsTableView.setEditing(editing, animated: animated)

        if editing {
            navigationItem.leftBarButtonItem = cancelBarButtonItem
        } else {
            navigationItem.leftBarButtonItem = nil
        }
    }

    @objc func cancelBarButtonTapped(_ sender: UIBarButtonItem) {
        // ここにキャンセル時のアクションを実装

        setEditing(false, animated: true)
    }
```

### 解説

こうして必要最低限のみ書き出してみると本当に単純なことをしているな。`UIBarButtonItem`の変数`cancelBarButtonItem`を定義して、`viewDidLoad()`内部で初期化しておく。ちなみに`var`定義部で初期化もしてしまうとactionが実行されなくなる。（参考：[Xcode - UIBarButtonItemのactionメソッドが呼ばれないケースがある｜teratail](https://teratail.com/questions/207895)）

`setEditing()`の説明は省略する。まあ`editButtonItem`と組み合わせたらNavigation BarにEdit←→Done切り替え機能ありのボタンが勝手に作られるだけ。引数の`editing: Bool`が、編集状態を表す真偽値であり、切り替わるたびに`setEditing()`が呼ばれる。そこで`if editing {} else {}`文を実装すれば同じタイミングで切り替えられる。

あとは、メソッド名はなんでも良いが（よくねぇ）`@objc`でキャンセルアクションを定義して、最後に`editing = false`となるように`setEditing(false, animated: true)`で実行してやれば、`if`文でボタンが`nil`になる。

この実装の何が便利かって`if`文で一緒に`navigationItem.hidesBackButton = true/false`を実装すれば、編集モードではNavigation Bar左側の「\<Back」ボタンが消えて「Cancel」ボタン、モード解除で入れ替わる、というのが簡単に実装できることである。

ただ、`animated: true`としているのに滑らかに変化しない。TableViewも編集モードになっているがそれがピチュンて元に戻る。とりあえず放置しているが。

## 案2：「無効かつ透明にしたら非表示と一緒」作戦

```swift
    @IBOutlet weak var albumsTableView: UITableView!
    @IBOutlet weak var cancelBarButtonItem: UIBarButtonItem!

    override func viewDidLoad() {
        super.viewDidLoad()
        cancelBarButtonItem.isEnabled = false // editingのときだけ有効にする
        cancelBarButtonItem.tintColor = .clear
    }

    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)

        albumsTableView.setEditing(editing, animated: animated)

        if editing {
            cancelBarButtonItem.isEnabled = true
            cancelBarButtonItem.tintColor = .systemBlue
        } else {
            cancelBarButtonItem.isEnabled = false
            cancelBarButtonItem.tintColor = .clear
        }
    }

    @IBAction func cancelBarButtonTapped(_ sender: Any) {
        // ここにキャンセル時のアクションを実装

        setEditing(false, animated: true)
    }
```

### 解説

作戦名の通りなので、案1の解説を先に読んでもらえればとくにこちらで補足することはない。あ、この場合は先に、Navigation Bar左側にボタンを配置して、`cancelBarButtonItem`と`cancelBarButtonTapped`に接続させておく必要がある。

こちらもがんばれば「\<Back」ボタンとの入れ替えができるのかもしれないが、案1よりシンプルではないだろう。しらんけど。

## 参考資料

- [【Swift/iOS】ナビゲーションバーにボタンを追加する \| カピ通信](https://capibara1969.com/1391/)
- [【Swift】UINavigationControllerの戻るボタンを非表示にする方法 \| Swift Note](https://naoya-ono.com/swift/navigation-back-hidden/)
- [Xcode - UIBarButtonItemのactionメソッドが呼ばれないケースがある｜teratail](https://teratail.com/questions/207895)
- [ios - How do I show/hide a UIBarButtonItem? - Stack Overflow](https://stackoverflow.com/questions/10021748/how-do-i-show-hide-a-uibarbuttonitem)
- [ios - How to hide Bar Button Items when UITableView is in edit mode? (Swift) - Stack Overflow](https://stackoverflow.com/questions/31693008/how-to-hide-bar-button-items-when-uitableview-is-in-edit-mode-swift)
