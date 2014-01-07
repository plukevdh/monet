require 'spec_helper'
require 'monet/config'

describe Monet::Config do
  context "has defaults" do
    When(:config) { Monet::Config.new }
    Then { config.driver.should == :poltergeist }
    And { config.capture_dir.should == File.expand_path("./captures") }
  end

  context "can load yaml" do
    When(:config) { Monet::Config.load }
    Then { config.base_url.to_s.should == "http://lance.com" }
    And { config.map.size.should == 3 }
  end

  context "can set options" do
    When(:config) {
      Monet::Config.config do |config|
        config.driver = :poltergeist
        config.dimensions = [1440,900]
        config.base_url = "http://www.spider.io/"

        config.map do |map|
          map.add 'home/index'
          map.add 'home/show'
        end
      end
    }
    Then { config.driver.should == :poltergeist }
    And { config.dimensions.should == [1440,900] }
    And { config.map.paths.should == ["home/index", "home/show"] }
  end

  context "should require base_url" do
    When(:config) do
      Monet::Config.config do |config|
        config.map do |map|
          map.add 'home/index'
          map.add 'home/show'
        end
      end
    end
    Then { config.should have_failed(Monet::Config::MissingBaseURL, /set the base_url/) }
  end

  context "can request spider agent instead of explicit paths" do
    When(:config) do
      Monet::Config.config do |config|
        config.base_url = "http://www.spider.io/"
        config.map :spider
      end
    end
    Then { config.map.should be_a(Monet::CaptureMap) }

    And { config.map.type.should == :spider }
  end
end