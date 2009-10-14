#-e This is a basic VCL configuration file for varnish.  See the vcl(7)
#man page for details on VCL syntax and semantics.
#
#Default backend definition.  Set this to point to your content
#server.
#
backend default {
.host = "127.0.0.1";
.port = "3000";
}
      
sub vcl_recv {   
  #in vcl_revc you can "pass" , "pipe", or "lookup" 
  #never cache non-GET methods      
  if (req.request != "GET") {
   pipe; #pass will accomplish same, but apparently more varnish handling
  }   
  # #allow static assets automatically   
  # if (req.url ~ "\.(pdf|png|gif|jpg|swf|css|js)(/$|/\?|\?|$)" ) {
  #   remove req.http.cookie;
  #   remove req.http.authenticate;
  #   remove req.http.Etag;   
  #   remove req.http.If-None-Match;
  #   lookup; #go to backend and see if there is an object        
  # }                                                     
  #     
  #dynamic ruleset for frontend caching, attempt to pull from cache on ALL GET requests.
  if (req.request == "GET") {   
      # disable Etags && incoming cookies
      remove req.http.cookie;
      remove req.http.authenticate;
      remove req.http.Etag;   
      remove req.http.If-None-Match;                        
      lookup; #go to backend and see if there is an object 

  # i give up, no caching as default strategy
  } 
  pass;    
}  

sub vcl_fetch {   
  
  # fetch happens when we pass or try lookup and miss or otherwise go to backend.
  # we can make more assertions on the obj and possibly cache for future use.
  # deliver == cache
  # pass == no caching
  
 	# very important, we don't want to cache 500s
 	# we are not letting varnish have a grace period to handle and error or slow backend. 
  if (obj.status >= 300) {
     pass;
  }    
   #         
  #respect the backend from Rails private, no caching here
  if ( obj.http.Cache-Control ~ "private") {
    pass;
  }

  # #to be pulled from cache, we need the public set         
  if (obj.http.Cache-Control ~ "public") {
      unset obj.http.Set-Cookie;
      #unset the cache control, else the browser will keep for that long too. 
      #we want to control requests.
      unset obj.http.Etag;
      unset obj.http.Cache-Control; 
      set obj.http.Cache-Control = "no-cache"; #tell client to request a new one everytime
      esi; #we will attempt to ESI process as well
      deliver;
  } 
  #else we will try NOT cache by default , be safe
  pass;  

}

# this executes on every response from varnish
sub vcl_deliver {
  if (obj.hits > 0) {
          set resp.http.X-Cache = "HIT";
  } else {
          set resp.http.X-Cache = "MISS";
  }
}

 
#This is displayed if there is an error.
sub vcl_error {
   set obj.http.Content-Type = "text/html; charset=utf-8";
   synthetic {"
<?xml version="1.0" encoding="utf-8"?>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN"
"http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
<html>
 <head>
   <title>"} obj.status " " obj.response {"</title>
 </head>
 <body>
   <h1>Error "} obj.status " " obj.response {"</h1>
   <p>"} obj.response {"</p>
  <br>Request URL: "} req.url {"
  <br>Request Host: "} req.http.host {"
   <h3>Guru Meditation:</h3>
   <p>XID(): "} req.xid {"</p>
 
   <address><a href="http://www.atlruby.org/">This error was customized for ATLRUG</a></address>
 </body>
</html>
"};
   deliver;
}
