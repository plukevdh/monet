require "capybara"
require 'capybara/poltergeist'
require "capybara/dsl"

require 'monet/config'

module Monet
  class Capture
    include Capybara::DSL

    MAX_HEIGHT = 10000

    def initialize(config)
      @config = Monet::Config.build_config(config)
      @router = Monet::PathRouter.new(@config)

      Capybara.default_driver = @config.driver
      Capybara.javascript_driver = @config.driver
    end

    def capture_all
      @config.map.paths.each do |path|
        @config.dimensions.each do |width|
          capture(path, width)
        end
      end
    end

    def capture(path, width)
      visit @router.build_url(path)

      page.driver.resize(width, MAX_HEIGHT)
      page.driver.render(@router.route_url_path(path, width), full: true)
    end
  end
end