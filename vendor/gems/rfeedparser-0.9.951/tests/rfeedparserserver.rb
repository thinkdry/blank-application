#!/usr/bin/env ruby

require File.join(File.dirname(__FILE__), 'rfeedparser_test_helper')

# Start up the mongrel server and tell it how to send the tests
server = Mongrel::HttpServer.new("0.0.0.0", $PORT)
Mongrel::DirHandler::add_mime_type('.xml','application/xml')
Mongrel::DirHandler::add_mime_type('.xml_redirect','application/xml')
server.register("/", FeedParserTestRequestHandler.new('.'))
server.run.join
