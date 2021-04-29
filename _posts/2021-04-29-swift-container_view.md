---
title: "Container Viewを後付け（Xcode12.4、Swift 5.3.2）"
header:
  overlay_image: /assets/images/pc-freephoto.jpg
  overlay_filter: 0.5
excerpt: "View Controller+Navigation Controllerで色々作った後、全画面共通でFront（画面一番手前）にViewを表示したくなった場合（iPhoneのミュージックアプリでタイトルと再生ボタンが下の方に表示されている感じ）"
categories:
  - System
  - Programming
tags:
  - Swift
  - Xcode
  - Container View
  - View Controller
---

![alt]({{ "/assets/images/containerview_viewcontroller-1.png" | relative_url }})

<figcaption>もとの状態。右に遷移先のView Controllerが複数ある</figcaption>
<p></p>

最初は共通View部分をContainer Viewで作らないといけないと思っていたが、調べた感じ、共通ViewをもつView Controllerを作成してそこにContainer Viewを配置し、これまでView Controllerで作成してきたすべてをそのContainer Viewに入れたらよいとわかった。

![alt]({{ "/assets/images/containerview_viewcontroller-2.png" | relative_url }})

<figcaption>左が新しく作ったView Controllerと、全画面共通で表示させるView。右がContainer ViewのView Controller</figcaption>
<p></p>

Container View Controllerにこれまでの作業を全部移植しないといけないのか、コピペできるかな。あ、できてもAuto Layout全部つけ直さないと。グロ……

![alt]({{ "/assets/images/containerview_viewcontroller-3.png" | relative_url }})

<figcaption>試しにコピペで右側のContainer View用領域に入れてみたが、Auto Layoutがなくなっている</figcaption>
<p></p>

となっていたが、コピペなんていらない！！

1. Container View Controllerを削除
2. 共通ViewをもつView Controller上にUIViewとだけ表示されるようになる
3. これをControlを押しながらマウスドラッグで既存のNavigation ControllerにEmbed接続
4. 既存のView ControllerがすべてContainer View仕様に自動で変更される
5. 共通ViewをもつView ControllerにStoryboard Entry Pointを設定（Attributes Inspector > View Controller > Is Initial View Controller にチェック）

以上！これだけ！！楽！！！

![alt]({{ "/assets/images/containerview_viewcontroller-4.png" | relative_url }})

<figcaption>Zみたいにして接続されているところが新しく付けたもの。右側のView Controllerは自動的に長方形領域に変更された</figcaption>
<p></p>
