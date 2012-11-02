module Monet::Errors
  class DifferentDimensions < StandardError
    def message
      "Images are different dimensions. Cannot compare accurately."
    end
  end

end