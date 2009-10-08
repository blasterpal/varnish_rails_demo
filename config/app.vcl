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
# 
sub req_strip_cookies {
  remove req.http.cookie;
  remove req.http.authenticate;    
}  
#             


sub vcl_recv { 
   
   #in vcl_revc you can "pass" or "lookup" 
   #never cache non GET methods
   if (req.request != "GET") {
     pass;
   }   
   
   #enable Shift-Refresh auto purging in Development. You should disable in Production deployment.
   if (req.http.Cache-Control ~ "no-cache") {
       purge_url(req.url);
   }
     
   
   # Simple non-dynamic rule
   if (req.url ~ "\.(pdf|png|gif|jpg|swf|css|js)(/$|/\?|\?|$)" ) {
     req_strip_cookies;
     lookup; #go to backend and see if there is an object        
   }                                                     
   
   #dynamic ruleset for blog posts
   if (req.request == "GET" && req.url ~ "^/posts.*$") {
        # disable Etags   
        #error 200 "cache";
        req_strip_cookies;  
        remove obj.http.Etag;   
        remove req.http.If-None-Match;
        lookup;

    #listing details only
    } else {  
      #error 200 "don't cache";
      pass;   
    }
    
  
}  

sub vcl_fetch {   
  
   if (req.url ~ "\.(pdf|png|gif|jpg|swf|css|js)(/$|/\?|\?|$)" ) {
      unset obj.http.set-cookie; #strip cookie from backend before storing in cache
      
   } 
   
   if (obj.cacheable) {
       /* Remove Expires from backend, it's not long enough */
       unset obj.http.expires;

       /* Set the clients TTL on this object */
       set obj.http.cache-control = "max-age = 900"; #set to your business needs  
    }
   
   if (!obj.cacheable) {
       return (pass);
   }
   if (obj.http.Set-Cookie) {
       return (pass);
   }
   set obj.prefetch =  -30s;
   return (deliver);
}
   

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
   <h3>Guru Meditation:</h3>
   <p>XID(): "} req.xid {"</p>
     <br>Host Header: "} req.http.host {"
   <address><a href="http://www.varnish-cache.org/">Varnish</a></address>
 </body>
</html>
"};
   deliver;
}
