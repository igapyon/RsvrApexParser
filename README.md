# RsvrApexParser

Apex Parser written in Apex language.

Apex言語で記述された Apex パーサの作成を目標とするプロジェクトです。
2022/11/23 現在、Apex 字句解析の一部のみが実装された状態です。

## RsvrApexLexicalParser

- 字句解析について、おおよそ妥当に動作します。
- Salesforce が混雑した状態では `System.LimitException: Apex CPU time limit exceeded` が発生しやすくなります。小さめの Apex Class を試したり、あるいは混雑が緩和された状態でお試しください。

### 対応していない機能

以下の機能には対応していない。

- SOQL Currency literal
- SOSL FIND seriese

## RsvrApexSyntaxParser

- 未実装 / TBD

# 参考にしたリソース

## 以下のサイトのリソースを参考にしています

以下のサイトのリソースを参考にしています。すばらしい BNF をありがとう。

- https://github.com/nawforce/apex-parser/tree/master/antlr

## それら入力情報の権利情報

それら入力情報の権利情報は以下。詳しくは githubリンク先のファイルヘッダーなどを参照ください。

- Copyright (c) 2013 Terence Parr, Sam Harwell
- maintainer: Andrey Gavrikov

