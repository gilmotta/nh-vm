#!/usr/bin/env ruby

	require 'colorize'
	require 'json'
	require 'geocoder'
	require 'socket'
	require 'open-uri'
require 'speedtest'
	
	module NODE_HAVEN
	
	  module Geodecoder
	  
	    def Geodecoder.main
	    
	        $logger.debug( "Geocoder main ...")
        
        	# get my IP address
        	ip = open('http://whatismyip.akamai.com').read

=begin        
        	# Geocoder is NOT the best solution for Geocoding an IP address
        	# it is not very accurate
        	results = Geocoder.search(ip)
        	puts results.first.coordinates
        	puts results.first.country
=end        	
        	server_ip_address = ip
        	server_info = open("http://api.ipstack.com/#{server_ip_address}" + "?access_key=724b41fa34f45d09b3161ca59cdd9e54&format=1").read
        	
        	#puts server_info.green
        	
        	info = JSON.parse(server_info)
        	
        	puts info["latitude"].to_s
        	puts info["longitude"].to_s
        	  
          test = Speedtest::Test.new(
            download_runs: 2,
              upload_runs: 2,
              ping_runs: 2,
              download_sizes: [750, 1500],
              upload_sizes: [10000, 400000],
              debug: true
           )
              
           results = test.run
           puts results        	  
        	
        	puts "bye".cyan.bold
        	return server_info  	
	    end
	  end
	end
