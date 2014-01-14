require 'spec_helper'
require 'monet/page_logger'

describe Monet::PageLogger do
  When { log.add("http://google.com", 200) }
  When { log.add("http://google.com/chrome", 302) }
  When { log.add("http://google.com/notathing", 404) }
  When { log.add("http://lance.com/snack", 403) }

  shared_examples "valid logger" do
    context "logs a set of responses for urls" do
      Then { log.failures.size.should == 2 }
      And { log.successes.size.should == 2 }
      And { log.failures.should == {"http://google.com/notathing" => 404, "http://lance.com/snack" => 403} }
    end

    context "can lookup a url's status" do
      When(:result) { log.status_for("http://google.com/chrome") }
      Then { result.should == 302 }
    end

    context "can test for failure of a failed url" do
      When(:result) { log.failed?("http://google.com/notathing") }
      Then { result.should be_true }
    end

    context "can test for failure of a successful url" do
      When(:result) { log.failed?("http://google.com/chrome") }
      Then { result.should be_false }
    end

    context "can test for success of a bad url" do
      When(:result) { log.succeeded?("http://google.com/notathing") }
      Then { result.should be_false }
    end

    context "can test for success of a good url" do
      When(:result) { log.succeeded?("http://google.com") }
      Then { result.should be_true }
    end

    context "raises no UnseenUrl error for url that hasn't been seen" do
      Given(:url) { "http://www.spider.io" }
      When(:result) { log.status_for(url) }
      Then { result.should have_failed(Monet::Errors::UnseenURL, "There is no recorded status for #{url}") }
    end
  end

  context "initialized logger" do
    it_should_behave_like "valid logger" do
      Given(:log) { Monet::PageLogger.new }
    end
  end

  context "log persistance" do
    Given(:log) { Monet::PageLogger.new }
    Given(:path) { "./spec/tmp/output/log.txt" }
    When { log.save(path) }

    context "can save a log file" do
      Then { File.exists?(path).should be_true }
    end

    context "has a csv listing of urls and codes" do
      When(:txt) { IO.readlines(path) }
      Then { txt.should == %W(http://google.com,200\n http://google.com/chrome,302\n http://google.com/notathing,404\n http://lance.com/snack,403\n) }
    end

    context "can load a listing of codes from file" do
      it_should_behave_like "valid logger" do
        Given(:log) { Monet::PageLogger.load(path) }
      end
    end
  end
end