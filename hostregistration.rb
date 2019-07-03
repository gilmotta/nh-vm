#!/usr/bin/env ruby

  require 'colorize'
  require 'uri'
  require 'net/http'
  require 'net/https'
  require 'json'
  require 'csv'
  require_relative 'os_detector.rb'
  
  def getSystemInfo      
      if OS.windows?()
          # if running on windows
          # get the system info in CSV format
          $systeminfocsv = `systeminfo /fo CSV`
      
          File.write('systeminfo.csv', $systeminfocsv)
          
          #$systeminfoCSV = CSV.read('systeminfo.csv', headers:true)
          #$systeminfo = $systeminfoCSV.to_json
          
          lines = CSV.open('systeminfo.csv').readlines
          keys = lines.delete lines.first
          
          File.open('systeminfo.json', 'w') do |f|
            data = lines.map do |values|
              Hash[keys.zip(values)]
            end
            f.puts JSON.pretty_generate(data)
          end

          file = File.open('systeminfo.json')
          $systeminfo = file.read
      else
          $systeminfo = `sudo lshw -json`
      end
      return $systeminfo  
  end

  puts "Hello Inspector!".cyan.bold
  
  begin
    uri = URI.parse('https://nh.cargohold.net:8443/hostregistration.php')
    https = Net::HTTP.new(uri.host,uri.port)
    https.use_ssl = true
    https.verify_mode = OpenSSL::SSL::VERIFY_NONE
      
    req = Net::HTTP::Post.new(uri.path, initheader = {'Content-Type' => 'text/plain'})
    req.body = getSystemInfo
    
    res = https.request(req)
    puts "Response #{res.code} #{res.message}: #{res.body}".yellow.bold
  rescue StandardError => e
    puts e.message  
    puts e.backtrace.inspect
    exit(1)
  end

  puts "bye".cyan.bold
  