if [-z $1] then;
  echo "You must supply a VCL file path!"
fi

#Backend host "localhost": resolves to multiple IPv6 addresses.
#Only one address is allowed.
#Please specify which exact address you want to use, we found these:

#/usr/local/sbin/varnishd -a blackbook.local:3000 -b blackbook.local:8080 -T blackbook.local:6082 


#start up Varnish, listening on localhost:8080, with default backend to Rails on 3000, management on port 6082, storage set for 100m in /tmp, 
/usr/local/sbin/varnishd -a localhost:8080 -b blackbook.local:3000 -T localhost:6082 -F -s file,/tmp/varnish.storage,100M            


/usr/local/sbin/varnishd -a localhost:8080 -T localhost:6082 -F -s file,/tmp/varnish.storage,100M -f ~/code/varnish_demo/config/app.vcl  
                                       

/usr/local/sbin/varnishd -f  ~/code/varnish_demo/config/app.vcl