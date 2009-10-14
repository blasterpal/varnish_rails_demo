require 'rubygems'

namespace "varnish" do

  desc "Purge ALL urls from Varnish"
  task :global_purge, :varnish_host do  |i, args|

    varnish_host = args.varnish_host
    if !varnish_host
      puts "You must supply a Varnish host argument. Like so: rake varnish:global_purge['172.1.1.20']"
      exit
    end
    #It WILL timeout, just accept it. Varnish does not have a command prompt.
    require 'net/telnet'
    @result = ""
    begin
      varnish_server = Net::Telnet::new("Host" => varnish_host,
      "Port" => 6082,
      "Timeout" => 5)
      varnish_server.cmd("url.purge .*") { |c| @result = c}
    rescue Exception
      if @result.include? ("200 0")
        puts "varnish purged OK."
      else
        raise "Varnish not purged."
      end
    end
  end

end
