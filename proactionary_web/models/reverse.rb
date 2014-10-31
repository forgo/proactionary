require './models/models.rb'
require 'geocoder'

def address_for_coordinate
	promoter = DB::getRandomPromoter()
	address_components_short = []
	Geocoder.search([29.652,-98.29], :min_radius => 0.1)[0].data["address_components"].each do |c|
		address_components_short.push(c["short_name"])
	end
	return address_components_short.join(", ")
end