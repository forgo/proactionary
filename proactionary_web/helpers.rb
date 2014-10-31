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

        def header
            if is_authenticated?
                partial(:logout)
            else
                partial(:login)
            end
        end

        def modal(modal_id, modal_content)
            @id = modal_id
            @content = modal_content
            partial(:modal, {:id => @id, :content => @content}) 
        end

        def footer
            partial(:footer)
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

                def do_some_koala_shit
            fb_graph.get_connections("me", "friends").to_s
        end

        def user_profile
            # return fb_graph.get_object("me")
        end

        def internet_connection?
            begin
                true if open("http://www.google.com/")
            rescue
                false
            end
        end

        def zip_from_ip
            if ENV['RACK_ENV'] == "development" || request.ip = "127.0.0.1"
                return "78240"
            else
                if request.location != nil
                    if request.location.postal_code != ""
                        return request.location.postal_code
                    else
                        return "78240"
                    end
                end
            end
        end

        def coordinates_from_ip(range, request)

            if ENV['RACK_ENV'] == "development" || request.ip == "127.0.0.1" || request.location == nil
                # Create Coordinate Bounding Box Around Dummy Lat/Lon Location
                location = GeoBox.new(DEFAULT_LATITUDE, DEFAULT_LONGITUDE, "degrees", range.to_f)
            else
                # Create Coordinate Bounding Box Around Lat/Lon Location
                location = GeoBox.new(request.location.latitude, request.location.longitude, "degrees", range.to_f)
            end
            # Extract String Values of Location + Bounds for Query Generation
            lat = location.latitude.to_degrees;
            lon = location.longitude.to_degrees;
            minLat = location.minLatitude.to_degrees;
            maxLat = location.maxLatitude.to_degrees;
            minLon = location.minLongitude.to_degrees;
            maxLon = location.maxLongitude.to_degrees;

            return { "min" => {"lat" => minLat, "lng" => minLon}, "max" => {"lat" => maxLat, "lng" => maxLon}, "center" => {"lat" => lat, "lng" => lon} }
        end

        def coordinates_from_coordinate(coordinate, range)

            location = GeoBox.new(coordinate["lat"], coordinate["lng"], "degrees", range.to_f)

            # Extract String Values of Location + Bounds for Query Generation
            lat = location.latitude.to_degrees;
            lon = location.longitude.to_degrees;
            minLat = location.minLatitude.to_degrees;
            maxLat = location.maxLatitude.to_degrees;
            minLon = location.minLongitude.to_degrees;
            maxLon = location.maxLongitude.to_degrees;

            return { "min" => {"lat" => minLat, "lng" => minLon}, "max" => {"lat" => maxLat, "lng" => maxLon}, "center" => {"lat" => lat, "lng" => lon} }
        end

        def address_for_coordinate(coordinate)
            if ENV['RACK_ENV'] == "development"
                return "[no address in dev mode]"
            else
                acs = []
                Geocoder.search([coordinate["lat"],coordinate["lng"]], :min_radius => 0.1)[0].data["address_components"].each do |c|
                    if c.nil? or c["short_name"].nil?
                        acs.push("")
                    else
                        acs.push(c["short_name"])
                    end
                end
                streetNumber = acs[0].nil? ? "" : acs[0]
                street = acs[1].nil? ? "" : acs[1]
                city = acs[3].nil? ? "" : acs[3]
                state = acs[5].nil? ? "" : acs[5]
                zip = acs[7].nil? ? "" : acs[7]
                return streetNumber + " " + street + ", " + city + ", " + state + " " + zip
            end
        end

        def events_default(request)
            location = coordinates_from_ip(DEFAULT_RANGE, request)["center"]
            events = DB.getEvents(request,DEFAULT_CATEGORY_ID,DEFAULT_PROMOTER_ID,DEFAULT_RANGE,location,DEFAULT_DATE_OPTION,DateTime.now.strftime(FORMAT_DATE),nil)
        end

        def partial(template,locals=nil)

            if template.is_a?(String) || template.is_a?(Symbol)
                template=('_' + template.to_s).to_sym
            else
                locals=template
                template=template.is_a?(Array) ? ('_' + template.first.class.to_s.downcase).to_sym : ('_' + template.class.to_s.downcase).to_sym
            end

            if locals.is_a?(Hash)
                erb(template,{:layout => false},locals)      
            elsif locals
                locals=[locals] unless locals.respond_to?(:inject)
                locals.inject([]) do |output,element|
                    output <<     erb(template,{:layout=>false},{template.to_s.delete("_").to_sym => element})
                end.join("\n")
            else 
                erb(template,{:layout => false})
            end
        end 

    end
  end
end