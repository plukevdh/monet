require 'spec_helper'
require 'monet/capture_map'

describe Monet::CaptureMap::PathCollection do
  context "base helper" do
    Given(:helper) { Monet::CaptureMap::PathCollection.new("http://google.com") }
    Then { helper.paths.should == [] }
  end

  context "add items" do
    Given(:helper) { Monet::CaptureMap::PathCollection.new("http://google.com") }
    When { helper.add('path') }
    Then { helper.paths.should == ['path'] }
  end
end

describe Monet::CaptureMap::PathSpider do
  Given(:spider) { Monet::CaptureMap::PathSpider.new("http://spider.io/") }

  context "ignores" do
    When(:ignores) { spider.ignores }
    Then { ignores.all? {|x| x.is_a? Regexp}.should be_true }
  end
end

describe Monet::CaptureMap do
  context "no arguments" do
    When(:result) { Monet::CaptureMap.new }
    Then { result.should have_failed(ArgumentError) }
  end

  context "requires full url" do
    When(:result) { Monet::CaptureMap.new("google.com") }
    Then { result.should have_failed(Monet::CaptureMap::InvalidURL, /google.com is not a valid url/) }
  end

  context "requires valid url" do
    When(:result) { Monet::CaptureMap.new("google") }
    Then { result.should have_failed(Monet::CaptureMap::InvalidURL, /google is not a valid url/) }
  end

  context "with name" do
    Given(:map) { Monet::CaptureMap.new("http://google.com") }
    Then { map.root_url.should == "http://google.com" }
    And { map.paths.should == [] }
  end

  context "with paths" do
    Given(:map) {
      Monet::CaptureMap.new("http://google.com") do |map|
        map.add 'home/'
        map.add 'test/new'
      end
    }

    context "add paths" do
      Then { map.root_url.should == "http://google.com" }
      And { map.paths.should == ['home', 'test/new'] }
    end
  end

  context "spider mapper", vcr: { cassette_name: "spider", record: :new_episodes } do
    Given(:map) { Monet::CaptureMap.new("http://www.spider.io", :spider) }
    When(:paths) { map.paths }
    Then { paths.should == [
      "http://www.spider.io",
      "http://www.spider.io/anti-malware/",
      "http://www.spider.io/viewability/",
      "http://www.spider.io/press/",
      "http://www.spider.io/team/",
      "http://www.spider.io/blog/",
      "http://www.spider.io/",
      "http://www.spider.io/blog/2013/03/chameleon-botnet/",
      "http://www.spider.io/blog/2013/12/cyber-criminals-defraud-display-advertisers-with-tdss/",
      "http://www.spider.io/zeus",
      "http://www.spider.io/blog/2013/11/how-to-defraud-display-advertisers-with-zeus/",
      "http://www.spider.io/blog/2013/05/a-botnet-primer-for-display-advertisers/",
      "http://www.spider.io/blog/2013/09/display-advertisers-funding-cybercriminals-since-2011/",
      "http://www.spider.io/blog/2013/09/securing-the-legitimacy-of-display-ad-inventory/",
      "http://www.spider.io/blog/2013/04/display-advertising-fraud-is-a-sell-side-problem/",
      "http://www.spider.io/blog/2012/12/internet-explorer-data-leakage/",
      "http://www.spider.io/blog/2013/08/sambreel-is-still-injecting-ads-video-advertisers-beware/",
      "http://www.spider.io/blog/page/2/",
      "http://www.spider.io/blog/2011/10/the-problem-with-client-side-analytics/",
      "http://www.spider.io/blog/2012/12/responsible-disclosure/",
      "http://www.spider.io/blog/2013/05/spider-io-granted-mrc-accreditation-for-viewable-impression-measurement/",
      "http://www.spider.io/blog/2013/04/at-least-two-percent-of-monitored-display-ad-exchange-inventory-is-hidden/",
      "http://www.spider.io/blog/2013/03/who-is-behind-the-chameleon-botnet/",
      "http://www.spider.io/blog/page/3/",
      "http://www.spider.io/blog/2013/02/which-display-ad-exchange-sells-the-highest-quality-inventory/",
      "http://www.spider.io/blog/2012/12/there-are-two-ways-to-measure-ad-viewability-there-is-only-one-right-way/",
      "http://www.spider.io/blog/page/4/",
      "http://www.spider.io/blog/2012/12/review-of-iab-safeframe-1-0/",
      "http://www.spider.io/blog/2012/10/qa-about-ad-viewability/",
      "http://www.spider.io/blog/2012/10/the-first-technology-to-measure-the-viewability-of-iframed-ads-across-all-major-browsers-press-release/",
      "http://www.spider.io/vSta98h",
      "http://www.spider.io/blog/2012/07/join-us-for-a-tipple-at-spider-towers/",
      "http://www.spider.io/blog/2012/07/startups-acquiring-startups-for-equity/",
      "http://www.spider.io/blog/page/5/",
      "http://www.spider.io/visibility-demo-screencast/",
      "http://www.spider.io/blog/2012/07/whats-in-an-ip-address/",
      "http://www.spider.io/blog/2011/12/physical-hack-day/",
      "http://www.spider.io/blog/2011/11/our-first-hack-day/",
      "http://www.spider.io/careers/",
      "http://www.spider.io/blog/2011/10/extreme-architecting/",
      "http://www.spider.io/blog/2011/09/how-to-catch-a-bot/",
      "http://www.spider.io/blog/page/6/",
      "http://www.spider.io/blog/2011/10/testing-javascript-with-mturk/",
      "http://www.spider.io/blog/2011/10/demonstration-screencast-verifying-that-display-ads-are-visible-from-within-iframes/",
      "http://www.spider.io/blog/2011/10/calling-out-to-researchersacademics/",
      "http://www.spider.io/blog/page/7/"
    ]}
    And { paths.any? {|p| p.end_with? "css" }.should be_false }
  end
end

