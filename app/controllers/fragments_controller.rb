class FragmentsController < ApplicationController 
  
  require 'yaml'
  layout false

  def viewed_posts         
    if params[:id]  
            cookies[:viewed_posts] = 
            {:value => "#{params[:id]}", :expires => 1.week.from_now} 
    end 
    render :text => "You just viewed post: #{params[:id]} at #{Time.now} "
  end
  
  def time
      cache_control({:ttl => 10})       
      render :partial => 'shared/time'
  end  
  
  def personal_info
      cache_control({:ttl => 15})
      @ip = request.remote_ip      
      @user_agent = request.headers['User-Agent']  
      render :partial => 'shared/personal_info'  
  end

    
end