service = F1ApiService.new

puts "Fetching drivers from OpenF1..."
drivers_data = service.get_drivers

drivers_data.each do |data|
  driver = Driver.find_or_create_by(api_id: data[:driver_number]) do |d|
    d.name = data[:full_name]
    d.team = data[:team_name]
  end

  if driver.persisted?
      puts "  ✅ [#{driver.api_id}] #{driver.name} - #{driver.team}"
  else
      puts "  ❌ Failed to save: #{data[:full_name]} - #{driver.errors.full_messages.join(', ')}"
  end
end

puts "Database populated. Total Drivers: #{Driver.count}"

# New seed fetching race calendar from OpenF1 API
# db/seeds.rb
p# db/seeds.rb
puts "---------"
puts "🏎️  Starting Race Import..."

service = F1ApiService.new
# Fetch ALL sessions (Practice, Quali, Race, etc.)
all_sessions = service.get_schedule

puts "API returned #{all_sessions.count} total sessions."

# Helper method to normalize session name to valid race_type
def normalize_race_type(session_name)
  return "race" if session_name.match?(/Race/i) && !session_name.match?(/Sprint/i)
  return "sprint" if session_name.match?(/Sprint/i)
  return "qualifying" if session_name.match?(/Qualifying/i)
  nil
end

all_sessions.each do |session|


  # 1. Filter: Keep Race, Qualifying, and Sprint
  # We use regex match? to catch "Sprint Qualifying" or "Sprint Shootout"
  next unless session[:session_name].match?(/Race|Qualifying|Sprint/)

  # Normalize race_type to valid value
  race_type = normalize_race_type(session[:session_name])
  next unless race_type # Skip if we can't determine a valid race_type

  # Parse date_start to get datetime and year
  date_start = session[:date_start]
  next unless date_start # Skip if date_start is missing

  start_time = date_start.is_a?(String) ? DateTime.parse(date_start) : date_start
  year = start_time.year

  # 2. Create the Race
  # We use find_or_initialize_by so we can see errors before saving
  race = Race.find_or_initialize_by(api_id: session[:session_key])

  race.name = session[:circuit_short_name]
  race.location = session[:location]
  race.date = start_time.to_date
  race.start_time = start_time
  race.year = year
  race.race_type = race_type
  race.status ||= "upcoming"

  # 3. Save and Report
  if race.save
    puts "✅ #{race.name} -> #{race.location} (#{race.race_type.capitalize})"
  else
    # This will now tell you EXACTLY why it failed (e.g. "Date can't be blank")
    puts "  ❌ Failed: #{session[:location]} - #{race.errors.full_messages.join(', ')}"
  end
end

puts "---------"
puts "🏁 FINAL COUNT: #{Race.count} races in database."
