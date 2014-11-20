boundaries_file = ARGV[0]
source_folder = ARGV[1]
dest_folder = ARGV[2]
unless boundaries_file && source_folder && dest_folder
  puts "Usage: filter_countries.rb boundaries_file source_folder dest_folder"
  exit 1
end

require 'json'
require 'yaml'

boundaries = YAML::load_file(boundaries_file)

def polygon_within?(polygon, boundary)
  lon1, lat1, lon2, lat2 = boundary
  lat1, lon1, lat2, lon2 = lat1.to_f, lon1.to_f, lat2.to_f, lon2.to_f
  outlyer = polygon.find do |part|
    part.find do |coord|
      c_lon, c_lat = coord
      c_lon < lon1 || c_lon > lon2 || c_lat < lat1 || c_lat > lat2
    end
  end
  outlyer.nil? ? true : false
end

Dir.foreach(source_folder) do |country|

  next if country[0].chr == '.'
  puts country
  hash =  JSON.parse(File.read(File.join(source_folder, country)))
  geo = hash['geometry']
  boundary = boundaries[hash['properties']['adm0_a3']]

  if boundary && geo['type'] == 'MultiPolygon' # only deal with multipolygons for now

    geo['coordinates'].reject! do |polygon|
      !polygon_within?(polygon, boundary.split(/,s*/))
    end
  end

  File.open(File.join(dest_folder, country), 'w') do |fw|
    fw.write(hash.to_json)
  end

end

