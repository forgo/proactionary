# PromoterObject.rb

require './random'
require './models/validation'
require './models/exception'

class PromoterObject

	attr_reader :id, :facebook_id, :category_id, :name, :slogan, :latitude, 
	:longitude, :street, :city, :state, :zip, :country, :phone, :active_status, 
	:color_primary, :color_secondary, :created_at, :updated_at

	def initialize(id, facebook_id, category_id, name, slogan, latitude, 
		longitude, street, city, state, zip, country, phone, active_status, 
		color_primary, color_secondary, created_at, updated_at)

	self.id = id
	self.facebook_id = facebook_id
	self.category_id = category_id
	self.name = name
	self.slogan = slogan
	self.latitude = latitude
	self.longitude = longitude
	self.street = street
	self.city = city
	self.state = state
	self.zip = zip 
	self.country = country
	self.phone = phone
	self.active_status = active_status
	self.color_primary = color_primary
	self.color_secondary = color_secondary
	self.created_at = created_at
	self.updated_at = updated_at
end

def id=(new_id)
	if valid_database_id? new_id or new_id.nil?
		@id = new_id
	else
		raise InvalidDatabaseIDException, "bad id value"
	end
end

def facebook_id=(new_facebook_id)
	if valid_database_id? new_facebook_id or new_facebook_id.nil?
		@facebook_id = new_facebook_id
	else
		raise InvalidDatabaseIDException, "bad facebook_id value"
	end
end

def category_id=(new_category_id)
	if valid_database_id? new_category_id or new_category_id.nil?
		@category_id = new_category_id
	else
		raise InvalidDatabaseIDException, "bad category_id value"
	end
end

def name=(new_name)
	if valid_promoter_name? new_name or new_name.nil?
		@name = new_name
	else
		raise InvalidPromoterNameException, "bad name value"
	end
end

def slogan=(new_slogan)
	if valid_promoter_slogan? new_slogan or new_slogan.nil?
		@slogan = new_slogan
	else
		raise InvalidPromoterSloganException, "bad slogan value"
	end
end

def latitude=(new_latitude)
	if valid_latitude? new_latitude or new_latitude.nil?
		@latitude = new_latitude
	else
		raise InvalidLatitudeException, "bad latitude value"
	end
end

def longitude=(new_longitude)
	if valid_longitude? new_longitude or new_longitude.nil?
		@longitude = new_longitude
	else
		raise InvalidLongitudeException, "bad longitude value"
	end
end

def street=(new_street)
	if valid_street? new_street or new_street.nil?
		@street = new_street
	else
		raise InvalidStreetException, "bad street value"
	end
end

def city=(new_city)
	if valid_city? new_city or new_city.nil?
		@city = new_city
	else
		raise InvalidCityException, "bad city value"
	end
end

def state=(new_state)
	if valid_state? new_state or new_state.nil?
		@state = new_state
	else
		raise InvalidStateException, "bad state value"
	end
end

def zip=(new_zip)
	if valid_zip? new_zip or new_zip.nil?
		@zip = new_zip 
	else
		raise InvalidZipException, "bad zip value"
	end
end

def country=(new_country)
  if valid_country? new_country or new_country.nil?
    @country = new_country
  else
    raise InvalidCountryException, "bad country value"
  end
end

def phone=(new_phone)
	if valid_phone? new_phone or new_phone.nil?
		@phone = new_phone
	else
		raise InvalidPhoneException, "bad phone value"
	end
end

def active_status=(new_active_status)
	if valid_boolean? new_active_status or new_active_status.nil?
		@active_status = new_active_status
	else
		raise InvalidBooleanException, "bad active_status value"
	end
end

def color_primary=(new_color_primary)
	if valid_hex_color? new_color_primary or new_color_primary.nil?
		@color_primary = new_color_primary
	else
		raise InvalidHexColorException, "bad color_primary value"
	end
end

def color_secondary=(new_color_secondary)
	if valid_hex_color? new_color_secondary or new_color_secondary.nil?
		@color_secondary = new_color_secondary
	else
		raise InvalidHexColorException, "bad color_secondary value"
	end
end

def created_at=(new_created_at)
	if valid_timestamp? new_created_at or new_created_at.nil?
		@created_at = new_created_at
	else
		raise InvalidTimestampException, "bad created_at value" 
	end
end

def updated_at=(new_updated_at)
	if valid_timestamp? new_updated_at or new_updated_at.nil?
		@updated_at = new_updated_at
	else
		raise InvalidTimestampException, "bad updated_at value"
	end
end

end