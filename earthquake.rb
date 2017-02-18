require 'csv'
require 'haversine'

class Earthquake
  attr_reader :earthquake_data

  def initialize
    @imported_data   = []
    @earthquake_data = []
  end

  def compile_data_from_csv(filename = '')
    @imported_data = import_data_from_csv filename

    @imported_data.each do |row|
      next if row[14] != 'earthquake'

      time       = row[0]
      date       = time.gsub(/T\d*:.*/, '')
      magnitude  = row[4]
      place      = get_city_and_state row[13]
      distance   = get_distance row[1], row[2]

      # Skip if earthquake was too far to be felt from LA
      next if distance > (magnitude.to_f * 100).round

      @earthquake_data << [date, time, place, magnitude, distance]
    end

    # @earthquake_data.sort! # sort by date
    @earthquake_data.sort_by! do |data|
      [data[0], data[1]] # sort by date and then by time
    end
  rescue => e
    puts "Earthquake#generate_data failed: #{e}"
  end

  # start_date and end_date should be strings in the format
  # 'YYYY-MM-DD'.
  def find_earthquakes_felt_in_la(start_date = '', end_date = '')
    end_date   = todays_date if end_date.empty?
    start_date = date_30_days_ago if start_date.empty?

    fail date_err_msg unless valid_date_format?(start_date)
    fail date_err_msg unless valid_date_format?(end_date)

    result = @earthquake_data.select do |data|
      date = data.first
      date >= start_date && date <= end_date
    end

    print_results(result.first(10))

    result.first 10
  end

  private

  def import_data_from_csv(filename = '')
    imported_data = []
    CSV.foreach(filename) do |row|
      imported_data << row
    end

    # prune CSV header
    imported_data = imported_data[1..(imported_data.size-1)]
  rescue => e
    puts "Earthquake#import_data_from_csv failed: #{e}"
  end

  def print_results(results)
    format = '%-25s %-32s %-10s %-17s'
    puts format % ['Time', 'Place', 'Magnitude', 'Distance from LA']
    results.each do |result|
      puts format % [result[1], result[2], result[3], result[4]]
    end
  end

  def get_city_and_state(str = '')
    city, state = str.split(', ')
    city.gsub!(/^.* of /, '')
    "#{city}, #{state}"
  end

  def get_distance(lat = '', long = '')
    la_lat  = 34.0522
    la_long = -118.2437

    Haversine.distance(la_lat, la_long, lat.to_f, long.to_f).to_miles.round
  end

  def valid_date_format?(date)
    return false if date.split('-').size != 3
    year = date.split('-').first
    return false if year.size != 4

    true if Date.parse(date)
  rescue
    false
  end

  def date_err_msg
    'Earthquake#find_earthquakes_felt_in_la: Dates must be a string in the form YYYY-MM-DD.'
  end

  def todays_date
    DateTime.now.strftime("%F")
  end

  def date_30_days_ago
    (DateTime.new(DateTime.now.year, DateTime.now.month, DateTime.now.day) - 30).strftime("%F")
  end
end
