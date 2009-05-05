# -*- coding: utf-8 -*-

require 'test/unit'
require File.join(File.dirname(__FILE__),'../lib/rfeedparser')

begin 
  require 'rubygems'
  gem 'mongrel'
  require 'mongrel'
rescue LoadError
  STDERR.puts "Whoops, had an error with loading mongrel as a gem. Trying just 'require'. Mongrel is required for testing."
  require 'mongrel'
end

Mongrel::HTTP_STATUS_CODES[220] = "Unspecified success"

def uconvert(one, two, three); FeedParser::uconvert(one, two, three); end
def _ebcdic_to_ascii(one); FeedParser::_ebcdic_to_ascii(one); end

$PORT = 8097 # Not configurable, hard coded in the xml files

def translate_data(data)
  if data[0..3] == "\x4c\x6f\xa7\x94"
    # EBCDIC
    data = _ebcdic_to_ascii(data)
  elsif data[0..3] == "\x00\x3c\x00\x3f"
    # UTF-16BE
    data = uconvert(data, 'utf-16be', 'utf-8')
  elsif data.size >= 4 and data[0..1] == "\xfe\xff" and data[2..3] != "\x00\x00"
    # UTF-16BE with BOM
    data = uconvert(data[2..-1], 'utf-16be', 'utf-8')
  elsif data[0..3] == "\x3c\x00\x3f\x00"
    # UTF-16LE
    data = uconvert(data, 'utf-16le', 'utf-8')
  elsif data.size >=4 and data[0..1] == "\xff\xfe" and data[2..3] != "\x00\x00"
    # UTF-16LE with BOM
    data = uconvert(data[2..-1], 'utf-16le', 'utf-8')
  elsif data[0..3] == "\x00\x00\x00\x3c"
    # UTF-32BE
    data = uconvert(data, 'utf-32be', 'utf-8')
  elsif data[0..3] == "\x3c\x00\x00\x00"
    # UTF-32LE
    data = uconvert(data, 'utf-32le', 'utf-8')
  elsif data[0..3] == "\x00\x00\xfe\xff"
    # UTF-32BE with BOM
    data = uconvert(data[4..-1], 'utf-32BE', 'utf-8')
  elsif data[0..3] == "\xff\xfe\x00\x00"
    # UTF-32LE with BOM
    data = uconvert(data[4..-1], 'utf-32LE', 'utf-8')
  elsif data[0..2] == "\xef\xbb\xbf"
    # UTF-8 with BOM
    data = data[3..-1]
  else
    # ASCII-compatible
  end
  return data
end

def scrape_headers(xmlfile)
  # Called by the server
  xm = open(xmlfile)
  data = xm.read
  htaccess = File.dirname(xmlfile)+"/.htaccess"
  xml_headers = {}
  server_headers = {}
  the_type = nil
  if File.exists? htaccess
    fn = File.split(xm.path)[-1]
    ht_file = open(htaccess)
    type_match = ht_file.read.match(/^\s*<Files\s+#{fn}>\s*\n\s*AddType\s+(.*?)\s+.xml/m)
    the_type = type_match[1].strip.gsub(/^("|')/,'').gsub(/("|')$/,'').strip if type_match and type_match[1]
    if type_match and the_type
      #content_type, charset = type_match[1].split(';')
      server_headers["Content-Type"] = the_type
    end
  end
  data = translate_data(data)
  header_regexp = /^Header:\s*([^:]+)\s*:\s*(.+)\s*$/
  da = data.scan header_regexp
  unless da.nil? or da.empty?
    da.flatten!
    da.each{|e| e.strip!;e.gsub!(/(Content-type|content-type|content-Type)/, "Content-Type")}
    xml_headers = Hash[*da] # Asterisk magic!
  end
  Mongrel::Const::const_set('ETAG_FORMAT', xml_headers['ETag']) unless (xml_headers['ETag'].nil? or xml_headers['ETag'].empty?)
  return xml_headers.merge(server_headers)
end

def scrape_status(xmlfile)
  # Called by the server
  xm = open(xmlfile)
  data = xm.read
  data = translate_data(data)
  da = data.scan /^Status:\s*(.+)\s?$/
  unless da.nil? or da.empty?
    da.flatten!
    da.each{ |e| return e.to_i }
  end
  return 200
end

def scrape_assertion_strings(xmlfile)
  # Called by the testing client
  data = open(xmlfile).read
  data = translate_data(data)
  test = data.scan /Description:\s*(.*?)\s*Expect:\s*(.*)\s*-->/
  description, evalString = test.first.map{ |s| s.strip }

  # Here we translate the expected values in Python to Ruby
  
  # Find Python unicode strings starting with u"
  evalString.gsub!(/\bu'(.*?)'/) do |m| 
    esc = $1.to_s.dup
    # Replace \u hex values with actual Unicode char
    esc.gsub!(/\\u([0-9a-fA-F]{4})/){ |m| [$1.hex].pack('U*') }
    " '"+esc+"'"
  end 
  
  # Find Python unicode strings starting with u"
  evalString.gsub!(/\bu"(.*?)"/) do |m| 
    esc = $1.to_s.dup
    # Replace \u hex values with actual Unicode char
    esc.gsub!(/\\u([0-9a-fA-F]{4})/){ |m| [$1.hex].pack('U*') }
    " \""+esc+"\""
  end
  # The above does the following:               u'string' => 'string'
  #                                             u'ba\u20acha' => 'ba€ha' # Same for double quoted strings

  evalString.gsub!(/\\x([0-9a-fA-F]{2})/){ |m| [$1.hex].pack('U*') } # "ba\xa3la" => "ba£la"
  evalString.gsub! /'\s*:\s+/, "' => "        # {'foo': 'bar'} => {'foo' => 'bar'}
  evalString.gsub! /"\s*:\s+/, "\" => "       # {"foo": 'bar'} => {"foo" => 'bar'}
  evalString.gsub! /\=\s*\((.*?)\)/, '= [\1]' # = (2004, 12, 4) => = [2004, 12, 4]
  evalString.gsub!(/"""(.*?)"""/) do          # """<a b="foo">""" => "<a b=\"foo\">"
    "\""+$1.gsub!(/"/,"\\\"")+"\"" # haha, ugly!
  end
  evalString.gsub! /(\w|\])\s*\=\= 0\s*$/, '\1 == false'   # ] == 0 => ] == false
  evalString.gsub! /(\w|\])\s*\=\= 1\s*$/, '\1 == true'    # ] == 1 => ] == true
  evalString.gsub! /len\((.*?)\)\s*\=\=\s*(\d{1,3})/, '\1.length == \2' # len(ary) == 1 => ary.length == 1
  evalString.gsub! /None/, "nil" # None => nil # well, duh
  return description, evalString
end

def is_invalid(response_status)
  !is_valid(response_status)
end

def is_valid(response_status)
  response_status > 199 && response_status < 300
end

class FeedParserTestRequestHandler < Mongrel::DirHandler 
  def process(request, response)
    req_method = request.params[Mongrel::Const::REQUEST_METHOD] || Mongrel::Const::GET
    req_path = can_serve request.params[Mongrel::Const::PATH_INFO]
    if not req_path
      # not found, return a 404
      response.start(404) do |head, out|
        head['Content-Type'] = 'text/plain'
        out << "File not found"
      end
    else
      begin
        if File.directory? req_path
          send_dir_listing(request.params[Mongrel::Const::REQUEST_URI], req_path, response)
        elsif req_method == Mongrel::Const::HEAD
          response_status = scrape_status(req_path)
          response.start(response_status) do |head,out| 
            xml_head = scrape_headers(req_path)
            xml_head.each_key{|k| head[k] = xml_head[k] }
            
            if is_invalid(response_status)
              head['content-type'] = 'text/plain;'
              out << response_status 
            end
          end

          send_file(req_path, request, response, true) unless is_invalid(response_status)
        elsif req_method == Mongrel::Const::GET
          response_status = scrape_status(req_path)
          response.start(response_status) do |head,out| 
            xml_head = scrape_headers(req_path)
            xml_head.each_key{|k| head[k] = xml_head[k] }
            if is_invalid(response_status)
              head['content-type'] = 'text/plain;'
              out << response_status 
            end
          end

          send_file(req_path, request, response, false) unless is_invalid(response_status)
        else
          response.start(403) { |head,out|
            head['Content-Type'] = 'text/plain'
            out.write(ONLY_HEAD_GET)
          }
        end
      rescue => details
        STDERR.puts "Error sending file #{req_path}: #{details}"
      end
    end
  end
  
  # Overriding the send_file in DirHandler for a goddamn one line bug fix. 
  # Holy shit does this suck.  Changing `response.status = 200` to 
  # `response.status ||= 200`.  Also, adding Mongrel:: in front of the Const
  # because subclassing makes them break.
  def send_file(req_path, request, response, header_only=false)

    stat = File.stat(req_path)

    # Set the last modified times as well and etag for all files
    mtime = stat.mtime
    # Calculated the same as apache, not sure how well the works on win32
    etag = Mongrel::Const::ETAG_FORMAT % [mtime.to_i, stat.size, stat.ino]

    modified_since = request.params[Mongrel::Const::HTTP_IF_MODIFIED_SINCE]
    none_match = request.params[Mongrel::Const::HTTP_IF_NONE_MATCH]

    # test to see if this is a conditional request, and test if
    # the response would be identical to the last response
    same_response = case
                    when modified_since && !last_response_time = Time.httpdate(modified_since) rescue nil : false
                    when modified_since && last_response_time > Time.now                                  : false
                    when modified_since && mtime > last_response_time                                     : false
                    when none_match     && none_match == '*'                                              : false
                    when none_match     && !none_match.strip.split(/\s*,\s*/).include?(etag)              : false
                    else modified_since || none_match  # validation successful if we get this far and at least one of the header exists
                    end

    header = response.header
    header[Mongrel::Const::ETAG] = etag

    if same_response
      response.start(304) {}
    else
      # first we setup the headers and status then we do a very fast send on the socket directly
      response.status ||= 200
      header[Mongrel::Const::LAST_MODIFIED] = mtime.httpdate

      # set the mime type from our map based on the ending
      dot_at = req_path.rindex('.')
      if dot_at
        header[Mongrel::Const::CONTENT_TYPE] = MIME_TYPES[req_path[dot_at .. -1]] || @default_content_type
      else
        header[Mongrel::Const::CONTENT_TYPE] = @default_content_type
      end

      # send a status with out content length
      response.send_status(stat.size)
      response.send_header

      if not header_only
        response.send_file(req_path, stat.size < Mongrel::Const::CHUNK_SIZE * 2)
      end
    end
  end
end
