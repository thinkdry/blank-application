$:.unshift(File.dirname(__FILE__)) unless
  $:.include?(File.dirname(__FILE__)) || $:.include?(File.expand_path(File.dirname(__FILE__)))

require "socket"
require "yaml"
require "forwardable"
require "ostruct"
require "thread"
require "fcntl"
#require "enumerable"

require "packet/packet_parser"
require "packet/packet_invalid_worker"
require "packet/packet_guid"
require "packet/packet_helper"
require "packet/double_keyed_hash"
require "packet/packet_event"
require "packet/packet_periodic_event"
require "packet/disconnect_error"
require "packet/packet_callback"
require "packet/packet_nbio"
require "packet/packet_pimp"
require "packet/packet_meta_pimp"
require "packet/packet_core"
require "packet/packet_master"
require "packet/packet_connection"
require "packet/packet_worker"

PACKET_APP = File.expand_path'../' unless defined?(PACKET_APP)

module Packet
  VERSION='0.1.14'
end
