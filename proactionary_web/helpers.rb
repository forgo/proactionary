#-------------------------------------------------------------------------------
# PROACTIONARY.COM
#-------------------------------------------------------------------------------
# helpers.rb
# ------------------------------------------------------------------------------
# Author:   Elliott Richerson
# Created:  July 20, 2014
# Modified: July 20, 2014
# ------------------------------------------------------------------------------
require './constants'
require 'open-uri'

module Sinatra
  module ProactionaryApp
    module Helpers
 
    	def title
    		@title ? "#{@title}" : "Proactionary"
    	end

    	def pretty_date(time)
    		time.strftime("%d %b %Y")
    	end

		def require_logged_in
			redirect('/login') unless is_authenticated?
		end

		def is_authenticated?
			return !!session["access_token"]
		end

		def fb_graph
			return Koala::Facebook::API.new(session["access_token"]) if is_authenticated?
		end

    end
  end
end