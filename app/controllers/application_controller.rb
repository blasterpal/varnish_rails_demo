# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  helper :all # include all helpers, all the time
  protect_from_forgery # See ActionController::RequestForgeryProtection for details

  # Scrub sensitive parameters from your log
  # filter_parameter_logging :password  
  
  
  # #from http://russ.github.com/2009/01/15/rails-varnish-and-esi.html
  # def cache_control(options = {})
  #   #unless Rails.env == 'development'
  #     options[:type] ||= 'public'
  #     options[:ttl] = 2  #low for testing
  #     headers['Cache-Control'] =
  #       "#{options[:type]},max-age=#{options[:ttl]}"
  #   #end
  # end 
  
  
  
end
