require "capybara"
require 'capybara/poltergeist'
require "capybara/dsl"

require 'monet/config'

module Monet
  class Capture
    include Capybara::DSL

    MAX_HEIGHT = 10000

    def initialize(config={})
      @config = (config.is_a? Monet::Config) ? config : Monet::Config.new(config)

      Capybara.default_driver = @config.driver
    end

    def capture_all(paths, dimensions)
      paths.each do |path|
        dimensions.each do |width|
          capture(path, width)
        end
      end
    end

    def capture(path, width)
      url = normalize_path(path)
      visit url

      page.driver.resize(width, MAX_HEIGHT)
      page.driver.render(image_name(url, width), full: true)
    end

    private
    def capture_path
      @config.capture_dir
    end

    def normalize_path(path)
      "#{@config.base_url}#{path}"
    end

    def image_name(path, width)
      name = path.gsub(/https?:\/\//, '').gsub(/\.]/, '_')
      "#{capture_path}/#{name}-#{width}.png"
    end
  end
end