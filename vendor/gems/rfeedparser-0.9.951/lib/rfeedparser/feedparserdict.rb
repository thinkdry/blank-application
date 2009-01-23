#!/usr/bin/env ruby
module FeedParser
  class FeedParserDict < Hash 
=begin
     The naming of a certain common attribute (such as, "When was the last
     time this feed was updated?") can have many different names depending
     on the type of feed we are handling. This class allows us to satisfy
     the expectations of both the developer who has prior knowledge of the
     feed type as well as the developer who wants a consistent application
     interface.

     @@keymap is a Hash that contains information on what a certain
     attribute names "really are" in each kind of feed. It does this by
     providing a common name that will map to any feed type in the keys,
     with possible "correct" attributes in the its values. the #[] and #[]=
     methods check with keymaps to see what attribute the developer "really
     means" if they've asked for one which happens to be in @@keymap's keys.
=end
    @@keymap = {
      'channel' => 'feed',
      'items' => 'entries',
	    'guid' => 'id',
	    'date' => 'updated',
	    'date_parsed' => 'updated_parsed',
	    'description' => ['subtitle', 'summary'],
	    'url' => ['href'],
	    'modified' => 'updated',
	    'modified_parsed' => 'updated_parsed',
	    'issued' => 'published',
	    'issued_parsed' => 'published_parsed',
	    'copyright' => 'rights',
	    'copyright_detail' => 'rights_detail',
	    'tagline' => 'subtitle',
	    'tagline_detail' => 'subtitle_detail'
    }
    
    # Apparently, Hash has an entries method!  That blew a good 3 hours or more of my time
    alias :hash_entries :entries
    def entries 
      self['entries']
    end

    # Added to avoid deprecated method wornings
    alias :object_type :type
    def type
      self['type']
    end
    
    # We could include the [] rewrite in new using Hash.new's fancy pants block thing
    # but we'd still have to overwrite []= and such. 
    # I'm going to make it easy to turn lists of pairs into FeedParserDicts's though.
    def initialize(pairs=nil)
      if pairs.class == Array and pairs[0].class == Array and pairs[0].length == 2
	pairs.each do |l| 
	  k,v = l
	  self[k] = v
	end
      elsif pairs.class == Hash
	self.merge!(pairs) 
      end
    end

    def [](key)
      if key == 'category'
	return self['tags'][0]['term']
      end
      if key == 'categories'
	return self['tags'].collect{|tag| [tag['scheme'],tag['term']]}
      end
      realkey = @@keymap[key] || key 
      if realkey.class == Array
	realkey.each{ |key| return self[key] if has_key?key }
      end
      # Note that the original key is preferred over the realkey we (might 
      # have) found in @@keymap
      if has_key?(key)
	return super(key)
      end
      return super(realkey)
    end

    def []=(key,value)
      if @@keymap.key?key
	key = @@keymap[key]
	if key.class == Array
	  key = key[0]
	end
      end
      super(key,value)
    end

    def method_missing(msym, *args)
      methodname = msym.to_s
      if methodname[-1] == '='
	return self[methodname[0..-2]] = args[0]
      elsif methodname[-1] != '!' and methodname[-1] != '?' and methodname[0] != "_" # FIXME implement with private?
	return self[methodname]
      else
	raise NoMethodError, "whoops, we don't know about the attribute or method called `#{methodname}' for #{self}:#{self.class}"
      end
    end 
  end
end
