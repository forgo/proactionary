#-------------------------------------------------------------------------------
# PROACTIONARY.COM
#-------------------------------------------------------------------------------
# config.ru
# ------------------------------------------------------------------------------
# Author: 	Elliott Richerson
# Created:  July 20, 2014
# Modified: July 20, 2014
# ------------------------------------------------------------------------------

require 'rubygems'
require 'bundler'

Bundler.require

require File.dirname(__FILE__) + "/app"

run ProactionaryApp