#-------------------------------------------------------------------------------
# PROACTIONARY.COM
#-------------------------------------------------------------------------------
# constants.rb
# ------------------------------------------------------------------------------
# Author: 	Elliott Richerson
# Created:  July 20, 2014
# Modified: July 20, 2014
# ------------------------------------------------------------------------------

DEFAULT_CATEGORY_ID = 0 		# 0 = All Categories
DEFAULT_PROMOTER_ID = 0 		# 0 = All Promoters
DEFAULT_DATE_OPTION = "on" 		# "on" / "between"
DEFAULT_RANGE = 10 				# miles

# Somewhere Near 78240 in San Antonio
DEFAULT_LATITUDE = 29.5269768
DEFAULT_LONGITUDE = -98.6105703


REGEX_LABEL = /^[-' a-zA-Z0-9\[\]\(\)\+\$\*\^\?\.!#&%=,\/<>:"~_]+$/i
REGEX_HEX_COLOR = /^#[a-f0-9]{6}$/i
REGEX_ZIP = /^[0-9]{5}$/
REGEX_PHONE = /^[0-9]{10}$/
REGEX_ALPHA_LOWER = /^[a-z]{1}$/

FORMAT_DATE = "%Y-%m-%d"
FORMAT_TIMESTAMP = "%Y-%m-%d %H:%M:%S"
FORMAT_DAY_BOUNDARY = "%A, %b.%d, %Y"
FORMAT_DAY_TIME = "%I:%M %p"
