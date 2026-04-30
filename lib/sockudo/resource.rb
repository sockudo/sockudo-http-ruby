# frozen_string_literal: true

module Sockudo
  class Resource
    def initialize(client, path)
      @client = client
      @path = path
    end

    def get(params)
      create_request(:get, params).send_sync
    end

    def get_async(params)
      create_request(:get, params).send_async
    end

    def post(params, headers = {})
      body = MultiJson.encode(params)
      create_request(:post, {}, body, headers).send_sync
    end

    def post_async(params, headers = {})
      body = MultiJson.encode(params)
      create_request(:post, {}, body, headers).send_async
    end

    def delete(params)
      create_request(:delete, params).send_sync
    end

    private

    def create_request(verb, params, body = nil, extra_headers = {})
      Request.new(@client, verb, url, params, body, extra_headers)
    end

    def url
      @url ||= @client.url(@path)
    end
  end
end
