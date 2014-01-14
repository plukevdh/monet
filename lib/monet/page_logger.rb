require 'csv'
require 'singleton'

require 'monet/errors'

module Monet
  class PageLogger
    include Singleton
    extend Forwardable

    module Helpers
      def log_page(url, status)
        PageLogger.instance.add(url, status)
      end

      def failed?(url)
        PageLogger.instance.failed? url
      end
    end

    def initialize
      reset
    end

    def_delegators :@cache, :size, :length, :count, :[]

    def status_for(url)
      status = @cache[url]
      raise Monet::Errors::UnseenURL.new(url) unless status

      status
    end

    def add(url, status)
      @cache[normalize_url(url)] = status.to_i
    end

    def save(path)
      File.open(path, "w+") do |io|
        @cache.each do |k,v|
          io.puts "#{k},#{v}"
        end
      end
    end

    def self.load(path)
      logger = new
      CSV.foreach(path) do |k,v|
        logger.add(k,v)
      end

      logger
    end

    def reset
      @cache = {}
    end

    def self.reset
      instance.reset
    end

    def failures
      @cache.select {|k,v| failed? k }
    end

    def successes
      @cache.select {|k,v| succeeded? k }
    end

    def succeeded?(url)
      status_for(url) < 400
    end

    def failed?(url)
      !succeeded?(url)
    end

    private
    def normalize_url(url)
      url.to_s.chomp("/")
    end
  end
end