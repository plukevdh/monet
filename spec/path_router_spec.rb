require 'spec_helper'
require 'monet/path_router'

describe Monet::PathRouter do
  Given(:root) { URI.parse("http://google.com") }
  Given(:router) { Monet::PathRouter.new(root, './capture') }

  context "build url from path" do
    When(:url) { router.build_url("/space/manager") }
    Then { url.should == "http://google.com/space/manager" }
  end

  context "full url to path" do
    When(:path) { router.route_url("http://google.com/space/manager", 900) }
    Then { path.should == "./capture/google.com/google.com>space>manager-900.png" }
  end

  context "url path to path" do
    When(:path) { router.route_url_path("/space/manager", 900) }
    Then { path.should == "./capture/google.com/google.com>space>manager-900.png"}
  end

  context "path to url" do
    When(:url) { router.route_path("./capture/google.com/google.com>space>manager-900.png") }
    Then { url.should == "http://google.com/space/manager" }
  end
end