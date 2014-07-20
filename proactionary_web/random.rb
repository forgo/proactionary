#-------------------------------------------------------------------------------
# PROACTIONARY.COM
#-------------------------------------------------------------------------------
# random.rb
# ------------------------------------------------------------------------------
# Author: 	Elliott Richerson
# Created:  July 20, 2014
# Modified: July 20, 2014
# ------------------------------------------------------------------------------

require 'random-word'

def randomDate(from = 0.0, to = Time.now)
	r = Random.new
	return Time.at(from + r.rand * (to.to_f - from.to_f)) 
end

def randomTimestampString(from = 0.0, to = Time.now)
	return randomDate(from,to).strftime("%Y-%m-%d %H:%M:%S");
end

def randomDateString(from = 0.0, to = Time.now)
	return randomDate(from,to).strftime("%Y-%m-%d");
end

def randomFloatInRange(min, max)
	r = Random.new
	return min + r.rand * (max - min)
end

def randomIntegerInRange(min, max)
	raise "random integer must have Fixnum min/max values" unless min.class == Fixnum and max.class == Fixnum
	return Random.new.rand(min..max)
end

def randomLatitude(units="degrees")
	raise "random latitude units are in 'degrees' or 'radians'" unless (units == "degrees" || units == "radians")
	min =  (units == "degrees" ? -90.0 : -Math::PI/2.0)
	max =  (units == "degrees" ?  90.0 :  Math::PI/2.0)
	return randomFloatInRange(min, max)
end

def randomLongitude(units="degrees")
	raise "random longitude units are in 'degrees' or 'radians'" unless (units == "degrees" || units == "radians")
	min =  (units == "degrees" ? -180.0 : -Math::PI)
	max =  (units == "degrees" ?  180.0 :  Math::PI)
	return randomFloatInRange(min, max)
end

def randomLatLng(north, south, east, west, units="degrees")
	minLat = (units == "degrees" ? north : north * deg2rad)
	maxLat = (units == "degrees" ? south : south * deg2rad)
	minLng = (units == "degrees" ? east : east * deg2rad)
	maxLng = (units == "degrees" ? west : west * deg2rad)
	lat = randomFloatInRange(minLat, maxLat)
	lng = randomFloatInRange(minLng, maxLng)
	return {:lat => lat, :lng => lng}
end

def randomNoun()
	return RandomWord.nouns.next.gsub(/_/, ' ')
end

def randomAdjective()
	return RandomWord.adjs.next.gsub(/_/, ' ')
end




