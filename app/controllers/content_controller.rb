class ContentController < ApplicationController 
  
  #do a before filter so all content actions get caught
  before_filter do |controller|
       controller.cache_control({:ttl => 200})
  end
  
  def home                               
     if params[:id].nil?
       @post = Post.find(rand(Post.count)+1)  #get a random post, nice huh?
     else
       @post = Post.find(params[:id])  
     end
  end
  
    
end