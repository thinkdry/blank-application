#!/usr/bin/env ruby

# Add some helper methods to make AttributeList (all of those damn attrs
# and attrsD used by StrictFeedParser) act more like a Hash.
# NOTE AttributeList is still Read-Only (AFAICT).
# Monkey patching is terrible, and I have an addiction.
module XML
  module SAX
    module AttributeList # in xml/sax.rb
      def [](key)
        getValue(key)
      end

      def each(&blk)
        (0...getLength).each{|pos| yield [getName(pos), getValue(pos)]}
      end

      def each_key(&blk)
        (0...getLength).each{|pos| yield getName(pos) }
      end

      def each_value(&blk)
        (0...getLength).each{|pos| yield getValue(pos) }
      end

      def to_a # Rather use collect? grep for to_a.collect
        l = []
        each{|k,v| l << [k,v]}
        return l
      end

      def to_s
        l = []
        each{|k,v| l << "#{k} => #{v}"}
        "{ "+l.join(", ")+" }"
      end
    end
  end
end


