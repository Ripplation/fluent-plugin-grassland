# fluent-plugin-grassland

Output filter plugin for Grassland

[![Gem Version](https://badge.fury.io/rb/fluent-plugin-grassland.svg)](http://badge.fury.io/rb/fluent-plugin-grassland)

## Notice
* このアプリケーションはまだテスト中です。

本アプリケーションはFluentdのGrassland用プラグインです。
[Fluentdをインストール](http://docs.fluentd.org/categories/installation)してからご利用下さい。

## Installation

__Gemfileに記載する場合__

まずGemfileに以下を追記します。

    gem 'fluent-plugin-grassland'

次に以下のコマンドを実行します。

    $ bundle

__直接インストールする場合__

以下のコマンドにて、インストールして下さい。

    $ gem install fluent-plugin-grassland

__Red Hat系OSでtd-agentを利用している場合__

fluent-gemでインストールします。
注意： fluent-gemのパスは環境によって異なります。

    $ /usr/lib64/fluent/ruby/bin/fluent-gem install fluent-plugin-grassland

## Usage

### Configuration

__Fluentdの設定ファイルに以下を追記します。__
```
<match grassland.**>
  type grassland
  key xxxxxxxxxxxxxxxx
  flush_interval 3
</match>
```
