# This is an SGMLParser subclass that knows about HTML 4.0 rules
# and can spot empty tags and deal with tags that may have omitted endtags.
#
# Copyright::   Copyright (C) 2003, Johannes Brodwall <johannes@brodwall.com>, 
#               Copyright (C) 2002, Ned Konz <ned@bike-nomad.com>
# License::   Ruby's License
# CVS ID::    $Id: stparser.rb,v 1.4 2004/09/24 23:28:55 jhannes Exp $

require 'html/sgml-parser'
require 'html/tags'

module HTML
  class StackingParser < SGMLParser
    # accessors

    def stack; @tagStack; end

    def last_tag; @tagStack[-1] || 'html'; end

    def parent_tag; @tagStack[-2] || 'html'; end

    def strip_whitespace=(flag); @stripWhitespace = flag; end

    # input methods

    # Open and parse the given file.
    def parse_file_named(name)
      File.open(name) { |f|
        while bytes = f.read(65536)
          feed(bytes)
        end
      }
    end

    # Feed some more data to the parser.
    def feed(string)
      super
      while @saved.size > 0
        saved = @saved
        @saved = ''
        super(saved)
      end
    end

    # available only to subclasses
    private

    if $DEBUG
      def dprint(*stuff)
        print(("  " * @tagStack.size), stuff) if @verbose
      end
    else
      def dprint(*stuff); end
    end

    def warn(msg)
      $stderr.print(msg) if @verbose
    end

    def initialize(verbose=false, strip_white=false)
      super(verbose)
      @tagStack = []
      @saved = ''
      @stripWhitespace = strip_white
    end

    # handle_data will call this.
    def skip_script(data)
      # is the end of the script in this buffer?
      if m = data.index(%r{</[A-Za-z]})
        @nomoretags = false
        @saved = data[m..-1]
        handle_script(data[0,m]) # call user handler
      else
        handle_script(data)
      end
    end

    # Unfortunately, sgml-parser calls this and there's important work to do in
    # it. So the user handler has to be named something different.
    def handle_data(data)
      # need to handle scripts
      if last_tag() == 'script' && @nomoretags
        skip_script(data)
      else
        if @stripWhitespace
          begin
            data.strip! if HTML::Tag.named(last_tag()).can_ignore_whitespace
          rescue NoSuchHTMLTagError
            data.strip!
          end
        end
        handle_cdata(data)  if data.size > 0 # call user handler
      end
    end

    def finish_starttag(tag, attrs)
      dprint "*START* #{tag} #{attrs.inspect}\n"
      # dprint "-START- #{tag}\n"
      begin
        unless HTML::Tag.named(last_tag()).can_contain(tag, parent_tag())
          dprint "-INSERT-\n"
          finish_endtag(last_tag())
        end
      rescue NoSuchHTMLTagError
        # hmm.. last_tag was unknown.
        # Assume it doesn't have an optional endtag.
      end

      push(tag)

      begin
        if HTML::Tag.named(tag).is_empty_element
          dprint "-EMPTY-\n"
          handle_empty_tag(tag, attrs)  # call user handler
          drop_to_tag(tag)
        else
          handle_start_tag(tag, attrs)  # call user handler
        end

        if tag.downcase == 'script'
          @nomoretags = true
        end
      rescue NoSuchHTMLTagError
        # hmm... the start tag is unknown.
        # And we pushed it.
        # If it's empty, we'll get rid of it at the next end tag.
        handle_unknown_tag(tag, attrs)
      end
    end

    # return true if tag is not extra
    def drop_to_tag(tag)
      dropped = @tagStack.size - (@tagStack.rindex(tag.downcase) || @tagStack.size)
      if dropped == 0   # got an end tag but we haven't seen start tag?
        handle_extra_end_tag(tag)  # call user handler
        return false
      end
      dropped.times do
        begin
          # detect missing end tag
          if last_tag != tag and ! HTML::Tag.named(last_tag).can_omit_end_tag
            handle_missing_end_tag(last_tag)  # call user handler
          elsif last_tag != tag
            handle_end_tag(last_tag)
          end
        rescue NoSuchHTMLTagError
          # oops, don't recognize last_tag.
        end
        pop
      end
      return true
    end

    def finish_endtag(tag)
      dprint "*END* #{tag}\n"
      if drop_to_tag(tag)
        dprint "-END- #{tag} #{@tagStack.inspect}\n"
        handle_end_tag(tag) # call user handler
      end
    end

    def push(tag)
      @tagStack.push(tag.downcase)
      dprint "*PUSH* #{tag} => #{@tagStack.inspect}\n"
    end

    def pop
      tag = @tagStack.pop
      dprint "*POP*  #{tag} => #{@tagStack.inspect}\n"
      tag
    end

    def unknown_charref(name)
      handle_unknown_character(name)
    end

    def unknown_entityref(name)
      handle_unknown_entity(name)
    end

    # callbacks: can be overridden in subclasses

    def handle_start_tag(tag, attrs)
    end

    def handle_end_tag(tag)
    end

    # by default, an empty tag is handled as a start tag
    # with an inserted end tag.
    def handle_empty_tag(tag, attrs)
      handle_start_tag(tag, attrs)
      handle_end_tag(tag)
    end

    def handle_unknown_tag(tag, attrs)
      warn("warning: unknown tag #{tag}\n")
    end

    def handle_missing_end_tag(tag)
      warn("warning: missing end tag </#{tag}>\n")
    end

    def handle_extra_end_tag(tag)
      warn("warning: extra end tag </#{tag}>\n")
    end

    def handle_cdata(data)
    end

    def handle_script(data)
    end

    def handle_unknown_character(name)
    end

    def handle_unknown_entity(name)
    end

    # call super if you want the data stripped
    def handle_comment(data)
      data.strip! if @stripWhitespace
    end

    def handle_special(data)
    end

  end
end

# test script
if $0 == __FILE__
  $stdout.sync = true

  class TestStackingParser < HTML::StackingParser
    def dump_stack
      stack.each { |ea| print ea, '/' }
    end
    def handle_start_tag(tag, attrs)
      print("START: #{tag} #{attrs.inspect}\n")
    end
    def handle_end_tag(tag)
      # print("END: #{tag}\n")
    end
    def handle_empty_tag(tag, attrs)
      # print("EMPTY: #{tag} #{attrs.inspect}\n")
    end
    def handle_cdata(data)
      # print("DATA: #{data.size} chars\n")
      if last_tag() != 'style'
        str = data.strip
        if str.size > 0
          dump_stack
          print(str.inspect, "\n")
        end
      end
    end
    def handle_script(data)
      # print("SCRIPT: #{data.size} chars\n")
    end
    def handle_unknown_character(name)
      print("UNKC: #{name}\n")
    end
    def handle_unknown_entity(name)
      print("UNKE: #{name}\n")
    end
    def handle_comment(data)
      super
      print("COMMENT: #{data}\n")
    end
    def handle_special(data)
      print("SPECIAL: #{data}\n")
    end
  end

  $DEBUG = false
  p = TestStackingParser.new(true)
  p.parse_file_named(ARGV[0] || 'ebay.html')
end
