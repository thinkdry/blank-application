#!/usr/bin/env ruby
module FeedParserUtilities
  def stripDoctype(data)
    #Strips DOCTYPE from XML document, returns (rss_version, stripped_data)
    #rss_version may be 'rss091n' or None
    #stripped_data is the same XML document, minus the DOCTYPE
    entity_pattern = /<!ENTITY(.*?)>/m # m is for Regexp::MULTILINE
    
    data = data.gsub(entity_pattern,'')

    doctype_pattern = /<!DOCTYPE(.*?)>/m
    doctype_results = data.scan(doctype_pattern)
    if doctype_results and doctype_results[0]
      doctype = doctype_results[0][0]
    else
      doctype = ''
    end

    if /netscape/ =~ doctype.downcase
      version = 'rss091n'
    else
      version = nil
    end
    data = data.sub(doctype_pattern, '')
    return version, data
  end
  
  def resolveRelativeURIs(htmlSource, baseURI, encoding)
    $stderr << "entering resolveRelativeURIs\n" if $debug # FIXME write a decent logger
    relative_uris = [ ['a','href'],
      ['applet','codebase'],
      ['area','href'],
      ['blockquote','cite'],
      ['body','background'],
      ['del','cite'],
      ['form','action'],
      ['frame','longdesc'],
      ['frame','src'],
      ['iframe','longdesc'],
      ['iframe','src'],
      ['head','profile'],
      ['img','longdesc'],
      ['img','src'],
      ['img','usemap'],
      ['input','src'],
      ['input','usemap'],
      ['ins','cite'],
      ['link','href'],
      ['object','classid'],
      ['object','codebase'],
      ['object','data'],
      ['object','usemap'],
      ['q','cite'],
      ['script','src'],
    ]
    h = Hpricot(htmlSource)
    relative_uris.each do |l|
      ename, eattr = l
      h.search(ename).each do |elem|
        euri = elem.attributes[eattr]
        uri = Addressable::URI.parse(Addressable::URI.encode(euri)) rescue nil
        if euri and not euri.empty? and uri and uri.relative?
          elem.raw_attributes[eattr] = urljoin(baseURI, euri)
        end
      end
    end
    return h.to_html
  end
end


