# fluent-plugin-grassland

Output filter plugin for Grassland

[![Gem Version](https://badge.fury.io/rb/fluent-plugin-grassland.svg)](http://badge.fury.io/rb/fluent-plugin-grassland)

## Notice
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
    または、
    $ /opt/td-agent/embedded/bin/fluent-gem install fluent-plugin-grassland

## Usage

### Configuration

__Fluentdの設定ファイルに以下を追記します。__
```
<source>
  type forward
  port 24224
  bind 127.0.0.1
</source>
<match grassland.**>
  type grassland
  key xxxxxxxxxxxxxxxx
  flush_interval 5
</match>
```


### PHP usage

__1. [fluent-logger-phpをインストール](https://github.com/fluent/fluent-logger-php)して下さい。__
```
cat > composer.json << EOF
{
    "require": {
        "fluent/logger": "v0.3.7"
    }
}
EOF
curl -sS https://getcomposer.org/installer | php
php composer.phar install
```

__2. 実際にPHPに記載して下さい。__
```
<?php
require 'vendor/autoload.php';
use Fluent\Autoloader,
    Fluent\Logger\FluentLogger;

Autoloader::register();
$logger = FluentLogger::open("localhost", "24224");

/*** ここまでがfluent-logger-php用の前準備 ***/

$param = array(
	'dt' => 'データID',
	'pt' => '(optional)データの発生時刻(ISO 8601準拠の文字列、又はUnixtimestamp（秒）, Ex. "2014-04-01T12:00:00+09:00" or "1432698912")',
	'd' => array(
    '任意のキー1' => array('任意のキー2' => '集計を行いたいデータ'),
		'(optional)任意のキー1' => array('任意のキー2' => '集計を行いたいデータ'),
    ...
	)
);
$logger->post("grassland.data", $param);
```

ptを省略した場合、fluentdが受け付けた時間のUTC時刻として入力されます。  
「任意のキー」は、グラフに表示される一つの要素になります。  
例を以下に示します。  

```
//timezone設定
date_default_timezone_set('Asia/Tokyo');

$param = array(
  'dt' => 'd822fab12eeb4db997db87876a082d82',
  'd' => array(
    'itemGroup1' => array('item1' => '100'),
    'itemGroup1' => array('item2' => '200')
  )
);
$logger->post("grassland.data", $param);
```

### Node.js usage

__1. [fluent-logger-nodeをインストール](https://github.com/fluent/fluent-logger-node)して下さい。__
```
cat > package.json << EOF
{
  "name": "grassland_test ",
  "version": "0.0.1",
  "dependencies": {
    "fluent-logger": "0.2.6"
  }
}
EOF
npm install
```

__2. 実際にPHPに記載して下さい。__
```
var logger = require('fluent-logger');
logger.configure('grassland', {
   host: 'localhost',
   port: 24224,
   timeout: 3.0
});

/*** ここまでがfluent-loggerの前準備 ***/

var param = {
  dt: 'データID',
  pt: '(optional)データの発生時刻(ISO 8601準拠の文字列 Ex. "2014-04-01T12:00:00+09:00")',
  d: {
    '任意のキー1': {'任意のキー2': '(int)集計を行いたいデータ'},
    '(optional)任意のキー1': {'任意のキー2': '(int)集計を行いたいデータ'}
  }
};
logger.emit('data', param);
```