# $Id: tc_source-parser.rb,v 1.3 2006/07/24 09:28:19 Philip Dorrell Exp $

require 'html/stparser'
require 'test/unit'

class TestSourceParser < HTML::SGMLParser
 def initialize(verbose, test_case)
   super(verbose)
   @test_case = test_case
   @fulldata = ""
 end
 attr_reader :test_case

 def feed(data)
   @fulldata = @fulldata + data
   super(data)
 end

 def last_src
   return @fulldata[src_range]
 end

 def warn(msg); test_case.callback('warn', msg); end

 def handle_starttag(tag, method, attrs); test_case.callback('starttag', last_src); end
 def unknown_starttag(tag, attrs); test_case.callback('starttag', last_src); end
 def handle_endtag(tag, method); test_case.callback('endtag', last_src); end
 def unknown_endtag(tag); test_case.callback('endtag', last_src); end
 def handle_charref(name); test_case.callback('charref', last_src); end
 def handle_entityref(name); test_case.callback('entityref', last_src); end
 def handle_data(data); test_case.callback('data', last_src); end
 def handle_comment(data); test_case.callback('comment', last_src); end
 def handle_special(data); test_case.callback('special', last_src); end
end

class SourceParserTestCase < Test::Unit::TestCase

 def setup
   @parser = TestSourceParser.new(true, self)
   @callbacks = []
 end

 def callback(*stuff)
   @callbacks << stuff
 end

 attr_reader :parser
 attr_reader :callbacks

 # run the given block and return the callbacks if any
 def callbacks_from
   @callbacks = []
   yield
   #show_callbacks
   @callbacks
 end

 def show_callbacks
   puts "Callbacks: "
   @callbacks.each do |callback|
     puts " [#{callback[0]}: \"#{callback[1]}\"]"
   end
 end

 def test_empty_html
   cbs = callbacks_from { parser.feed('<html>') }
   assert_equal(1, cbs.size, "cbs is #{cbs.inspect}")
   assert_equal(['starttag', '<html>'], cbs[0])

   cbs = callbacks_from{ parser.feed('</html>') }
   assert_equal(1, cbs.size, "cbs is #{cbs.inspect}")
   assert_equal(['endtag', '</html>'], cbs[0])
 end

 def test_attribs
   cbs = callbacks_from {
     parser.feed('<html><body bgcolor="#ffffff" width="123"><p>Fred</p></body></html>')
   }
   assert_equal(7, cbs.size, "cbs is #{cbs.inspect}")
   assert_equal(['starttag', '<html>'], cbs[0])
   assert_equal(['starttag', '<body bgcolor="#ffffff" width="123">'], cbs[1])
   assert_equal(['data', "Fred"], cbs[3])
   assert_equal(['endtag', '</body>'], cbs[5])
 end

 # FIXME should we insert <p> tags here?
 def test_no_para_tags_in_body
   cbs = callbacks_from { parser.feed('<html><body>Fred</body></html>') }
   assert_equal(5, cbs.size, "cbs is #{cbs.inspect}")
   assert_equal(['endtag', '</body>'], cbs[3])
 end

 def test_empty_tag
   cbs = callbacks_from { parser.feed('<html><body><img src="whatever"></body></html>') }
   assert_equal(5, cbs.size, "cbs is #{cbs.inspect}")
   assert_equal(["starttag", '<img src="whatever">'], cbs[2])
 end

 def test_data
   cbs = callbacks_from { parser.feed('<html><body><p>Data1</p><br><p>More_data</p></body></html>') }
   assert_equal(11, cbs.size, "cbs is #{cbs.inspect}")
   assert_equal(["data", "Data1"], cbs[3])
   assert_equal(["data", "More_data"], cbs[7])
 end

 def test_whitespace_stripping
   cbs = callbacks_from { parser.feed('<html><body><p>  Data1  ') }
   assert_equal(4, cbs.size, "cbs is #{cbs.inspect}")
   assert_equal(["data", "  Data1  "], cbs[3])

   cbs = callbacks_from { parser.feed('</p><p>  Data2  </p></body></html>') }
   assert_equal(6, cbs.size, "cbs is #{cbs.inspect}")
   assert_equal(["data", "  Data2  "], cbs[2])
 end

 def test_script
   cbs = callbacks_from { parser.feed <<EOS
<html><body>
<script type="text/javascript" language="Java_script">
<!--
var page_name = "Page_view_item";
//-->
</script>
</body></html>
EOS
   }
   assert_equal(12, cbs.size, "cbs is #{cbs.inspect}")
   assert_equal(["starttag", '<script type="text/javascript" language="Java_script">'], cbs[3]);
   assert_equal(["endtag", "</script>"], cbs[7])
 end

 def test_unknown_character
   cbs = callbacks_from { parser.feed('<html><body>&#12345;</body></html>') }
   assert_equal(5, cbs.size, "cbs is #{cbs.inspect}")
   assert_equal(["charref", "&#12345;"], cbs[2])
 end

 def test_unknown_entity
   cbs = callbacks_from { parser.feed('<html><body>&fred;</body></html>') }
   assert_equal(5, cbs.size, "cbs is #{cbs.inspect}")
   assert_equal(["entityref", "&fred;"], cbs[2])
 end

 def test_comment
   cbs = callbacks_from { parser.feed('<html><body><!--  comment here --></body></html>') }
   assert_equal(5, cbs.size, "cbs is #{cbs.inspect}")
   assert_equal(["comment", "<!--  comment here -->"], cbs[2])
 end

 #TODO is this right (w/the !)?
 def test_special
   cbs = callbacks_from { parser.feed <<EOS
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html><body></body></html>
EOS
   }
   assert_equal(7, cbs.size, "cbs is #{cbs.inspect}")
   assert_equal(["special", '<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">'], cbs[0])
 end
end