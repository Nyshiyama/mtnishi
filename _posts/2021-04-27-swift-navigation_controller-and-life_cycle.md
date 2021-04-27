---
title: "Navigation Controllerありのライフサイクル（Xcode12.4、Swift 5.3.2）"
header:
  overlay_image: /assets/images/pc-freephoto.jpg
  overlay_filter: 0.5
excerpt: "viewDidLoad()やらなんやら混乱したので、一度まとめておく。"
categories:
  - System
  - Programming
tags:
  - Swift
  - Xcode
  - NavigationController
  - LifeCycle
---

## テストケースの実装内容

テストケースは以下のように、ParentとChildをNavigation Controllerでつなげたシンプル構成。

![alt]({{ "/assets/images/navigationcontrollerandlifecycleview.png" | relative_url }})

先にコードを載せておく。なお、ChildViewControllerは下記ParentをChildに変更したものとほぼ変わらないので省略する。各メソッドが具体的にどういったものなのかは、末尾に参考記事を載せているのでそれらを参照されたし。

```swift
import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        print("Parent: viewDidLoad")
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        print("Parent: viewWillAppear")
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        print("Parent: viewDidAppear")
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        print("Parent: viewWillDisappear")
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        print("Parent: viewDidDisappear")
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        print("Parent: viewDidLayoutSubviews")
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        print("Parent: viewWillLayoutSubviews")
    }

    @IBAction func goChildButtonTapped(_ sender: Any) {
        performSegue(withIdentifier: "goChild", sender: nil)
    }
}
```

## テスト

![alt]({{ "/assets/images/navigationcontrollerandlifecycle.gif" | relative_url }})

動画のように画面遷移したとき、

1. Simulator起動（Parentを表示）

   Parent: viewDidLoad<br>
   Parent: viewWillAppear<br>
   Parent: viewWillLayoutSubviews<br>
   Parent: viewDidLayoutSubviews<br>
   Parent: viewWillLayoutSubviews<br>
   Parent: viewDidLayoutSubviews<br>
   Parent: viewDidAppear<br>

2. Childへ移動

   Child: viewDidLoad<br>
   Parent: viewWillDisappear<br>
   Child: viewWillAppear<br>
   Child: viewWillLayoutSubviews<br>
   Child: viewDidLayoutSubviews<br>
   Parent: viewDidDisappear<br>
   Child: viewDidAppear<br>

3. Parentに戻る

   Child: viewWillDisappear<br>
   Parent: viewWillAppear<br>
   Parent: viewWillLayoutSubviews<br>
   Parent: viewDidLayoutSubviews<br>
   Child: viewDidDisappear<br>
   Parent: viewDidAppear<br>

4. Childへ移動（2と同じ）

   Child: viewDidLoad<br>
   Parent: viewWillDisappear<br>
   Child: viewWillAppear<br>
   Child: viewWillLayoutSubviews<br>
   Child: viewDidLayoutSubviews<br>
   Parent: viewDidDisappear<br>
   Child: viewDidAppear<br>

5. Parentに戻るスワイプを途中で戻す

   Child: viewWillDisappear<br>
   Parent: viewWillAppear<br>
   Child: viewWillAppear<br>
   Child: viewDidAppear<br>

## 知見の利用

たとえば、スワイプキャンセル（5番）では実行してほしくないが、完全にParentへ戻ったとき（3番）は実行してほしい場合、3番から5番のうち被っているものを除いて（あと`viewWillLayoutSubviews`はレイアウト系ライフサイクルメソッド（参考：[UIViewControllerのライフサイクル - Qiita](https://qiita.com/motokiee/items/0ca628b4cc74c8c5599d)）なので省略）

Child: viewDidDisappear<br>
Parent: viewDidAppear

のどちらかということに、とりあえずはなる。さらにここからChildへ移動する場合（4番）は実行したくない場合、

Child: viewDidDisappear

だけが生き残る。さーらーに、Parentへ戻ったとき（3番）に上記を実行したあとで何かを実行したい場合は、3番から`Child: viewDidDisappear`よりあとのメソッドを探して

Parent: viewDidAppear

に白羽の矢が立つ。

実際は、上記メソッドと何らかのブーリアンを組み合わせてうまいことやるのかしら。そのまま`viewDidDisappear`で`UITableView.reloadData()`とかすると、一度画面が写りきってから更新されるので見目麗し……くない。

## まとめ

とりあえず現状の問題はこの知見をもとに解決できた。場当たり的だが、動けばいいんだよ。

スマホに入れているアプリを見ても、一度画面が写ってから更新されるような挙動をしているものなどない。どうやって実装しているのだろう。と考えだしたらGitHubの旅に出たほうがいいのか。まあそのうち気が向いたら笑

ここでは基本的なメソッドに限定したが、各挙動に対してトグル変化するブーリアンもいるので（参考：[[開発者向け] UINavigationController と生きていく: ヒコザレポート](http://blog.hikware.com/article/177622706.html)）、これらも考え出すとグロいことになってくる。

## 参考

- [[開発者向け] UINavigationController と生きていく: ヒコザレポート](http://blog.hikware.com/article/177622706.html)
- [【Swift】UIViewController ライフサイクル 簡易説明書 \| ポケットリファレンス サンプル付き](https://blog.77jp.net/swift-uiviewcontroller-life-cycle)
- [UIViewControllerのライフサイクル - Qiita](https://qiita.com/motokiee/items/0ca628b4cc74c8c5599d)
