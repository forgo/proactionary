#-------------------------------------------------------------------------------
# PROACTIONARY.COM
#-------------------------------------------------------------------------------
# app.rb
# ------------------------------------------------------------------------------
# Author: 	Elliott Richerson
# Created:  July 20, 2014
# Modified: July 20, 2014
# ------------------------------------------------------------------------------

require 'sinatra'
require 'sinatra/base'
require 'sinatra/reloader'
require 'sinatra/content_for2'
require 'geocoder'
require 'yaml'

APP_ID     = 525302707571274						# Register AppID w/Facebook
APP_SECRET = '44db8aa6b25444fd9d8bc378c3607f30'		# Facebook App Secret

require_relative 'models/models'
require_relative 'utilities'
require_relative 'helpers'
require_relative 'routes/sessions'
require_relative 'routes/promoter'
require_relative 'routes/facebook'

class ProactionaryApp < Sinatra::Base

	configure :development do
		register Sinatra::Reloader
	end

	register Sinatra::ProactionaryApp::Routing::Sessions
	register Sinatra::ProactionaryApp::Routing::Promoter
	register Sinatra::ProactionaryApp::Routing::Facebook

	helpers Sinatra::ContentFor2
	helpers Sinatra::ProactionaryApp::Helpers

	enable :sessions

	set :root, File.dirname(__FILE__)
	
	set :session_secret, 'otwoifbtfisdaiygnptglislislis'

	get '/' do
		@request = request
		erb :index
	end

end