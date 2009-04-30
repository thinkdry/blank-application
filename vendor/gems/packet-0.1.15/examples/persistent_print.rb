require "rubygems"
require "eventmachine"

module Client
  def receive_data data
    @tokenizer.extract(data).each do |b_data|
      client_data = b_data
      p "Client has sent #{client_data}"
    end
  end

  def start_push_on_client
    send_data("Hello World : #{Time.now}\n")
  end

  def post_init
    @tokenizer = BufferedTokenizer.new
    EM::add_periodic_timer(1) { start_push_on_client }
  end
end

EM.run do
  EM.start_server("localhost",11009,Client)
end
