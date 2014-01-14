module Monet
  class ErrorImage
    attr_reader :path, :error

    def initialize(path, code)
      @path = path
      @error = code
    end

    def image
      Monet::Image.new @path
    end
  end
end
