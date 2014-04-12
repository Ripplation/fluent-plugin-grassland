# fluent-plugin-kinesis-alt

Output filter plugin for Amazon Kinesis

[![Gem Version](https://badge.fury.io/rb/fluent-plugin-kinesis-alt.png)](http://badge.fury.io/rb/fluent-plugin-kinesis-alt)

## Notice

This code was merged into [fluent-plugin-kinesis](https://github.com/imaifactory/fluent-plugin-kinesis).
I think that [fluent-plugin-kinesis](https://github.com/imaifactory/fluent-plugin-kinesis) is released in the near future.

## Installation

Add this line to your application's Gemfile:

    gem 'fluent-plugin-kinesis-alt'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install fluent-plugin-kinesis-alt

## Usage

### Configuration

```
<match kinesis.**>
  type grassland
  aws_key_id ...
  aws_sec_key ...
  region us-east-1

  stream_name your_stream_name

  #partition_key any_json_key

  # partition_key:
  #   JSON Object Hash Key for PartitionKey
  #   e.g.)
  #     JSON Object: {'foo': 100, 'bar': 200}
  #     fluentd conf: partition_key=foo
  #     -> PutRecord Action: PartitionKey=100

  partition_key_proc proc {|i| Time.now.to_i.to_s }

  # partition_key_proc:
  #   Ruby Code to create PartitionKey
  #   e.g.)
  #     JSON Object: {'foo': 100, 'bar': 200}
  #     fluentd conf: partition_key_proc=proc {|i| i['bar'] }
  #     -> PutRecord Action: PartitionKey=200

  #explicit_hash_key ...
  #explicit_hash_key_proc ...

  #debug false
  #include_tag true
  #include_time true

  flush_interval 3
</match>
```

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
