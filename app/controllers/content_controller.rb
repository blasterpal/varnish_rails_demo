class ContentController < ApplicationController 
  
  def home                               
     
     if params[:id].nil?
       @post = Post.find(rand(Post.count)+1)
     else
       @post = Post.find(params[:id])  
     end
  end
  
    
end