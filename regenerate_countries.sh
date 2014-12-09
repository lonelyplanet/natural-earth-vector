#!/bin/sh

mkdir -p filtered
ruby tools/filter_countries.rb boundaries.yml countries filtered
ruby tools/join_countries.rb filtered geojson/ne_10m_admin_0_countries_common.geojson
