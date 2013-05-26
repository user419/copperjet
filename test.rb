#!/usr/local/rvm/rubies/ruby-1.9.3-p125/bin/ruby
require 'rest_client'
require 'nokogiri'

##
#  What mapping do we want?
##

desired_ip         = "172.19.3.2" # rt1.lan
desired_transport  = "udp"        # icmp, igmp, ip, tcp, egp, udp, rsvp, gre, ospf, ipip, all
desired_port       = "1194"       # openvpn

##
#  Where do we want it?
##

modem_ip = "172.19.3.1"
user     = "user"
pass     = "user"

##
#  How do we get it?
##

def checkForMapping(desired_ip, desired_transport, desired_port, user, pass, modem_ip) 
  dom = "#{user}:#{pass}@#{modem_ip}"
  url = "http://#{dom}/"
  res = RestClient.get url
  doc = Nokogiri::HTML(res)
  
  success = false

puts doc.class
puts doc.title()


  return success
end
checkForMapping(desired_ip, desired_transport, desired_port, user, pass, modem_ip) 

