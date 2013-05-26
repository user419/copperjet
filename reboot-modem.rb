#!/usr/local/rvm/rubies/ruby-1.9.3-p125/bin/ruby
require 'rest_client'
require 'nokogiri'

##
#  What do we want?
##

modem_ip = "172.19.3.1"
user     = "user"
pass     = "user"

##
#  When do we want it?
##

##
#  How do we get it?
##

def reboot(modem_ip, user, pass)
  url  = "http://#{modem_ip}/reset/index.html?"
  post = ""

  site = RestClient::Resource.new url, user, pass
  res = site.post post, :content_type => 'application/x-www-form-urlencoded'

  doc = Nokogiri::HTML(res)

  success = false
  if doc.title() == "Restarting"
    success = true
  end

  return success
end

##
#  Let's do it
##

if reboot(modem_ip, user, pass)
  puts "Reboot started, yay"
else
  puts "Reboot did not start"
end

