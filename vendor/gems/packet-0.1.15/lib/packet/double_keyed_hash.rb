module Packet
  class DoubleKeyedHash
#    include Enumerable
    attr_accessor :internal_hash
    def initialize
      @keys1 = {}
      @internal_hash = {}
    end

    def []=(key1,key2,value)
      @keys1[key2] = key1
      @internal_hash[key1] = value
    end

    def [] key
      @internal_hash[key] || @internal_hash[@keys1[key]]
    end

    def delete(key)
      t_key = @keys1[key]
      if t_key
        @keys1.delete(key)
        @internal_hash.delete(t_key)
      else
        @keys1.delete_if { |key,value| value == key }
        @internal_hash.delete(key)
      end
    end

    def length
      @internal_hash.keys.length
    end

    def each
      @internal_hash.each { |key,value| yield(key,value)}
    end
  end
end


