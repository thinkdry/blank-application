# Test cases for html-tree.rb
# Copyright (C) 2002 Ned Konz <ned@bike-nomad.com>
# License: Ruby's
# $Id: tc_stacking-parser.rb,v 1.4 2004/02/10 21:36:31 jhannes Exp $

require 'html/stparser'
require 'test/unit'

class TestStackingParser < HTML::StackingParser
  def initialize(verbose, test_case)
    super(verbose)
    @test_case = test_case
  end
  attr_reader :test_case

  def warn(msg); test_case.callback('warn', msg); end

  def handle_comment(data); super; test_case.callback('comment', data); end
  def handle_cdata(data); test_case.callback('data', data); end
  def handle_start_tag(tag, attrs); test_case.callback('start_tag', tag, attrs); end
  def handle_end_tag(tag); test_case.callback('end_tag', tag); end
  def handle_empty_tag(tag, attrs); test_case.callback('empty_tag', tag, attrs); end
  def handle_unknown_tag(tag, attrs); test_case.callback('unknown_tag', tag, attrs); end
  def handle_missing_end_tag(tag); test_case.callback('missing_end_tag', tag); end;
  def handle_extra_end_tag(tag); test_case.callback('extra_end_tag', tag); end
  def handle_script(data); test_case.callback('script', data); end
  def handle_unknown_character(name); test_case.callback('unknown_character', name); end
  def handle_unknown_entity(name); test_case.callback('unknown_entity', name); end
  def handle_special(data); test_case.callback('special', data); end
end

class StackingParserTestCase < Test::Unit::TestCase

  def setup
    @parser = TestStackingParser.new(true, self)
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
    @callbacks
  end

  def test_empty_stack
    # test stack empty at first
    assert(parser.stack.empty?)
    # test last_tag and parent_tag don't blow up with empty stack
    assert_equal('html', parser.last_tag)
    assert_equal('html', parser.parent_tag)
  end

  def test_empty_html
    cbs = callbacks_from { parser.feed('<html>') }
    assert_same(false, parser.stack.empty?)
    assert_equal('html', parser.last_tag)
    assert_equal('html', parser.parent_tag)
    assert_equal(1, cbs.size, "cbs is #{cbs.inspect}")
    assert_equal(['start_tag', 'html', []], cbs[0])

    cbs = callbacks_from{ parser.feed('</html>') }
    assert(parser.stack.empty?)
    assert_equal(1, cbs.size, "cbs is #{cbs.inspect}")
    assert_equal(['end_tag', 'html'], cbs[0])
  end

  def test_attribs
    cbs = callbacks_from {
      parser.feed('<html><body bgcolor="#ffffff" width="123"><p>Fred</p></body></html>')
    }
    assert_same(true, parser.stack.empty?)
    assert_equal(7, cbs.size, "cbs is #{cbs.inspect}")
    assert_equal(['start_tag', 'html', []], cbs[0])
    assert_equal(["start_tag", "body", [["bgcolor", "#ffffff"], ["width", "123"]]], cbs[1])
    assert_equal(['data', "Fred"], cbs[3])
  end

  # FIXME should we insert <p> tags here?
  def test_no_para_tags_in_body
    cbs = callbacks_from { parser.feed('<html><body>Fred</body></html>') }
    assert_equal(true, parser.stack.empty?)
    assert_equal(5, cbs.size, "cbs is #{cbs.inspect}")
    assert_equal(['data', 'Fred'], cbs[2])
  end

  def test_empty_tag
    cbs = callbacks_from { parser.feed('<html><body><img src="whatever"></body></html>') }
    assert_equal(true, parser.stack.empty?)
    assert_equal(5, cbs.size, "cbs is #{cbs.inspect}")
    assert_equal(["empty_tag", "img", [["src", "whatever"]]], cbs[2])
  end

  def test_unknown_tag
    cbs = callbacks_from { parser.feed('<html><body><froobzle a="b"></froobzle></body></html>') }
    assert_equal(true, parser.stack.empty?)
    assert_equal(6, cbs.size, "cbs is #{cbs.inspect}")
    assert_equal(["unknown_tag", "froobzle", [["a", "b"]]], cbs[2])
  end

  def test_missing_end_tag
    cbs = callbacks_from { parser.feed('<html><body><div></body></html>') }
    assert_equal(true, parser.stack.empty?)
    assert_equal(6, cbs.size, "cbs is #{cbs.inspect}")
    assert_equal(["missing_end_tag", "div"], cbs[3])
  end

  def test_extra_end_tag
    cbs = callbacks_from { parser.feed('<html><body></body></body></html>') }
    assert_equal(true, parser.stack.empty?)
    assert_equal(5, cbs.size, "cbs is #{cbs.inspect}")
    assert_equal(["extra_end_tag", "body"], cbs[3])
  end

  def test_data
    cbs = callbacks_from { parser.feed('<html><body><p>Data1</p><br><p>More_data</p></body></html>') }
    assert_equal(true, parser.stack.empty?)
    assert_equal(11, cbs.size, "cbs is #{cbs.inspect}")
    assert_equal(["data", "Data1"], cbs[3])
    assert_equal(["data", "More_data"], cbs[7])
  end

  def test_whitespace_stripping
    parser.strip_whitespace = false
    cbs = callbacks_from { parser.feed('<html><body><p>  Data1  ') }
    assert_equal(4, cbs.size, "cbs is #{cbs.inspect}")
    assert_equal(["data", "  Data1  "], cbs[3])

    parser.strip_whitespace = true
    cbs = callbacks_from { parser.feed('</p><p>  Data2  </p></body></html>') }
    assert_equal(6, cbs.size, "cbs is #{cbs.inspect}")
    assert_equal(["data", "Data2"], cbs[2])
    assert_equal(true, parser.stack.empty?)
  end

  def test_script
    parser.strip_whitespace = true
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
    assert_equal([], parser.stack)
    assert_equal(true, parser.stack.empty?)
    assert_equal(7, cbs.size, "cbs is #{cbs.inspect}")
    assert_equal(["start_tag", "script",
      [["type", "text/javascript"], ["language", "Java_script"]]], cbs[2])
    assert_equal(["script", "\n<!--\nvar page_name = \"Page_view_item\";\n//-->\n"], cbs[3])
    assert_equal(["end_tag", "script"], cbs[4])
  end

  def test_unknown_character
    cbs = callbacks_from { parser.feed('<html><body>&#12345;</body></html>') }
    assert_equal(5, cbs.size, "cbs is #{cbs.inspect}")
    assert_equal(["unknown_character", "12345"], cbs[2])
  end

  def test_unknown_entity
    cbs = callbacks_from { parser.feed('<html><body>&fred;</body></html>') }
    assert_equal(5, cbs.size, "cbs is #{cbs.inspect}")
    assert_equal(["unknown_entity", "fred"], cbs[2])
  end

  def test_comment
    parser.strip_whitespace = true
    cbs = callbacks_from { parser.feed('<html><body><!--  comment here --></body></html>') }
    assert_equal(5, cbs.size, "cbs is #{cbs.inspect}")
    assert_equal(["comment", "comment here"], cbs[2])
  end

  #TODO is this right (w/the !)?
  def test_special
    parser.strip_whitespace = true
    cbs = callbacks_from { parser.feed <<EOS
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html><body></body></html>
EOS
    }
    assert_equal(5, cbs.size, "cbs is #{cbs.inspect}")
    assert_equal(["special", '!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN"'], cbs[0])
  end
end

$stdout.sync = true
