---
title: "ブログ用の写真用意について"
header:
  overlay_image: /assets/images/qiitaoutput-freephoto.jpg
  overlay_filter: 0.5
excerpt: "とりたてて新しい情報というわけでもないが、ブログに写真を載せる際の手順についてまとめておく。決してブログネタが他にないわけではない。"
categories:
  - System
  - Dev-blog
tags:
  - Googleフォト
  - 写真
---

とくに圧縮は大事。サイズが半分以下になったりする。

## 基本

1. 写真オリジナルデータをダウンロード

   Googleフォトからの場合、昔は写真を1／4回転させてダウンロードしないとiPhoneからの写真はHEIC形式だったが、気づいたら別に回転しなくてよくなっていた。という意味ではポジディブだが、無制限ではなくなるのがネガティブ。

   [Googleフォトに保存されたHEIC画像をJPGに変換する方法 \| iSchool合同会社](https://ischool.co.jp/2019-02-04/)←昔の話

   [【悲報】iOS版Googleフォト、HEIF形式をJPGに変換し始めた…！ \│ きよさんが果てるまで。](https://kiyosan.life/2019/12/31/google-photo/)←最新に近い情報。自動でJPGになるらしい。

2. （かつては回転させたデータをもとに戻していたがこの手間はなくなった）

3. 画像サイズを横700pxに揃える

   700で十分。大量にあると手作業は手間なのでウェブアプリを使って一気に縮小する。iPhoneで撮った写真は基本的に大きいので縮小方向だが、フリーフォトとかだと700より小さい場合もあるのでここは区別したほうが良いか

   [Bulk Resize Photos (日本語) - 画像サイズ変更](https://bulkresizephotos.com/ja)：画質はデフォルトだと80%になっているが100%にする

4. 情報の圧縮。Windowsの場合はウェブアプリ、Macの場合はローカルアプリがあるけどウェブアプリでもおk。

   [ImageOptim online](https://imageoptim.com/online)：Qualityは基本Medium

   [ImageOptim — better Save for Web](https://imageoptim.com/mac)：ローカルアプリはMacしかない

   2021/09/24追記：
   Thank you for your information!

   問い合わせで、WEBSITEPLANETもいいよ、と教えていただいた。[ImageOptim online](https://imageoptim.com/online)とやることは似ているが、圧縮率が若干高いかも。

   [WEBSITEPLANET](https://www.websiteplanet.com/ja/webtools/imagecompressor/)

   ![websiteplanet test]({{ "/assets/images/websiteplanet-test.png" | relative_url }})
   <figcaption>たしかImageOptimで圧縮していたけど、websiteplanetに入れたら少しだけ追加で圧縮された</figcaption>

## ヘッダーイメージとか

大きい画像の場合は、サイズを表示される枠に合わせてできるだけ小さくする。あと、圧縮する際はMediumかHighのように、オリジナル近いクオリティを維持するように気をつける。うっかり粗くしてしまうとけっこう悲しい見た目になる笑
