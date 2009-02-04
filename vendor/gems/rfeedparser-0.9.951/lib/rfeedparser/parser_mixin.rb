#!/usr/bin/env ruby

module FeedParser
module FeedParserMixin
  include FeedParserUtilities
  attr_accessor :feeddata, :version, :namespacesInUse, :date_handlers

  def startup(baseuri=nil, baselang=nil, encoding='utf-8')
    $stderr << "initializing FeedParser\n" if $debug

    @namespaces = {'' => '',
      'http://backend.userland.com/rss' => '',
      'http://blogs.law.harvard.edu/tech/rss' => '',
      'http://purl.org/rss/1.0/' => '',
      'http://my.netscape.com/rdf/simple/0.9/' => '',
      'http://example.com/newformat#' => '',
      'http://example.com/necho' => '',
      'http://purl.org/echo/' => '',
      'uri/of/echo/namespace#' => '',
      'http://purl.org/pie/' => '',
      'http://purl.org/atom/ns#' => '',
      'http://www.w3.org/2005/Atom' => '',
      'http://purl.org/rss/1.0/modules/rss091#' => '',
      'http://webns.net/mvcb/' =>                               'admin',
      'http://purl.org/rss/1.0/modules/aggregation/' =>         'ag',
      'http://purl.org/rss/1.0/modules/annotate/' =>            'annotate',
      'http://media.tangent.org/rss/1.0/' =>                    'audio',
      'http://backend.userland.com/blogChannelModule' =>        'blogChannel',
      'http://web.resource.org/cc/' =>                          'cc',
      'http://backend.userland.com/creativeCommonsRssModule' => 'creativeCommons',
      'http://purl.org/rss/1.0/modules/company' =>              'co',
      'http://purl.org/rss/1.0/modules/content/' =>             'content',
      'http://my.theinfo.org/changed/1.0/rss/' =>               'cp',
      'http://purl.org/dc/elements/1.1/' =>                     'dc',
      'http://purl.org/dc/terms/' =>                            'dcterms',
      'http://purl.org/rss/1.0/modules/email/' =>               'email',
      'http://purl.org/rss/1.0/modules/event/' =>               'ev',
      'http://rssnamespace.org/feedburner/ext/1.0' =>           'feedburner',
      'http://freshmeat.net/rss/fm/' =>                         'fm',
      'http://xmlns.com/foaf/0.1/' =>                           'foaf',
      'http://www.w3.org/2003/01/geo/wgs84_pos#' =>             'geo',
      'http://postneo.com/icbm/' =>                             'icbm',
      'http://purl.org/rss/1.0/modules/image/' =>               'image',
      'http://www.itunes.com/DTDs/PodCast-1.0.dtd' =>           'itunes',
      'http://example.com/DTDs/PodCast-1.0.dtd' =>              'itunes',
      'http://purl.org/rss/1.0/modules/link/' =>                'l',
      'http://search.yahoo.com/mrss' =>                         'media',
      'http://madskills.com/public/xml/rss/module/pingback/' => 'pingback',
      'http://prismstandard.org/namespaces/1.2/basic/' =>       'prism',
      'http://www.w3.org/1999/02/22-rdf-syntax-ns#' =>          'rdf',
      'http://www.w3.org/2000/01/rdf-schema#' =>                'rdfs',
      'http://purl.org/rss/1.0/modules/reference/' =>           'ref',
      'http://purl.org/rss/1.0/modules/richequiv/' =>           'reqv',
      'http://purl.org/rss/1.0/modules/search/' =>              'search',
      'http://purl.org/rss/1.0/modules/slash/' =>               'slash',
      'http://schemas.xmlsoap.org/soap/envelope/' =>            'soap',
      'http://purl.org/rss/1.0/modules/servicestatus/' =>       'ss',
      'http://hacks.benhammersley.com/rss/streaming/' =>        'str',
      'http://purl.org/rss/1.0/modules/subscription/' =>        'sub',
      'http://purl.org/rss/1.0/modules/syndication/' =>         'sy',
      'http://purl.org/rss/1.0/modules/taxonomy/' =>            'taxo',
      'http://purl.org/rss/1.0/modules/threading/' =>           'thr',
      'http://purl.org/rss/1.0/modules/textinput/' =>           'ti',
      'http://madskills.com/public/xml/rss/module/trackback/' =>'trackback',
      'http://wellformedweb.org/commentAPI/' =>                 'wfw',
      'http://purl.org/rss/1.0/modules/wiki/' =>                'wiki',
      'http://www.w3.org/1999/xhtml' =>                         'xhtml',
      'http://www.w3.org/XML/1998/namespace' =>                 'xml',
      'http://www.w3.org/1999/xlink' =>                         'xlink',
      'http://schemas.pocketsoap.com/rss/myDescModule/' =>      'szf'
    }
    @matchnamespaces = {}
    @namespaces.each do |l|
      @matchnamespaces[l[0].downcase] = l[1]
    end
    @can_be_relative_uri = ['link', 'id', 'wfw_comment', 'wfw_commentrss', 'docs', 'url', 'href', 'comments', 'license', 'icon', 'logo']
    @can_contain_relative_uris = ['content', 'title', 'summary', 'info', 'tagline', 'subtitle', 'copyright', 'rights', 'description']
    @can_contain_dangerous_markup = ['content', 'title', 'summary', 'info', 'tagline', 'subtitle', 'copyright', 'rights', 'description']
    @html_types = ['text/html', 'application/xhtml+xml']
    @feeddata = FeedParserDict.new # feed-level data
    @encoding = encoding # character encoding
    @entries = [] # list of entry-level data
    @version = '' # feed type/version see SUPPORTED_VERSIOSN
    @namespacesInUse = {} # hash of namespaces defined by the feed

    # the following are used internall to track state;
    # this is really out of control and should be refactored
    @infeed = false
    @inentry = false
    @incontent = 0 # Yes, this needs to be zero until I work out popContent and pushContent
    @intextinput = false
    @inimage = false
    @inauthor = false
    @incontributor = false
    @inpublisher = false
    @insource = false
    @sourcedata = FeedParserDict.new
    @contentparams = FeedParserDict.new
    @summaryKey = nil
    @namespacemap = {}
    @elementstack = []
    @basestack = []
    @langstack = []
    @baseuri = baseuri || ''
    @lang = baselang || nil
    @has_title = false
    if baselang 
      @feeddata['language'] = baselang.gsub('_','-')
    end
    $stderr << "Leaving startup\n" if $debug # My addition
  end

  def unknown_starttag(tag, attrsd)
    $stderr << "start #{tag} with #{attrsd}\n" if $debug
    # normalize attrs
    attrsD = {}
    attrsd = Hash[*attrsd.flatten] if attrsd.class == Array # Magic! Asterisk!
    # LooseFeedParser needs the above because SGMLParser sends attrs as a 
    # list of lists (like [['type','text/html'],['mode','escaped']])

    attrsd.each do |old_k,value| 
      # There has to be a better, non-ugly way of doing this
      k = old_k.downcase # Downcase all keys
      attrsD[k] = value
      if ['rel','type'].include?value
        attrsD[k].downcase!   # Downcase the value if the key is 'rel' or 'type'
      end
    end

    # track xml:base and xml:lang
    baseuri = attrsD['xml:base'] || attrsD['base'] || @baseuri 
    @baseuri = urljoin(@baseuri, baseuri)
    lang = attrsD['xml:lang'] || attrsD['lang']
    if lang == '' # FIXME This next bit of code is right? Wtf?
      # xml:lang could be explicitly set to '', we need to capture that
      lang = nil
    elsif lang.nil?
      # if no xml:lang is specified, use parent lang
      lang = @lang
    end

    if lang and not lang.empty? # Seriously, this cannot be correct
      if ['feed', 'rss', 'rdf:RDF'].include?tag
        @feeddata['language'] = lang.gsub('_','-')
      end
    end
    @lang = lang
    @basestack << @baseuri 
    @langstack << lang

    # track namespaces
    attrsd.each do |prefix, uri|
      if /^xmlns:/ =~ prefix # prefix begins with xmlns:
        trackNamespace(prefix[6..-1], uri)
      elsif prefix == 'xmlns':
        trackNamespace(nil, uri)
      end
    end

    # track inline content
    if @incontent != 0 and @contentparams.has_key?('type') and not ( /xml$/ =~ (@contentparams['type'] || 'xml') )
      # element declared itself as escaped markup, but isn't really

      @contentparams['type'] = 'application/xhtml+xml'
    end
    if @incontent != 0 and @contentparams['type'] == 'application/xhtml+xml'
      # Note: probably shouldn't simply recreate localname here, but
      # our namespace handling isn't actually 100% correct in cases where
      # the feed redefines the default namespace (which is actually
      # the usual case for inline content, thanks Sam), so here we
      # cheat and just reconstruct the element based on localname
      # because that compensates for the bugs in our namespace handling.
      # This will horribly munge inline content with non-empty qnames,
      # but nobody actually does that, so I'm not fixing it.
      tag = tag.split(':')[-1]
      attrsA = attrsd.to_a.collect{|l| "#{l[0]}=\"#{l[1]}\""}
      attrsS = ' '+attrsA.join(' ')
      return handle_data("<#{tag}#{attrsS}>", escape=false) 
    end

    # match namespaces
    if /:/ =~ tag
      prefix, suffix = tag.split(':', 2)
    else
      prefix, suffix = '', tag
    end
    prefix = @namespacemap[prefix] || prefix
    if prefix and not prefix.empty?
      prefix = prefix + '_'
    end

    # special hack for better tracking of empty textinput/image elements in illformed feeds
    if (not prefix and not prefix.empty?) and not (['title', 'link', 'description','name'].include?tag)
      @intextinput = false
    end
    if (prefix.nil? or prefix.empty?) and not (['title', 'link', 'description', 'url', 'href', 'width', 'height'].include?tag)
      @inimage = false
    end

    # call special handler (if defined) or default handler
    begin
      return send('_start_'+prefix+suffix, attrsD)
    rescue NoMethodError
      return push(prefix + suffix, true) 
    end  
  end # End unknown_starttag

  def unknown_endtag(tag)
    $stderr << "end #{tag}\n" if $debug
    # match namespaces
    if tag.index(':')
      prefix, suffix = tag.split(':',2)
    else
      prefix, suffix = '', tag
    end
    prefix = @namespacemap[prefix] || prefix
    if prefix and not prefix.empty?
      prefix = prefix + '_'
    end

    # call special handler (if defined) or default handler
    begin
      send('_end_' + prefix + suffix) # NOTE no return here! do not add it!
    rescue NoMethodError => details
      pop(prefix + suffix)
    end

    # track inline content
    if @incontent != 0 and @contentparams.has_key?'type' and /xml$/ =~ (@contentparams['type'] || 'xml')
      # element declared itself as escaped markup, but it isn't really
      @contentparams['type'] = 'application/xhtml+xml'
    end
    if @incontent != 0 and @contentparams['type'] == 'application/xhtml+xml'
      tag = tag.split(':')[-1]
      handle_data("</#{tag}>", escape=false)
    end

    # track xml:base and xml:lang going out of scope
    if @basestack and not @basestack.empty?
      @basestack.pop
      if @basestack and @basestack[-1] and not (@basestack.empty? or @basestack[-1].empty?)
        @baseuri = @basestack[-1]
      end
    end
    if @langstack and not @langstack.empty?
      @langstack.pop
      if @langstack and not @langstack.empty? # and @langstack[-1] and not @langstack.empty?
        @lang = @langstack[-1]
      end
    end
  end

  def handle_charref(ref)
    # LooseParserOnly 
    # called for each character reference, e.g. for '&#160;', ref will be '160'
    $stderr << "entering handle_charref with #{ref}\n" if $debug
    return if @elementstack.nil? or @elementstack.empty? 
    ref.downcase!
    chars = ['34', '38', '39', '60', '62', 'x22', 'x26', 'x27', 'x3c', 'x3e']
    if chars.include?ref
      text = "&##{ref};"
    else
      if ref[0..0] == 'x'
        c = (ref[1..-1]).to_i(16)
      else
        c = ref.to_i
      end
      text = [c].pack('U*')
    end
    @elementstack[-1][2] << text
  end

  def handle_entityref(ref)
    # LooseParserOnly
    # called for each entity reference, e.g. for '&copy;', ref will be 'copy'

    return if @elementstack.nil? or @elementstack.empty?
    $stderr << "entering handle_entityref with #{ref}\n" if $debug
    ents = ['lt', 'gt', 'quot', 'amp', 'apos']
    if ents.include?ref
      text = "&#{ref};"
    else
      text = HTMLEntities::decode_entities("&#{ref};")
    end
    @elementstack[-1][2] << text
  end

  def handle_data(text, escape=true)
    # called for each block of plain text, i.e. outside of any tag and
    # not containing any character or entity references
    return if @elementstack.nil? or @elementstack.empty?
    if escape and @contentparams['type'] == 'application/xhtml+xml'
      text = text.to_xs
    end
    @elementstack[-1][2] << text
  end

  def handle_comment(comment)
    # called for each comment, e.g. <!-- insert message here -->
  end

  def handle_pi(text)
  end

  def handle_decl(text)
  end

  def parse_declaration(i)
    # for LooseFeedParser
    $stderr << "entering parse_declaration\n" if $debug
    if @rawdata[i...i+9] == '<![CDATA['
      k = @rawdata.index(/\]\]>/u,i+9)
      k = @rawdata.length unless k
      handle_data(@rawdata[i+9...k].to_xs,false)
      return k+3
    else
      k = @rawdata.index(/>/,i).to_i
      return k+1
    end
  end

  def mapContentType(contentType)
    contentType.downcase!
    case contentType
    when 'text'
      contentType = 'text/plain'
    when 'html'
      contentType = 'text/html'
    when 'xhtml'
      contentType = 'application/xhtml+xml'
    end
    return contentType
  end

  def trackNamespace(prefix, uri)

    loweruri = uri.downcase.strip
    if [prefix, loweruri] == [nil, 'http://my.netscape.com/rdf/simple/0.9/'] and (@version.nil? or @version.empty?)
      @version = 'rss090'
    elsif loweruri == 'http://purl.org/rss/1.0/' and (@version.nil? or @version.empty?)
      @version = 'rss10'
    elsif loweruri == 'http://www.w3.org/2005/atom' and (@version.nil? or @version.empty?)
      @version = 'atom10'
    elsif /backend\.userland\.com\/rss/ =~ loweruri
      # match any backend.userland.com namespace
      uri = 'http://backend.userland.com/rss'
      loweruri = uri
    end
    if @matchnamespaces.has_key? loweruri
      @namespacemap[prefix] = @matchnamespaces[loweruri]
      @namespacesInUse[@matchnamespaces[loweruri]] = uri
    else
      @namespacesInUse[prefix || ''] = uri
    end
  end

  def resolveURI(uri)
    return urljoin(@baseuri || '', uri)
  end

  def decodeEntities(element, data)
    return data
  end

  def push(element, expectingText)
    @elementstack << [element, expectingText, []]
  end

  def pop(element, stripWhitespace=true)
    return if @elementstack.nil? or @elementstack.empty?
    return if @elementstack[-1][0] != element
    element, expectingText, pieces = @elementstack.pop

    if pieces.class == Array
      output = pieces.join('')
    else
      output = pieces
    end
    if stripWhitespace
      output.strip!
    end
    return output if not expectingText

    # decode base64 content
    if @contentparams['base64']
      out64 = Base64::decode64(output) # a.k.a. [output].unpack('m')[0]
      if not output.empty? and not out64.empty?
        output = out64
      end
    end

    # resolve relative URIs
    if @can_be_relative_uri.include?(element) && output && !output.empty?
      output = resolveURI(output)
    end

    # decode entities within embedded markup
    if not @contentparams['base64']
      output = decodeEntities(element, output)
    end

    # remove temporary cruft from contentparams
    @contentparams.delete('mode')
    @contentparams.delete('base64')

    # resolve relative URIs within embedded markup
    if @html_types.include?(mapContentType(@contentparams['type'] || 'text/html'))
      if @can_contain_relative_uris.include?(element)
        output = FeedParser.resolveRelativeURIs(output, @baseuri, @encoding)
      end
    end
    # sanitize embedded markup
    if @html_types.include?(mapContentType(@contentparams['type'] || 'text/html'))
      if @can_contain_dangerous_markup.include?(element)
        output = FeedParser.sanitizeHTML(output, @encoding)
      end
    end

    if @encoding and not @encoding.empty? and @encoding != 'utf-8'
      output = uconvert(output, @encoding, 'utf-8')
      # FIXME I turn everything into utf-8, not unicode, originally because REXML was being used but now beause I haven't tested it out yet.
    end

    # categories/tags/keywords/whatever are handled in _end_category
    return output if element == 'category'

    return output if element == 'title' and @has_title

    # store output in appropriate place(s)
    if @inentry and not @insource
      if element == 'content'
        @entries[-1][element] ||= []
        contentparams = Marshal.load(Marshal.dump(@contentparams)) # deepcopy
        contentparams['value'] = output
        @entries[-1][element] << contentparams
      elsif element == 'link'
        @entries[-1][element] = output
        if output and not output.empty?
          @entries[-1]['links'][-1]['href'] = output
        end
      else
        element = 'summary' if element == 'description'
        @entries[-1][element] = output
        if @incontent != 0
          contentparams = Marshal.load(Marshal.dump(@contentparams))
          contentparams['value'] = output
          @entries[-1][element + '_detail'] = contentparams
        end
      end
    elsif (@infeed or @insource) and not @intextinput and not @inimage
      context = getContext()
      element = 'subtitle' if element == 'description'
      context[element] = output
      if element == 'link'
        context['links'][-1]['href'] = output
      elsif @incontent != 0
        contentparams = Marshal.load(Marshal.dump(@contentparams))
        contentparams['value'] = output
        context[element + '_detail'] = contentparams
      end
    end

    return output
  end

  def pushContent(tag, attrsD, defaultContentType, expectingText)
    @incontent += 1 # Yes, I hate this.
    type = mapContentType(attrsD['type'] || defaultContentType)
    @contentparams = FeedParserDict.new({'type' => type,'language' => @lang,'base' => @baseuri})
    @contentparams['base64'] = isBase64(attrsD, @contentparams)
    push(tag, expectingText)
  end

  def popContent(tag)
    value = pop(tag)
    @incontent -= 1
    @contentparams.clear
    return value
  end

  def mapToStandardPrefix(name)
    colonpos = name.index(':')
    if colonpos
      prefix = name[0..colonpos-1]
      suffix = name[colonpos+1..-1]
      prefix = @namespacemap[prefix] || prefix
      name = prefix + ':' + suffix
    end
    return name
  end

  def getAttribute(attrsD, name)
    return attrsD[mapToStandardPrefix(name)]
  end

  def isBase64(attrsD, contentparams)
    return true if (attrsD['mode'] == 'base64')
    if /(^text\/)|(\+xml$)|(\/xml$)/ =~ contentparams['type']
      return false
    end
    return true
  end

  def itsAnHrefDamnIt(attrsD)
    href= attrsD['url'] || attrsD['uri'] || attrsD['href'] 
    if href
      attrsD.delete('url')
      attrsD.delete('uri')
      attrsD['href'] = href
    end
    return attrsD
  end


  def _save(key, value)
    context = getContext()
    context[key] ||= value
  end

  def _start_rss(attrsD)
    versionmap = {'0.91' => 'rss091u',
      '0.92' => 'rss092',
      '0.93' => 'rss093',
      '0.94' => 'rss094'
    }

    if not @version or @version.empty?
      attr_version = attrsD['version'] || ''
      version = versionmap[attr_version]
      if version and not version.empty?
        @version = version
      elsif /^2\./ =~ attr_version
        @version = 'rss20'
      else
        @version = 'rss'
      end
    end
  end

  def _start_dlhottitles(attrsD)
    @version = 'hotrss'
  end

  def _start_channel(attrsD)
    @infeed = true
    _cdf_common(attrsD)
  end
  alias :_start_feedinfo :_start_channel

  def _cdf_common(attrsD)
    if attrsD.has_key?'lastmod'
      _start_modified({})
      @elementstack[-1][-1] = attrsD['lastmod']
      _end_modified
    end
    if attrsD.has_key?'href'
      _start_link({})
      @elementstack[-1][-1] = attrsD['href']
      _end_link
    end
  end

  def _start_feed(attrsD)
    @infeed = true 
    versionmap = {'0.1' => 'atom01',
      '0.2' => 'atom02',
      '0.3' => 'atom03'
    }

    if not @version or @version.empty?
      attr_version = attrsD['version']
      version = versionmap[attr_version]
      if @version and not @version.empty?
        @version = version
      else
        @version = 'atom'
      end
    end
  end

  def _end_channel
    @infeed = false
  end
  alias :_end_feed :_end_channel

  def _start_image(attrsD)
    @inimage = true
    @has_title = false
    push('image', false)
    context = getContext()
    context['image'] ||= FeedParserDict.new
  end

  def _end_image
    pop('image')
    @inimage = false
  end

  def _start_textinput(attrsD)
    @intextinput = true
    @has_title = false
    push('textinput', false)
    context = getContext()
    context['textinput'] ||= FeedParserDict.new
  end
  alias :_start_textInput :_start_textinput

  def _end_textinput
    pop('textinput')
    @intextinput = false
  end
  alias :_end_textInput :_end_textinput

  def _start_author(attrsD)
    @inauthor = true
    push('author', true)
  end
  alias :_start_managingeditor :_start_author
  alias :_start_dc_author :_start_author
  alias :_start_dc_creator :_start_author
  alias :_start_itunes_author :_start_author

  def _end_author
    pop('author')
    @inauthor = false
    _sync_author_detail()
  end
  alias :_end_managingeditor :_end_author
  alias :_end_dc_author :_end_author
  alias :_end_dc_creator :_end_author
  alias :_end_itunes_author :_end_author

  def _start_itunes_owner(attrsD)
    @inpublisher = true
    push('publisher', false)
  end

  def _end_itunes_owner
    pop('publisher')
    @inpublisher = false
    _sync_author_detail('publisher')
  end

  def _start_contributor(attrsD)
    @incontributor = true
    context = getContext()
    context['contributors'] ||= []
    context['contributors'] << FeedParserDict.new
    push('contributor', false)
  end

  def _end_contributor
    pop('contributor')
    @incontributor = false
  end

  def _start_dc_contributor(attrsD)
    @incontributor = true
    context = getContext()
    context['contributors'] ||= []
    context['contributors'] << FeedParserDict.new
    push('name', false)
  end

  def _end_dc_contributor
    _end_name
    @incontributor = false
  end

  def _start_name(attrsD)
    push('name', false)
  end
  alias :_start_itunes_name :_start_name

  def _end_name
    value = pop('name')
    if @inpublisher
      _save_author('name', value, 'publisher')
    elsif @inauthor
      _save_author('name', value)
    elsif @incontributor
      _save_contributor('name', value)
    elsif @intextinput
      context = getContext()
      context['textinput']['name'] = value
    end
  end
  alias :_end_itunes_name :_end_name

  def _start_width(attrsD)
    push('width', false)
  end

  def _end_width
    value = pop('width').to_i
    if @inimage 
      context = getContext
      context['image']['width'] = value
    end
  end

  def _start_height(attrsD)
    push('height', false)
  end

  def _end_height
    value = pop('height').to_i
    if @inimage
      context = getContext()
      context['image']['height'] = value
    end
  end

  def _start_url(attrsD)
    push('href', true)
  end
  alias :_start_homepage :_start_url
  alias :_start_uri :_start_url

  def _end_url
    value = pop('href')
    if @inauthor
      _save_author('href', value)
    elsif @incontributor
      _save_contributor('href', value)
    elsif @inimage
      context = getContext()
      context['image']['href'] = value
    elsif @intextinput
      context = getContext()
      context['textinput']['link'] = value
    end
  end
  alias :_end_homepage :_end_url
  alias :_end_uri :_end_url

  def _start_email(attrsD)
    push('email', false)
  end
  alias :_start_itunes_email :_start_email

  def _end_email
    value = pop('email')
    if @inpublisher
      _save_author('email', value, 'publisher')
    elsif @inauthor
      _save_author('email', value)
    elsif @incontributor
      _save_contributor('email', value)
    end
  end
  alias :_end_itunes_email :_end_email

  def getContext
    if @insource
      context = @sourcedata
    elsif @inentry
      context = @entries[-1]
    else
      context = @feeddata
    end
    return context
  end

  def _save_author(key, value, prefix='author')
    context = getContext()
    context[prefix + '_detail'] ||= FeedParserDict.new
    context[prefix + '_detail'][key] = value
    _sync_author_detail()
  end

  def _save_contributor(key, value)
    context = getContext
    context['contributors'] ||= [FeedParserDict.new]
    context['contributors'][-1][key] = value
  end

  def _sync_author_detail(key='author')
    context = getContext()
    detail = context["#{key}_detail"]
    if detail and not detail.empty?
      name = detail['name']
      email = detail['email']

      if name and email and not (name.empty? or name.empty?)
        context[key] = "#{name} (#{email})"
      elsif name and not name.empty?
        context[key] = name
      elsif email and not email.empty?
        context[key] = email
      end
    else
      author = context[key].dup unless context[key].nil?
      return if not author or author.empty?
      emailmatch = author.match(/(([a-zA-Z0-9\_\-\.\+]+)@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.)|(([a-zA-Z0-9\-]+\.)+))([a-zA-Z]{2,4}|[0-9]{1,3})(\]?))/)
      email = emailmatch[1]
      author.gsub!(email, '')
      author.gsub!("\(\)", '')
      author.strip!
      author.gsub!(/^\(/,'')
      author.gsub!(/\)$/,'')
      author.strip!
      context["#{key}_detail"] ||= FeedParserDict.new
      context["#{key}_detail"]['name'] = author
      context["#{key}_detail"]['email'] = email
    end
  end

  def _start_subtitle(attrsD)
    pushContent('subtitle', attrsD, 'text/plain', true)
  end
  alias :_start_tagline :_start_subtitle
  alias :_start_itunes_subtitle :_start_subtitle

  def _end_subtitle
    popContent('subtitle')
  end
  alias :_end_tagline :_end_subtitle
  alias :_end_itunes_subtitle :_end_subtitle

  def _start_rights(attrsD)
    pushContent('rights', attrsD, 'text/plain', true)
  end
  alias :_start_dc_rights :_start_rights
  alias :_start_copyright :_start_rights

  def _end_rights
    popContent('rights')
  end
  alias :_end_dc_rights :_end_rights
  alias :_end_copyright :_end_rights

  def _start_item(attrsD)
    @entries << FeedParserDict.new
    push('item', false)
    @inentry = true
    @has_title = false
    @guidislink = false
    id = getAttribute(attrsD, 'rdf:about')
    if id and not id.empty?
      context = getContext()
      context['id'] = id
    end
    _cdf_common(attrsD)
  end
  alias :_start_entry :_start_item
  alias :_start_product :_start_item

  def _end_item
    pop('item')
    @inentry = false
  end
  alias :_end_entry :_end_item

  def _start_dc_language(attrsD)
    push('language', true)
  end
  alias :_start_language :_start_dc_language

  def _end_dc_language
    @lang = pop('language')
  end
  alias :_end_language :_end_dc_language

  def _start_dc_publisher(attrsD)
    push('publisher', true)
  end
  alias :_start_webmaster :_start_dc_publisher

  def _end_dc_publisher
    pop('publisher')
    _sync_author_detail('publisher')
  end
  alias :_end_webmaster :_end_dc_publisher

  def _start_published(attrsD)
    push('published', true)
  end
  alias :_start_dcterms_issued :_start_published
  alias :_start_issued :_start_published

  def _end_published
    value = pop('published')
    d = parse_date(value)
    _save('published_parsed', extract_tuple(d))
    _save('published_time', d)
  end
  alias :_end_dcterms_issued :_end_published
  alias :_end_issued :_end_published

  def _start_updated(attrsD)
    push('updated', true)
  end
  alias :_start_modified :_start_updated
  alias :_start_dcterms_modified :_start_updated
  alias :_start_pubdate :_start_updated
  alias :_start_dc_date :_start_updated

  def _end_updated
    value = pop('updated')
    d = parse_date(value)
    _save('updated_parsed', extract_tuple(d))
    _save('updated_time', d)
  end
  alias :_end_modified :_end_updated
  alias :_end_dcterms_modified :_end_updated
  alias :_end_pubdate :_end_updated
  alias :_end_dc_date :_end_updated

  def _start_created(attrsD)
    push('created', true)
  end
  alias :_start_dcterms_created :_start_created

  def _end_created
    value = pop('created')
    d = parse_date(value)
    _save('created_parsed', extract_tuple(d))
    _save('created_time', d)
  end
  alias :_end_dcterms_created :_end_created

  def _start_expirationdate(attrsD)
    push('expired', true)
  end
  def _end_expirationdate
    d = parse_date(pop('expired'))
    _save('expired_parsed', extract_tuple(d))
    _save('expired_time', d)
  end

  def _start_cc_license(attrsD)
    push('license', true)
    value = getAttribute(attrsD, 'rdf:resource')
    if value and not value.empty?
      @elementstack[-1][2] <<  value
      pop('license')
    end
  end

  def _start_creativecommons_license(attrsD)
    push('license', true)
  end

  def _end_creativecommons_license
    pop('license')
  end

  def addTag(term, scheme, label)
    context = getContext()
    context['tags'] ||= []
    tags = context['tags']
    if (term.nil? or term.empty?) and (scheme.nil? or scheme.empty?) and (label.nil? or label.empty?)
      return
    end
    value = FeedParserDict.new({'term' => term, 'scheme' => scheme, 'label' => label})
    if not tags.include?value
      context['tags'] << FeedParserDict.new({'term' => term, 'scheme' => scheme, 'label' => label})
    end
  end

  def _start_category(attrsD)
    $stderr << "entering _start_category with #{attrsD}\n" if $debug

    term = attrsD['term']
    scheme = attrsD['scheme'] || attrsD['domain']
    label = attrsD['label']
    addTag(term, scheme, label)
    push('category', true)
  end
  alias :_start_dc_subject :_start_category
  alias :_start_keywords :_start_category

  def _end_itunes_keywords
    pop('itunes_keywords').split.each do |term|
      addTag(term, 'http://www.itunes.com/', nil)
    end
  end

  def _start_itunes_category(attrsD)
    addTag(attrsD['text'], 'http://www.itunes.com/', nil)
    push('category', true)
  end

  def _end_category
    value = pop('category')
    return if value.nil? or value.empty?
    context = getContext()
    tags = context['tags']
    if value and not value.empty? and not tags.empty? and not tags[-1]['term']:
      tags[-1]['term'] = value
    else
      addTag(value, nil, nil)
    end
  end
  alias :_end_dc_subject :_end_category
  alias :_end_keywords :_end_category
  alias :_end_itunes_category :_end_category

  def _start_cloud(attrsD)
    getContext()['cloud'] = FeedParserDict.new(attrsD)
  end

  def _start_link(attrsD)
    attrsD['rel'] ||= 'alternate'
    attrsD['type'] ||= 'text/html'
    attrsD = itsAnHrefDamnIt(attrsD)
    if attrsD.has_key? 'href'
      attrsD['href'] = resolveURI(attrsD['href'])
    end
    expectingText = @infeed || @inentry || @insource
    context = getContext()
    context['links'] ||= []
    context['links'] << FeedParserDict.new(attrsD)
    if attrsD['rel'] == 'enclosure'
      _start_enclosure(attrsD)
    end
    if attrsD.has_key? 'href'
      expectingText = false
      if (attrsD['rel'] == 'alternate') and @html_types.include?mapContentType(attrsD['type'])
        context['link'] = attrsD['href']
      end
    else
      push('link', expectingText)
    end
  end
  alias :_start_producturl :_start_link

  def _end_link
    value = pop('link')
    context = getContext()
    if @intextinput
      context['textinput']['link'] = value
    end
    if @inimage
      context['image']['link'] = value
    end
  end
  alias :_end_producturl :_end_link

  def _start_guid(attrsD)
    @guidislink = ((attrsD['ispermalink'] || 'true') == 'true')
    push('id', true)
  end

  def _end_guid
    value = pop('id')
    _save('guidislink', (@guidislink and not getContext().has_key?('link')))
    if @guidislink:
      # guid acts as link, but only if 'ispermalink' is not present or is 'true',
      # and only if the item doesn't already have a link element
      _save('link', value)
    end
  end


  def _start_title(attrsD)
    pushContent('title', attrsD, 'text/plain', @infeed || @inentry || @insource)
  end
  alias :_start_dc_title :_start_title
  alias :_start_media_title :_start_title

  def _end_title
    value = popContent('title')
    context = getContext
    if @intextinput
      context['textinput']['title'] = value
    elsif @inimage
      context['image']['title'] = value
    end
    @has_title = true
  end
  alias :_end_dc_title :_end_title

  def _end_media_title
    orig_has_title = @has_title
    _end_title
    @has_title = orig_has_title
  end

  def _start_description(attrsD)
    context = getContext()
    if context.has_key?('summary')
      @summaryKey = 'content'
      _start_content(attrsD)
    else
      pushContent('description', attrsD, 'text/html', @infeed || @inentry || @insource)
    end
  end

  def _start_abstract(attrsD)
    pushContent('description', attrsD, 'text/plain', @infeed || @inentry || @insource)
  end

  def _end_description
    if @summaryKey == 'content'
      _end_content()
    else
      value = popContent('description')
      context = getContext()
      if @intextinput
        context['textinput']['description'] = value
      elsif @inimage:
        context['image']['description'] = value
      end
    end
    @summaryKey = nil
  end
  alias :_end_abstract :_end_description

  def _start_info(attrsD)
    pushContent('info', attrsD, 'text/plain', true)
  end
  alias :_start_feedburner_browserfriendly :_start_info

  def _end_info
    popContent('info')
  end
  alias :_end_feedburner_browserfriendly :_end_info

  def _start_generator(attrsD)
    if attrsD and not attrsD.empty?
      attrsD = itsAnHrefDamnIt(attrsD)
      if attrsD.has_key?('href')
        attrsD['href'] = resolveURI(attrsD['href'])
      end
    end
    getContext()['generator_detail'] = FeedParserDict.new(attrsD)
    push('generator', true)
  end

  def _end_generator
    value = pop('generator')
    context = getContext()
    if context.has_key?('generator_detail')
      context['generator_detail']['name'] = value
    end
  end

  def _start_admin_generatoragent(attrsD)
    push('generator', true)
    value = getAttribute(attrsD, 'rdf:resource')
    if value and not value.empty?
      @elementstack[-1][2] << value
    end
    pop('generator')
    getContext()['generator_detail'] = FeedParserDict.new({'href' => value})
  end

  def _start_admin_errorreportsto(attrsD)
    push('errorreportsto', true)
    value = getAttribute(attrsD, 'rdf:resource')
    if value and not value.empty?
      @elementstack[-1][2] << value
    end
    pop('errorreportsto')
  end

  def _start_summary(attrsD)
    context = getContext()
    if context.has_key?'summary'
      @summaryKey = 'content'
      _start_content(attrsD)
    else
      @summaryKey = 'summary'
      pushContent(@summaryKey, attrsD, 'text/plain', true)
    end
  end
  alias :_start_itunes_summary :_start_summary

  def _end_summary
    if @summaryKey == 'content':
      _end_content()
    else
      popContent(@summaryKey || 'summary')
    end
    @summaryKey = nil
  end
  alias :_end_itunes_summary :_end_summary

  def _start_enclosure(attrsD)
    attrsD = itsAnHrefDamnIt(attrsD)
    getContext()['enclosures'] ||= []
    getContext()['enclosures'] << FeedParserDict.new(attrsD)
    href = attrsD['href']
    if href and not href.empty?
      context = getContext()
      if not context['id']
        context['id'] = href
      end
    end
  end
  alias :_start_media_content :_start_enclosure
  alias :_start_media_thumbnail :_start_enclosure

  def _start_source(attrsD)
    @insource = true
    @has_title = false
  end

  def _end_source
    @insource = false
    getContext()['source'] = Marshal.load(Marshal.dump(@sourcedata))
    @sourcedata.clear()
  end

  def _start_content(attrsD)
    pushContent('content', attrsD, 'text/plain', true)
    src = attrsD['src']
    if src and not src.empty?:
      @contentparams['src'] = src
    end
    push('content', true)
  end

  def _start_prodlink(attrsD)
    pushContent('content', attrsD, 'text/html', true)
  end

  def _start_body(attrsD)
    pushContent('content', attrsD, 'application/xhtml+xml', true)
  end
  alias :_start_xhtml_body :_start_body

  def _start_content_encoded(attrsD)
    pushContent('content', attrsD, 'text/html', true)
  end
  alias :_start_fullitem :_start_content_encoded

  def _end_content
    copyToDescription = (['text/plain'] + @html_types).include? mapContentType(@contentparams['type'])
    value = popContent('content')
    if copyToDescription
      _save('description', value)
    end
  end
  alias :_end_body :_end_content
  alias :_end_xhtml_body :_end_content
  alias :_end_content_encoded :_end_content
  alias :_end_fullitem :_end_content
  alias :_end_prodlink :_end_content
  
  def _start_itunes_image(attrsD)
    push('itunes_image', false)
    getContext()['image'] = FeedParserDict.new({'href' => attrsD['href']})
  end
  alias :_start_itunes_link :_start_itunes_image

  def _end_itunes_block
    value = pop('itunes_block', false)
    getContext()['itunes_block'] = (value == 'yes') and true or false
  end

  def _end_itunes_explicit
    value = pop('itunes_explicit', false)
    getContext()['itunes_explicit'] = (value == 'yes') and true or false
  end
  
end # End FeedParserMixin
end

def urljoin(base, uri)
  urifixer = /^([A-Za-z][A-Za-z0-9+-.]*:\/\/)(\/*)(.*?)/u
  uri = uri.sub(urifixer, '\1\3') 
  pbase = Addressable::URI.parse(base) rescue nil
  if pbase && pbase.absolute?
    puri = Addressable::URI.parse(uri) rescue nil
    if puri && puri.relative?
      # ForgivingURI.join does the wrong thing.  What the hell.
      return Addressable::URI.join(base, uri).to_s.gsub(/[^:]\/{2,}/, '')
    end
  end
  return uri
end
