module HeyWatch
  # Authenticate to the Hey!Watch service
  #
  #  user = Auth.create("login", "password")
  #  user.account
  #
  # If you want to recover a session:
  #
  #  user = Auth.recover(session_id)
  #  user.account
  #
  # The initialize and create methods can take blocks.
  #
  #  Auth.create("login", "password") do |user|
  #    video = user.videos.find(:first)
  #    format = user.formats.find(:first, :conditions => {:name => "iPod 4:3"})
  #    user.jobs.create :video_id => video.id, :format_id => format.id
  #  end
  #
  # All the resources (pluralized) are available within the Auth class:
  #
  #  jobs, encoded_videos, videos, formats, downloads, discovers, logs, account
  #
	class Auth
    attr_reader :session
    @@sessions = {}
    
    # Authenticate to the Hey!Watch service
    #
    # options can be:
    #
    # * <tt>:login</tt> Hey!Watch username
    # * <tt>:password</tt> Hey!Watch password
    # * <tt>:session</tt> A previous session, using this option, you will not be reconnected, you will just recover your session
		def initialize(options={}, &block)
      if options[:session]
        @session = options[:session]
      else
        @session = Browser::login(options[:login], options[:password])
        @@sessions.merge!(@session => true)
      end
      yield self if block_given?
		end
		
		# Same as initialize
		#
    #   Auth::create 'login', 'password'
    def self.create(login, password, &block)
      new(:login => login, :password => password, &block)
    end
    
    # Recover a session
    #
    #  Auth.recover(session_id)
    def self.recover(session, &block)
      #raise SessionNotFound if @@sessions[session].nil?
      new(:session => session, &block)
    end

    Resources.each do |k| 
      Auth.module_eval(%{
                         def #{k.to_s+"s"}
                           klass = #{k.to_s.camelize}
                           klass.session = @session
                           klass
                         end
                        }
                      )
    end
    
    # Delete the current session
    def destroy
      @@sessions.delete(@session)
      @session = nil
    end
    
    # Show account info
    def account
      Account.session = @session
      Account.find(:first)
    end
	end
end
