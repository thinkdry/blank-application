require "asteroid"

module Server
  def receive_data data

  end

  def post_init
    puts "A new client connected"
  end

  def unbind
    puts "client disconnected"
  end
end

Asteroid::run("0.0.0.0", 11007, Server) do
  puts "Someone connected"
end
