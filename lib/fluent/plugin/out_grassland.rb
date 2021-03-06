require 'syslog/logger'
require 'fluent/plugin/output'

module Fluent::Plugin
  class GrasslandOutput < Fluent::Plugin::Output
    Fluent::Plugin.register_output("grassland", self)

    attr_accessor :random
    attr_accessor :kinesis
    attr_accessor :id, :stream_name, :access_key_id, :secret_access_key, :region, :sessionToken, :partitionKeys

    def initialize
      super
      # require 'aws-sdk-v1'
      require 'aws-sdk'
      require 'base64'
      require 'json'
      require 'logger'
      require 'net/http'
      require 'uri'
      @random = Random.new

      log = Syslog::Logger.new 'grasslandplugin'
      log.info 'grassland initialize'
      # puts "grassland initialize"
    end

    config_param :apiuri,               :string,  :default => 'https://grassland.biz/credentials'
    # config_param :id,                  :string,  :default => 'nil'
    config_param :key,                  :string,  :default => 'nil'
    config_param :debug,                :bool,    :default => false
    config_param :resetCredentialTimer, :integer, :default => 86400
    # config_param :resetCredentialTimer, :integer, :default => 20

    def set_interval(delay)
      Thread.new do
        loop do
          sleep delay
          yield # call passed block
        end
      end
    end

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
      set_interval(@resetCredentialTimer){
        resetAwsCredential
      }
      resetAwsCredential
    end

    def shutdown
      super
    end

    def resetAwsCredential()
      begin
        setCredential
        configure_aws
        @kinesis.put_record({
          :stream_name   => @stream_name,
          :data          => "test",
          :partition_key => "#{random.rand(999)}"
        })
        log.info "grassland: reset credential"
      rescue => e
        log.info [e.class, e].join(" : initialize error.")
      end
    end

    def setCredential()
      credential = get_json("#{@apiuri}?key=#{@key}")
      @id = credential['id']
      @stream_name = credential['streamName']
      @access_key_id = credential['accessKeyId']
      @secret_access_key = credential['secretAccessKey']
      @region = credential['region']
      @sessionToken = credential['SessionToken']
      @partitionKeys = credential['partitionKeyList']
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
          log.info [uri.to_s, response.value].join(" : ")
          # handle error
        end
      rescue => e
        log.info [uri.to_s, e.class, e].join(" : ")
        # handle error
      end
    end

    def format(tag, time, record)
      # print(record)
      ['dt', 'd'].each do |key|
        unless record.has_key?(key)
          log.info "input data error: '#{key}' is required"
          return ""
        end
      end
      unless record.has_key?('pt')
        record['pt'] = time
      end
      unless record.has_key?('cid')
        record['cid'] = @id
      end
      unless record.has_key?('uid')
        record['uid'] = '0'
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
          # debug log
          # log.info data.to_json
          if bufList[":#{data['pk']}"] == nil then
            bufList[":#{data['pk']}"] = "#{data.to_json},"
          else
            bufList[":#{data['pk']}"] += "#{data.to_json},"
          end
          if bufList[":#{data['pk']}"].bytesize >= 30720 then
            @kinesis.put_record({
              :stream_name   => @stream_name,
              :data          => "["+bufList[":#{data['pk']}"].chop+"]",
              :partition_key => partitionKeys[random.rand(partitionKeys.length)]
              # :partition_key => data['pk']
            })
            bufList.delete(":#{data['pk']}")
          end
        end
        dataList.each do |data|
          if bufList[":#{data['pk']}"] != nil then
            @kinesis.put_record({
              :stream_name   => @stream_name,
              :data          => "["+bufList[":#{data['pk']}"].chop+"]",
              :partition_key => partitionKeys[random.rand(partitionKeys.length)]
              # :partition_key => data['pk']
            })
            bufList.delete(":#{data['pk']}")
          end
        end
      rescue
        log.info "error: put_record to grassland. maybe too many requests. few data dropped."
      end
    end

    private

    def configure_aws
      options = {
        :access_key_id     => @access_key_id,
        :secret_access_key => @secret_access_key,
        :region            => @region,
        :session_token     => @sessionToken
      }

      if @debug
        options.update(
          :logger          => Logger.new($log.out),
          :log_level       => :debug,
          #http_wire_trace => true
        )
      end

      @kinesis = Aws::Kinesis::Client.new(options)
    end
  end
  end
