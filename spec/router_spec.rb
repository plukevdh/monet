require 'spec_helper'
require 'monet/router'

describe "Monet::Router" do
  Given(:config) { Monet::Config.new({
    base_url: "http://lance.com",
    capture_dir: "./spec/fixtures/captures",
    baseline_dir: "./spec/fixtures/baselines",
    thumbnail_dir: "./spec/fixtures/thumbnails"
  })}
  Given(:router) { Monet::Router.new config }


  def expand *parts
    File.expand_path File.join(*parts)
  end

  shared_examples "type routing" do |type|
    context "can get the #{type} for a path" do
      When(:route) { router.send "#{type}_dir", "about-500.png" }
      Then { route.should == expand(config.send("#{type}_dir"), "lance.com", "about-500.png") }
    end

    context "can get the #{type} url for a path" do
      When(:route) { router.send "#{type}_url", "about-500.png" }
      Then { route.should == "/#{type}s/#{config.site}/about-500.png" }
    end

    context "can get the root dir for a #{type}" do
      When(:route) { router.send "#{type}_dir" }
      Then { route.should == expand(config.send("#{type}_dir"), "lance.com") }
    end

    context "can get the diff dir for a path" do
      When(:route) { router.diff_dir "lance.com|about-500.png" }
      Then { route.should == expand(config.baseline_dir, "lance.com", "lance.com|about-500-diff.png") }
    end

    context "can get the diff url for a path" do
      When(:route) { router.diff_url "lance.com|about-500.png" }
      Then { route.should == "/baselines/lance.com/lance.com|about-500-diff.png" }
    end
  end

  context "can convert url path to capture path" do
    When(:path) { router.url_to_filepath("http://lance.com/my-fake-url/chromist", 2000) }
    Then { path.should == File.join(config.capture_dir, "lance.com", "lance.com|my-fake-url|chromist-2000.png") }
  end

  context "can list out urls" do
    Given do
      config.dimensions = [1440,900]
      config.map = ['/home/index', '/home/show']
    end

    When(:urls) { router.capture_routes }
    Then { urls.should == {
      "http://lance.com/home/index" => [
        expand(config.capture_dir, "lance.com", "lance.com|home|index-1440.png"),
        expand(config.capture_dir, "lance.com", "lance.com|home|index-900.png")
      ],
      "http://lance.com/home/show" => [
        expand(config.capture_dir, "lance.com", "lance.com|home|show-1440.png"),
        expand(config.capture_dir, "lance.com", "lance.com|home|show-900.png")
      ]}
    }
  end

  context "original url" do
    When(:route) { router.original_url "lance.com/lance.com|about-500.png" }
    Then { route.should == "http://lance.com/about" }
  end

  context "baseline" do
    it_should_behave_like "type routing", "baseline"
  end

  context "capture" do
    it_should_behave_like "type routing", "capture"
  end

  context "thumbnail" do
    it_should_behave_like "type routing", "thumbnail"
  end

  context "knows how to get the base diff dir" do
    When(:route) { router.diff_dir }
    Then { route.should == expand(config.baseline_dir, "lance.com") }
  end
end