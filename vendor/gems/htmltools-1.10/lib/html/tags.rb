# This encodes the knowledge of HTML 4.0 tags for a parser.
# It knows about block vs. inline tags, empty tags, and optionally
# omitted end tags.
#
# Copyright::   Copyright (C) 2003, Johannes Brodwall <johannes@brodwall.com>, 
#               Copyright (C) 2002, Ned Konz <ned@bike-nomad.com>
# License::   Ruby's license
# CVS ID::    $Id: tags.rb,v 1.4 2004/09/24 23:28:55 jhannes Exp $

# This is an error raised by <tt>HTML::Tag.named()</tt> when a tag doesn't exist.
class NoSuchHTMLTagError < RuntimeError
end

# This is the base class for all the HTML tag classes.
module HTML

  class Tag

    # tag_name:: a String, the name of the tag
    # can_omit:: a Boolean, true if end tag is optional
    def initialize(tag_name, can_omit)
      @name = tag_name.downcase
      @can_omit_end = can_omit
    end

    # Return my tag name.
    def name; @name; end

    # Return true if my end tag can be omitted.
    def can_omit_end_tag; @can_omit_end; end

    # Return true if I am a block element.
    def is_block_element; false; end

    # Return true if I am an inline element.
    def is_inline_element; false; end

    # Return true if I am an empty element.
    def is_empty_element; false; end

    # Return true if I can contain <tt>tag</tt> if my parent is of type <tt>parent</tt>.
    # tag:: tag name, a String
    # parent:: parent tag name, a String.
    def can_contain(tag, parent); false; end

    # Return true if whitespace within me can be omitted (ignoring browser
    # bugs)
    def can_ignore_whitespace; true; end
  end

  # This represents an HTML block element.
  class BlockTag < Tag
    def is_block_element; true; end

    # Blocks can contain anything, so return true.
    def can_contain(tag, parent); true; end
  end

  # This represents an HTML inline element.
  class InlineTag < Tag
    def is_inline_element; true; end

    # Inlines can only contain other inlines.
    def can_contain(tag, parent)
      Tag.named(tag).is_inline_element
    end
  end

  # This represents an HTML element that can be regarded as either a block
  # or an inline element..
  class BlockOrInlineTag < InlineTag

    def is_block_element; true; end

    # If used as inline elements (e.g., within another inline element or a P),
    # these elements should not contain any block-level elements.
    def can_contain(tag, parent)
      return ((parent.downcase == 'p' \
        or Tag.named(parent).is_inline_element) \
          and ! Tag.named(tag).is_block_element)
    end
  end

  # This represents an HTML tag that never has an end tag.
  class EmptyTag < Tag
    def is_empty_element; true; end
    def is_inline_element; true; end
    def can_contain(tag, parent); false; end
  end

  # This block initializes the tag lookup table.
  class Tag
    @table = Hash.new

    # Add the given tag to the tag lookup table.
    #
    # This can be called by user code to add otherwise unknown tags to the
    # table.
    #
    # name::      the tag name, a String.
    # is_block::  true if I am a block element.
    # is_inline:: true if I am an inline element.
    # is_empty::  true if I am an empty element.
    # can_omit::  true if my end tag can be omitted.
    def Tag.add_tag(name, is_block, is_inline, is_empty, can_omit)
      @table[ name.upcase ] = @table[ name.downcase ] = \
      if is_empty
        EmptyTag.new(name, true)
      elsif is_block
        if is_inline
          BlockOrInlineTag.new(name, can_omit)
        else
          BlockTag.new(name, can_omit)
        end
      else
        InlineTag.new(name, can_omit)
      end
    end

    # Return an Tag with the given name, or raise a
    # NoSuchHTMLTagError.
    def Tag.named(tagname)
      @table[ tagname ] || raise(NoSuchHTMLTagError.exception(tagname))
    end

    #               Block Inline Empty can_omit_end
    [
    [ 'A',          false, true, false, false ], # Anchor
    [ 'ABBR',       false, true, false, false ], # Abbreviation
    [ 'ACRONYM',    false, true, false, false ], # Acronym
    [ 'ADDRESS',    true, false, false, false ], # Address
    [ 'APPLET',     true,  true, false, false ], # Java applet
    [ 'AREA',       true, false, true, true ], # Image map region
    [ 'B',          false, true, false, false ], # Bold text
    [ 'BASE',       false, false, true, true ], # Document base URI
    [ 'BASEFONT',   false, true, true,  true  ], # Base font change
    [ 'BDO',        false, true, false, false ], # Bi_di override
    [ 'BIG',        false, true, false, false ], # Large text
    [ 'BLOCKQUOTE', true, false, false, false ], # Block quotation
    [ 'BODY',       true, false, false, false ], # Document body
    [ 'BR',         false, true,  true, true ], # Line break
    [ 'BUTTON',     true,  true,  false, false ], # Button
    [ 'CAPTION',    false, true, false, false ], # Table caption
    [ 'CENTER',     false, true, false, false ], # Centered block
    [ 'CITE',       false, true, false, false ], # Citation
    [ 'CODE',       false, true, false, false ], # Computer code
    [ 'COL',        false, false, true, true ], # Table column
    [ 'COLGROUP',   true, false, false, true ], # Table column group
    [ 'DD',         true, false, false, true ], # Definition description
    [ 'DEL',        true,  true,  false, false ], # Deleted text
    [ 'DFN',        false, true, false, false ], # Defined term
    [ 'DIR',        true, false, false, false ], # Directory list
    [ 'DIV',        true, false, false, false ], # Generic block-level container
    [ 'DL',         true, false, false, false ], # Definition list
    [ 'DT',         false, true, false, true ], # Definition term
    [ 'EM',         false, true, false, false ], # Emphasis
    [ 'FIELDSET',   true, false, false, false ], # Form control group
    [ 'FONT',       false, true, false, false ], # Font change
    [ 'FORM',       true, false, false, false ], # Interactive form
    [ 'FRAME',      false, false, true, true ], # Frame
    [ 'FRAMESET',   true, false, false, false ], # Frameset
    [ 'H1',         true, false, false, false ], # Level-one heading
    [ 'H2',         true, false, false, false ], # Level-two heading
    [ 'H3',         true, false, false, false ], # Level-three heading
    [ 'H4',         true, false, false, false ], # Level-four heading
    [ 'H5',         true, false, false, false ], # Level-five heading
    [ 'H6',         true, false, false, false ], # Level-six heading
    [ 'HEAD',       true, false, false, false ], # Document head
    [ 'HR',         false, true, true, true ], # Horizontal rule
    [ 'HTML',       true, false, false, false ], # HTML document
    [ 'I',          false, true, false, false ], # Italic text
    [ 'IFRAME',     true,  true,  false, false ], # Inline frame
    [ 'IMG',        false, true, true, true ], # Inline image
    [ 'INPUT',      false, true, true, true ], # Form input
    [ 'INS',        true,  true, false, false ], # Inserted text
    [ 'ISINDEX',    false, true, true,  true ], # Input prompt
    [ 'KBD',        false, true, false, false ], # Text to be input
    [ 'LABEL',      false, true, false, false ], # Form field label
    [ 'LEGEND',     false, true, false, false ], # Fieldset caption
    [ 'LI',         true, false, false, true ], # List item
    [ 'LINK',       true, false, false, true ], # Document relationship
    [ 'MAP',        true,  true, false, false ], # Image map
    [ 'MENU',       true, false, false, false ], # Menu list
    [ 'META',       false, true,  true, true ], # Metadata
    [ 'NOFRAMES',   true, false, false, false ], # Frames alternate content
    [ 'NOSCRIPT',   true, false, false, false ], # Alternate script content
    [ 'OBJECT',     true,  true,  false, false ], # Object
    [ 'OL',         true, false, false, false ], # Ordered list
    [ 'OPTGROUP',   true, false, false, false ], # Option group
    [ 'OPTION',     true, false, false, false ], # Menu option
    [ 'P',          true, false, false, true ], # Paragraph
    [ 'PARAM',      false, true, true,  true ], # Object parameter
    [ 'PRE',        true, false, false, false ], # Preformatted text
    [ 'Q',          false, true, false, false ], # Short quotation
    [ 'S',          false, true, false, false ], # Strike-through text
    [ 'SAMP',       false, true, false, false ], # Sample output
    [ 'SCRIPT',     true,  true, false, false ], # Client-side script
    [ 'SELECT',     true, false, false, false ], # Option selector
    [ 'SMALL',      false, true, false, false ], # Small text
    [ 'SPAN',       false, true, false, false ], # Generic inline container
    [ 'STRIKE',     false, true, false, false ], # Strike-through text
    [ 'STRONG',     false, true, false, false ], # Strong emphasis
    [ 'STYLE',      true, false, false, false ], # Embedded style sheet
    [ 'SUB',        false, true, false, false ], # Subscript
    [ 'SUP',        false, true, false, false ], # Superscript
    [ 'TABLE',      true, false, false, false ], # Table
    [ 'TBODY',      true, false, false, false ], # Table body
    [ 'TD',         true, false, false, true ], # Table data cell
    [ 'TEXTAREA',   false, true, false, false ], # Multi-line text input
    [ 'TFOOT',      true, false, false, true ], # Table foot
    [ 'TH',         true, false, false, true ], # Table header cell
    [ 'THEAD',      true, false, false, true ], # Table head
    [ 'TITLE',      true, false, false, false ], # Document title
    [ 'TR',         true, false, false, true ], # Table row
    [ 'TT',         false, true, false, false ], # Teletype text
    [ 'U',          false, true, false, false ], # Underlined text
    [ 'UL',         true, false, false, false ], # Unordered list
    [ 'VAR',        false, true, false, false ], # Variable
    ].each { |a| add_tag(*a) }

    # EXCEPTIONS TODO
    # A, LABEL can't contain itself
    # several things (fonts, etc) can't be in PRE
    # SELECT can only have OPTGROUP or OPTION
    # TEXTAREA, OPTION only contains plain text
    # APPLET and OBJECT has PARAM+ followed by block and/or inline
    # BUTTON can't contain:
    #  A, INPUT, SELECT, TEXTAREA, LABEL, BUTTON, or IFRAME
    #  nor FORM, ISINDEX, and FIELDSET
    # IFRAME can only contain block elems if parent can
    # MAP can contain block+ *xor* AREA+
    # SCRIPT only contains a SCRIPT (that is, until /<\/[A-Za-z]/)
    # BODY must be in HTML or NOFRAMES
    # COL can only be in COLGROUP or TABLE
    # COLGROUP has only COL*, and can only be in TABLE
    # DIR, MENU can only contain LI+, none of which may contain block elems
    # DL must contain (DT|DD)+
    # DT and DD are only allowed in DL
    # FIELDSET contains LEGEND, (block|inline)*
    # FRAMESET contains (FRAMESET|FRAME), plus NOFRAMES and must be in HTML
    # H# can only be contained in block elems, but only contain inlines.
    # HEAD must only contain TITLE, BASE?, ISINDEX?, SCRIPT* STYLE* META* LINK*
    #   OBJECT* HEAD must be in HTML
    # HTML is top-level and can only contain HEAD, BODY, or HEAD, FRAMESET
    # LI can contain blocks except when inside DIR or MENU
    # LI can only be inside OL, UL, DIR, MENU
    # OL, UL can only contain LI+
    # OPTGROUP contains OPTION+
    # P can only contain inlines. However, it is a block-level elem.
    # PRE can only contain inlines except IMG, OBJECT, APPLET, BIG, SMALL, SUB,
    #   SUP, FONT, BASEFONT

    # tags with optional omitted endtags and their allowed contents:
    # anchor matches at beginning and end
      {
          'AREA'      => '(?!AREA)[A-Z]+',
          'COLGROUP'  => 'COL',
          'DD'        => '(?!D[DT]$)[A-Z]+',
          'DT'        => '(?!D[DT]$)[A-Z]+',
          'LI'        => '(?!LI$)[A-Z]+',
          'MAP'       => 'AREA',
          'P'         => '(?!P$)[A-Z]+',
          'TD'        => '(?!T[HDR]$)[A-Z]+',
          'TFOOT'     => 'TR',
          'TH'        => '(?!T[HDR]$)[A-Z]+',
          'THEAD'     => 'TR',
          'TR'        => 'T[HD]',
      }.each_pair { |tagname, pattern|
      eval <<EOM
      class << named(tagname)   # :nodoc:
        def can_contain(tag, parent)
          (/\\A#{pattern}\\z/i =~ tag) == 0
        end
      end
EOM
    }

    class << named('TEXTAREA') # :nodoc:
      def can_ignore_whitespace; false; end
    end
    class << named('PRE') # :nodoc:
      def can_ignore_whitespace; false; end
    end
    class << named('OPTION') # :nodoc:
      def can_ignore_whitespace; false; end
    end
  end
end
