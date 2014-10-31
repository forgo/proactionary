#-------------------------------------------------------------------------------
# PROACTIONARY.COM
#-------------------------------------------------------------------------------
# utilities.rb
# ------------------------------------------------------------------------------
# Author: 	Elliott Richerson
# Created:  July 20, 2014
# Modified: July 20, 2014
# ------------------------------------------------------------------------------
require './constants'

def logit(msg)
	puts "----------------------------------------------------------"
	puts msg
	puts "----------------------------------------------------------"
end

def event_count_total
	DB.getEventCountTotal
end

def event_category
	result = DB.getCategories

	html = "<li data-value='0' data-selected='true'>All</li>"
	if (result["count"] > 0)
		result["categories"].each do |category|
			html += "\t<li data-value='"+category["id"].to_s+"' data-selected='false'>"+category["name"]+"</li>"
		end
	end
	html
end

def promoter_category_form
	result = DB.getCategories

	html = ""
	if (result["count"] > 0)
		result["categories"].each_with_index do |category, index|
			if index == 0
				html += "\t<option name='"+category["name"]+"' value='"+category["id"].to_s+"' selected>"+category["name"]+"</option>"
			else
				html += "\t<option name='"+category["name"]+"' value='"+category["id"].to_s+"'>"+category["name"]+"</option>"
			end
		end
	end
	html
end

def promoter_state_form
	result = DB.getStates

	html = ""
	if (result["count"] > 0)
		result["states"].each_with_index do |state, index|
			if index == 0
				html += "\t<option name='"+state["state"]+"' value='"+state["state"].to_s+"' selected>"+state["state"]+"</option>"
			else
				html += "\t<option name='"+state["state"]+"' value='"+state["state"].to_s+"'>"+state["state"]+"</option>"
			end
		end
	end
	html
end

def promoter_id_form
	result = DB.getPromoterIDs

	html = ""
	if (result["count"] > 0)
		result["promoterIDs"].each_with_index do |promoterID, index|
			if index == 0
				html += "\t<option name='"+promoterID["id"].to_s+"' value='"+promoterID["id"].to_s+"' selected>"+promoterID["id"].to_s+"</option>"
			else
				html += "\t<option name='"+promoterID["id"].to_s+"' value='"+promoterID["id"].to_s+"'>"+promoterID["id"].to_s+"</option>"
			end
		end
	end
	html
end

def event_hour_form
	hourArray = [12,1,2,3,4,5,6,7,8,9,10,11]
	html = ""
	hourArray.each do |h|
		html += "\t<option name='eventStartHour' value='"+h.to_s+"'>"+h.to_s+"</option>"
	end
	html
end

def event_minute_form
	minuteArray = ["00","15","30","45"]
	html = ""
	minuteArray.each do |m|
		html += "\t<option name='eventStartMinute' value='"+m.to_s+"'>"+m.to_s+"</option>"
	end
	html
end

#There is another way to do this with type="number" and min/max but it doesn't have easy validation
def event_durationHr_form
	dHourArray = [0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23]
	html = ""
	dHourArray.each do |dh|
		html += "\t<option name='eventStartHour' value='"+dh.to_s+"'>"+dh.to_s+"</option>"
	end
	html
end

def event_durationMn_form
	dMinuteArray = [0,15,30,45]
	html = ""
	dMinuteArray.each do |dm|
		html += "\t<option name='eventStartMinute' value='"+dm.to_s+"'>"+dm.to_s+"</option>"
	end
	html
end

def event_range
	ranges = [1,2,5,10,25,50,100,0];	# miles
	html = ""
	ranges.each do |r|
		# TODO: Select 10 miles by default
		html += "\t<li data-value='"+r.to_s+"' data-selected='"+(r == 10 ? "true" : "false")+"'>"+(r == 0 ? "any distance" : r.to_s+" miles")+"</li>"
	end
	html
end

def event_date_option
	html = "\t<li data-value='on' data-selected='true'>on</li>"
	html += "\t<li data-value='between' data-selected='false'>between</li>"
end

def event_promoter
	html = "<input id='event_promoter' name='event_promoter' type='hidden' maxlength='25' placeholder='promoter' value='0'>"
end

def events_spinner
	html = "<img src='/img/spinner.gif' alt='Events loading...'>"
end

def events_table()
	htmlTable(events_default());
end

def events_list_sidebar(ip)
	htmlListSidebar(events_default(request));
end

def htmlListSidebar(events)

	# TODO: Actually Use Promoter ID Based Filename for Getting Stored Icons
	iconFilenames = ["Amazon","Basecamp","Behance","Blogger","DeviantArt","Dribbble","Dropbox","Evernote","Facebook","Flickr","Forrst","GitHub","GooglePlus","Instagram","LastFM","LinkedIn","Picasa","Pinterest","Reddit","Rss","ShareThis","Skype","StumbleUpon","Tumblr","Twitter","Vimeo","Vine","YouTube"]

	html = "<ul>"
	events["sections"].each do |section, section_index|
		# Section Header
		html += %{
			<li class="sidebar-event-boundary">
				<a name="#{section_index}">#{section["label"]}</a>
			</li>
		}
		# Section Events
		section["events"].each do |event, event_index|	
			html += %{
				<li>
					<div class="sidebar-event">
						<div class="sidebar-event-time">
							<div class="sidebar-event-time-start">#{event["start"].strftime(FORMAT_DAY_TIME)}</div>
							<div class="sidebar-event-time-end">#{event["end"].strftime(FORMAT_DAY_TIME)}</div>
						</div>
						<div class="sidebar-event-text">
							<div class="sidebar-event-text-title">#{event["name"]}</div>
							<div class="sidebar-event-text-description">#{event["description"]}</div>
						</div>
						<div class="sidebar-event-icon">
							<img width="48px" height="48px" src="/img/icons/#{iconFilenames.sample}.png" alt="#{event["promoter_name"]}" />
						</div>
					</div>
				</li>
			}
		end
	end
	html += "</ul>"
end

def htmlTable(data)

	# ActiveRecord Result Was Empty (Grab Columns For Empty Table)
	if (result.count == 0)
		data = Array[Hash[result.fields.map {|k| [k,""]}]]
	end

	if (result.count != 0) && (data.class != Array || data.first.class != Hash || !data)
		  	raise "Expected Array of Hash(es) to create table markup"
	else 
		bootstrap_classes = ["table", "table-striped", "table-bordered", "table-condensed"]

		html = "<table class='"+bootstrap_classes.join(" ")+"'>"
		num_rows = data.length
		num_cols = data.first.length

		# Header Row
		html += "<tr class='heading'>"
		data.first.each_key do |key|
			html += "<th class='bold' style='text-align:left'>" + key.to_s + "</th>"
		end
		html += "</tr>"

		data.each_with_index do |row, index|
			# Confirm Keys Identical to First
			# unless sameKeys(row, data.first)
			# 	what = "Row " + index.to_s + " of table has mismatched keys: " + row.keys.to_s + " compared to " + data.first.keys.to_s
			# 	raise what
			# end
			# Data Rows
			html += (index % 2 == 0) ? "<tr>" : "<tr class='odd'>"
			row.each do |key,value|
				html += "<td>" + value.to_s + "</td>"
			end
			html += "</tr>"
		end
	end
	html += "</table>"
end

def sameKeys(h1,h2)
	if (h1.size == h2.size)
		h1.keys.all?{ |key| !!h2[key] }
	end
end

