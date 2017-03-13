module S3
  class Service
    include Parser
    include Proxies

    attr_reader :access_key_id, :secret_access_key, :use_ssl, :use_vhost, :proxy, :host, :custom_port

    # Compares service to other, by <tt>access_key_id</tt> and
    # <tt>secret_access_key</tt>
    def ==(other)
      access_key_id == other.access_key_id && secret_access_key == other.secret_access_key
    end

    # Creates new service.
    #
    # ==== Options
    # * <tt>:access_key_id</tt> - Access key id (REQUIRED)
    # * <tt>:secret_access_key</tt> - Secret access key (REQUIRED)
    # * <tt>:use_ssl</tt> - Use https or http protocol (false by
    #   default)
    # * <tt>:use_vhost</tt> - Use bucket.s3.amazonaws.com or s3.amazonaws.com/bucket (true by
    #   default)
    # * <tt>:debug</tt> - Display debug information on the STDOUT
    #   (false by default)
    # * <tt>:timeout</tt> - Timeout to use by the Net::HTTP object
    #   (60 by default)
    def initialize(options)
      # The keys for these required options might exist in the options hash, but
      # they might be set to something like `nil`. If this is the case, we want
      # to fail early.
      fail ArgumentError, 'Missing :access_key_id.' unless options[:access_key_id]
      fail ArgumentError, 'Missing :secret_access_key.' unless options[:secret_access_key]

      @access_key_id = options.fetch(:access_key_id)
      @secret_access_key = options.fetch(:secret_access_key)
      @host = options.fetch(:host)
      @use_ssl = options.fetch(:use_ssl, false)
      @use_vhost = options.fetch(:use_vhost, true)
      @timeout = options.fetch(:timeout, 60)
      @debug = options.fetch(:debug, false)
      @custom_port = options.fetch(:port, false)

      fail ArgumentError, 'Missing proxy settings. Must specify at least :host.' if options[:proxy] && !options[:proxy][:host]
      @proxy = options.fetch(:proxy, nil)
    end

    # Returns all buckets in the service and caches the result (see
    # +reload+)
    def buckets
      Proxy.new(-> { list_all_my_buckets }, owner: self, extend: BucketsExtension)
    end

    # Returns the bucket with the given name. Does not check whether the
    # bucket exists. But also does not issue any HTTP requests, so it's
    # much faster than buckets.find
    def bucket(name)
      Bucket.send(:new, self, name)
    end

    # Returns the signature for POST operations done externally via javascript
    def auth_sign
      service_request(:post, :use_authsign => true)
    end

    # Returns "http://" or "https://", depends on <tt>:use_ssl</tt>
    # value from initializer
    def protocol
      use_ssl ? 'https://' : 'http://'
    end

    # Returns 443 or 80, depends on <tt>:use_ssl</tt> value from
    # initializer
    def port
      custom_port ? custom_port : (use_ssl ? 443 : 80)
    end

    def inspect #:nodoc:
      "#<#{self.class}:#{@access_key_id}>"
    end

    private

    def list_all_my_buckets
      response = service_request(:get)
      names = parse_list_all_my_buckets_result(response.body)
      names.map { |name| Bucket.send(:new, self, name) }
    end

    def service_request(method, options = {})
      connection.request(method, options.merge(path: "/#{options[:path]}"))
    end

    def connection
      return @connection if defined?(@connection)
      @connection = Connection.new(access_key_id: @access_key_id,
                                   secret_access_key: @secret_access_key,
                                   host: @host,
                                   use_ssl: @use_ssl,
                                   timeout: @timeout,
                                   debug: @debug,
                                   port: @custom_port,
                                   proxy: @proxy)
    end
  end
end
