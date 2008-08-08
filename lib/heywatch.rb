#--
# Copyright (c) 2007 Bruno Celeste
#
# Permission is hereby granted, free of charge, to any person obtaining
# a copy of this software and associated documentation files (the
# "Software"), to deal in the Software without restriction, including
# without limitation the rights to use, copy, modify, merge, publish,
# distribute, sublicense, and/or sell copies of the Software, and to
# permit persons to whom the Software is furnished to do so, subject to
# the following conditions:
#
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
# LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
# OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
# WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
#++

require "rubygems"
require "xmlsimple"
require "cgi"

module HeyWatch
	Host = "heywatch.com" unless const_defined? :Host
	OutFormat = "xml" unless const_defined? :OutFormat
  Resources = %w{job format download discover encoded_video video account log} unless const_defined? :Resources

  # These are error codes you receive if you use ping options
  ErrorCode = {
                100 => "Unknown error",
                101 => "Unsupported audio codec",
                102 => "Unsupported video codec",
                103 => "This video cannot be encoded in this format",
                104 => "Wrong settings for audio",
                105 => "Wrong settings for video",
                106 => "Cannot retrieve info from this video",
                107 => "Not a video file",
                108 => "Video too long",
                109 => "The container of this video is not supported yet",
                110 => "The audio can't be resampled",
                201 => "404 Not Found",
                202 => "Bad address",
                300 => "No more credit available"
              } unless const_defined? :ErrorCode
              
  class NotAuthorized < RuntimeError; end
  class RequestError < RuntimeError; end
  class ResourceNotFound < RuntimeError; end
  class ServerError < RuntimeError; end
  class SessionNotFound < RuntimeError; end
  
  # Convert the XML response into Hash
  def self.response(xml)
    XmlSimple.xml_in(xml, {'ForceArray' => false})
  end
  
  # sanitize url
  def self.sanitize_url(url)
    return url.gsub(/[^a-zA-Z0-9:\/\.\-\+_\?\=&]/) {|s| CGI::escape(s)}.gsub("+", "%20")
  end
end

$: << File.dirname(File.expand_path(__FILE__))

require "heywatch/ext"
require "heywatch/version"
require "heywatch/browser"
require "heywatch/auth"
require "heywatch/base"
require "heywatch/encoded_video"
require "heywatch/video"
require "heywatch/account"
require "heywatch/download"
require "heywatch/discover"
require "heywatch/job"

class Hash
  include HeyWatch::CoreExtension::HashExtension
end

class Array
  include HeyWatch::CoreExtension::ArrayExtension
end
