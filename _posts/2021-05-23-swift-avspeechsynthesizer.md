---
title: "「AVSpeechSynthesizerでシミュレーターを再実行するまで再生できなくなる」エラー（Xcode12.4、Swift 5.3.2）"
header:
  overlay_image: /assets/images/xcodeimage-freephoto.jpg
  overlay_filter: 0.5
excerpt: "これまであまり気にせずアプリ開発を進めてきたが、絶対に放っておけないエラーなのでがんばって対処した。そうはいっても色々調べていくとひとまずの解決方法が見つかったのでそれをパクることになった。iOS7？くらいからってことは最初からか（笑）、既知のバグっぽい。"
categories:
  - System
  - Programming
tags:
  - Swift
  - Xcode
  - AVSpeechSynthesizer
---

## エラー概要

問題のコード抜粋。

```swift

import UIKit
import AVFoundation

public class AVSpeechModel {
    static var synthesizer = AVSpeechSynthesizer()
    static var avSource0 = AVSpeechUtterance.init(string: "")
    static var avSource1 = AVSpeechUtterance.init(string: "")
    static let avSpeechSynthesizerSource = AVSpeechSynthesizerSource() // AVSpeechSynthesizerDelegateをまとめたクラスのインスタンス

    static func play() {

        avSource0 = AVSpeechUtterance(string: ”hogehoge")
        avSource1 = AVSpeechUtterance(string: "fugafuga")

        synthesizer.speak(avSource0)
        synthesizer.speak(avSource1)
    }

    static func stop() {
        if synthesizer.isSpeaking {
            synthesizer.stopSpeaking(at: AVSpeechBoundary.immediate)
        }
    }
}
```

色々と省略しているが、今注目すべきは最後の`synthesizer.speak`2本。こうすると`avSource0`はすぐに再生され始めるが、`avSource1`は`synthesizer`のキューに保存される。`avSource0`の再生が終了すると自動的に`avSource1`の再生が始まる。

それで、ちょうど2つの再生間（`avSource0`の再生が終わった直後）で`synthesizer.stopSpeaking(at: AVSpeechBoundary.immediate)`を実行してからもう一度同じソースで`.speak()`を実行する、つまり`stop()`して`play()`するのだが、こうするとシミュレーターを再実行するまで何も再生されなくなる。

## 解決方法を探る

実際の解決方法はこのあと。

`.stopSpeaking()`が何か悪さしてんのかな？と思うも、

>シンセサイザーを停止すると、それ以降の発話はキャンセルされます。シンセサイザーが一時停止した場合とは異なり、発話は中断したところから再開できません。まだ発話されていない発話は、シンセサイザーのキューから削除されます。
>
>[AVSpeechSynthesizer \| Apple Developer Documentation](https://developer.apple.com/documentation/avfaudio/avspeechsynthesizer)

でキューは削除されるしおすし。

あとでまったく別問題だとわかるのだが、はじめは「AddInstanceForFactory: No factory registered for id？」エラーか「_BeginSpeaking: couldn't begin playback」エラーが原因だと考えていた。両方ともAVFoundationつながり？のエラーで、前者はシミュレーターを実行した直後から、後者は色々と再生を操作していると現れる。今回は結局これらとは関係していなかったので省略（なんならこいつらはまだ取り除けていない笑）。

上記エラーで出てきた対策を色々と試してみるも解決せず、でもやっぱりキューあたりが悪い？公式ドキュメントに

>Attempting to enqueue the same utterance more than once throws an exception.（同じ発話を2回以上エンキューしようとすると、例外が発生します。）
>
>[speak(_:) \| Apple Developer Documentation](https://developer.apple.com/documentation/avfaudio/avspeechsynthesizer/1619686-speak)

例外ってなに。とはいえ、ストップでキューを削除しているつもりがなんだかうまくいっていなくて同じソースを入れるから例外とやらが発生して死ぬのか？と考えた。

で、「synthesizer queue swift」でググる。

[AVSpeechSynthesizer's queue doesn't work - timbroder.com](https://www.timbroder.com/2014/03/avspeechsynthesizers-queue-doesnt-work/)

ほう、同じようなエラーやないか。記事にあったリンク

[ios - An issue with AVSpeechSynthesizer, Any workarounds? - Stack Overflow](https://stackoverflow.com/questions/19672814/an-issue-with-avspeechsynthesizer-any-workarounds)

に先人たちの格闘跡が。キタコレ。

## 解決方法

ストップされるたびにインスタンスを再生成する。Delegateも再接続する必要がある。

```swift
    static func stop() {
        if synthesizer.isSpeaking {
            synthesizer.stopSpeaking(at: AVSpeechBoundary.immediate)
            synthesizer = AVSpeechSynthesizer() // インスタンスを再生成しないと、2つの.speak()間で.stopSpeaking()を実行したときに再生できなくなるバグが生じる
            synthesizer.delegate = avSpeechSynthesizerSource // 再生成したのでデリゲートも再接続
        }
    }
```

Delegateの再接続部分は、ややこしいことをしていなければ`synthesizer.delegate = self`で済む。

なんでこれでいけるかって言われてもよくわかっていないしSwift側のバグが根幹にあるだろうが、[On using AVSpeech... objects, warnings: TTSPlaybackCreate unable to init dynamics · Issue #13 · apraka16/iOSAR · GitHub](https://github.com/apraka16/iOSAR/issues/13)にあるように「performing access to the same synthesizers on several threads simultaneously.（同じシンセサイザーへのアクセスを複数のスレッドで同時に行う）」が原因なのかな？しらんけど。

## 補足

もしかしたら、クラス内に定義で直接インスタンスを生成している（`synthesizer = AVSpeechSynthesizer()`とか）ことが原因で「AddInstanceForFactory: No factory registered for id？」エラーメッセージが出ているのかもしれない。あと「_BeginSpeaking: couldn't begin playback」エラーも出てくるが、ガン無視で再生してくれる笑　なのでこの2つはいったん放置かな。
