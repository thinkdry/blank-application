# This module is a mix-in that provides parent/child behavior to real
# Element classes. Because it defines <tt>each()</tt> and includes Enumerable,
# you can iterate through a tree using the usual Enumerable methods.
#
# Copyright::   Copyright (C) 2003, Johannes Brodwall <johannes@brodwall.com>, 
#               Copyright (C) 2002, Ned Konz <ned@bike-nomad.com>
# License::     Same as Ruby's
# CVS ID:       $Id: element.rb,v 1.4 2004/09/24 23:28:55 jhannes Exp $

require 'html/tags'

module HTMLTree
  module TreeElement
    include Enumerable

    protected

    def initialize_tree_element(parent_or_nil = nil, contents_or_nil = nil)
      @_content, @_parent = contents_or_nil, parent_or_nil
      if parent_or_nil
        parent_or_nil.add_child(self)
      end
    end

    attr_accessor :_parent

    public

    # Add one or more children to this node.
    def add_child(*children_to_add)
      if can_have_children?
        children_to_add.each do |child|
          @_content << child
          child._parent = self
        end
      else
        raise(ArgumentError.exception('node cannot have children'))
      end
    end

    alias_method :add_children, :add_child

    # Remove one or more children from this node.
    def remove_child(*children_to_remove)
      if can_have_children?
        children_to_remove.each do |child|
          child._parent = nil if @_content.delete(child)
        end
      else
        raise(ArgumentError.exception('node cannot have children'))
      end
    end

    alias_method :remove_children, :remove_child

    # Change my parent. Disconnects from prior parent, if any.
    def parent=(parent_or_nil)
      @_parent.remove_child(self) if @_parent
      parent_or_nil.add_child(self) if parent_or_nil
    end

    # Return true if my content is a collection of Elements
    # rather than actual data.
    def can_have_children?
      @_content.kind_of?(Array)
    end

    # Return a collection of my children. Returns an empty Array if I am a
    # data element, just to keep other methods simple.
    def children
      can_have_children? ? @_content : []
    end

    # Return my content; either my children or my data.
    def content
      @_content
    end

    # Return my parent element.
    def parent
      @_parent
    end

    def path
      "/"
    end

    # Return the ultimate parent.
    def root
      @_parent ? self : @_parent.root
    end

    # Return true if I have any children.
    def has_children?
      children.size > 0
    end

    # Breadth-first iterator, required by Enumerable.
    def each(&block)
      block.call(self)
      children.each { |ch| ch.each(&block) }
    end

    # Print out to $stdout (or given IO or String)
    # a formatted dump of my structure.
    def dump(indent=0, io=$stdout)
      io << "  " * indent
      io << self.to_s
      io << "\n"
      children.each { |ea| ea.dump(indent+1, io) }
    end

  end

  # This is a Element that represents the whole document (and makes a
  # scope for the DTD declaration)
  class Document
    include TreeElement

    def initialize
      initialize_tree_element(nil, [])
    end

    def to_s
      ''
    end

    def each(&block)
      children.each { |ch| ch.each(&block) }
    end

    def write(io)
      children.each { |t| t.write(io) }
    end

    def tag
      ''
    end

    # Return my child <html> node, if any.
    def html_node
      children.detect { |ea| ea.tag == 'html' }
    end
  end

  # This is a TreeElement that represents tagged items in an HTML
  # document.
  class Element
    include TreeElement

    protected

    # parent_or_nil::   TreeElement or nil
    # tag_name::        String
    def initialize(parent_or_nil = nil, tag_name = nil)
      initialize_tree_element(parent_or_nil, [])
      @_tag = tag_name
      @_attributes = {}
      @_attribute_order = []
    end

    public

    def can_have_children?; true; end

    # Return true if I'm data instead of a tag
    def data?; false; end

    def to_s
      a = [ "<", tag ]
      @_attribute_order.each { |k|
        v = @_attributes[k]
        a << " #{k.to_s}=\"#{v.to_s}\""
      }
      a << ">"
      a.join('')
    end

    # Append an attribute. <tt>values</tt> are first flattened into an Array,
    # then converted into strings.
    #
    # If there is a single attribute value, it will appear as a String,
    # otherwise it will be an Array of Strings.
    #
    # Example:
    #   element.add_attribute("width", "123")
    #   element.add_attribute("value", [ "a", "b" ])
    def add_attribute(name, *values)
      values = values.flatten.collect { |ea| ea.to_s.strip }
      name = name.downcase
      if @_attributes.include?(name)
        @_attributes[name] = @_attributes[name].to_a + values
      else
        @_attributes[name] = values.size > 1 ? values : values[0]
      end
      @_attribute_order << name
      self
    end

    # Return my tag (should be a String)
    def tag; @_tag; end

    # Return an HTML::Tag for further information, or nil if this is an
    # unknown tag.
    def tag_info
      begin
        HTML::Tag.named(@_tag)
      rescue NoSuchHTMLTagError
        nil
      end
    end

    # Return the path to this element from the root
    def path
      path = []
      node = self
      while node do
        path.unshift node.tag
        node = node.parent
      end
      path.join(".")
    end

    def show_structure(indent = 0)
      puts(' ' * indent) + path
      elements.each { |node| node.show_structure(indent + 2) }
      nil
    end

    # Return the children of this node that are elements (not data)
    def elements
      children.select { |node| node.is_a? Element }
    end

    # Return my attributes Hash.
    def attributes; @_attributes; end

    # Return the order of my attributes
    def attribute_order; @_attribute_order; end

    # Return the value of a single attribute (a String or Array).
    def attribute(name); @_attributes[name]; end

    # Return the value of a single attribute (a String or Array).
    def [](name); attribute(name); end

    # Replace an attribute.
    def []=(name, *values)
      @_attributes[name] = values.size > 1 ? values : values[0]
      @_attribute_order.delete(name)
      self
    end

    # Print me (and my descendents) on the given IO stream.
    def write(io)
      io << self
      children.each { |t| t.write(io) }
      unless tag_info.is_empty_element
        io.puts( "</#{tag()}>" )
      end
    end

  end

  # This is a TreeElement that represents leaf data nodes (CDATA, scripts,
  # comments, processing directives). It forwards unknown messages to the
  # content element, so it otherwise behaves like a String.
  class Data
    include TreeElement

    protected 

    # parent_or_nil:: parent, TreeElement or nil
    # str:: contents, String
    def initialize(parent_or_nil = nil, str = '')
      initialize_tree_element(parent_or_nil, str)
    end

    public

    # Return true because I am a data Element.
    def data?; true; end

    # Return false because I have no children.
    def can_have_children?; false; end

    # Return an empty collection because I have no children.
    def children; []; end

    # Return my (empty) tag String.
    def tag; ''; end

    # Return my (empty) attributes Hash.
    def attributes; {}; end

    def to_s
      @_content
    end

    # Print me on the given IO stream.
    def write(io)
      io << self
    end

    # Forward all other methods to my content, so I can otherwise behave
    # like a String.
    def method_missing(sym, *args)
      @_content.method(sym).call(*args)
    end
  end

  class Comment < Data
    def to_s
      '<!--' + @_content + '-->'
    end
  end

  class Special < Data
    def to_s
      '<' + @_content + '>'
    end
  end
end
