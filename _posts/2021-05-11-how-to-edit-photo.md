---
title: "写真の編集について"
header:
  overlay_image: /assets/images/rainwindow-freephoto.jpg
  overlay_filter: 0.5
excerpt: "ホームページで使えるように写真を編集する情報まとめ。自分用な感じなのであまり分かりよく書いていない。"
categories:
  - System
  - Dev-blog
tags:
  - 写真編集
---

とりあえずほしい機能としては

- ななめにトリミングして遠近を修正しつつ被写体をまっすぐにする
- 縁を均一にぼかす
- ポートレート
- 顔のナチュラルメイク修正
- ライトの光を自然に弱める
- 影を消す、または足す。とくに太陽光による自然影。
- 背景を透明にする
- 全体を淡くしたり暗くしたり明るくしたり、色の編集
- 抽出

以下に情報をまとめる。現状、顔はSoda、簡単なポートレートならFocos、簡単な抽出は合成写真 合成スタジオ、細かく調整とか他の作業は人力バンザイGIMP。気になっているのはKrita（お絵かき）、PhotoScape X（GIMP同様の多機能）。

## もはやリンクまとめ

### フリー素材

もはやトリミングでサイズを修正する以外に編集がいらないようなフリー素材は、

[フリー画像の鉄板サイト4選！おしゃれでカッコいいアイキャッチ写真素材はここでOK](https://skuwana.info/free-picture/)

フリー素材はグーグル検索「〇〇　フリー」よりもこれらから探したほうが良い。そりゃ有料サービスのほうが種類も豊富でオシャンティだろうが、素人的にはこれらで十分。

### 全般

[Macの無料・有料おすすめ画像編集ソフト18選【2020年版】 \| テックキャンプ ブログ](https://tech-camp.in/note/technology/95934/)：無料と有料を分けているので見やすい。とりあえずSeashoreを試したが機能が少なかったのですぐGIMPに乗り換え。Kritaも気になるがお絵かきするわけではないからひとまずGIMPでいけるかな。

[【Mac】おすすめ写真編集ソフトはこれしかない【簡単多機能無料】 \| GoGoザウルス](https://retrygogo.com/photoscapex/)：PhotoScape Xも魅力的だな

### 顔の加工

[SODA(ソーダ)アプリの機能・使い方！おすすめフィルターや裏技 \| ライバーラボ](https://media.primeagain.co.jp/soda/)：顔の自然な加工はこれで十分。これでデフォルト設定のまま写真を撮れば楽（ウォーターマークは設定で消せる）

### 影の加工

[GIMP(日本語)使い方 - 修復ブラシを使って不要な部分の消し方](https://createkidslab.com/2018/10/05/gimp-2-10-syufukuburashi/)：余計な影を消したりするのにも使える。人力だが。

X　[Photoshopで簡単にリアルな影を作る方法！人物から物まで応用できる便利なチュートリアル \| ヒーコ \| あたらしい写真の楽しみを発見し、発信する。](https://xico.media/tutorials/shadow-make/)：フォトショでなら影を自動で付けられるのかと思ったら人力だったw

X　[写真に光を加工でプラス。おしゃれな自然光を入れられるカメラアプリ4選 - isuta（イスタ） -私の“好き”にウソをつかない。-](https://isuta.jp/category/iphone/2017/08/551040)：違う、おれがほしいのはそういう影や光ではない。

X　[【Appliv】Apollo: 超リアルな光源の追加](https://app-liv.jp/4872038/)：惜しい。光源ではあるが照明で影をつけるようなレベルではない。

X　[Apowersoftオンライン透かし消去ソフト](https://www.apowersoft.jp/online-watermark-remover)：試したが草結果でなし

「写真 影 消す ai アプリ」「photo delete shadow ai applications」でググったけど、完璧に近いものってまだ開発段階なのね。[無駄な映り込みを消せる神アプリ！　TouchRetouchで写真を簡単加工してみた – hintos](https://hintos.jp/articles/touchretouch_20180814/)はなかなかよかったけど、結局画像の一部をコピーしたスタンプを貼り付けて上書きする場合もあるし。

### 切り抜き（抽出）

[GIMP(日本語)使い方 - 女性の髪の毛や人物を綺麗に切り抜きする方法](https://createkidslab.com/2018/07/14/gimp2-10-2%E3%81%A7%E9%A2%A8%E3%81%AB%E3%81%AA%E3%81%B3%E3%81%8F%E5%A5%B3%E6%80%A7%E3%81%AE%E9%AB%AA%E3%82%92%E7%B6%BA%E9%BA%97%E3%81%AB%E5%88%87%E3%82%8A%E6%8A%9C%E3%81%8F%E6%96%B9%E6%B3%95/)：無料ソフトのGIMPで十分通用する

△　[写真切り抜き無料アプリ5選！ 人物も簡単・綺麗に合成【iPhone/Android】 -Appliv TOPICS](https://mag.app-liv.jp/archive/130928/)：自動でできれば楽なのだが、どれもあと一歩な印象。とくに境界がぼやけるのが気になる。気にならない背景にすればよいがシチュが限定されるし、境界のぼやけを手動で取り除くなら結局やった意味ないし。ちなみに試したのは『合成写真 合成スタジオ』

△　[「2020最新版」簡単に画像や写真の影を消す方法TOP4](https://www.apowersoft.jp/remove-photo-shadow.html)：自動で消去できるのはかなりはっきりした影のみという印象

### ぼかし（ポートレート）

[ポートレートアプリのおすすめ10選｜ぼかし加工ができるカメラアプリとは？ \| Smartlog](https://smartlog.jp/175768)：ついで？にiPhone 8なのでポートレート写真用のアプリを検索、Focosを使ってみる。GIMPでは手動でできる→[背景をぼかしてポートレイト風に画像編集 \| watamoco blog](https://watamoco.work/gimp-portrait/)
