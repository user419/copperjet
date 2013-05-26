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
  url = "http://#{dom}/configuration/fw_natParms.html?ImFireWall.ImFwInterfaces.ppp-0"
  res = RestClient.get url
  doc = Nokogiri::HTML(res)
  
  success = false
  doc.search('table > tr').each do |tr_tag|
    # Only continue on XML elements (td's?)
    if tr_tag.children[2].class == Nokogiri::XML::Element
      # Check if tr_tag has our desired IP
      if tr_tag.children[2].content == desired_ip
  
        # Check if tr_tag has our desired transport
        if tr_tag.children[4].content == desired_transport
         
          # Continue to check port
          if tr_tag.children[6].content == desired_port
            success = true
          end
        end
      end
    end
  end
  
  return success
end

def putInMapping(desired_ip, desired_transport, desired_port, user, pass, modem_ip) 

# GET location for our temp resp_var
# http://172.19.3.1/configuration/fw_addReservedMapping.html?ImFireWall.ImFwInterfaces.ppp-0

dom = "#{user}:#{pass}@#{modem_ip}"
url = "http://#{dom}/configuration/fw_addReservedMapping.html?ImFireWall.ImFwInterfaces.ppp-0"
res = RestClient.get url
doc = Nokogiri::HTML(res)

response_var = 0
doc.css('input').each do |i|
  if i['name'] == "EmWeb_ns:vim:2"
    response_var = i['value']
  end
end

# POST location
# http://172.19.3.1/configuration/fw_addReservedMapping.html/fwAddReservedMapping
# POST data
#   EmWeb_ns%3Avim%3A2  = 45                           # Our response_var
#  &EmWeb_ns%3Avim%3A3  = %2Fconfiguration%2Ffw_natParms.html
#  &EmWeb_ns%3Avim%3A11 = ImFireWall.ImFwInterfaces.ppp-0
#  &EmWeb_ns%3Avim%3A7._mapping = ImFwNATresvMap
#  &EmWeb_ns%3Avim%3A4._mapping%3AInterfaceName         = ppp-0
#  &EmWeb_ns%3Avim%3A4._mapping%3AGlobalIPaddress       = 0.0.0.0
#  &EmWeb_ns%3Avim%3A4._mapping%3AInternalIPaddress     = 172.19.3.1
#  &EmWeb_ns%3Avim%3A4._mapping%3ATransportType         = udp
#  &EmWeb_ns%3Avim%3A4._mapping%3APortNumber            = 1000
#  &EmWeb_ns%3Avim%3A4._mapping%3ASecondPortNumber      = 1000
#  &EmWeb_ns%3Avim%3A4._mapping%3ALocalPortNumber       = 1000
#  &EmWeb_ns%3Avim%3A4._mapping%3ASecondLocalPortNumber = 1000
#  &EmWeb_ns%3Avim%3A24._mapping=GlobalIPaddress%2CTransportType%2CPortNumber%2CSecondPortNumber%3AReserved+Mapping+already+defined
#  &EmWeb_ns%3Avim%3A8._mapping=ImFireWall.ImFwInterfaces.ppp-0.ImFwNATresvMaps


url    = "http://#{modem_ip}/configuration/fw_addReservedMapping.html/fwAddReservedMapping"
post   = "EmWeb_ns%3Avim%3A2=#{response_var}&EmWeb_ns%3Avim%3A3=%2Fconfiguration%2Ffw_natParms.html&EmWeb_ns%3Avim%3A11=ImFireWall.ImFwInterfaces.ppp-0&EmWeb_ns%3Avim%3A7._mapping=ImFwNATresvMap&EmWeb_ns%3Avim%3A4._mapping%3AInterfaceName=ppp-0&EmWeb_ns%3Avim%3A4._mapping%3AGlobalIPaddress=0.0.0.0&EmWeb_ns%3Avim%3A4._mapping%3AInternalIPaddress=#{desired_ip}&EmWeb_ns%3Avim%3A4._mapping%3ATransportType=#{desired_transport}&EmWeb_ns%3Avim%3A4._mapping%3APortNumber=#{desired_port}&EmWeb_ns%3Avim%3A4._mapping%3ASecondPortNumber=#{desired_port}&EmWeb_ns%3Avim%3A4._mapping%3ALocalPortNumber=#{desired_port}&EmWeb_ns%3Avim%3A4._mapping%3ASecondLocalPortNumber=#{desired_port}&EmWeb_ns%3Avim%3A24._mapping=GlobalIPaddress%2CTransportType%2CPortNumber%2CSecondPortNumber%3AReserved+Mapping+already+defined&EmWeb_ns%3Avim%3A8._mapping=ImFireWall.ImFwInterfaces.ppp-0.ImFwNATresvMaps"

  site = RestClient::Resource.new url, user, pass
  res = site.post post, :content_type => 'application/x-www-form-urlencoded'
  doc = Nokogiri::HTML(res)
  
  return checkForMapping( desired_ip, desired_transport, desired_port, user, pass, modem_ip)
end

##
#  Let's do it
##

if checkForMapping(desired_ip, desired_transport, desired_port, user, pass, modem_ip)
  puts "We already had our mapping => success"
else
  puts "We had nothing, trying it now"
  if putInMapping(desired_ip, desired_transport, desired_port, user, pass, modem_ip)
    puts "We put in our mapping => success"
  else
    puts "It failed, but hey at least we tried"
  end
end

