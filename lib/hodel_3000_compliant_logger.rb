require 'logger'
require 'English'
# Jan  2 03:38:05 topfunky postfix/postqueue[2947]: warning blah blah blah

##
# A logger for use with pl_analyze and other tools that expect syslog-style log output.

class Hodel3000CompliantLogger < Logger

  ##
  # Note: If you are using FastCGI you may need to hard-code the hostname here instead of using Socket.gethostname

  def format_message(severity, timestamp, progname, msg)
    "#{timestamp.strftime("%b %d %H:%M:%S")} #{hostname} rails[#{$PID}]: #{msg2str(msg).gsub(/\n/, '').lstrip}\n"
  end

  # original method, pre-patch for Exception handling:
  #
  # def format_message(severity, timestamp, msg, progname)
  #   "#{timestamp.strftime("%b %d %H:%M:%S")} #{Socket.gethostname.split('.').first} rails[#{$PID}]: #{progname.gsub(/\n/, '').lstrip}\n"
  # end

  private

  def hostname
    @parsed_hostname ||= Socket.gethostname.split('.').first
  end

  def msg2str(msg)
    case msg
    when ::String
      msg
    when ::Exception
      "#{ msg.message } (#{ msg.class }): " <<
      (msg.backtrace || []).join(" | ")
    else
      msg.inspect
    end
  end

end
