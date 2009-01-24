# If you don't have libxml installed (or for some reason you would
# rather use expat) you can fall back upon this for your parser. Be
# advised that the bindings for expat are much older (from the days of
# Ruby 1.6.7) and are unmaintained. If you want to force use of expat
# even when libxml is installed, you can do this:
#
#   feed = FeedParser.parse("some-feed-stream-filepath-or-url",
#                           :strict => FeedParser::Expat::StrictFeedParser)

require 'xml/saxdriver'

module FeedParser
 module Expat
   class StrictFeedParser
     attr_reader :handler
     def initialize(baseuri, baselang)
       @handler = StrictFeedParserHandler.new(baseuri, baselang, 'utf-8')
     end

     def parse(data)
       # initialize the SAX parser
       saxparser = XML::SAX::Helpers::ParserFactory.makeParser("XML::Parser::SAXDriver")
       saxparser.setDocumentHandler(@handler)
       saxparser.setDTDHandler(@handler)
       saxparser.setEntityResolver(@handler)
       saxparser.setErrorHandler(@handler)

       inputdata = XML::SAX::InputSource.new('parsedfeed')
       inputdata.setByteStream(StringIO.new(data))
       begin
         saxparser.parse(inputdata)
       rescue XML::SAX::SAXParseException => err
         # This does not inherit from StandardError as it should, so
         # we have to catch and re-raise specially.
         raise err.to_s
       end
     end
   end

   class StrictFeedParserHandler < XML::SAX::HandlerBase # expat
     include FeedParserMixin

     attr_accessor :bozo, :entries, :feeddata, :exc
     def initialize(baseuri, baselang, encoding)
       $stderr << "trying StrictFeedParser\n" if $debug
       startup(baseuri, baselang, encoding)
       @bozo = false
       @exc = nil
       super()
     end

     def getPos
       [@locator.getSystemId, @locator.getLineNumber]
     end

     def getAttrs(attrs)
       ret = []
       for i in 0..attrs.getLength
   ret.push([attrs.getName(i), attrs.getValue(i)])
       end
       ret
     end

     def setDocumentLocator(loc)
       @locator = loc
     end

     def startDoctypeDecl(name, pub_sys, long_name, uri)
       #Nothing is done here. What could we do that is neat and useful?
     end

     def startNamespaceDecl(prefix, uri)
       trackNamespace(prefix, uri)
     end

     def endNamespaceDecl(prefix)
     end

     def startElement(name, attrs)
       name =~ /^(([^;]*);)?(.+)$/ # Snag namespaceuri from name
   namespaceuri = ($2 || '').downcase
       name = $3
       if /backend\.userland\.com\/rss/ =~ namespaceuri
   # match any backend.userland.com namespace
   namespaceuri = 'http://backend.userland.com/rss'
       end
       prefix = @matchnamespaces[namespaceuri]
       # No need to raise UndeclaredNamespace, Expat does that for us with
       "unbound prefix (XMLParserError)"
       if prefix and not prefix.empty?
   name = prefix + ':' + name
       end
       name.downcase!
       unknown_starttag(name, attrs)
     end

     def character(text, start, length)
       #handle_data(CGI.unescapeHTML(text))
       handle_data(text)
     end
     # expat provides "character" not "characters"!
     alias :characters :character # Just in case.

     def startCdata(content)
       handle_data(content)
     end

     def endElement(name)
       name =~ /^(([^;]*);)?(.+)$/ # Snag namespaceuri from name
   namespaceuri = ($2 || '').downcase
       prefix = @matchnamespaces[namespaceuri]
       if prefix and not prefix.empty?
   localname = prefix + ':' + name
       end
       name.downcase!
       unknown_endtag(name)
     end

     def comment(comment)
       handle_comment(comment)
     end

     def entityDecl(*foo)
     end

     def unparsedEntityDecl(*foo)
     end

     def error(exc)
       @bozo = true
       @exc = exc
     end

     def fatalError(exc)
       error(exc)
       raise exc
     end
   end
 end
end


# FIXME line 5 maps to line 171 in saxdriver.rb. note that there is no return 
# in the original
class XML::Parser::SAXDriver
   def openInputStream(stream)
      if stream.getByteStream
        return stream
      else stream.getSystemId
        url = URL.new(stream.getSystemId)
        if url.scheme == 'file' && url.login == 'localhost'
          s = open(url.urlpath)
          stream.setByteStream(s)
          return stream
        end
      end
      return nil
    end
end
