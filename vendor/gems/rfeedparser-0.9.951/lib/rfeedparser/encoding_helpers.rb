#!/usr/bin/env ruby

module FeedParserUtilities

  def unicode(data, from_encoding)
    # Takes a single string and converts it from the encoding in 
    # from_encoding to unicode.
    uconvert(data, from_encoding, 'unicode')
  end

  def uconvert(data, from_encoding, to_encoding = 'utf-8')
    from_encoding = Encoding_Aliases[from_encoding] || from_encoding
    to_encoding = Encoding_Aliases[to_encoding] || to_encoding
    Iconv.iconv(to_encoding, from_encoding, data)[0]
  end

  def index_match(stri,regexp, offset)
    i = stri.index(regexp, offset)

    return nil, nil unless i

    full = stri[i..-1].match(regexp)
    return i, full
  end

  def _ebcdic_to_ascii(s)   
    return Iconv.iconv("iso88591", "ebcdic-cp-be", s)[0]
  end

  def getCharacterEncoding(http_headers, xml_data)
    # Get the character encoding of the XML document
    $stderr << "In getCharacterEncoding\n" if $debug
    sniffed_xml_encoding = nil
    xml_encoding = nil
    true_encoding = nil
    
    http_content_type, charset = http_headers['content-type'].to_s.split(';',2)

    encoding_regexp = /\s*charset\s*=\s*(?:"|')?(.*?)(?:"|')?\s*$/
    http_encoding = charset.to_s.scan(encoding_regexp).flatten[0]

    http_encoding = nil if http_encoding && http_encoding.empty?
    # FIXME Open-Uri returns iso8859-1 if there is no charset header,
    # but that doesn't pass the tests. Open-Uri claims its following
    # the right RFC. Are they wrong or do we need to change the tests?
    
    # Must sniff for non-ASCII-compatible character encodings before
    # searching for XML declaration.  This heuristic is defined in
    # section F of the XML specification:
    # http://www.w3.org/TR/REC-xml/#sec-guessing-no-ext-info
    begin 
      if xml_data[0..3] == "\x4c\x6f\xa7\x94"
        # EBCDIC
        xml_data = __ebcdic_to_ascii(xml_data)
      elsif xml_data[0..3] == "\x00\x3c\x00\x3f"
        # UTF-16BE
        sniffed_xml_encoding = 'utf-16be'
        xml_data = uconvert(xml_data, 'utf-16be', 'utf-8')
      elsif xml_data.size >= 4 and xml_data[0..1] == "\xfe\xff" and xml_data[2..3] != "\x00\x00"
        # UTF-16BE with BOM
        sniffed_xml_encoding = 'utf-16be'
        xml_data = uconvert(xml_data[2..-1], 'utf-16be', 'utf-8')
      elsif xml_data[0..3] == "\x3c\x00\x3f\x00"
        # UTF-16LE
        sniffed_xml_encoding = 'utf-16le'
        xml_data = uconvert(xml_data, 'utf-16le', 'utf-8')
      elsif xml_data.size >=4 and xml_data[0..1] == "\xff\xfe" and xml_data[2..3] != "\x00\x00"
        # UTF-16LE with BOM
        sniffed_xml_encoding = 'utf-16le'
        xml_data = uconvert(xml_data[2..-1], 'utf-16le', 'utf-8')
      elsif xml_data[0..3] == "\x00\x00\x00\x3c"
        # UTF-32BE
        sniffed_xml_encoding = 'utf-32be'
        xml_data = uconvert(xml_data, 'utf-32be', 'utf-8')
      elsif xml_data[0..3] == "\x3c\x00\x00\x00"
        # UTF-32LE
        sniffed_xml_encoding = 'utf-32le'
        xml_data = uconvert(xml_data, 'utf-32le', 'utf-8')
      elsif xml_data[0..3] == "\x00\x00\xfe\xff"
        # UTF-32BE with BOM
        sniffed_xml_encoding = 'utf-32be'
        xml_data = uconvert(xml_data[4..-1], 'utf-32BE', 'utf-8')
      elsif xml_data[0..3] == "\xff\xfe\x00\x00"
        # UTF-32LE with BOM
        sniffed_xml_encoding = 'utf-32le'
        xml_data = uconvert(xml_data[4..-1], 'utf-32le', 'utf-8')
      elsif xml_data[0..2] == "\xef\xbb\xbf"
        # UTF-8 with BOM
        sniffed_xml_encoding = 'utf-8'
        xml_data = xml_data[3..-1]
      else
        # ASCII-compatible
      end
      xml_encoding_match = /^<\?.*encoding=[\'"](.*?)[\'"].*\?>/.match(xml_data)
    rescue
      xml_encoding_match = nil
    end
    if xml_encoding_match 
      xml_encoding = xml_encoding_match[1].downcase
      xencodings = ['iso-10646-ucs-2', 'ucs-2', 'csunicode', 'iso-10646-ucs-4', 'ucs-4', 'csucs4', 'utf-16', 'utf-32', 'utf_16', 'utf_32', 'utf16', 'u16']
      if sniffed_xml_encoding and xencodings.include?xml_encoding
        xml_encoding = sniffed_xml_encoding
      end
    end

    acceptable_content_type = false
    application_content_types = ['application/xml', 'application/xml-dtd', 'application/xml-external-parsed-entity']
    text_content_types = ['text/xml', 'text/xml-external-parsed-entity']

    if application_content_types.include?(http_content_type) or (/^application\// =~ http_content_type and /\+xml$/ =~ http_content_type)
      acceptable_content_type = true
      true_encoding = http_encoding || xml_encoding || 'utf-8'
    elsif text_content_types.include?(http_content_type) or (/^text\// =~ http_content_type and /\+xml$/ =~ http_content_type)
      acceptable_content_type = true
      true_encoding = http_encoding || 'us-ascii'
    elsif /^text\// =~ http_content_type 
      true_encoding = http_encoding || 'us-ascii'
    elsif http_headers and not http_headers.empty? and not http_headers.has_key?'content-type'
      true_encoding = xml_encoding || 'iso-8859-1'
    else
      true_encoding = xml_encoding || 'utf-8'
    end
    return true_encoding, http_encoding, xml_encoding, sniffed_xml_encoding, acceptable_content_type
  end
  
  def toUTF8(data, encoding)
    $stderr << "entering self.toUTF8, trying encoding %s\n" % encoding if $debug
    # NOTE we must use double quotes when dealing with \x encodings!
    if (data.size >= 4 and data[0..1] == "\xfe\xff" and data[2..3] != "\x00\x00")
      if $debug
        $stderr << "stripping BOM\n"
        if encoding != 'utf-16be'
          $stderr << "string utf-16be instead\n"
        end
      end
      encoding = 'utf-16be'
      data = data[2..-1]
    elsif (data.size >= 4 and data[0..1] == "\xff\xfe" and data[2..3] != "\x00\x00")
      if $debug
        $stderr << "stripping BOM\n"
        $stderr << "trying utf-16le instead\n" if encoding != 'utf-16le'
      end
      encoding = 'utf-16le'
      data = data[2..-1]
    elsif (data[0..2] == "\xef\xbb\xbf")
      if $debug
        $stderr << "stripping BOM\n"
        $stderr << "trying utf-8 instead\n" if encoding != 'utf-8'
      end
      encoding = 'utf-8'
      data = data[3..-1]
    elsif (data[0..3] == "\x00\x00\xfe\xff")
      if $debug
        $stderr << "stripping BOM\n"
        if encoding != 'utf-32be'
          $stderr << "trying utf-32be instead\n"
        end
      end
      encoding = 'utf-32be'
      data = data[4..-1]
    elsif (data[0..3] == "\xff\xfe\x00\x00")
      if $debug
        $stderr << "stripping BOM\n"
        if encoding != 'utf-32le'
          $stderr << "trying utf-32le instead\n"
        end
      end
      encoding = 'utf-32le'
      data = data[4..-1]
    end
    begin
      newdata = uconvert(data, encoding, 'utf-8')
    rescue => details
      raise details
    end
    $stderr << "successfully converted #{encoding} data to utf-8\n" if $debug
    declmatch = /^<\?xml[^>]*?>/
    newdecl = "<?xml version=\'1.0\' encoding=\'utf-8\'?>"
    if declmatch =~ newdata
      newdata.sub!(declmatch, newdecl) 
    else
      newdata = newdecl + "\n" + newdata
    end
    return newdata
  end
  
end

unless defined?(Builder::XChar)
  # http://intertwingly.net/stories/2005/09/28/xchar.rb
  module XChar
    # http://intertwingly.net/stories/2004/04/14/i18n.html#CleaningWindows
    CP1252 = {
      128 => 8364, # euro sign
      130 => 8218, # single low-9 quotation mark
      131 =>  402, # latin small letter f with hook
      132 => 8222, # double low-9 quotation mark
      133 => 8230, # horizontal ellipsis
      134 => 8224, # dagger
      135 => 8225, # double dagger
      136 =>  710, # modifier letter circumflex accent
      137 => 8240, # per mille sign
      138 =>  352, # latin capital letter s with caron
      139 => 8249, # single left-pointing angle quotation mark
      140 =>  338, # latin capital ligature oe
      142 =>  381, # latin capital letter z with caron
      145 => 8216, # left single quotation mark
      146 => 8217, # right single quotation mark
      147 => 8220, # left double quotation mark
      148 => 8221, # right double quotation mark
      149 => 8226, # bullet
      150 => 8211, # en dash
      151 => 8212, # em dash
      152 =>  732, # small tilde
      153 => 8482, # trade mark sign
      154 =>  353, # latin small letter s with caron
      155 => 8250, # single right-pointing angle quotation mark
      156 =>  339, # latin small ligature oe
      158 =>  382, # latin small letter z with caron
      159 =>  376 # latin capital letter y with diaeresis
    }
    # http://www.w3.org/TR/REC-xml/#dt-chardata
    PREDEFINED = {
      38 => '&amp;', # ampersand
      60 => '&lt;',  # left angle bracket
      62 => '&gt;'  # right angle bracket
    }
    # http://www.w3.org/TR/REC-xml/#charsets
    VALID = [
      0x9, 0xA, 0xD,
      (0x20..0xD7FF),
      (0xE000..0xFFFD),
      (0x10000..0x10FFFF)
    ]
  end

  class Fixnum
    # xml escaped version of chr
    def xchr
      n = XChar::CP1252[self] || self

      case n when *XChar::VALID
        XChar::PREDEFINED[n] or (n<128 ? n.chr : "&##{n};")
      else
        '*'
      end
    end
  end

  class String
    def to_xs
      unpack('U*').map {|n| n.xchr}.join # ASCII, UTF-8
    rescue
      unpack('C*').map {|n| n.xchr}.join # ISO-8859-1, WIN-1252
    end
  end
end