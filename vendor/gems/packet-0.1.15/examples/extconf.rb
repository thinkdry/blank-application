require 'mkmf'

unless have_header("sys/epoll.h") || have_header("sys/event.h")
  message "epoll or kqueue required.\n"
  exit 1
end

create_header
create_makefile 'asteroid'

