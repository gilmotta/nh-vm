#!/usr/bin/env ruby

	require 'colorize'
	require 'json'
	require 'geocoder'
	require 'socket'
	require 'open-uri'
	
	puts "Hello Inspector!".cyan.bold
	puts "decoding our ip address"
	puts

	# get my IP address
	ip = open('http://whatismyip.akamai.com').read

	results = Geocoder.search(ip)
	puts results.first.coordinates
	puts results.first.country
	
	puts
	
	results = Geocoder.search("52.205.48.33")
	puts results.first.coordinates
	puts results.first.country
	
	puts
	
	server_ip_address = "52.205.48.33"
	server_info = open("http://api.ipstack.com/#{server_ip_address}" + "?access_key=724b41fa34f45d09b3161ca59cdd9e54&format=1").read
	
	#puts server_info.green
	
	info = JSON.parse(server_info)
	
	puts info["latitude"].to_s
	puts info["longitude"].to_s
	
	puts "bye".cyan.bold
