fs = require 'fs'

# gdata = JSON.parse fs.readFileSync '/home/david/gavel/test_game_data.json'

# # Strip out the scanlines to make things a little less overwhelming to read.
# map_data = JSON.parse gdata.map_data

# for rname, region of map_data.regions
# 	region.scanlines = []

# console.log JSON.stringify map_data, null, 4


vdata = JSON.parse fs.readFileSync '/home/david/gavel/test_variant_data.json'
console.log JSON.stringify (JSON.parse vdata.map_data), null, 4
