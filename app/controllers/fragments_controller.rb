class FragmentsController < ApplicationController 
  
  require 'yaml'

             
  layout false

  def viewed_posts         
    if params[:id]  
            cookies[:viewed_posts] = 
            {:value => "The last post you viewed was: #{params[:id]}", :expires => 1.week.from_now} 
    end 
    render :text => "<!-- Viewed Posts Called with #{params[:id] }-->"
  end
  
  
  def tweets
     tweet_list
  end

    
end