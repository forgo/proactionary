class GeoBoxCoordinate

  @value

  def initialize(value)
    raise "Expected Float value for GeoLocationCoordinate value" unless value.is_a?(Float)
    @value = value
  end

  def value
    @value
  end

  def to_degrees
    @value * GeoBox::RADIANS_TO_DEGREES
  end

  def set(value)
    @value = value
  end

  def to_s
    sprintf("%10.6f", @value)
  end

  def to_degrees_s
    sprintf("%10.6f", @value * GeoBox::RADIANS_TO_DEGREES)
  end

end

# GeoLocation
# TODO: attr_reader/attr_writer for automatic getters/setters DOH!
class GeoBox 

	# Class variables
    MINIMUM_LATITUDE = -Math::PI/2.0
    MAXIMUM_LATITUDE = Math::PI/2.0
    MINIMUM_LONGITUDE = -Math::PI
    MAXIMUM_LONGITUDE = Math::PI

    DEGREES_TO_RADIANS = Math::PI / 180.0
    RADIANS_TO_DEGREES = 180.0 / Math::PI

    EARTH_RADIUS = 6371.01

    # Instance variables  
    @latitude  			# Latitude [radians]
    @longitude 			# Longitude [radians]
    @minLatitude  # Lower Bounds Latitude [radians]
    @minLongitude # Lower Bounds Longitude [radians]
    @maxLatitude  # Upper Bounds Latitude [radians]
    @maxLongitude # Upper Bounds Longitude [radians]

  def initialize(lat, lon, units="radians", range=0.0)  
  	raise "Expected Float value for lat initializing GeoLocation" unless lat.is_a?(Float)
  	raise "Expected Float value for lon initializing GeoLocation" unless lon.is_a?(Float)
    raise "Expected >= 0.0 value for GeoLocation range" unless range >= 0.0
    raise "Expected units='radians' or units='degrees' for GeoLocation" unless (units == "radians" || units == "degrees")
    if units == "degrees"
      @latitude = GeoBoxCoordinate.new(lat * DEGREES_TO_RADIANS)
      @longitude = GeoBoxCoordinate.new(lon * DEGREES_TO_RADIANS)
    else
      @latitude = GeoBoxCoordinate.new(lat)
      @longitude = GeoBoxCoordinate.new(lon)
    end
    raise "Invalid lat/lon passed to GeoLocation" unless (self.valid?)
    @minLatitude = GeoBoxCoordinate.new(lat)
    @minLongitude = GeoBoxCoordinate.new(lon)
    @maxLatitude = GeoBoxCoordinate.new(lat)
    @maxLongitude = GeoBoxCoordinate.new(lon)
    self.setBounds(range)
  end

  def latitude
    @latitude
  end

  def setLatitude(lat)
    @latitude = lat
  end

  def longitude
    @longitude
  end

  def setLongitude(lon)
    @longitude = lon
  end

  def setLatitudeAndLongitude(lat,lon)
    @latitude = lat
    @longitude = lon
  end

  def minLatitude
    @minLatitude
  end

  def setMinLatitude(lat)
    @minLatitude = lat
  end

  def minLongitude
    @minLongitude
  end

  def setMinLongitude(lon)
    @minLongitude = lon
  end

  def maxLatitude
    @maxLatitude
  end

  def setMaxLatitude(lat)
    @maxLatitude = lat
  end

  def maxLongitude
    @maxLongitude
  end

  def setMaxLongitude(lon)
    @maxLongitude = lon
  end

  def valid?
  	if (@latitude.value < MINIMUM_LATITUDE || @latitude.value > MAXIMUM_LATITUDE ||
  		@longitude.value < MINIMUM_LONGITUDE || @longitude.value > MAXIMUM_LONGITUDE)
  		return false
    else
      return true
  	end
  end

  def distanceTo(location, radius)
  	raise "Expected GeoLocation value for distanceTo location" unless location.is_a?(GeoLocation)
  	raise "Expected Float value for distanceTo radius"
  	distance = Math::acos(Math::sin(@latitude) * Math::sin(@latitude) + 
  					Math::cos(@latitude) * Math::cos(@latitude) * Math::cos(@longitude - 
  					location.longitude)) * radius;
  end
  
  def setBounds(range, radius_of_curvature=EARTH_RADIUS)
  	raise "Expected Float value for setBounds distance" unless range.is_a?(Float)
  	raise "Expected Float value for setBounds radius_of_curvature" unless radius_of_curvature.is_a?(Float)
  	if range < 0.0 || radius_of_curvature < 0.0
  		raise "Expected positive distance and radius values for boundingCoordinates"
  	end

  	# Angular Distance in Radians on a Great Circle
  	radialDistance = range / radius_of_curvature
  	minLat = @latitude.value - radialDistance
  	maxLat = @latitude.value + radialDistance

  	if minLat > MINIMUM_LATITUDE && maxLat < MAXIMUM_LATITUDE
  		deltaLon = Math::asin(Math::sin(radialDistance) / Math::cos(@latitude.value))
  		minLon = @longitude.value - deltaLon
  		(minLon += 2.0 * Math::PI) if minLon < MINIMUM_LONGITUDE
  		maxLon = @longitude.value + deltaLon
  		(maxLon -= 2.0 * Math::PI) if maxLon > MAXIMUM_LONGITUDE
  	else
  		# a pole is within the distance
  		minLat = [minLat, MINIMUM_LATITUDE].max
  		maxLat = [maxLat, MAXIMUM_LATITUDE].min
  		minLon = MINIMUM_LONGITUDE
  		maxLon = MAXIMUM_LONGITUDE
  	end

    @minLatitude.set(minLat)
    @minLongitude.set(minLon)
    @maxLatitude.set(maxLat)
    @maxLongitude.set(maxLon)
  end

end  