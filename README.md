# fluent-plugin-grassland

Output filter plugin for Grassland

[![Gem Version](https://badge.fury.io/rb/fluent-plugin-grassland.svg)](http://badge.fury.io/rb/fluent-plugin-grassland)

## Notice

maybe write after.

## Installation
* It still not working

Add this line to your application's Gemfile:

    gem 'fluent-plugin-grassland'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install fluent-plugin-grassland

## Usage

### Configuration

```
<match kinesis.**>
  type grassland
  key xxxxxxxxxxxxxxxx
  flush_interval 3
</match>
```
