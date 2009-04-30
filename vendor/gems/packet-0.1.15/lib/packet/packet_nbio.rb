module Packet
  module NbioHelper
    def packet_classify(original_string)
      word_parts = original_string.split('_')
      return word_parts.map { |x| x.capitalize}.join
    end

    def gen_worker_key(worker_name,worker_key = nil)
      return worker_name if worker_key.nil?
      return "#{worker_name}_#{worker_key}".to_sym
    end

    def read_data(t_sock)
      sock_data = []
      begin
        while(t_data = t_sock.read_nonblock((16*1024)-1))
          sock_data << t_data
        end
      rescue Errno::EAGAIN
        return sock_data.join
      rescue Errno::EWOULDBLOCK
        return sock_data.join
      rescue
        raise DisconnectError.new(t_sock,sock_data.join)
      end
    end

    # method writes data to socket in a non blocking manner, but doesn't care if there is a error writing data
    def write_once(p_data,p_sock)
      t_data = p_data.to_s
      written_length = 0
      data_length = t_data.length
      begin
        written_length = p_sock.write_nonblock(t_data)
        return "" if written_length == data_length
        return t_data[written_length..-1]
      rescue Errno::EAGAIN
        return t_data[written_length..-1]
      rescue Errno::EPIPE
        raise DisconnectError.new(p_sock)
      rescue Errno::ECONNRESET
        raise DisconnectError.new(p_sock)
      rescue
        raise DisconnectError.new(p_sock)
      end
    end

    # write the data in socket buffer and schedule the thing
    def write_and_schedule sock
      outbound_data.each_with_index do |t_data,index|
        leftover = write_once(t_data,sock)
        if leftover.empty?
          outbound_data[index] = nil
        else
          outbound_data[index] = leftover
          reactor.schedule_write(sock,self)
          break
        end
      end
      outbound_data.compact!
      reactor.cancel_write(sock) if outbound_data.empty?
    end

    # returns Marshal dump of the specified object
    def object_dump p_data
      object_dump = Marshal.dump(p_data)
      dump_length = object_dump.length.to_s
      length_str = dump_length.rjust(9,'0')
      final_data = length_str + object_dump
    end

    # method dumps the object in a protocol format which can be easily picked by a recursive descent parser
    def dump_object(p_data,p_sock)
      object_dump = Marshal.dump(p_data)
      dump_length = object_dump.length.to_s
      length_str = dump_length.rjust(9,'0')
      final_data = length_str + object_dump
      outbound_data << final_data
      begin
        write_and_schedule(p_sock)
      rescue DisconnectError => sock
        close_connection(sock)
      end
    end
  end
end
