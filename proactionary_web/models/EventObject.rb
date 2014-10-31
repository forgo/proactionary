# EventObject.rb

require './random'
require './constants'
require './models/validation'
require './models/exception'

class EventObject

	attr_reader :id, :promoter_id, :category_id, :approval_status, :alternate_location, :latitude, 
  :longitude, :street, :city, :state, :zip, :country, :created_at, :updated_at, 
  :start_ts, :end_ts, :notification_ts, :name, :description;

  def initialize(id, promoter_id, category_id, approval_status, alternate_location, latitude, 
   longitude, street, city, state, zip, country, created_at, updated_at, 
   start_ts, end_ts, notification_ts, name, description)

  self.id = id
  self.promoter_id = promoter_id
  self.category_id = category_id
  self.approval_status = approval_status
  self.alternate_location = alternate_location
  self.latitude = latitude
  self.longitude = longitude
  self.street = street
  self.city = city
  self.state = state
  self.zip = zip
  self.country = country
  self.created_at = created_at
  self.updated_at = updated_at
  self.start_ts = start_ts
  self.end_ts = end_ts
  self.notification_ts = notification_ts
  self.name = name
  self.description = description

end

def id=(new_id)
  if valid_database_id? new_id or new_id.nil?
    @id = new_id
  else
    raise InvalidDatabaseIDException, "bad id value"
  end
end

def promoter_id=(new_promoter_id)
  if valid_database_id? new_promoter_id or new_promoter_id.nil?
    @promoter_id = new_promoter_id
  else
    raise InvalidDatabaseIDException, "bad promoter_id value"
  end
end

def category_id=(new_category_id)
  if valid_database_id? new_category_id or new_category_id.nil?
    @category_id = new_category_id
  else
    raise InvalidDatabaseIDException, "bad category_id value"
  end
end

def approval_status=(new_approval_status)
  if valid_boolean? new_approval_status or new_approval_status.nil?
    @approval_status = new_approval_status
  else
    raise InvalidBooleanException, "bad approval_status value"
  end
end

def alternate_location=(new_alternate_location)
  if valid_boolean? new_alternate_location or new_alternate_location.nil?
    @alternate_location = new_alternate_location
  else
    raise InvalidBooleanException, "bad alternate_location value"
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

def start_ts=(new_start_ts)
 if valid_timestamp? new_start_ts or new_start_ts.nil?
  @start_ts = new_start_ts
else
  raise InvalidTimestampException, "bad start_ts value"
end
end

def end_ts=(new_end_ts)
  if valid_timestamp? new_end_ts or new_end_ts.nil?
    @end_ts = new_end_ts
  else
    raise InvalidTimestampException, "bad end_ts value"
  end
end

def notification_ts=(new_notification_ts)
  if valid_timestamp? new_notification_ts or new_notification_ts.nil?
   @notification_ts = new_notification_ts
 else
   raise InvalidTimestampException, "bad notification_ts value"
 end
end

def name=(new_name)
  if valid_event_name? new_name or new_name.nil?
   @name = new_name
 else
   raise InvalidEventNameException, "bad name value"
 end
end

def description=(new_description)
  if valid_event_description? new_description or new_description.nil?
   @description = new_description
 else
   puts "What the fuck = " + new_description
   raise InvalidEventDescriptionException, "bad description value"
 end
end

end