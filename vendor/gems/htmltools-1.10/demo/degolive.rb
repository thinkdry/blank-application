#!c:/ruby-1.8/bin/ruby
# This removes GoLive tags and attributes.
#
# usage:
#   ruby degolive.rb \<file> > <file>
#
# or (changes the file in place and saves the originals as .bak):
#   ruby -i.bak degolive.rb files
#
# Copyright:: Copyright (C) 2002 Ned Konz
# License::   Ruby License
# CVS ID::    $Id: degolive.rb,v 1.1 2003/09/12 18:41:04 jhannes Exp $
#
require 'html/tags'
require 'html/stparser'

# Add nasty GoLive tags so we can remove them
#                (name,      is_block, is_inline, is_empty, can_omit)
HTML::Tag.add_tag('CSACTIONS',    true,   false,  false,  false)
HTML::Tag.add_tag('CSACTION',     false,  true,   true,   false)
HTML::Tag.add_tag('CSSCRIPTDICT', true,   false,  false,  false)
HTML::Tag.add_tag('CSACTIONDICT', true,   false,  false,  false)

class GoLiveRemover < HTML::StackingParser
  # return true if we are in the scope of a bad tag
  def ignoring(tag=nil)
    (tag and tag =~ /^cs[as]/i) or
    last_tag =~ /^cs[as]/i or
    parent_tag =~ /^cs[as]/i
  end

  def printTag(tag, isStart=false, attrs=nil)
    print(isStart ? "<" : "</")
    print tag
    if attrs
      attrs.each { |a|
        # Also need to remove 'csclick="..."'
        # and on.*="CSAction(..." attribs
        print " #{a[0]}=\"#{a[1]}\"" \
          unless a[0] == "csclick" or (a[1] || '') =~ /^CSAction\(/
      }
    end
    print(">")
  end

  def handle_start_tag(tag, attrs)
    printTag(tag, true, attrs) unless ignoring(tag)
  end

  def handle_empty_tag(tag, attrs)
    printTag(tag, true, attrs) unless ignoring(tag)
  end

  def handle_end_tag(tag)
    printTag(tag, false) unless ignoring(tag)
  end

  def handle_missing_end_tag(tag)
    warn("warning: inserting missing end tag </#{tag}>\n")
    print("</#{tag}><!-- inserted -->")
  end

  def handle_data(data)
    print(data)  unless ignoring
  end

  def handle_script(data)
    print(data) unless ignoring
  end

  def handle_unknown_character(name)
    print("&\##{name};") unless ignoring
  end

  def handle_unknown_entity(name)
    print("&#{name};") unless ignoring
  end

  def handle_comment(data)
    print(data) unless ignoring
  end

  def handle_special(data)
    print(data) unless ignoring
  end
end

p = GoLiveRemover.new(true, true)
ARGF.each_line { |line| p.feed(line) }
