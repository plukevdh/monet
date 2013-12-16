require 'fileutils'

module Monet
  class BaselessImage
    attr_reader :path

    def initialize(path)
      @path = path
    end
  end
end