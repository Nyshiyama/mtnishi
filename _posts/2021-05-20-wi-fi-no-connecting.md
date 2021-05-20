---
title: "Wi-Fi◯ック"
header:
  overlay_image: /assets/images/worrynayami-freephoto.jpg
  overlay_filter: 0.5
excerpt: "◯に入るのは「ハ」ではない。「ファ」である。Wi-Fiがおかしいので交換したのにまったく同じ症状で繋がらなくなる。Wi-Fiは「住友電工　BFW6011-BAL」、中継機として「BUFFALO　WEX-733D」。"
categories:
  - System
  - Applications
tags:
  - Wi-Fi
  - Buffalo
  - Modem
---

[BFW6011-BAL取説.pdf](http://gozura101.chukai.ne.jp/photolib/Cco00417/26713.pdf)

[WEX-733D : Wi-Fi中継機 : AirStation \| バッファロー](https://www.buffalo.jp/product/detail/wex-733d.html)

## 症状

gのみ繋がらなくなる。しかも質の悪いことに、扇マークは付いている。中継機もG経由で基本的に利用しているので、実質モデム本体のaのみが生き残ることになる。

![alt]({{ "/assets/images/wi-fi-iphone-a.jpg" | relative_url }})
<figcaption>aはつながる。gも扇マークが付いている。</figcaption>
<p></p>

![alt]({{ "/assets/images/wi-fi-iphone-unable-to-join-the-network.jpg" | relative_url }})
<figcaption>よろしい、ならば戦争だ。</figcaption>
<p></p>

![alt]({{ "/assets/images/wi-fi-modem.jpg" | relative_url }})
<figcaption>ちなみに本体は問題なくランプが点灯している。2.4GHz部分が点滅とかしていたらおかしい可能性はあるのだが。</figcaption>
<p></p>

## 対策、解決方法、はない

再☆起☆動~~デュエルモンスターズ~~

とりあえず対症療法としてはこれしかない。CHの変更とか、そのへんでどうにかなるようにも思えんが。下の参考記事でも無駄だったらしいし。

結局、根本的な治療はできていない。g/a片方が扇マークありにもかかわらずつながらなくなるってことなので、「無線LANルーター 2.4GHZ つながらない 5GHZ つながる」でググってみたところ、[価格.com - 『2.4ghzは電波があっても繋がらず5ghzは常に繋がる』 NEC Aterm WG2600HP2 PA-WG2600HP2 のクチコミ掲示板](https://bbs.kakaku.com/bbs/K0000913523/SortID=20794322/#20794322)というスレッドを見つけた。

記事では結局交換していたので、こちらも交換してもらった。それが土曜日。検査は交換で住電側が持って帰ってから調べるそうなので、故障していたって結果だったらいいな〜と思っていたら、今日また同じ症状……。と、いうことは、家の環境に問題があるのか？

わからんので明日もう一度連絡して専門家的に思い当たる原因がないか聞いてみよう。
