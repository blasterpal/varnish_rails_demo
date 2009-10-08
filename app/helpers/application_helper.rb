# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper     
  
  require 'rubygems'
  require 'simple-rss'
  require 'open-uri'
  
  def pretty_time
     Time.now
  end 
  
  def view_post(id)                                
     post = Post.find(id)
     render :partial => 'posts/view', :locals => {:post => post} if post
  end   
  
  def personal_info
       @cookie = cookies[:viewed_posts]  
       @ip = request.remote_ip      
       @user_agent = request.headers['User-Agent']
       render :partial => 'shared/cookie_info'
  end  
  
  def posts_list
     posts = Post.find(:all)
     render :partial => 'shared/post_list', :locals => {:posts => posts} if posts
  end
  
  def tweet_list
    feed = 'http://search.twitter.com/search.atom?q=ghosts'
    @tweets = SimpleRSS.parse open(feed)
    render :partial => 'shared/tweets_list'
  end    
  
  #from http://russ.github.com/2009/01/15/rails-varnish-and-esi.html    
  
  def cache_control(options = {})
    unless Rails.env == 'development'
      options[:type] ||= 'public'
      options[:ttl] = 60
      headers['Cache-Control'] =
        "#{options[:type]},max-age=#{options[:ttl]}"
    end
  end


  def render_esi(path)
    if Rails.env == 'development'
      div_id = Digest::MD5.hexdigest(path + rand.to_s)
      out = content_tag(:div, :id => div_id) do '' end
      out += content_tag(:script, :type => 'text/javascript') do
        '$.ajax({ 
          type:"GET", 
          url:"' + path + '", 
          dataType:"html", 
          success:function(html) { 
          $("#' + div_id + '").html(html)
        }});'
      end
    else
      '<esi:include src="' + path + '" />'
    end
  end
  
  
end
