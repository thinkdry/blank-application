#!/usr/bin/env ruby


class BetterSGMLParserError < StandardError; end;
class BetterSGMLParser < HTML::SGMLParser
  # Replaced Tagfind and Charref Regexps with the ones in feedparser.py
  # This makes things work. 
  Interesting = /[&<]/u
  Incomplete = Regexp.compile('&([a-zA-Z][a-zA-Z0-9]*|#[0-9]*)?|<([a-zA-Z][^<>]*|/([a-zA-Z][^<>]*)?|![^<>]*)?', 64) 
  # 64 is the unicode flag

  Entityref = /&([a-zA-Z][-.a-zA-Z0-9]*)[^-.a-zA-Z0-9]/u
  Charref = /&#(x?[0-9A-Fa-f]+)[^0-9A-Fa-f]/u

  Shorttagopen = /'<[a-zA-Z][-.a-zA-Z0-9]*/u
  Shorttag = /'<([a-zA-Z][-.a-zA-Z0-9]*)\/([^\/]*)\//u
  Endtagopen = /<\//u # Changed the RegExps to match the Python SGMLParser
  Endbracket = /[<>]/u
  Declopen = /<!/u
  Piopenbegin = /^<\?/u
  Piclose = />/u

  Commentopen = /<!--/u
  Commentclose = /--\s*>/u
  Tagfind = /[a-zA-Z][-_.:a-zA-Z0-9]*/u
  Attrfind = Regexp.compile('\s*([a-zA-Z_][-:.a-zA-Z_0-9]*)(\s*=\s*'+
  '(\'[^\']*\'|"[^"]*"|[\]\[\-a-zA-Z0-9./,:;+*%?!&$\(\)_#=~\'"@]*))?',
  64)
  Endtagfind = /\s*\/\s*>/u
  def initialize(verbose=false)
    super(verbose)
  end
  def feed(*args)
    super(*args)
  end

  def goahead(_end)
    rawdata = @rawdata # woo, utf-8 magic
    i = 0
    n = rawdata.length
    while i < n
      if @nomoretags
        # handle_data_range does nothing more than set a "Range" that is never used. wtf?
        handle_data(rawdata[i...n]) # i...n means "range from i to n not including n" 
        i = n
        break
      end
      j = rawdata.index(Interesting, i) 
      j = n unless j
      handle_data(rawdata[i...j]) if i < j
      i = j
      break if (i == n)
      if rawdata[i..i] == '<' # Yeah, ugly, but I prefer it to rawdata[i] == ?<
        if rawdata.index(Starttagopen,i) == i
          if @literal
            handle_data(rawdata[i..i])
            i = i+1
            next
          end
          k = parse_starttag(i)
          break unless k
          i = k
          next
        end
        if rawdata.index(Endtagopen,i) == i #Don't use Endtagopen
          k = parse_endtag(i)
          break unless k
          i = k
          @literal = false
          next
        end
        if @literal
          if n > (i+1)
            handle_data("<")
            i = i+1
          else
            #incomplete
            break
          end
          next
        end
        if rawdata.index(Commentopen,i) == i 
          k = parse_comment(i)
          break unless k
          i = k
          next
        end
        if rawdata.index(Piopenbegin,i) == i # Like Piopen but must be at beginning of rawdata
          k = parse_pi(i)
          break unless k
          i += k
          next
        end
        if rawdata.index(Declopen,i) == i
          # This is some sort of declaration; in "HTML as
          # deployed," this should only be the document type
          # declaration ("<!DOCTYPE html...>").
          k = parse_declaration(i)
          break unless k
          i = k
          next
        end
      elsif rawdata[i..i] == '&'
        if @literal # FIXME BUGME SGMLParser totally does not check this. Bug it.
          handle_data(rawdata[i..i])
          i += 1
          next
        end

        # the Char must come first as its #=~ method is the only one that is UTF-8 safe 
        ni,match = index_match(rawdata, Charref, i)
        if ni and ni == i # See? Ugly
          handle_charref(match[1]) # $1 is just the first group we captured (with parentheses)
          i += match[0].length  # $& is the "all" of the match.. it includes the full match we looked for not just the stuff we put parentheses around to capture. 
          i -= 1 unless rawdata[i-1..i-1] == ";"
          next
        end
        ni,match = index_match(rawdata, Entityref, i)
        if ni and ni == i
          handle_entityref(match[1])
          i += match[0].length
          i -= 1 unless rawdata[i-1..i-1] == ";"
          next
        end
      else
        error('neither < nor & ??')
      end
      # We get here only if incomplete matches but
      # nothing else
      ni,match = index_match(rawdata,Incomplete,i)
      unless ni and ni == 0
        handle_data(rawdata[i...i+1]) # str[i...i+1] == str[i..i]
        i += 1
        next
      end
      j = ni + match[0].length 
      break if j == n # Really incomplete
      handle_data(rawdata[i...j])
      i = j
    end # end while

    if _end and i < n
      handle_data(rawdata[i...n])
      i = n
    end

    @rawdata = rawdata[i..-1] 
    # @offset += i # FIXME BUGME another unused variable in SGMLParser?
  end


  # Internal -- parse processing instr, return length or -1 if not terminated
  def parse_pi(i)
    rawdata = @rawdata 
    if rawdata[i...i+2] != '<?' 
      error("unexpected call to parse_pi()")
    end
    ni,match = index_match(rawdata,Piclose,i+2)
    return nil unless match
    j = ni
    handle_pi(rawdata[i+2...j])
    j = (j + match[0].length)
    return j-i
  end

  def parse_comment(i)
    rawdata = @rawdata
    if rawdata[i...i+4] != "<!--"
      error("unexpected call to parse_comment()")
    end
    ni,match = index_match(rawdata, Commentclose,i)
    return nil unless match
    handle_comment(rawdata[i+4..(ni-1)])
    return ni+match[0].length # Length from i to just past the closing comment tag
  end


  def parse_starttag(i)
    @_starttag_text = nil
    start_pos = i
    rawdata = @rawdata
    ni,match = index_match(rawdata,Shorttagopen,i)
    if ni == i 
      # SGML shorthand: <tag/data/ == <tag>data</tag>
      # XXX Can data contain &... (entity or char refs)?
      # XXX Can data contain < or > (tag characters)?
      # XXX Can there be whitespace before the first /?
      k,match = index_match(rawdata,Shorttag,i)
      return nil unless match
      tag, data = match[1], match[2]
      @_starttag_text = "<#{tag}/"
      tag.downcase!
      second_end = rawdata.index(Shorttagopen,k)
      finish_shorttag(tag, data)
      @_starttag_text = rawdata[start_pos...second_end+1]
      return k
    end

    j = rawdata.index(Endbracket, i+1)
    return nil unless j
    attrsd = []
    if rawdata[i...i+2] == '<>'
      # SGML shorthand: <> == <last open tag seen>
      k = j
      tag = @lasttag
    else
      ni,match = index_match(rawdata,Tagfind,i+1)
      unless match
        error('unexpected call to parse_starttag')
      end
      k = ni+match[0].length+1
      tag = match[0].downcase
      @lasttag = tag
    end

    while k < j
      break if rawdata.index(Endtagfind, k) == k
      ni,match = index_match(rawdata,Attrfind,k)
      break unless ni
      matched_length = match[0].length
      attrname, rest, attrvalue = match[1],match[2],match[3]
      if rest.nil? or rest.empty?
        attrvalue = '' # was: = attrname # Why the change?
      elsif [?',?'] == [attrvalue[0..0], attrvalue[-1..-1]] or [?",?"] == [attrvalue[0],attrvalue[-1]]
        attrvalue = attrvalue[1...-1]
      end
      attrsd << [attrname.downcase, attrvalue]
      k += matched_length
    end
    if rawdata[j..j] == ">"
      j += 1
    end
    @_starttag_text = rawdata[start_pos...j]
    finish_starttag(tag, attrsd)
    return j
  end

  def parse_endtag(i)
    rawdata = @rawdata
    j, match = index_match(rawdata, /[<>]/,i+1)
    return nil unless j
    tag = rawdata[i+2...j].strip.downcase
    if rawdata[j..j] == ">"
      j += 1
    end
    finish_endtag(tag)
    return j
  end

  def output
    # Return processed HTML as a single string
    return @pieces.map{|p| p.to_s}.join
  end

  def error(message)
    raise BetterSGMLParserError.new(message)
  end
  def handle_pi(text)
  end
  def handle_decl(text)
  end
end


