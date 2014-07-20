#-------------------------------------------------------------------------------
# PROACTIONARY.COM
#-------------------------------------------------------------------------------
# spec/spec_helper.rb
# ------------------------------------------------------------------------------
# Author: 	Elliott Richerson
# Created:  July 20, 2014
# Modified: July 20, 2014
# ------------------------------------------------------------------------------

ENV['RACK_ENV'] = 'test'

require "rack/test"

require_relative File.join('..', 'app')

RSpec.configure do |config|
	
	include Rack::Test::Methods

	def app
		ProactionaryApp
	end
end