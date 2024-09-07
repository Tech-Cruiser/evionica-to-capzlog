# frozen_string_literal: true

require 'bundler/setup'
Bundler.require(:default)

EXPECTED_HEADERS = [
  "Date", "Registration", "Type", "From", "To", "Off Block", "On Block", "Total Time", "SE Time", "ME Time", "MP Time", 
  "PIC Time", "Copi Time", "Dual Time", "Instructor Time", "PICUS Time", "SPIC Time", "Night Time", "IFR Time", 
  "PIC Name", "Day Ldg", "Night Ldg", "IFR Approaches", "Day Toff", "Night Toff", "IFR Departures", "Remark", 
  "Marker: Cross Country", "Marker: Solo"
].freeze

HEADER_MAPPING = {
  day: "Date",
  registration_number: "Registration",
  aircraft: "Type",
  departure_place: "From",
  arrival_place: "To",
  engine_start_time: "Off Block",
  engine_stop_time: "On Block",
  engine_time: "Total Time",
  vfr_night: "Night Time",
  ifr: "IFR Time",
  pilot_in_command: "PIC Name",
  number_of_flights: "Day Ldg",
  touch_and_goes: "Night Ldg",
  nr_of_approaches: "IFR Approaches",
  day_toff: "Day Toff",
  go_arounds: "Night Toff",
  remarks: "Remark",
  cross_country: "Marker: Cross Country",
  marker_solo: "Marker: Solo"
}.freeze

AIRCRAFT_TYPE_MAPPING = {
  "Czech Aircraft Group s.r.o. PS-28 Cruiser" => "CRUZ",
  "AEROSTAR SA R40F Festival" => "FEST",
  "Zlin 142" => "Z142",
  "Zlin 242" => "Z242",
  "Cessna 172" => "C172",
  "Cessna 182" => "C182"
}.freeze

AERODROME_CODE_MAPPING = {
  'ATCJ' => 'DZM',
  'LRCJ' => 'DZM',
  'LRMM' => 'LRBM'
}.freeze

CALCULATED_HEADERS = ['SE Time', 'Dual Time', 'PIC Time', 'SPIC Time', 'PICUS Time'].freeze
ADDITIONAL_EMPTY_HEADERS = {
  'ME Time' => '0:00',
  'MP Time' => '0:00',
  'Copi Time' => '0:00',
  'Instructor Time' => '0:00',
  'IFR Approaches' => 0,
  'IFR Departures' => 0
}.freeze

def convert_csv(input_file, output_file, user_name, dpe_name)
  options = {
    headers_in_file: true,
    quote_char: '"',
    col_sep: ',',
    file_encoding: 'UTF-8'
  }

  CSV.open(output_file, "wb") do |csv|
    SmarterCSV.process(input_file, options) do |chunk|
      chunk.each_with_index do |row, index|
        next csv << EXPECTED_HEADERS if csv.lineno.zero?

        csv << convert_row(row, user_name, dpe_name)
      end
    end
  end
end

def convert_headers(headers)
  new_headers = headers.map { |header| HEADER_MAPPING[header] || header }
  
  total_time_index = new_headers.index('Total Time')
  if total_time_index
    new_headers.insert(total_time_index + 1, 'SE Time', *CALCULATED_HEADERS, *ADDITIONAL_EMPTY_HEADERS.keys)
  else
    # Handle the case where 'Total Time' is not found
    new_headers.concat(['SE Time', *CALCULATED_HEADERS, *ADDITIONAL_EMPTY_HEADERS.keys])
  end
  
  new_headers
end

def convert_row(row_hash, user_name, dpe_name)
  new_row = row_hash.transform_keys { |key| HEADER_MAPPING[key.to_sym] || key }

  update_aircraft_type!(new_row)
  update_aerodrom_code!(new_row)
  add_single_engine_time!(new_row)
  add_default_empty_values!(new_row)
  add_pic_times!(new_row, user_name, dpe_name)

  ordered_row = EXPECTED_HEADERS.map { |header| new_row[header] }
  ordered_row
end

def update_aircraft_type!(new_row)
  new_row['Type'] = AIRCRAFT_TYPE_MAPPING[new_row['Type']] if new_row['Type']
end

def update_aerodrom_code!(new_row)
  new_row['From'] = AERODROME_CODE_MAPPING[new_row['From']] || new_row['From']
  new_row['To'] = AERODROME_CODE_MAPPING[new_row['To']] || new_row['To']
end

def add_single_engine_time!(new_row)
  new_row['SE Time'] = new_row['Total Time']
end

def add_default_empty_values!(new_row)
  ADDITIONAL_EMPTY_HEADERS.each { |header, default_value| new_row[header] = default_value }
end

def add_pic_times!(row, user_name, dpe_name)
  if row['PIC Name'] != user_name && row['PIC Name'] != dpe_name
    row['SPIC Time'] = row['Total Time']
    row['Dual Time'] = row['Total Time']
    row['PICUS Time'] = '0:00'
    row['PIC Time'] = '0:00'

    return
  end

  if row[:supervision] == 'yes'
    row['SPIC Time'] = '0:00'
    row['Dual Time'] = '0:00'

    if row['PIC Name'] == dpe_name
      row['PICUS Time'] = '0:00'
      row['PIC Time'] = row['Total Time']
    else
      row['PICUS Time'] = row['Total Time']
      row['PIC Time'] = '0:00'
    end

    return
  end

  row['SPIC Time'] = '0:00'
  row['Dual Time'] = '0:00'
  row['PICUS Time'] = '0:00'
  row['PIC Time'] = row['Total Time']
end

puts "Enter your name to be able to determine PIC, SPIC, PICUS time:"
user_name = gets.chomp

puts "Enter your DPE's name to be able to mark your first PIC time:"
dpe_name = gets.chomp

# Get file paths from user
puts "Enter the input file path (leave empty for 'source.csv' in current folder):"
input_file = gets.chomp
input_file = 'source.csv' if input_file.empty?

puts "Enter the output file path (leave empty for 'destination.csv' in current folder):"
output_file = gets.chomp
output_file = 'destination.csv' if output_file.empty?

# Convert the CSV
convert_csv(input_file, output_file, user_name, dpe_name)

# Success message
puts "CSV conversion successful! 🛫".colorize(:green)
