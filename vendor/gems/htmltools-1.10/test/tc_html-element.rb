#!/usr/bin/ruby
require 'html/element'
require 'test/unit'

module HTMLTree
  class Element
    def inspect
      "<#{@_tag}> " + attributes.inspect + children.inspect
    end
  end
end

class HTMLElementTestCase < Test::Unit::TestCase
  def setup
    @e = HTMLTree::Element.new
  end

  attr_reader :e

  def test_empty
    assert_equal(nil, e.tag)
    assert_equal({}, e.attributes)
    assert_equal([], e.children)
  end

  def test_tag
    e2 = HTMLTree::Element.new(nil, 'sometag')
    assert_equal('sometag', e2.tag)
    assert_equal({}, e2.attributes)
    assert_equal([], e2.children)
  end

  def test_attribute
    e.add_attribute('a', 'b')
    assert_equal('b', e.attribute('a'))
    assert_equal('b', e['a'])
    e.add_attribute('a', 'c')
    assert_equal(['b','c'], e.attribute('a'))
    assert_equal(['b','c'], e['a'])
    e.add_attribute('a', 'd', 'e')
    assert_equal(['b','c', 'd', 'e'], e.attribute('a'))
    e.add_attribute('b', ['c','d'])
    assert_equal(['c','d'], e.attribute('b'))
    e.add_attribute('b', ['e','f'])
    assert_equal(['c','d', 'e', 'f'], e.attribute('b'))
    e['b'] = 'aaa'
    assert_equal('aaa', e.attribute('b'))
  end

  def test_parent
    p = HTMLTree::Element.new(nil, 'p')

    c = HTMLTree::Element.new(p, 'c')
    assert_equal(nil, p.parent)
    assert_equal([c], p.children)
    assert_equal(p, c.parent)

    d = HTMLTree::Element.new(p, 'd')
    assert_equal([c,d], p.children)
    assert_equal(p, d.parent)

    p.remove_child(d)
    assert_equal([c], p.children)
    assert_equal(p, c.parent)
    assert_equal(nil, d.parent)
  end

  def test_iterator
    p = HTMLTree::Element.new(nil, 'p')
    c = HTMLTree::Element.new(p, 'c')
    d = HTMLTree::Element.new(p, 'd')
  end
end
