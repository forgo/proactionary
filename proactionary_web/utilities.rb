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

