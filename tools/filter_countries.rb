boundaries_file = ARGV[0]
source_folder = ARGV[1]
dest_folder = ARGV[2]
unless boundaries_file && source_folder && dest_folder
  puts "Usage: filter_countries.rb boundaries_file source_folder dest_folder"
  exit 1
end

require 'json'
require 'yaml'
require 'rgeo'

boundaries = YAML::load_file(boundaries_file)

def polygon_within?(polygon, boundary)
  geo = RGeo::Geographic.simple_mercator_factory
  lon1, lat1, lon2, lat2 = boundary
  lat1, lon1, lat2, lon2 = lat1.to_f, lon1.to_f, lat2.to_f, lon2.to_f
  ring = geo.linear_ring([
    geo.point(lon1, lat1), geo.point(lon2, lat1), geo.point(lon2, lat2), geo.point(lon1, lat2)
  ])
  poly = geo.polygon(ring)
  outlyer = polygon.find do |part|
    part.find do |coord|
      c_lon, c_lat = coord
      point = geo.point(c_lon, c_lat)
      puts point.within?(poly)
      !point.within?(poly)
    end
  end
  outlyer.nil? ? true : false
end

def deep_dup(hash)
  Marshal.load(Marshal.dump(hash))
end

def write_dest(dest_folder, iso, hash)
  File.open(File.join(dest_folder, "#{iso}.geojson"), 'w') do |fw|
    fw.write(hash.to_json)
  end

end

Dir.foreach(source_folder) do |file_name|

  next if file_name[0].chr == '.'
  country = File.basename(file_name, '.geojson')
  puts country
  hash =  JSON.parse(File.read(File.join(source_folder, file_name)))
  geo = hash['geometry']
  boundary = boundaries[hash['properties']['adm0_a3']]

  targets = {}
  if boundary && geo['type'] == 'MultiPolygon' # only deal with multipolygons for now
    if boundary.is_a?(String)
      targets[country] = boundary
    elsif boundary.is_a?(Hash)
      targets = boundary
    end
    targets.each do |target, boundary|
      target_hash = deep_dup(hash)
      geo = target_hash['geometry']
      geo['coordinates'].reject! do |polygon|
        !polygon_within?(polygon, boundary.split(/,s*/))
      end
      ['adm0_a3', 'gu_a3', 'su_a3', 'brk_a3', 'iso_a3', 'adm0_a3_is', 'adm0_a3_us'].each do |k|
        target_hash['properties'][k] = target
      end
      write_dest(dest_folder, target, target_hash)
    end
  else
    write_dest(dest_folder, country, hash)
  end


end

