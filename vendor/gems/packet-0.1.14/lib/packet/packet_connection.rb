module Packet
  module Connection
    attr_accessor :outbound_data,:connection_live
    attr_accessor :worker,:connection,:reactor, :initialized,:signature
    include NbioHelper

    def unbind; end
    def connection_completed; end
    def post_init; end
    def receive_data data; end

    def send_data p_data
      @outbound_data << p_data
      begin
        write_and_schedule(connection)
      rescue DisconnectError => sock
        close_connection
      end
    end

    def invoke_init
      @initialized = true
      @connection_live = true
      @outbound_data = []
      post_init
    end

    def close_connection(sock = nil)
      unbind
      reactor.cancel_write(connection)
      reactor.remove_connection(connection)
    end

    def close_connection_after_writing
      connection.flush unless connection.closed?
      close_connection
    end

    def get_peername
      connection.getpeername
    end

    def send_object p_object
      dump_object(p_object,connection)
    end

    def ask_worker(*args)
      worker_name = args.shift
      data_options = args.last
      data_options[:client_signature] = connection.fileno
      t_worker = reactor.live_workers[worker_name]
      raise Packet::InvalidWorker.new("Invalid worker with name #{worker_name} and key #{data_options[:data][:worker_key]}") unless t_worker
      t_worker.send_request(data_options)
    end
    def start_server ip,port,t_module,&block
      reactor.start_server(ip,port,t_module,&block)
    end

    def connect ip,port,t_module,&block
      reactor.connect(ip,port,t_module,&block)
    end

    def add_periodic_timer interval, &block
      reactor.add_periodic_timer(interval,&block)
    end

    def add_timer(t_time,&block)
      reactor.add_timer(t_time,&block)
    end

    def cancel_timer(t_timer)
      reactor.cancel_timer(t_timer)
    end

    def reconnect server,port,handler
      reactor.reconnect(server,port,handler)
    end

    def start_worker(worker_options = {})
      reactor.start_worker(worker_options)
    end

    def delete_worker worker_options = {}
      reactor.delete_worker(worker_options)
    end

  end # end of class Connection
end # end of module Packet


