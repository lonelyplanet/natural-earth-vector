source_file = ARGV[0]
dest_folder = ARGV[1]
unless source_file && dest_folder
  puts "Usage: split_countries.rb source.geojson dest_folder"
  exit 1
end

require 'json'

obj = JSON.parse(File.read(source_file))
obj['features'].each do |country|
  id = country['properties']['adm0_a3']
  File.open(File.join(dest_folder, "#{id}.geojson"), 'w') do |f|
    f.write(country.to_json)
  end
end