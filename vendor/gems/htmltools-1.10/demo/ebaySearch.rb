require 'html/tree'
require 'net/http'

# A demo script showing HTML parsing after a HTTP request.
# This does an eBay search for the given term(s), and displays the
# results as a text table, delimited with '|' characters.
#
# usage:
#   ruby ebaySearch.rb searchterm [...]
#
# If you give the -d flag, it contacts http://localhost:8080 instead
# (for testing).
#
# Note that actually using this script is in violation of the
# eBay User Agreement.
#
# A real robot would respect the REP.
#
# This is just an example.

verbose = false
if ARGV[0] == '-v'
  verbose = true
  ARGV.shift 
end

unless ARGV.size > 0
  puts "usage: #{$0} [-v] searchterm [...]"
  puts "  -v  turns on verbose error reporting"
  exit 2
end

query = ARGV.join('+')

queryHost = "search.ebay.com"
queryPort = 80
queryURL = "/search/search.dll" +
  "?MfcISAPICommand=GetResult&ht=1&SortProperty=MetaEndSort&query=#{query}"

# try to look like a real browser (don't know if it matters)...
headers = {
  'User-Agent' => 'Mozilla/5.0 (compatible; Konqueror/3.0.0-10; Linux)',
  'Pragma' => 'no-cache',
  'Cache-control' => 'no-cache',
  'Accept' => 'text/*, image/jpeg, image/png, image/*, */*',
  'Accept-Encoding' => 'x-gzip, gzip, identity',
  'Accept-Charset' => 'ISO-8859-1',
}

data = ""

# add these non-HTML 4.0 tags because eBay seems to use them
#                (name,      is_block, is_inline, is_empty, can_omit)
HTML::Tag.add_tag('ilayer', true, false, true, true)
HTML::Tag.add_tag('layer', true, false, true, true)
HTML::Tag.add_tag('nolayer', true, false, true, true)
HTML::Tag.add_tag('noframe', true, false, false, false)

begin
  Net::HTTP.version_1_1
  http = Net::HTTP.new(queryHost, queryPort)
  # http.open_timeout = 30
  http.read_timeout = 120
  resp, data = http.get(queryURL, headers)
rescue
  print 'error:'
  puts http.inspect
  puts resp.inspect
  exit 1
end


p = HTMLTree::Parser.new(verbose, false)
p.feed(data)

# Find all ViewItem links. These are in table rows for each item.
itemAnchors = p.html.select { |ea| ea.tag == 'a' && ea['href'] =~ /ViewItem/ }

# Now find their rows by going up to the first <tr>
itemRows = itemAnchors.collect { |ea|
  while ea.tag != 'tr'
    ea = ea.parent
  end
  ea
}

# print the text from them
itemRows.each { |row|
  texts = row.select { |item| item.data?  }.  # just look at cdata
    collect { |data| data.strip }.            # strip it
    select { |data| data.size > 0 }           # and keep the non-blank fields
  puts texts.join('|')
}
