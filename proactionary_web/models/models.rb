require 'mysql2'
require './models/exception'
require './models/validation'

class DB

	if ENV['RACK_ENV'] == "production"
		@@mysqlclient = Mysql2::Client.new(:host => "localhost", :username => "proactionary_us", :password => "wifmitotmmctmswowlib", :database => "proactionary", :reconnect => true)
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

end


