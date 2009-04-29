# This module adapts REXML's XPath functionality for use with
# <tt>HTMLTree::Parser</tt>. 
#
# Copyright::   Copyright (C) 2003, Johannes Brodwall <johannes@brodwall.com>, 
#               Copyright (C) 2002, Ned Konz <ned@bike-nomad.com>
# License::     Same as Ruby's
# CVS ID:       $Id: xpath.rb,v 1.3 2004/09/24 23:28:55 jhannes Exp $

require 'html/tree'
require 'rexml/element'
require 'rexml/document'
require 'rexml/xpath'

module HTMLTree

  module TreeElement
    # Given the XPath path, return an Array of matching sub-elements of
    # the REXML tree.
    def rexml_match(path)
      node = as_rexml_document
      REXML::XPath.match(node, path)
    end
  end

  class Element
    # convert the given HTMLTree::Element (or HTMLTree::Document) into
    # a REXML::Element or REXML::Document, ready to use REXML::XPath on.
    # Note that this caches the tree; further changes to my tree will
    # not be reflected in subsequent calls
    def as_rexml_document(rparent = nil, context = {})
      return @_rexml_tree if @_rexml_tree
      node = REXML::Element.new( tag, rparent, context )
      attribute_order().each { |attr|
        node.add_attribute(attr, attribute(attr).to_s)
      }
      children().each { |child|
        childNode = child.as_rexml_document(node, context)
      }
      @_rexml_tree = node
    end
  end

  class Data
    def as_rexml_document(rparent = nil, context = {})
      rparent.add_text(@_content)
    end
  end

  class Comment
    def as_rexml_document(rparent = nil, context = {})
      node = REXML::Comment.new(@_content, parent)
    end
  end

  class Special
    def as_rexml_document(rparent = nil, context = {})
      node = REXML::Instruction.new(@_content,
        context[:respect_whitespace] || false, rparent)
    end
  end

  class Document
    def as_rexml_document(context = {})
      node = REXML::Document.new(nil, context)
      # add DocType
      # add <HTML> node
      html_node.as_rexml_document(node, context)
      node
    end
  end

end
