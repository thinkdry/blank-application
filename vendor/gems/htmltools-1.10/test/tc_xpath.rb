#!/usr/bin/ruby
# Copyright::   Copyright (C) 2002, Ned Konz <ned@bike-nomad.com>
# License::     Same as Ruby's
# CVS ID:       $Id: tc_xpath.rb,v 1.6 2004/09/10 17:29:37 jhannes Exp $
#
# This is the test file for the HTMLTree XPath interface.
#
require 'html/tree'
require 'html/xpath'
require 'test/unit'
require 'html/rexml-nodepath'


$sample1 = %q{
<html>
  <head>
  </head>
  <body>
  <ul compact="compact">
  <li>An item</li>
  </ul>
  <hr>
  <img src="http://wherever">
  <p class='123'>A &lt; paragraph
  <p class='234'>Another paragraph
  </body>
</html>
}

class XPathTestCase < Test::Unit::TestCase
  attr_accessor :p

  def setup
    @p = HTMLTree::Parser.new(true, true)
  end

  def test_basic
    p.feed("<html></html>")
    t = p.tree
    assert_same(HTMLTree::Document, t.class)
    d = t.as_rexml_document
    assert_same(REXML::Document, d.class)
  end

  def test_match1
    p.feed($sample1)
    d = p.tree.as_rexml_document
    m = d.root.get_elements( '//p' )
    assert_equal(2, m.size)
    assert_equal('p', m.first.name)
  end

  def test_match2
    p.feed($sample1)
    m = match('/html/body/p')
    assert_equal(2, m.size)
    assert_equal('p', m.first.name)
    assert_equal('123', m[0].attributes['class'])
    assert_equal('234', m[1].attributes['class'])
  end

  def test_match_all
    p.feed($sample1)
    html = p.tree.html_node
    m = html.rexml_match('descendant::node()')
    #m.each { |ea| puts ea.full_path + " --> " + ea.to_s }
    assert_equal(11, m.size)
  end
  
  def test_find_by_attribute
    p.feed($sample1)
    assert_equal("Another paragraph", match("/html/body/p[@class = '234']/text()").to_s)
  end
  
  def test_show_attribute
    p.feed("<html><body><ol>" +
      "<li item='1'><a href='http://wrong.com'>test</a></li>" +
      "<li item='2'><a href='http://test.com'>test</a></li>" +
      "<li item='3'><a href='http://wrong.com'>test</a></li>" +
      "</ol></body></html>")
    assert_equal('http://test.com', match("//li[@item = '2']/a/@href")[0].value)
  end

  def match(xpath)
    p.tree.rexml_match(xpath)
  end
end
