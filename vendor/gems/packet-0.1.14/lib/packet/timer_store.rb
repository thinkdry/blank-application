=begin
 There are many ordered hash implementation of ordered hashes, but this one is for packet.
 Nothing more, nothing less.
=end

require "event" 
require "packet_guid" 

module Packet
  class TimerStore
    attr_accessor :order
    def initialize
      @order = []
      @container = { }
    end

    def store(timer)
      int_time = timer.scheduled_time.to_i
      @container[int_time] ||= []
      @container[int_time] << timer

      if @container.empty? or @order.empty?
        @order << int_time
        return
      end


      if @order.last <= int_time
        @order << int_time
      else
        index = bin_search_for_key(0,@order.length - 1,int_time)
        if(int_time < @order[index-1] && index != 0)
          @order.insert(index-1,int_time)
        else
          @order.insert(index,int_time)
        end
      end
    end

    def bin_search_for_key(lower_index,upper_index,key)
      return upper_index if(upper_index - lower_index <= 1)
      pivot = (lower_index + upper_index)/2
      if @order[pivot] == key
        return pivot
      elsif @order[pivot] < key
        bin_search_for_key(pivot,upper_index,key)
      else
        bin_search_for_key(lower_index,pivot,key)
      end
    end

    def each
      @order.each_with_index do |x,i|
        @container[x].each do |timer| 
          yield timer
        end
        # @container.delete(x) if @container[x].empty?
        # @order.delete_at(i)
      end
    end

    def delete(timer)
      int_time = timer.scheduled_time.to_i
      @container[int_time] && @container[int_time].delete(timer)

      if(!@container[int_time] || @container[int_time].empty?)
        @order.delete(timer)
      end
    end
  end
end
