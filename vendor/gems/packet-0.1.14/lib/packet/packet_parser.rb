module Packet
  class BinParser
    attr_accessor :data,:numeric_length,:length_string,:remaining
    attr_accessor :parser_state
    def initialize
      @size = 0
      @data = []
      @remaining = ""
      # 0 => reading length
      # 1 => reading actual data
      @parser_state = 0
      @length_string = ""
      @numeric_length = 0
    end

    def reset
      @data = []
      @parser_state = 0
      @length_string = ""
      @numeric_length = 0
    end

    def extract new_data
      remaining = new_data

      loop do
        if @parser_state == 0
          length_to_read =  9 - @length_string.length
          len_str,remaining = remaining.unpack("a#{length_to_read}a*")
          break if len_str !~ /^\d+$/
          if len_str.length < length_to_read
            @length_string << len_str
            break
          else
            @length_string << len_str
            @numeric_length = @length_string.to_i
            @parser_state = 1
            if remaining.length < @numeric_length
              @data << remaining
              @numeric_length = @numeric_length - remaining.length
              break
            elsif remaining.length == @numeric_length
              @data << remaining
              yield(@data.join)
              reset
              break
            else
              pack_data,remaining = remaining.unpack("a#{@numeric_length}a*")
              @data << pack_data
              yield(@data.join)
              reset
            end
          end
        elsif @parser_state == 1
          pack_data,remaining = remaining.unpack("a#{@numeric_length}a*")
          if pack_data.length < @numeric_length
            @data << pack_data
            @numeric_length = @numeric_length - pack_data.length
            break
          elsif pack_data.length == @numeric_length
            @data << pack_data
            yield(@data.join)
            reset
            break
          else
            @data << pack_data
            yield(@data.join)
            reset
          end
        end # end of beginning if condition
      end # end of loop do
    end # end of extract method
  end # end of BinParser class
end # end of packet module

