#!/usr/bin/ruby
# This is an HTML parser that builds an element tree for further
# processing. Attributes and data are also stored.
#
# Typical usage is:
#   parser = HTMLTree::Parser.new(false, false)
#   parser.parse_file_named('whatever.html')
#   # then you have the tree built..
#   parser.tree.dump
#
# Copyright::   Copyright (C) 2003, Johannes Brodwall <johannes@brodwall.com>, 
#               Copyright (C) 2002, Ned Konz <ned@bike-nomad.com>
# License::   Ruby's
# CVS ID::    $Id: tree.rb,v 1.2 2004/09/24 23:28:55 jhannes Exp $

require 'html/tags'
require 'html/stparser'
require 'html/element'

# This is a tree building HTML parser.
module HTMLTree
  class Parser < HTML::StackingParser

    # verbose::  if true, will warn to $stderr on unknown
    # tags/entities/characters, as well as missing end tags and extra end
    # tags.
    # strip_white:: if true, remove all non-essential whitespace. Note
    # that there are browser bugs that may cause this to change the
    # appearance of HTML (even though it shouldn't by the standard).
    def initialize(verbose=false, strip_white=true)
      super
      reset
    end

    # Reset this parser so that it can parse a new document.
    def reset
      super
      @rootNode = @currentNode = Document.new
    end

    # Return the tree that was built. This will be an HTMLTree::Element that
    # represents the whole document. The \<html> node is a child of this.
    def tree
      @rootNode
    end

    # Return the <html> node, if any.
    def html
      @rootNode.html_node()
    end

    # no user-serviceable parts inside...
    # though you can subclass carefully.
    private

    def add_child_to_current(tag, attrs)
      node = Element.new(@currentNode, tag)
      attrs.each { |a| node.add_attribute(*a) }
      node
    end

    # callbacks

    # add a child to the current node and descend
    def handle_start_tag(tag, attrs)
      node = add_child_to_current(tag, attrs)
      @rootNode = node unless @rootNode
      @currentNode = node
    end

    # go up to parent
    def handle_end_tag(tag)
      @currentNode = @currentNode.parent
    end

    # add a child to the current node
    def handle_empty_tag(tag, attrs)
      add_child_to_current(tag, attrs)
    end

    # Add a child to the current node and descend
    # Assume that the unknown tag has an end tag.
    def handle_unknown_tag(tag, attrs)
      super
      handle_start_tag(tag, attrs)
    end

    # go up to parent
    def handle_missing_end_tag(tag)
      super
      handle_end_tag(tag)
    end

    # ignore
    def handle_extra_end_tag(tag)
      super
    end

    def handle_cdata(data)
      node = Data.new(@currentNode, data)
    end

    def handle_script(data)
      node = Data.new(@currentNode, data)
    end

    def handle_unknown_character(name)
      node = Data.new(@currentNode, "&##{name};")
    end

    def handle_unknown_entity(name)
      node = Data.new(@currentNode, "&#{name};")
    end

    def handle_comment(data)
      super # make sure and strip whitespace.
      node = Comment.new(@currentNode, data)
    end

    def handle_special(data)
      node = HTMLTree::Special.new(@currentNode, data)
      $stderr.print('special ', node, ' discarded') unless @currentNode
    end

  end
end

if $0 == __FILE__
  $stdout.sync = true

  class TestStackingParser < HTMLTree::Parser
    $DEBUG = false
    p = TestStackingParser.new(true, false)
    p.parse_file_named(ARGV[0] || 'ebay.html')
    File.open('xx.html', 'w') { |of|
      p.tree.write(of)
    }
    p.tree.dump
  end
end
