module FeedParser
 class LooseFeedParser < BetterSGMLParser
   include FeedParserMixin
   # We write the methods that were in BaseHTMLProcessor in the python code
   # in here directly. We do this because if we inherited from
   # BaseHTMLProcessor but then included from FeedParserMixin, the methods
   # of Mixin would overwrite the methods we inherited from
   # BaseHTMLProcessor. This is exactly the opposite of what we want to
   # happen!

   attr_accessor :encoding, :bozo, :feeddata, :entries, :namespacesInUse

   Elements_No_End_Tag = ['area', 'base', 'basefont', 'br', 'col', 'frame', 'hr',
     'img', 'input', 'isindex', 'link', 'meta', 'param']
   New_Declname_Re = /[a-zA-Z][-_.a-zA-Z0-9:]*\s*/
     alias :sgml_feed :feed # feed needs to mapped to feeddata, not the SGMLParser method feed. I think.
   def feed
     @feeddata
   end
   def feed=(data)
     @feeddata = data
   end

   def initialize(baseuri, baselang, encoding)
     startup(baseuri, baselang, encoding)
     super() # Keep the parentheses! No touchy.
   end

   def reset
     @pieces = []
     super
   end

   def parse(data)
     data.gsub!(/<!((?!DOCTYPE|--|\[))/i,  '&lt;!\1')
 data.gsub!(/<([^<\s]+?)\s*\/>/) do |tag|
   clean = tag[1..-3].strip
   if Elements_No_End_Tag.include?clean
     tag
   else
   '<'+clean+'></'+clean+'>'
   end
 end

 data.gsub!(/&#39;/, "'")
   data.gsub!(/&#34;/, "'")
   if @encoding and not @encoding.empty? # FIXME unicode check type(u'')
     data = uconvert(data,'utf-8',@encoding)
   end
 sgml_feed(data) # see the alias above
   end


   def decodeEntities(element, data)
     data.gsub!('&#60;', '&lt;')
     data.gsub!('&#x3c;', '&lt;')
     data.gsub!('&#62;', '&gt;')
     data.gsub!('&#x3e;', '&gt;')
     data.gsub!('&#38;', '&amp;')
     data.gsub!('&#x26;', '&amp;')
     data.gsub!('&#34;', '&quot;')
     data.gsub!('&#x22;', '&quot;')
     data.gsub!('&#39;', '&apos;')
     data.gsub!('&#x27;', '&apos;')
     if @contentparams.has_key? 'type' and not ((@contentparams['type'] || 'xml') =~ /xml$/u)
 data.gsub!('&lt;', '<')
 data.gsub!('&gt;', '>')
 data.gsub!('&amp;', '&')
 data.gsub!('&quot;', '"')
 data.gsub!('&apos;', "'")
     end
     return data
   end
 end
end
