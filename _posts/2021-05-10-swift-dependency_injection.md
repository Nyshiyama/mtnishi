---
title: "Swiftネタ：DIの基本"
header:
  overlay_image: /assets/images/linux-freephoto.jpg
  overlay_filter: 0.5
excerpt: "本当に秒でわかる基本だけ。本格的な勉強はアプリ開発が一段落ついてリファクタリングがんばることになってからだろうな。"
categories:
  - System
  - Programming
tags:
  - Swift
---

## 秒でわかるDIの基本

>DIとは、Dependency Injectionの略で、日本語で『依存性の注入』ということらしいです。

1. Protocolでfuncを固定させる
2. Protocolを守るstruct 1, 2, …を定義
3. それらを本命（View Controllerとか）と中継するためのclassを定義
4. このclassの中で、initを使ってProtocolを守るプロパティを定義しておく。methodはfunc プロトコルメソッド() { プロパティ.プロトコルメソッド() }としておけば同名methodが後で使える
5. 本命中でstruct 1, 2 …を好きに選んで、引数（classのプロパティ）としてclassのインスタンスを生成すれば、structが実際のところどう定義されているか気にせず、classのインスタンスメソッドが使える

何を言っているのかわからない？以下の参考資料を見て笑

- [[Swift] DIって何？ 実践編 - Qiita](https://qiita.com/eKushida/items/78a58559aedd851d105c)
- [iOS - Swiftで似たようなViewControllerを複数実装する場合のベストプラクティスについて｜teratail](https://teratail.com/questions/106824)
