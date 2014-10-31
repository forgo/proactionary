require 'mysql2'
require './models/exception'
require './models/validation'
require './models/GeoBox'
require './models/PromoterObject'
require './models/EventObject'

class DB

	if ENV['RACK_ENV'] == "production"
		@@mysqlclient = Mysql2::Client.new(:host => "localhost", :username => "proactionary_u", :password => "wifmitotmmctmswowlib", :database => "proactionary", :reconnect => true)
	else
		@@mysqlclient = Mysql2::Client.new(:host => "localhost", :username => "root", :password => "password", :database => "proactionary")
	end

	def self.client
		@@mysqlclient
	end

	def self.getKarmaLevels()
		query="SELECT id, level FROM proactionary.karma";
		DB::client.query(query).to_a
	end

		def self.transaction(&block)
		raise ArgumentError, "No block was given for DB transaction." unless block_given?
		begin
			DB::client.query("BEGIN")
			yield
			DB::client.query("COMMIT")
      		return true # Successful Transaction
	  	rescue
	  		DB::client.query("ROLLBACK")
	      	return false # Failed Transaction
	  end
	end

	def self.escapeQuotes(str)
		str.gsub(/\\|'/) { |c| "\\#{c}" }
	end

	def self.getEventCountTotal()
		query="SELECT COUNT(*) AS `count` FROM events";
		DB::client.query(query).first["count"];
	end

	def self.getCategories()
		query="SELECT id, name FROM categories";
		category_array = DB::client.query(query).to_a
		categories = { "count" => category_array.length, "categories" => category_array }
	end

	def self.getStates()
		query="SELECT DISTINCT state from zip_codes ORDER BY state ASC";
		states_array = DB::client.query(query).to_a
		states = { "count" => states_array.length, "states" => states_array }
	end

	def self.getPromoterIDs()
		query="SELECT DISTINCT id from promoters ORDER BY id ASC";
		promoterIDs_array = DB::client.query(query).to_a
		promoterIDs = { "count" => promoterIDs_array.length, "promoterIDs" => promoterIDs_array }
	end

	def self.getRandomCategory()
		query = "SELECT * FROM `categories` WHERE id >= (SELECT FLOOR( MAX(id) * RAND()) FROM `categories` ) ORDER BY id LIMIT 1";
		DB::client.query(query).first
	end

	def self.readable(var)
		return var.to_s if var.class != String
		return "nil" if var.nil?
		return "\"\"" if var.empty?
		return "\"" + var + "\""
	end

	def self.insertEvent(event)
		raise "DB only inserts events with class EventObject" unless event.class == EventObject

		if event.alternate_location
			query = "CALL new_event_with_alternate_location( " +
				(event.promoter_id ? "#{event.promoter_id}" : "NULL") + ", " + 
				(event.category_id ? "#{event.category_id}" : "NULL") + ", " + 
				(event.approval_status ? "'Y'" : "'N'") + ", " + 
				(event.alternate_location ? "'Y'" : "'N'") + ", " + 
				(event.created_at ? "'"+event.created_at+"'" : "NULL") + ", " + 
				(event.updated_at ? "'"+event.updated_at+"'" : "NULL") + ", " + 
				(event.start_ts ? "'"+event.start_ts+"'" : "NULL") + ", " + 
				(event.end_ts ? "'"+event.end_ts+"'" : "NULL") + ", " + 
				(event.notification_ts ? "'"+event.notification_ts+"'" : "NULL") + ", " + 
				(event.name ? "'"+DB::escapeQuotes(event.name)+"'" : "NULL") + ", " + 
				(event.description ? "'"+DB::escapeQuotes(event.description)+"'" : "NULL") + ", " +
				(event.latitude ? "#{event.latitude}" : "NULL") + ", " +
				(event.longitude ? "#{event.longitude}" : "NULL") + ", " +
				(event.street ? "'"+DB::escapeQuotes(event.street)+"'" : "NULL") + ", " +
				(event.city ? "'"+DB::escapeQuotes(event.city)+"'" : "NULL") + ", " +
				(event.state ? "'"+DB::escapeQuotes(event.state)+"'" : "NULL") + ", " +
				(event.zip ? "'"+DB::escapeQuotes(event.zip)+"'" : "NULL") + ", " +
				(event.country ? "'"+DB::escapeQuotes(event.country)+"'" : "NULL") + " )";
		else
			query = "CALL new_event( " +
				(event.promoter_id ? "#{event.promoter_id}" : "NULL") + ", " + 
				(event.category_id ? "#{event.category_id}" : "NULL") + ", " + 
				(event.approval_status ? "'Y'" : "'N'") + ", " + 
				(event.alternate_location ? "'Y'" : "'N'") + ", " + 
				(event.created_at ? "'"+event.created_at+"'" : "NULL") + ", " + 
				(event.updated_at ? "'"+event.updated_at+"'" : "NULL") + ", " + 
				(event.start_ts ? "'"+event.start_ts+"'" : "NULL") + ", " + 
				(event.end_ts ? "'"+event.end_ts+"'" : "NULL") + ", " + 
				(event.notification_ts ? "'"+event.notification_ts+"'" : "NULL") + ", " + 
				(event.name ? "'"+DB::escapeQuotes(event.name)+"'" : "NULL") + ", " + 
				(event.description ? "'"+DB::escapeQuotes(event.description)+"'" : "NULL") + " )";
		end

		begin

			puts "------------------"
			puts "event query  = " + query
			puts "------------------"

			id = DB::client.query(query).first["id"];

			# As per https://github.com/brianmario/mysql2/issues/307
			# "for the time being you need to call client.abandon_results! between queries. That will read and throw away any pending results, allowing you to send another query."
			DB::client.abandon_results!
			puts "------------------"
			puts "result of insert event = " + id.to_s
			puts "------------------"
			return id
		rescue Exception => e
			puts("#{e.class}: Failed to insert event.")
			return nil
		end
	end

	def self.insertPromoter(promoter)
		raise "DB only inserts promoters with class PromoterObject" unless promoter.class == PromoterObject

		query = "CALL new_promoter( " +
			(promoter.facebook_id ? "#{promoter.facebook_id.to_s}" : "NULL") + ", " + 
			(promoter.category_id ? "#{promoter.category_id.to_s}" : "NULL") + ", " + 
			(promoter.name ? "'"+DB::escapeQuotes(promoter.name)+"'" : "NULL") + ", " + 
			(promoter.slogan ? "'"+DB::escapeQuotes(promoter.slogan)+"'" : "NULL") + ", " + 
			(promoter.latitude ? "#{promoter.latitude}" : "NULL") + ", " + 
			(promoter.longitude ? "#{promoter.longitude}" : "NULL") + ", " + 
			(promoter.street ? "'"+DB::escapeQuotes(promoter.street)+"'" : "NULL") + ", " + 
			(promoter.city ? "'"+DB::escapeQuotes(promoter.city)+"'" : "NULL") + ", " + 
			(promoter.state ? "'"+DB::escapeQuotes(promoter.state)+"'" : "NULL") + ", " + 
			(promoter.zip ? "'"+DB::escapeQuotes(promoter.zip)+"'" : "NULL") + ", " + 
			(promoter.country ? "'"+DB::escapeQuotes(promoter.country)+"'" : "NULL") + ", " + 
			(promoter.phone ? "'"+DB::escapeQuotes(promoter.phone)+"'" : "NULL") + ", " + 
			(promoter.active_status ? "'Y'" : "'N'") + ", " + 
			(promoter.color_primary ? "'"+promoter.color_primary+"'" : "NULL") + ", " + 
			(promoter.color_secondary ? "'"+promoter.color_secondary+"'" : "NULL") + ", " + 
			(promoter.created_at ? "'"+promoter.created_at+"'" : "NULL") + ", " + 
			(promoter.updated_at ? "'"+promoter.updated_at+"'" : "NULL") + " )";

		begin
			puts "------------------"
			puts "promoter query  = " + query
			puts "------------------"
			id = DB::client.query(query).first["id"];

			# As per https://github.com/brianmario/mysql2/issues/307
			# "for the time being you need to call client.abandon_results! between queries. That will read and throw away any pending results, allowing you to send another query."
			DB::client.abandon_results!
			puts "------------------"
			puts "result of insert promoter = " + id.to_s
			puts "------------------"
			return id
		rescue Exception => e
			puts("#{e.class}: Failed to insert promoter.")
			return nil
		end
	end

	def self.sectionEventsByDay(events_unsectioned)
		# Now that we have events, let's do some extra organization for the clients
		day_boundary = nil
		sections = []
		num_sections = 0;
		section_events = [];
		num_section_events = 0;
		day_date = DateTime.new

		# Loop Through Full List of Events, Ordered by Start Time
		events_unsectioned.each_with_index do |event, index|

			# Section On Day of Event's Start Time
			day_date = DateTime.strptime(event["start"].to_s, "%Y-%m-%d %H:%M:%S %z")

			# New Section Reached, No Boundary Set If First Section
			if day_boundary.nil? or not (day_date === day_boundary)

				# Wait For Accumulation of Events Before Pushing Section
				if num_sections > 0
					sections[num_sections - 1] = 
						{ 
							"label" 	=> day_date.strftime(FORMAT_DAY_BOUNDARY), 
						  	"events" 	=> section_events.dup	# shallow copy
						}

					day_boundary = day_date 				# new boundary to beat 
					section_events.clear 					# clear events array for next section
					num_section_events = 0 					# reset event counter for next section
				end

				num_sections = num_sections + 1 		# on to next section
			end

			section_events.push(event);					# add next event to this section
			num_section_events = num_section_events + 1 # on to next event
		end

		# No Events, Return Empty Sections Array and Count = 0
		if num_sections <= 0
			events = { "count" => 0, "sections" => [] }
		else
			# After Last Iteration (Make Sure Last Section is Accounted For)
			sections[num_sections -1] = 
				{ 
					"label" => day_date.strftime(FORMAT_DAY_BOUNDARY), 
					"events" => section_events.dup	# shallow copy
				}

			events = { "count" => events_unsectioned.length , "sections" => sections }
		end
		events
	end

	def self.getEvents(request, category_id, promoter_id, range, location, date_option, date1, date2)

		logit("DB::getEvents(\n\t"+request.to_s+", # request"+
				"\n\t"+DB::readable(category_id)+", # category_id"+
				"\n\t"+DB::readable(promoter_id)+", # promoter_id"+
				"\n\t"+DB::readable(range)+", # range"+
				"\n\t"+DB::readable(location)+", # location"+
				"\n\t"+DB::readable(date_option)+", # date_option"+
				"\n\t"+DB::readable(date1)+", # date1"+
				"\n\t"+DB::readable(date2)+"  # date2\n)");

		raise InvalidDatabaseIDException, "bad database id value" unless valid_database_id? category_id
		raise InvalidDatabaseIDException, "bad database id value" unless valid_database_id? promoter_id
		raise InvalidRangeException, "bad range value" unless valid_range? range
		raise InvalidCoordinateException, "bad coordinate value" unless valid_coordinate? location
		raise InvalidDateOptionException, "bad date options" unless valid_date_option? date_option, date1, date2

		# Query Category Filter
		category_condition = (category_id == 0) ? " " : "AND e.category_id="+category_id.to_s+" "

		# Query Promoter Filter
		promoter_condition = (promoter_id == 0) ? " " : "AND p.id="+promoter_id.to_s+" "

		# Query Range Filter
		range_condition = (range != 0) ? "AND "+self.getLatLonConditionWithinDistanceOfLatLon(location["lat"], location["lng"], range.to_f, "p", "e", "a") : " "

		# Query Date Filter
		min_date = date1+" 00:00:00"
		max_date = (date_option == "on") ? date1+" 23:59:59" : date2+" 23:59:59"
		date_condition = "AND (e.start_ts BETWEEN '"+min_date+"' AND '"+max_date+"') "

		# Construct the Final Query
		query = "SELECT e.id AS `event_id`, " +
		"e.name AS `name`, "+
		"e.description AS `description`, "+
		"e.alternate_location AS `alt_location`, "+
		"IF(e.alternate_location = 'Y', a.latitude, p.latitude) AS `latitude`, "+
		"IF(e.alternate_location = 'Y', a.longitude, p.longitude) AS `longitude`, "+
		"IF(e.alternate_location = 'Y', a.street, p.street) AS `street`, "+
		"IF(e.alternate_location = 'Y', a.city, p.city) AS `city`, "+
		"IF(e.alternate_location = 'Y', a.state, p.state) AS `state`, "+
		"IF(e.alternate_location = 'Y', a.zip, p.zip) AS `zip`, "+
		"IF(e.alternate_location = 'Y', a.country, p.country) AS `country`, "+
		"e.start_ts AS `start`, "+
		"e.end_ts AS `end`, " +
		"p.id as `promoter_id`, "+
		"p.name as `promoter_name`, "+
		"c.id as `category_id`, "+
		"c.name AS `category` "+
		"FROM events AS e "+
		"LEFT OUTER JOIN alternate_locations AS a ON e.id = a.id " +	# Predence of Join Matters (outer join alternate location table first to avoid spitting back everything)
		"INNER JOIN categories AS c ON e.category_id = c.id " +
		"INNER JOIN promoters AS p ON e.promoter_id = p.id " + 
		category_condition + 
		promoter_condition + 
		range_condition +
		date_condition +
		"ORDER BY e.start_ts ASC LIMIT 100";		# For now let's limit the total events because do we really expect there to be > 100 Events coming back for a particular query?

		puts query
		events = DB::client.query(query).to_a
		DB::sectionEventsByDay(events)
	end

	def self.getEventsForPromoter(id)

		raise InvalidDatabaseIDException, "bad database id value" unless valid_database_id? id

		query = "SELECT c.name AS `Category`, "+
		"e.name AS `Event`, "+
		"e.description AS `What\'s Happening?`, "+
		"DATE_FORMAT(e.start_ts, '%b %D, %l:%i %p') AS `Start`, "+
		"DATE_FORMAT(e.end_ts, '%b %D, %l:%i %p') AS `End` "+
		"FROM events AS e, categories AS c "+
		"WHERE e.promoter_id = " + id.to_s + " AND c.id = e.category_id";
		DB::client.query(query)
	end

	def self.getPromoter(id)
		raise InvalidDatabaseIDException, "bad database id value" unless valid_database_id? id
		query = "SELECT * FROM promoters where id = "+id.to_s+" LIMIT 1"
		DB::client.query(query).first
	end

	def self.getRandomPromoter()
		query = "SELECT * FROM `promoters` WHERE id >= (SELECT FLOOR( MAX(id) * RAND()) FROM `promoters` ) ORDER BY id LIMIT 1";
		DB::client.query(query).first
	end

	def self.getPromoterFullAddress(id)
		raise InvalidDatabaseIDException, "bad database id value" unless valid_database_id? id
		query="SELECT z.id, z.city, z.state, p.address FROM zip_codes z, promoters p WHERE p.id = "+id.to_s+" AND z.id = p.zip"
		logit("ambiguous??? = " + query)
		result = DB::client.query(query).first
		result["address"] + ", " + result["city"] + ", " + result["state"] + " " + result["id"].to_s
	end

	def self.getPromoterFullPhone(id)
		raise InvalidDatabaseIDException, "bad database id value" unless valid_database_id? id
		query="SELECT phone FROM promoters WHERE id = "+id.to_s+" LIMIT 1"
		unformatted = DB::client.query(query).first["phone"]
		digits = unformatted.gsub(/\D/, '').split(//)
		if (digits.length == 11 and digits[0] == '1')
			digits.shift	# strip leading 1
		end
		if (digits.length == 10)
			'(%s) %s-%s' % [ digits[0,3].join(""), digits[3,3].join(""), digits[6,4].join("") ]
		end
	end

	def self.getOperatingHours(id)
		raise InvalidDatabaseIDException, "bad database id value" unless valid_database_id? id
		query="SELECT * FROM promoter_operating_hours WHERE id = "+id.to_s+" LIMIT 1"
		DB::client.query(query)
	end


	def self.getLatLonConditionWithinDistanceOfLatLon(latitude, longitude, distance, promoter_table_label, event_table_label, alternate_location_table_label)

		raise InvalidLatitudeException, "bad latitude value" unless valid_latitude? latitude
		raise InvalidLongitudeException, "bad longitude value" unless valid_longitude? longitude
		raise InvalidSingleLowerCharException, "bad single lowercase character value" unless valid_single_lowercase_character? promoter_table_label
		raise InvalidSingleLowerCharException, "bad single lowercase character value" unless valid_single_lowercase_character? event_table_label
		raise InvalidSingleLowerCharException, "bad single lowercase character value" unless valid_single_lowercase_character? alternate_location_table_label

		# Create Coordinate Bounding Box Around Lat/Lon Location
		location = GeoBox.new(latitude, longitude, "degrees", distance.to_f)

		# Extract String Values of Location + Bounds for Query Generation
		minLat = location.minLatitude;
		maxLat = location.maxLatitude;
		minLon = location.minLongitude;
		maxLon = location.maxLongitude;
		lat = location.latitude;
		lon = location.longitude;

		raise InvalidLatitudeException, "bad latitude value" unless valid_latitude? minLat.value, "radians"
		raise InvalidLongitudeException, "bad longitude value" unless valid_longitude? minLon.value, "radians"
		raise InvalidLatitudeException, "bad latitude value" unless valid_latitude? maxLat.value, "radians"
		raise InvalidLongitudeException, "bad longitude value" unless valid_longitude? maxLon.value, "radians"
		raise InvalidLatitudeException, "bad latitude value" unless valid_latitude? lat.value, "radians"
		raise InvalidLongitudeException, "bad longitude value" unless valid_longitude? lon.value, "radians"

		# Does the GeoBox Intersect with the 180th Meridian?
		on180Meridian = location.minLongitude.value > location.maxLongitude.value;

		# Angle from center of GeoBox to edge of GeoBox
		swathAngle = sprintf("%10.10f", distance / GeoBox::EARTH_RADIUS)

		ifAltLat = "IF("+event_table_label+".alternate_location = 'Y', "+alternate_location_table_label+".latitude, "+promoter_table_label+".latitude)"
		ifAltLng = "IF("+event_table_label+".alternate_location = 'Y', "+alternate_location_table_label+".longitude, "+promoter_table_label+".longitude)"

		condition = "((RADIANS("+ifAltLat+") >= " + minLat.to_s + " AND " +
				 	 "RADIANS("+ifAltLat+") <= " + maxLat.to_s + ")" +
					" AND " +
					"(RADIANS("+ifAltLng+") >= " + minLon.to_s +
					(on180Meridian ? " OR " : " AND ") + 
					 "RADIANS("+ifAltLng+") <= " + maxLon.to_s + ")" +
					" AND " + 
					"ACOS(SIN("+lat.to_s+") * " + "SIN(RADIANS("+ifAltLat+")) + " + 
						 "COS("+lat.to_s+") * COS(RADIANS("+ifAltLat+")) * COS(RADIANS("+ifAltLng+") - "+lon.to_s+"))" + 
				 	" <= " + swathAngle + ") ";
		return condition;
	end

	def self.getLatLonConditionWithinDistanceOfZipCode(zip_code, distance, promoter_table_label, event_table_label, alternate_location_table_label)
		raise InvalidZipException, "bad zip value" unless valid_zip? zip_code
		# Create Coordinate Bounding Box Around Zip Code Location
		query_zip="SELECT * from zip_codes WHERE id="+zip_code
		result_zip = DB::client.query(query_zip).first
		puts "result_zip = " + result_zip.to_s
		puts "distance = " + distance.to_s
		DB.getLatLonConditionWithinDistanceOfLatLon(result_zip['latitude'], result_zip['longitude'], distance.to_f, promoter_table_label, event_table_label, alternate_location_table_label)
	end

end


