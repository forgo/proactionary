#-------------------------------------------------------------------------------
# forms.rb
# ------------------------------------------------------------------------------
# Author: 	Elliott Richerson
# Created:  August 14, 2014
# Modified: August 14, 2014
# ------------------------------------------------------------------------------
require './constants'
require 'open-uri'

module Sinatra
  module ProactionaryApp
    module Forms
 
		def form_login
			partial(:form_login)
		end

		def form_registration
			partial(:form_registration)
		end

		def form_event
			partial(:form_event)
		end

    end
  end
end