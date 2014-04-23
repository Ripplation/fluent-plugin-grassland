module Fluent
  class GrasslandOutput < Fluent::BufferedOutput
    Fluent::Plugin.register_output('grassland', self)

    attr_accessor :stream_name, :access_key_id, :secret_access_key, :region

    def initialize
      super
      require 'aws-sdk'
      require 'base64'
      require 'json'
      require 'logger'
      require 'net/http'
      require 'uri'
    end

    config_param :apiuri,   :string, :default => 'https://grassland-api.elasticbeanstalk.com/credential'
    config_param :key,      :string, :default => 'nil'
    config_param :debug,    :bool, :default => false

    def configure(conf)
      super

      [:key].each do |name|
        unless self.instance_variable_get("@#{name}")
          raise ConfigError, "'#{name}' is required"
        end
      end
    end

    def start
      super
      setCredential
      configure_aws
      AWS.kinesis.client.put_record({
        :stream_name   => @stream_name,
        :data          => "test",
        :partition_key => "#{rand(999)}"
      })
    end

    def shutdown
      super
    end

    def setCredential()
      credential = get_json("#{@apiuri}?key=#{@key}")
      @stream_name = credential['streamName']
      @access_key_id = credential['accessKeyId']
      @secret_access_key = credential['secretAccessKey']
      @region = credential['region']
    end

    def get_json(location, limit = 3)
      raise ArgumentError, 'too many HTTP redirects' if limit == 0
      uri = URI.parse(location)
      begin
        response = Net::HTTP.start(uri.host, uri.port, use_ssl: uri.scheme == 'https') do |http|
          http.open_timeout = 5
          http.read_timeout = 10
          http.get(uri.request_uri)
        end
        case response
        when Net::HTTPSuccess
          json = response.body
          JSON.parse(json)
        when Net::HTTPRedirection
          location = response['location']
          warn "redirected to #{location}"
          get_json(location, limit - 1)
        else
          puts [uri.to_s, response.value].join(" : ")
          # handle error
        end
      rescue => e
        puts [uri.to_s, e.class, e].join(" : ")
        # handle error
      end
    end

    def format(tag, time, record)
      # print(record)
      ['cid', 'dt', 'uid', 'd'].each do |key|
        unless record.has_key?(key)
          puts "input data error: '#{key}' is required"
          return ""
        end
      end
      unless record.has_key?('pt')
        record['pt'] = time
      end

      record['pk'] = record['cid'] + record['dt']
      return "#{record.to_json},"
    end

    def write(chunk)
      buf = chunk.read
      dataList = JSON.parse("[#{buf.chop}]")
      putBuf = ""
      bufList = {}

      begin
        dataList.each do |data|
          if bufList[":#{data['pk']}"] == nil then
            bufList[":#{data['pk']}"] = "#{data.to_json},"
          else
            bufList[":#{data['pk']}"] += "#{data.to_json},"
          end
          if bufList[":#{data['pk']}"].bytesize >= 30720 then
            AWS.kinesis.client.put_record({
              :stream_name   => @stream_name,
              :data          => "["+bufList[":#{data['pk']}"].chop+"]",
              :partition_key => data['pk']
            })
            bufList.delete(":#{data['pk']}")
          end
        end
        dataList.each do |data|
          if bufList[":#{data['pk']}"] != nil then
            AWS.kinesis.client.put_record({
              :stream_name   => @stream_name,
              :data          => "["+bufList[":#{data['pk']}"].chop+"]",
              :partition_key => data['pk']
            })
            bufList.delete(":#{data['pk']}")
          end
        end
      rescue
        puts "error: put_record to grassland. maybe too many requests. few data dropped."
      end
    end

    private

    def configure_aws
      options = {
        :access_key_id     => @access_key_id,
        :secret_access_key => @secret_access_key,
        :region            => @region
      }

      if @debug
        options.update(
          :logger          => Logger.new($log.out),
          :log_level       => :debug,
          #http_wire_trace => true
        )
      end

      AWS.config(options)
    end
  end
end
