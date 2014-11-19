source_folder = ARGV[0]
dest_file = ARGV[1]
unless source_folder && dest_file
  puts "Usage: split_countries.rb source_folder dest_file.geojson"
  exit 1
end

require 'json'

collection = {'type' => 'FeatureCollection', 'features' => []}

Dir.foreach(source_folder) do |country|
  puts country
  next if country[0].chr == '.'
  collection['features'] << JSON.parse(File.read(File.join(source_folder, country)))
end

File.open(dest_file, 'w') do |f|
  f.write(collection.to_json)
end
