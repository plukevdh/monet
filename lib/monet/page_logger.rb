require 'csv'
require 'monet/errors'

module Monet
  class PageLogger
    def initialize
      @cache = {}
    end

    def status_for(url)
      status = @cache[url]
      raise Monet::Errors::UnseenURL.new(url) unless status

      status
    end

    def add(url, status)
      @cache[url] = status.to_i
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
  end
end