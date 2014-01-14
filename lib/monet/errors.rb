module Monet::Errors
  class DifferentDimensions < StandardError
    def message
      "Images are different dimensions. Cannot compare accurately."
    end
  end

  class UnseenURL < StandardError
    def initialize(url)
      @url = url
    end

    def message
      "There is no recorded status for #{@url}"
    end
  end
end