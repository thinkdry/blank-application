gem 'libxml-ruby', '>=0.8.3'
require 'libxml'

module FeedParser
 module LibXML
   class StrictFeedParser
     attr_reader :handler

     def initialize(baseuri, baselang)
       @handler = StrictFeedParserHandler.new(baseuri, baselang, 'utf-8')
     end

     def parse(data)
       saxparser = ::LibXML::XML::SaxParser.new
       saxparser.callbacks = @handler
       saxparser.string = data
       saxparser.parse
     end
   end

   class StrictFeedParserHandler
     include ::LibXML::XML::SaxParser::Callbacks
     include FeedParserMixin

     attr_accessor :bozo, :entries, :feeddata, :exc
     def initialize(baseuri, baselang, encoding)
       $stderr.puts "trying LibXML::StrictFeedParser" if $debug
       startup(baseuri, baselang, encoding)
       @bozo = false
     end

     def on_start_element(name, attrs)
       name =~ /^(([^;]*);)?(.+)$/ # Snag namespaceuri from name
       namespaceuri = ($2 || '').downcase
       name = $3
       if /backend\.userland\.com\/rss/ =~ namespaceuri
         # match any backend.userland.com namespace
         namespaceuri = 'http://backend.userland.com/rss'
       end
       prefix = @matchnamespaces[namespaceuri]

       if prefix and not prefix.empty?
         name = prefix + ':' + name
       end

       name.downcase!
       unknown_starttag(name, attrs)
     end

     def on_characters(text)
       handle_data(text)
     end

     def on_cdata_block(content)
       handle_data(content)
     end

     def on_end_element(name)
       name =~ /^(([^;]*);)?(.+)$/ # Snag namespaceuri from name
       namespaceuri = ($2 || '').downcase
       prefix = @matchnamespaces[namespaceuri]
       if prefix and not prefix.empty?
         localname = prefix + ':' + name
       end
       name.downcase!
       unknown_endtag(name)
     end

     def on_parser_error(exc)
       @bozo = true
       @exc = exc
       raise exc
     end
   end
 end
end
