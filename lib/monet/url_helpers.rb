module Monet
  module URLHelpers
    ::Monet::InvalidURL = Class.new(StandardError)

    private
    def parse_uri(path)
      uri = URI.parse path
      raise InvalidURL, "#{path} is not a valid url" if uri.class == URI::Generic

      uri
    end
  end
end