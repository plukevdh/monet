require 'spec_helper'
require 'monet/path_router'
require 'monet/config'

describe Monet::PathRouter do
  Given(:capture) { File.expand_path "./capture" }
  Given(:baseline) { File.expand_path "./baseline" }
  Given(:config) { Monet::Config.new(base_url: "http://google.com", capture_dir: "./capture", baseline_dir: "./baseline") }
  Given(:router) { Monet::PathRouter.new(config) }

  context "knows base dir" do
    When(:path) { router.root_dir }
    Then { path.should == "google.com" }
  end

  context "build url from path" do
    When(:url) { router.build_url("/space/manager") }
    Then { url.should == "http://google.com/space/manager" }
  end

  context "full url to path" do
    When(:path) { router.route_url("http://google.com/space/manager", 900) }
    Then { path.should == "#{capture}/google.com/google.com>space>manager-900.png" }
  end

  context "url path to path" do
    When(:path) { router.route_url_path("/space/manager", 900) }
    Then { path.should == "#{capture}/google.com/google.com>space>manager-900.png"}
  end

  context "path to url" do
    When(:url) { router.route_path("#{capture}/google.com/google.com>space>manager-900.png") }
    Then { url.should == "http://google.com/space/manager" }
  end

  context "path to baseline from url" do
    When(:path) { router.url_to_baseline("http://google.com/space/manager", 900) }
    Then { path.should == "#{baseline}/google.com/google.com>space>manager-900.png" }
  end

  context "path to baseline from path" do
    When(:path) { router.url_path_to_baseline("/space/manager", 900) }
    Then { path.should == "#{baseline}/google.com/google.com>space>manager-900.png" }
  end

  context "capture path to baseline path" do
    When(:path) { router.capture_to_baseline("#{capture}/google.com/google.com>space>manager-900.png") }
    Then { path.should == "#{baseline}/google.com/google.com>space>manager-900.png" }
  end
end