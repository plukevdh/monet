module Monet
  module URLHelpers
    InvalidURL = Class.new(StandardError)

    private
    def parse_uri(path)
      uri = URI.parse path
      raise InvalidURL, "#{path} is not a valid url" if uri.class == URI::Generic

      uri.to_s
    end
  end
end