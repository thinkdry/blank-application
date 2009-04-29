# A parser for SGML, using the derived class as static DTD.
#
# Taken from http://raa.ruby-lang.org/list.rhtml?name=html-parser-2
# This file seems to be included in the current install of Ruby,
# but with a bug related to attributes quoted with '"', so I have
# included in in the HTML package of this distribution
#
# Copyright::   Copyright (C) 2003, Johannes Brodwall <johannes@brodwall.com>, 
#               Copyright (C) 2002, Ned Konz <ned@bike-nomad.com>
# License::     Same as Ruby's
# CVS ID:       $Id: sgml-parser.rb,v 1.4 2004/09/24 23:28:55 jhannes Exp $


module HTML

   class SGMLParser

     attr_reader :src_range

     # Regular expressions used for parsing:
     Interesting = /[&<]/
     Incomplete = Regexp.compile('&([a-zA-Z][a-zA-Z0-9]*|#[0-9]*)?|' +
                                 '<([a-zA-Z][^<>]*|/([a-zA-Z][^<>]*)?|' +
                                 '![^<>]*)?')

     Entityref = /&([a-zA-Z][-.a-zA-Z0-9]*)[^-.a-zA-Z0-9]/
     Charref = /&#([0-9]+)[^0-9]/

     Starttagopen = /<[>a-zA-Z]/
     Endtagopen = /<\/[<>a-zA-Z]/
     Endbracket = /[<>]/
     Special = /<![^<>]*>/
     Commentopen = /<!--/
     Commentclose = /--[ \t\n]*>/
     Tagfind = /[a-zA-Z][a-zA-Z0-9.-]*/
     Attrfind = Regexp.compile('[\s,]*([a-zA-Z_][a-zA-Z_0-9.-]*)' +
                               '(\s*=\s*' +
                               "('[^']*'" +
                               '|"[^"]*"' +
                               '|[-~a-zA-Z0-9,./:+*%?!()_#=]*))?')
     Endtagfind = /\s*\/\s*>/
     Entitydefs =
       {'lt'=>'<', 'gt'=>'>', 'amp'=>'&', 'quot'=>'"', 'apos'=>'\''}

     def initialize(verbose=false)
       @verbose = verbose
       reset
     end

     def reset
       @rawdata = ''
       @stack = []
       @lasttag = '???'
       @nomoretags = false
       @literal = false
       @offset = 0
       @ranges = []
     end

     def get_source(range)
       start = range.first
       end_index = range.end
       exclusive = range.exclude_end?
       offset_range = Range.new(start-@offset, end_index-@offset, exclusive)
       return @rawdata[offset_range]
     end

     def set_range(start, end_index)
       @src_range = Range.new(start+@offset, end_index+@offset, exclusive = true)
       #puts "setting range #{@src_range}, text = \"#{get_source(src_range)}\""
     end

     def has_context(gi)
       @stack.include? gi
     end

     def setnomoretags
       @nomoretags = true
       @literal = true
     end

     def setliteral(*args)
       @literal = true
     end

     def feed(data)
       @rawdata << data
       goahead(false)
     end

     def close
       goahead(true)
     end

     def handle_data_range(rawdata, start, end_index)
       if end_index > start
         set_range(start, end_index)
         handle_data(rawdata[start...end_index])
       end
       return end_index
     end

     def goahead(_end)
       rawdata = @rawdata
       i = 0
       n = rawdata.length
       while i < n
         if @nomoretags
           i = handle_data_range(rawdata, i, n)
           break
         end
         j = rawdata.index(Interesting, i)
         j = n unless j
         i = handle_data_range(rawdata, i, j)
         break if (i == n)
         if rawdata[i] == ?< #
           if rawdata.index(Starttagopen, i) == i
             if @literal
               i = handle_data_range(rawdata, i, i+1)
               next
             end
             k = parse_starttag(i)
             break unless k
             i = k
             next
           end
           if rawdata.index(Endtagopen, i) == i
             k = parse_endtag(i)
             break unless k
             i = k
             @literal = false
             next
           end
           if rawdata.index(Commentopen, i) == i
             if @literal
               i = handle_data_range(rawdata, i, i+1)
               next
             end
             k = parse_comment(i)
             break unless k
             i += k
             next
           end
           if rawdata.index(Special, i) == i
             if @literal
               i = handle_data_range(rawdata, i, i+1)
               next
             end
             k = parse_special(i)
             break unless k
             i += k
             next
           end
         elsif rawdata[i] == ?& #
           if rawdata.index(Charref, i) == i
             end_index = i + $&.length
             end_index -= 1 unless rawdata[end_index-1] == ?;
             set_range(i, end_index)
             handle_charref($1)
             i = end_index
             next
           end
           if rawdata.index(Entityref, i) == i
             end_index = i + $&.length
             end_index -= 1 unless rawdata[end_index-1] == ?;
             set_range(i, end_index)
             handle_entityref($1)
             i = end_index
             next
           end
         else
           raise RuntimeError, 'neither < nor & ??'
         end
         # We get here only if incomplete matches but
         # nothing else
         match = rawdata.index(Incomplete, i)
         unless match == i
           i = handle_data_range(rawdata, i, i+1)
           next
         end
         j = match + $&.length
         break if j == n # Really incomplete
         i = handle_data_range(rawdata, i, j)
       end
       # end while
       if _end and i < n
         i = handle_data_range(rawdata, i, n)
       end
       @rawdata = rawdata[i..-1]
       @offset += i
     end

     def parse_comment(i)
       rawdata = @rawdata
       if rawdata[i, 4] != '<!--'
         raise RuntimeError, 'unexpected call to handle_comment'
       end
       match = rawdata.index(Commentclose, i)
       return nil unless match
       matched_length = $&.length
       j = match
       src_length = match + matched_length - i
       set_range(i, i + src_length)
       handle_comment(rawdata[i+4..(j-1)])
       return src_length
     end

     def parse_starttag(i)
       rawdata = @rawdata
       j = rawdata.index(Endbracket, i + 1)
       return nil unless j
       attrs = []
       if rawdata[i+1] == ?> #
         # SGML shorthand: <> == <last open tag seen>
         k = j
         tag = @lasttag
       else
         match = rawdata.index(Tagfind, i + 1)
         unless match
           raise RuntimeError, 'unexpected call to parse_starttag'
         end
         k = i + 1 + ($&.length)
         tag = $&.downcase
         @lasttag = tag
       end
       while k < j
         break if rawdata.index(Endtagfind, k)
         break unless rawdata.index(Attrfind, k)
         matched_length = $&.length
         attrname, rest, attrvalue = $1, $2, $3
         if not rest
           attrvalue = '' # was: = attrname
         elsif (attrvalue[0] == ?' && attrvalue[-1] == ?') or
             (attrvalue[0] == ?" && attrvalue[-1] == ?")
           attrvalue = attrvalue[1..-2]
         end
         attrs << [attrname.downcase, attrvalue]
         k += matched_length
       end
       if rawdata[j] == ?> #
         j += 1
       end
       set_range(i, j)
       finish_starttag(tag, attrs)
       return j
     end

     def parse_endtag(i)
       rawdata = @rawdata
       j = rawdata.index(Endbracket, i + 1)
       return nil unless j
       tag = (rawdata[i+2..j-1].strip).downcase
       if rawdata[j] == ?> #
         j += 1
       end
       set_range(i, j)
       finish_endtag(tag)
       return j
     end

     def finish_starttag(tag, attrs)
       method = 'start_' + tag
       if self.respond_to?(method)
         @stack << tag
         handle_starttag(tag, method, attrs)
         return 1
       else
         method = 'do_' + tag
         if self.respond_to?(method)
           handle_starttag(tag, method, attrs)
           return 0
         else
           unknown_starttag(tag, attrs)
           return -1
         end
       end
     end

     def finish_endtag(tag)
       if tag == ''
         found = @stack.length - 1
         if found < 0
           unknown_endtag(tag)
           return
         end
       else
         unless @stack.include? tag
           method = 'end_' + tag
           unless self.respond_to?(method)
             unknown_endtag(tag)
           end
           return
         end
         found = @stack.index(tag) #or @stack.length
       end
       while @stack.length > found
         tag = @stack[-1]
         method = 'end_' + tag
         if respond_to?(method)
           handle_endtag(tag, method)
         else
           unknown_endtag(tag)
         end
         @stack.pop
       end
     end

     def parse_special(i)
       rawdata = @rawdata
       match = rawdata.index(Endbracket, i+1)
       return nil unless match
       matched_length = $&.length
       src_length = match - i + matched_length
       set_range(i, i + src_length)
       handle_special(rawdata[i+1..(match-1)])
       return src_length
     end

     def handle_starttag(tag, method, attrs)
       self.send(method, attrs)
     end

     def handle_endtag(tag, method)
       self.send(method)
     end

     def report_unbalanced(tag)
       if @verbose
         print '*** Unbalanced </' + tag + '>', "\n"
         print '*** Stack:', self.stack, "\n"
       end
     end

     def handle_charref(name)
       n = Integer(name)
       if !(0 <= n && n <= 255)
         unknown_charref(name)
         return
       end
       handle_data(n.chr)
     end

     def handle_entityref(name)
       table = Entitydefs
       if table.include?(name)
         handle_data(table[name])
       else
         unknown_entityref(name)
         return
       end
     end

     def handle_data(data)
     end

     def handle_comment(data)
     end

     def handle_special(data)
     end

     def unknown_starttag(tag, attrs)
     end
     def unknown_endtag(tag)
     end
     def unknown_charref(ref)
     end
     def unknown_entityref(ref)
     end

   end
end