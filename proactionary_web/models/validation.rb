#-------------------------------------------------------------------------------
# PROACTIONARY.COM
#-------------------------------------------------------------------------------
# models/validation.rb
# ------------------------------------------------------------------------------
# Author:   Elliott Richerson
# Created:  July 20, 2014
# Modified: July 20, 2014
# ------------------------------------------------------------------------------
require 'date'
require './constants'

def valid_database_id?( id )
	return false if id.nil?
	return false unless id.is_a?(Fixnum) || id.is_a?(Bignum)
	return false unless id.to_s.length <= 20
	return true
end

def valid_date?( date, format=FORMAT_DATE )
	return false if date.nil?
  	Date.strptime(date, format) rescue false
  	return true
end

def valid_timestamp?( timestamp, format=FORMAT_TIMESTAMP )
	return false if timestamp.nil?
	Date.strptime(timestamp, format) rescue false
	return true;
end 

def valid_latitude?( latitude, units="degrees" )
	raise "valid latitude units are in 'degrees' or 'radians'" unless (units == "degrees" || units == "radians")
	return false if latitude.nil?
	return false unless latitude.is_a?(Float)
	min = (units == "degrees" ? -90.0 : -Math::PI/2.0)
	max = (units == "degrees" ?  90.0 :  Math::PI/2.0)
	return false unless (latitude >= min && latitude <= max)
	return true
end

def valid_longitude?( longitude, units="degrees" )
	raise "valid longitude units are in 'degrees' or 'radians'" unless (units == "degrees" || units == "radians")
	return false if longitude.nil?
	return false unless longitude.is_a?(Float)
	min =  (units == "degrees" ? -180.0 : -Math::PI)
	max =  (units == "degrees" ?  180.0 :  Math::PI)
	return false unless (longitude >= min && longitude <= max)
	return true
end

def valid_coordinate?( coordinate, units="degrees" )
	return false if 	coordinate.nil?
	return false unless valid_latitude?( coordinate["lat"], units )
	return false unless valid_longitude?( coordinate["lng"], units )
	return true
end

def valid_boolean? ( boolean )
	return false if boolean.nil?
	# return false unless boolean.is_a?(String) and (boolean =~ /\A(true|false|t|f|yes|no|y|n|1|0)\z/i)
	# return false unless boolean.is_a?(Fixnum) and (boolean == 1 || boolean == 0)
	return false unless boolean.is_a?(TrueClass) or boolean.is_a?(FalseClass)
	return true
end

def valid_range? ( range )
	return false if 	range.nil?
	return false unless range.is_a?(Fixnum)
	return false unless range >= 0 && range <= 100
	return true
end

def valid_location_option? (location_option, location)
	return false if 	location_option.nil? 			or location.nil?
	return false unless location_option.is_a?(String) 	and location.is_a?(String)
	return false unless location_option == "zip" 		or location_option == "coordinate" or location_option == "address"
	return false if 	location_option == "zip" 		and not valid_zip? location
	return false if 	location_option == "coordinate" and not valid_coordinate? location
	return false if 	location_option == "address" 	and not valid_address? location
	return true
end

def valid_date_option? (date_option, date1, date2=nil)
	return false if 	date_option.nil?			or date1.nil?
	return false unless date_option.is_a?(String)	and date1.is_a?(String)
	return false unless date_option == "on"			or date_option == "between"
	return false if 	date_option == "on"			and not valid_date? date1
	return false if 	date_option == "between"	and (not valid_date? date1 or not valid_date? date2)
	return true
end

def valid_single_lowercase_character? (label)
	return false if 	label.nil?
	return false unless label.is_a?(String)
	return false if 	(label.length != 1)
	return false if     (label =~ REGEX_ALPHA_LOWER) == nil
	return true
end

# Promoter Specific Validations
def valid_promoter_name? ( name )
	return false if 	name.nil?
	return false unless name.is_a?(String)
	return false if 	(name =~ REGEX_LABEL) == nil
	return true
end

def valid_promoter_slogan? ( slogan )
	return false if 	slogan.nil?
	return false unless slogan.is_a?(String)
	return false if 	(slogan =~ REGEX_LABEL) == nil
	return true
end

def valid_address? ( address )
	return false if 	address.nil?
	return false unless address.is_a?(String)
	# TODO: Better address validation... Using standard REGEX_LABEL for now
	return false if 	(address =~ REGEX_LABEL) == nil
	return true;
end

def valid_zip? ( zip )
	return false if 	zip.nil?
	return false unless zip.is_a?(String)
	return false if 	(zip =~ REGEX_ZIP) == nil
	return true
end

def valid_phone? ( phone )
	return false if 	phone.nil?
	return false unless phone.is_a?(String)
	return false if 	(phone =~ REGEX_PHONE) == nil
	return true
end

def valid_hex_color? ( hex )
	return false if 	hex.nil?
	return false unless hex.is_a?(String)
	return false if 	(hex =~ REGEX_HEX_COLOR) == nil
	return true
end

# Event Specific Validations
def valid_event_name? ( name )
	return false if 	name.nil?
	return false unless name.is_a?(String)
	return false if 	(name =~ REGEX_LABEL) == nil
	return true
end

def valid_event_description? ( description )
	return false if 	description.nil?
	return false unless description.is_a?(String)
	return false if 	(description =~ REGEX_LABEL) == nil
	return true
end