require "socket"
require "thread"

# sock = TCPSocket.open("localhost",11007)
#data = File.open("netbeans.jpg").read
data = File.open("nginx.dat").read
# p data.length

threads = []
500.times do
  #   sock.write(data)
  #   select([sock],nil,nil,nil)
  #   read_data = ""

  #   loop do
  #     begin
  #       while(read_data << sock.read_nonblock(1023)); end
  #     rescue Errno::EAGAIN
  #       break
  #     rescue
  #       break
  #     end
  #   end

  threads << Thread.new do
    sock = TCPSocket.open("localhost",11007)
    #   p read_data.length
    written_length = sock.write(data)
    p "Write Length: #{written_length}"
    read_length = sock.read(written_length)
    p "Read length: #{read_length.length}"
  end

#   #   p read_data.length
#   written_length = sock.write(data)
#   #p "Write Length: #{written_length}"
#   read_length = sock.read(written_length)
#   #p "Read length: #{read_length.length}"
end

threads.each { |x| x.join }
