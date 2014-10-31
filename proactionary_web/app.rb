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
require_relative 'forms'
require_relative 'routes/sessions'
require_relative 'routes/facebook'

class ProactionaryApp < Sinatra::Base

	configure :development do
		register Sinatra::Reloader
	end

	register Sinatra::ProactionaryApp::Routing::Sessions
	register Sinatra::ProactionaryApp::Routing::Facebook

	helpers Sinatra::ContentFor2
	helpers Sinatra::ProactionaryApp::Helpers
	helpers Sinatra::ProactionaryApp::Forms

	enable :sessions

	set :root, File.dirname(__FILE__)
	
	set :session_secret, 'otwoifbtfisdaiygnptglislislis'

	get '/' do
		@request = request
		erb :index
	end

	post '/suggest_coordinate_browser' do
		content_type :json
		request.body.rewind
		params = JSON.parse(request.body.read.to_s)
		range = params["range"].to_f
		payload = coordinates_from_ip(range, request)
		payload["address"] = address_for_coordinate(payload["center"])
		payload.to_json
	end

	post '/provide_coordinate_browser' do
		content_type :json
		request.body.rewind
		params = JSON.parse(request.body.read.to_s)
		coordinate = params["coordinate"]
		range = params["range"].to_f
		payload = coordinates_from_coordinate(coordinate, range)
		payload["address"] = address_for_coordinate(coordinate)
		payload.to_json
	end

	get '/categories' do #, :agent => /iPhone/ do
		content_type :json
		json = DB.getCategories().to_json
		puts "BLAH BLAH BLAH JSON = " + json
		json
	end

	get '/events', :agent => /iPhone/ do
		content_type :json
		filter = params
		location = { "lat" => filter["location"]["lat"].to_f, "lng" => filter["location"]["lng"].to_f}
		events = DB.getEvents(request, filter["category_id"].to_i, filter["promoter_id"].to_i, filter["range"].to_i, location, filter["date_option"].to_s, filter["date1"].to_s, filter["date2"].to_s)
		json = events.to_json
	end

	get '/events' do
		content_type :json
		#request.body.rewind
  		filter = params #JSON.parse(request.body.read.to_s)
  		location = { "lat" => filter["location"]["lat"].to_f, "lng" => filter["location"]["lng"].to_f}
  		events = DB.getEvents(request, filter["category_id"].to_i, filter["promoter_id"].to_i, filter["range"].to_i, location, filter["date_option"].to_s, filter["date1"].to_s, filter["date2"].to_s)
		sidebar = htmlListSidebar(events)
		json = { :events => events, :sidebar => sidebar }.to_json
	end


	get '/iptest' do 
		"Your DUMB IP Address is " + request.ip + " and it thinks your postal code is " + request.location.postal_code + 
		"<br/>and your SMART IP ADDRESS is " + ip + " and it thinks your postal code is " + Geocoder.search(ip).first.data["zipcode"]
	end


    def trusted_proxy?(ip)
      ip =~ /\A127\.0\.0\.1\Z|\A(10|172\.(1[6-9]|2[0-9]|30|31)|192\.168)\.|\A::1\Z|\Afd[0-9a-f]{2}:.+|\Alocalhost\Z|\Aunix\Z|\Aunix:/i
    end

    def ip
      remote_addrs = split_ip_addresses(@env['REMOTE_ADDR'])
      remote_addrs = reject_trusted_ip_addresses(remote_addrs)

      return remote_addrs.first if remote_addrs.any?

      forwarded_ips = split_ip_addresses(@env['HTTP_X_FORWARDED_FOR'])

      if client_ip = @env['HTTP_CLIENT_IP']
        # If forwarded_ips doesn't include the client_ip, it might be an
        # ip spoofing attempt, so we ignore HTTP_CLIENT_IP
        return client_ip if forwarded_ips.include?(client_ip)
      end

      return reject_trusted_ip_addresses(forwarded_ips).last || @env["REMOTE_ADDR"]
    end


	def split_ip_addresses(ip_addresses)
		ip_addresses ? ip_addresses.strip.split(/[,\s]+/) : []
	end

	def reject_trusted_ip_addresses(ip_addresses)
		ip_addresses.reject { |ip| trusted_proxy?(ip) }
	end

end