
require 'colorize'
require 'json'
require 'geocoder'
require 'socket'
require 'open-uri'
require 'logger'
require 'yaml' 
require 'csv'


module NODE_HAVEN
  VERSION = "0.0.0"
end

def get7ZipPath
  path1 = "C:\\Program Files\\7-zip\\7z.exe"
  path2 = "C:\\Program Files (x86)\\7-zip\\7z.exe"

  if File.exists?(path1)
    return path1
  elsif File.exists?(path2)
    return path2
  else
    return ""
  end  
end

puts "Hello Inspector".cyan.bold
puts
puts get7ZipPath()
puts "#{__dir__}/testova.zip"

$zip = `7z e testova.zip`

$found = $zip.each_line do |line| 
  line =~ /Everything is Ok/ 
end
 
if $found == nil
  $logger.debug("7z error!".red.bold)
  return(false)
end
  
puts $zip.green.bold
