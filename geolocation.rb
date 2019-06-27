#!/usr//bin/env ruby

	require 'colorize'
	require 'json'
	require 'geocoder'
	require 'open-uri'

	def ip2geolocation ip, msg, name, lvl
	  
	  level_hash = {:low => 250000, :medium => 500000, :high =>1000000}
	  level = level_hash[lvl]
	  
    puts msg.green
    results = Geocoder.search(ip)
    #puts results.first.coordinates.to_s.green.bold
    #puts Geocoder.search(ip).first.city
    #puts Geocoder.search(ip).first.country 
    puts
    
    # json output template
    # chicago:{center:{lat:41.878,lng:-87.629},population:250000}
    output_str = "#{name}:{center:{lat:#{results.first.coordinates[0].to_s},lng:#{results.first.coordinates[1].to_s}}, population:#{level.to_s}}"	  
	end
	
	puts "Hello Inspector!".cyan.bold

=begin	
	puts "Paris Server IP address Lat/Long".green
	results = Geocoder.search("35.181.7.97")
	puts results.first.coordinates.to_s.green.bold
	puts Geocoder.search('35.181.7.97').first.city
	puts Geocoder.search('35.181.7.97').first.country 
	puts

	puts "Alpharetta Server IP address Lat/Long".green
	results =  Geocoder.search('23.31.131.205')
	puts results.first.coordinates.to_s.green.bold
	puts Geocoder.search('23.31.131.205').first.city # => Alpharetta
	puts Geocoder.search('23.31.131.205').first.country # => USA
	puts

	puts "Saint Peter Server IP address Lat/Long".green
	results =  Geocoder.search('5.18.186.107')
	puts results.first.coordinates.to_s.green.bold
	puts Geocoder.search('5.18.186.107').first.city # => "Saint Petersburg"
	puts Geocoder.search('5.18.186.107').first.country # => "Saint Petersburg"

	puts Geocoder.search('213.180.204.26').first.city #
	puts Geocoder.search('213.180.204.26').first.country # => "

	# ipstack access key
	# 3cac968bf84103fdafdae4902c486f44

	json_results = open("http://api.ipstack.com/23.31.131.205?access_key=3cac968bf84103fdafdae4902c486f44").read

	puts json_results
=end

  puts ip2geolocation("35.181.7.97", "Paris Server IP address Lat/Long", "paris_server", :medium)
  puts
  puts ip2geolocation("23.31.131.205", "Alpharetta Server IP address Lat/Long", "alpha_server", :high)
  puts
  puts ip2geolocation("5.18.186.107", "Saint Peter Server IP address Lat/Long", "saint_peter_server", :low)
  puts
  puts ip2geolocation("213.180.204.26","Moscow Sever IP address Lat/Long", "moscow_server", :low)
  puts
  
  
  
	puts "bye".cyan.bold
