require 'fileutils'

module Monet
  class BaselessImage
    attr_reader :path

    def initialize(path)
      @path = path
    end

    def image
      Monet::Image.new @path
    end
  end
end
