require "capybara"
require 'capybara/poltergeist'
require "capybara/dsl"

require 'monet/config'

module Monet
  class Capture
    include Capybara::DSL

    def initialize(config={})
      @config = (config.is_a? Monet::Config) ? config : Monet::Config.new(config)

      # TODO: make configurable
      Capybara.default_driver = @config.driver
    end

    def capture(path)
      visit normalize_path(path)
      page.driver.render(image_name_from_path(path), full: true)
    end

    private
    def capture_path
      @config.capture_dir
    end

    def normalize_path(path)
      "http://#{path}" unless path.start_with?("https?")
    end

    def image_name_from_path(path)
      name = path.gsub(/https?:\/\//, '').gsub('.', '_')
      "#{capture_path}/#{name}-#{Time.now.to_i}.png"
    end
  end
end