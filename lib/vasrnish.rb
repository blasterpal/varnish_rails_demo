module Varnish
  require 'net/telnet'
  #requires telnet access from deploy machine
  def global_purge(varnish_host,varnish_port)
    #It WILL timeout, just accept it. Varnish does not have a command prompt.
    @result = ""
    begin
      varnish_server = Net::Telnet::new("Host" => varnish_host,
      "Port" => varnish_port.to_i,
      "Timeout" => 5)
      varnish_server.cmd("url.purge .*") { |c| @result = c}
    rescue Exception
      if @result.include?("200 0")
        return [true,"Varnish purged OK."]
      else
        return [false,"Varnish not purged."]
      end
    end
  end

end
