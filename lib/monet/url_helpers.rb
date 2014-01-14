module Monet
  module URLHelpers
    ::Monet::InvalidURL = Class.new(StandardError)

    private
    def clean(url)
      url.chomp("/")
    end

    def parse_uri(path)
      uri = path.is_a?(URI) ? path : URI.parse(path)
      raise InvalidURL, "#{path} is not a valid url" if uri.class == URI::Generic

      uri
    end
  end
end