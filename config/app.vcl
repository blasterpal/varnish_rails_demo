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
   
   #in vcl_revc you can "pass" or "lookup" 
   #never cache non-GET methods
   if (req.request != "GET") {
     pass;
   }   
   

   #Auto cache busting for dev, FF is not sending this.
   # #enable Shift-Refresh auto purging in Development. You should disable in Production deployment.
   # if (req.http.Cache-Control ~ "no-cache") {
   #     purge_url(req.url);
   # }   
     
   #allow static assets automatically   
   if (req.url ~ "\.(pdf|png|gif|jpg|swf|css|js)(/$|/\?|\?|$)" ) {
     remove req.http.cookie;
     remove req.http.authenticate;
     remove req.http.Etag;   
     remove req.http.If-None-Match;
     lookup; #go to backend and see if there is an object        
   }                                                     
   
   #dynamic ruleset for frontend caching, attempt to pull from cache on ALL GET requests.
   if (req.request == "GET") {   
        # disable Etags && incoming cookies
        remove req.http.cookie;
        remove req.http.authenticate;
        remove req.http.Etag;   
        remove req.http.If-None-Match;                        
        lookup; #go to backend and see if there is an object 

    # i give up, no caching
    } else {  
      #error 200 "don't cache";
      pass;   
    }
    
  
}  

sub vcl_fetch {   
   
   #very important, we don't want to cache 500s
   if (obj.status >= 300) {
       pass;
   }
     
   if (obj.cacheable) {
          /* Remove Expires from backend, it's not long enough */
          unset obj.http.expires;
   
          /* Set the clients TTL on this object */
          # set obj.http.cache-control = "max-age = 900"; #set to your business needs   
       }
   
   # #allow static assets automatically
   if (req.url ~ "\.(pdf|png|gif|jpg|swf|css|js)(/$|/\?|\?|$)" ) {
      unset obj.http.set-cookie; #strip cookie from backend before storing in cache
      deliver;     
   }  
   #         
   #respect the backend from Rails private, no caching here
   if (obj.http.Pragma ~ "no-cache" ||
      obj.http.Cache-Control ~ "no-cache" ||
      obj.http.Cache-Control ~ "private") {
      pass;
   }

   #to be pulled from cache, wax any cookies, we need the public set   
   #to cache all "/" you can't use regex ~ "^/$"      
    if (req.url == "/" || req.url ~ "^/content") {
         unset obj.http.Set-Cookie; 
         unset  obj.http.Etag;  
         #set obj.ttl = 30m; 
         deliver;
     }  
   #   
   # #to be pulled from cache, we need the public set         
   # if (obj.http.Cache-Control ~ "public") {
   #      unset obj.http.Set-Cookie; 
   #      unset  obj.http.Etag;
   #      deliver;
   #  }
   # 
   #catch all from Varnish
   if (!obj.cacheable) {
       return (pass);
   }  
   # 
   #this tells Varnish to not cache b/c this obj wants to set a cookie.
   if (obj.http.Set-Cookie) {  

       return (pass);
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
 
   <address><a href="http://www.varnish-cache.org/">Varnish</a></address>
 </body>
</html>
"};
   deliver;
}
