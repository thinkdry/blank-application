#!/usr/bin/env ruby
require File.join(File.dirname(__FILE__), 'aliases')
require File.join(File.dirname(__FILE__), 'encoding_helpers')
require File.join(File.dirname(__FILE__), 'markup_helpers')
require File.join(File.dirname(__FILE__), 'scrub')
require File.join(File.dirname(__FILE__), 'time_helpers')

module FeedParserUtilities
  
  def parse_date(date_string)
    FeedParser::FeedTimeParser.parse_date(date_string)
  end
  module_function :parse_date

  def extract_tuple(atime)
    FeedParser::FeedTimeParser.extract_tuple(atime)
  end
  module_function :extract_tuple
  
  def py2rtime(pytuple)
    Time.utc(*pytuple[0..5]) unless pytuple.nil? || pytuple.empty? 
  end
end