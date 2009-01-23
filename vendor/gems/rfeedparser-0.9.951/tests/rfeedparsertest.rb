#!/usr/bin/env ruby

# This is based off of Sam Ruby's xml_filetest.rb
# I've adapted it for rfeedparser
# http://intertwingly.net/blog/2005/10/30/Testing-FeedTools-Dynamically/

require 'yaml'
require File.join(File.dirname(__FILE__),'rfeedparser_test_helper')

class XMLTests < Test::Unit::TestCase
  # Some tests are known to fail because we're copying the Python
  # version's feed suite verbatim, and we have minor implementation
  # details that don't constitute brokenness but are still
  # different. Running `rake test skip=y' will skip these.
  #
  # Additionally if you want to run a single test, run:
  # rake test n=test_tests_wellformed_encoding_x80macroman
  #
  def self.skip?(name)
    return true if ENV['n'] and ENV['n'] != name

    if ENV['skip']
      @to_skip ||= YAML.load(File.open(File.dirname(__FILE__) + '/to_skip.yml'))
      @to_skip.include? name
    end
  end

  Dir["#{File.dirname(__FILE__)}/**/*.xml"].each do |xmlfile|
    name = "test_#{xmlfile.gsub('./', '').gsub('/','_').sub('.xml','')}"
    next if skip?(name)
    
    define_method(name) do

      fp = FeedParser.parse("http://127.0.0.1:#{$PORT}/#{xmlfile}", :compatible => true) 
      # I should point out that the 'compatible' arg is not necessary,
      # but probably will be in the future if we decide to change the default.

      description, evalString = scrape_assertion_strings(xmlfile)

      assert fp.instance_eval(evalString), description
    end
  end
end

# TODO: don't fail if the rfeedparserserver.rb is already running
# Start up the mongrel server and tell it how to send the tests
server = Mongrel::HttpServer.new("0.0.0.0",$PORT)
Mongrel::DirHandler::add_mime_type('.xml','application/xml')
Mongrel::DirHandler::add_mime_type('.xml_redirect','application/xml')
server.register("/", FeedParserTestRequestHandler.new("."))
server.run
