require "capybara"
require 'capybara/poltergeist'
require "capybara/dsl"

module Monet
  class Capture
    include Capybara::DSL

    def initialize(config={})
      @base_path = File.expand_path(config[:base_path] || './baselines')

      # TODO: make configurable
      Capybara.default_driver = :poltergeist
      Capybara.javascript_driver = :poltergeist
    end

    def capture(path)
      visit normalize_path(path)
      page.driver.render(image_name_from_path(path), full: true)
    end

    private

    def normalize_path(path)
      "http://#{path}" unless path.start_with?("https?")
    end

    def image_name_from_path(path)
      name = path.gsub(/https?:\/\//, '').gsub('.', '_')
      "#{@base_path}/#{name}-#{Time.now.to_i}.png"
    end
  end
end