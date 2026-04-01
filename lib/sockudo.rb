autoload 'Logger', 'logger'
require 'securerandom'
require 'uri'
require 'forwardable'
require 'pusher-signature'

require 'sockudo/utils'
require 'sockudo/client'

# Used for configuring API credentials and creating Channel objects
#
module Sockudo
  # All errors descend from this class so they can be easily rescued
  #
  # @example
  #   begin
  #     Sockudo.trigger('channel_name', 'event_name, {:some => 'data'})
  #   rescue Sockudo::Error => e
  #     # Do something on error
  #   end
  class Error < RuntimeError; end
  class AuthenticationError < Error; end
  class ConfigurationError < Error
    def initialize(key)
      super "missing key `#{key}' in the client configuration"
    end
  end
  class HTTPError < Error; attr_accessor :original_error; end

  # Alias Pusher::Signature into the Sockudo namespace so that request signing
  # works correctly (pusher-signature gem defines Pusher::Signature, not Sockudo::Signature).
  Signature = Pusher::Signature

  class << self
    extend Forwardable

    def_delegators :default_client, :scheme, :host, :port, :app_id, :key,
                   :secret, :http_proxy, :encryption_master_key_base64
    def_delegators :default_client, :scheme=, :host=, :port=, :app_id=, :key=,
                   :secret=, :http_proxy=, :encryption_master_key_base64=

    def_delegators :default_client, :authentication_token, :url, :cluster
    def_delegators :default_client, :encrypted=, :url=, :cluster=
    def_delegators :default_client, :timeout=, :connect_timeout=, :send_timeout=, :receive_timeout=, :keep_alive_timeout=

    def_delegators :default_client, :get, :get_async, :post, :post_async
    def_delegators :default_client, :channels, :channel_info, :channel_users
    def_delegators :default_client, :trigger, :trigger_batch, :trigger_async, :trigger_batch_async
    def_delegators :default_client, :authenticate, :webhook, :channel, :[]
    def_delegators :default_client, :notify

    # Generate a unique idempotency key (UUID v4) for use with trigger methods.
    #
    # @return [String] A UUID string
    def generate_idempotency_key
      SecureRandom.uuid
    end

    attr_writer :logger

    def logger
      @logger ||= begin
        log = Logger.new($stdout)
        log.level = Logger::INFO
        log
      end
    end

    def default_client
      @default_client ||= begin
        cli = Sockudo::Client
        ENV['SOCKUDO_URL'] ? cli.from_env : cli.new
      end
    end
  end
end

require 'sockudo/version'
require 'sockudo/channel'
require 'sockudo/request'
require 'sockudo/resource'
require 'sockudo/webhook'