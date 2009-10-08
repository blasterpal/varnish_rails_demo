# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper     
  
  def pretty_time
     Time.now
  end    
  
  def personal_info
       @cookie = cookies[:viewed_posts]  
       @ip = request.remote_ip      
       @user_agent = request.headers['User-Agent']
       render :partial => 'shared/cookie_info'
  end
end
