#!/usr/bin/ruby
require 'html/tree'
require 'test/unit'

module HTMLTree
  class Parser
    attr_reader :currentNode
    attr_reader :rootNode
  end

  module TreeElement
    alias :ch :children 
  end
end

class HTMLTreeParserTestCase < Test::Unit::TestCase
  def setup
    @p = HTMLTree::Parser.new(true, false)
  end

  def rn
    @p.rootNode
  end

  def cn
    @p.currentNode
  end

  attr_reader :p

  def test_empty
    assert_equal(cn, rn)
    assert_equal(nil, cn.parent)
    assert_equal([], rn.children)
  end

  def test_skeleton
    d = rn
    assert_equal(d.class, HTMLTree::Document)
    p.feed('<html></html>')
    assert_equal(d, cn)
    assert_equal(d, rn)
    assert_equal(rn, @p.tree)
    assert_equal(@p.html, @p.tree.html_node)
    assert_equal(@p.html, rn.ch[0])
    assert_equal(1, rn.ch.size)
    assert_equal('', rn.tag)
    assert_equal('html', rn.ch[0].tag)
    assert_equal(d.html_node, rn.ch[0])
  end

  def test_reset
    p.feed('<html><head></head><body attrib1="xxx"></body></html>')
    assert_equal(1, rn.ch.size)
    assert_equal(2, rn.ch[0].ch.size)
    p.reset
    assert_equal(0, rn.ch.size)
    p.feed('<html><head></head><body attrib1="xxx"></body></html>')
    assert_equal(1, rn.ch.size)
    assert_equal(2, rn.ch[0].ch.size)
  end

  def test_skeleton2
    d = rn
    p.feed('<html><head></head><body attrib1="xxx"></body></html>')
    assert_equal(d, cn)
    assert_equal(d, rn)
    assert_equal(1, rn.ch.size)
    h = rn.ch[0]  # html
    assert_equal(d.html_node, h)
    assert_equal('html', h.tag)
    assert_equal(2, h.ch.size)
    assert_equal(0, h.ch[1].ch.size)
    assert_equal(0, h.ch[0].ch.size)
    assert_equal('head', h.ch[0].tag)
    assert_equal('body', h.ch[1].tag)
    assert_equal('xxx', h.ch[1].attribute('attrib1'))
  end

  def test_empty_tag
    d = rn
    p.feed('<html><head></head><body attrib1="xxx"><br></body></html>')
    assert_equal(d, cn)
    h = rn.ch[0]
    assert_equal('html', h.tag)
    assert_equal(2, h.ch.size)
    assert_equal(0, h.ch[0].ch.size)
    assert_equal(1, h.ch[1].ch.size)
    assert_equal('head', h.ch[0].tag)
    assert_equal('body', h.ch[1].tag)
    assert_equal('br', h.ch[1].ch[0].tag)
  end

  def test_no_end_tag
    p.feed("<html><body>Foo<br />bar</body></html>")
    h = rn.ch[0]
    assert_equal('html', h.tag)
    assert_equal('body', h.ch[0].tag)
    assert_equal('br', h.ch[0].ch[1].tag)
    assert_equal({}, h.ch[0].ch[1].attributes)
    assert_equal([], h.ch[0].ch[1].ch)
    assert_equal('Foo', h.ch[0].ch[0].content)
    assert_equal('bar', h.ch[0].ch[2].content)
  end

  def test_content
    d = rn
    p.feed('<html><head></head><body attrib1="xxx"><p>stuff</p></body></html>')
    assert_equal(d, rn)
    assert_equal(d, cn)
    h = rn.ch[0]
    assert_equal('html', h.tag)
    assert_equal(2, h.ch.size) # html => head, body
    assert_equal(0, h.ch[0].ch.size) # head =>
    assert_equal(1, h.ch[1].ch.size) # body=>p
    assert_equal(1, h.ch[1].ch[0].ch.size) #p=>stuff
    assert_equal('head', h.ch[0].tag)
    assert_equal('body', h.ch[1].tag)
    assert_equal('p', h.ch[1].ch[0].tag)
    data = h.ch[1].ch[0].ch[0]  # html/body/p/<data>
    assert_equal(true, data.data?)
    assert_equal('', data.tag)
    assert_equal('stuff', data.to_s)
    assert_equal({}, data.attributes)
  end

  def test_unclosed_li
    p.feed('<html><body><ul><li>Item 1<li>Item 2<li>Item 3</ul></body></html>')
    
    html = rn.ch[0]
    assert_equal('html', html.tag)

    ul = html.ch[0].ch[0]
    assert_equal('ul', ul.tag)

    assert_equal(3, ul.ch.size)
  end

  def test_partial_file
    p.feed("<ul><li>test</li><li>test test</li></ul>")
    li = rn.ch[0]
    assert_equal('ul', li.tag)
    assert_equal(2, li.ch.size)
    assert_equal('li', li.ch[0].tag)
    assert_equal('li', li.ch[1].tag)
  end

  def test_break_nesting
    p.feed('<HTML><BODY><p><ul><LI></ul><p></BODY></HTML>')

    expected = tree("html", 
      tree("body",  tree("p", tree("ul", tree("li"))), tree("p"))
      )
    expected.assert_matches(p.html)
  end

  def test_meta
    p.feed('<html><head><META NAME="robots" CONTENT="noindex,follow"></head><body></body></html>')

    expected = tree("html", 
        tree("head", tree("meta")),
        tree("body"))

    expected.assert_matches(p.html)
  end

  class VerificationTree
    include Test::Unit::Assertions

    def initialize(tag)
      @tag = tag
      @children = []
    end

    def add_children(children)
      @children = children
      self
    end

    def assert_matches(tree)
      assert_equal(@tag, tree.tag)

      assert_equal(tree.elements.collect { |node| node.tag }, @children.collect { |node| node.tag }, tree.path)
      assert_children_matches(@children, tree.elements)
    end

    def assert_children_matches(children, treechildren)
      for i in (0...children.size) do
        children[i].assert_matches(treechildren[i])
      end
    end

    attr_reader :tag
  end

  def tree(tag, *children)
    tree = VerificationTree.new(tag)
    tree.add_children(children)
    tree
  end
end
