puts "---------"
puts "💣 Clearing Database..."

# 1. DELETE CHILDREN FIRST (Records that belong to others)
# Delete in order of dependency: most dependent first
BetPosition.destroy_all
Bet.destroy_all
Result.destroy_all
ChampionshipResult.destroy_all

# 2. DELETE PARENTS NEXT (after all children are gone)
Race.destroy_all
Driver.destroy_all

# 3. Reset Primary Keys (Optional but clean for SQLite)
ActiveRecord::Base.connection.execute("DELETE FROM sqlite_sequence WHERE name='races';")
ActiveRecord::Base.connection.execute("DELETE FROM sqlite_sequence WHERE name='drivers';")
ActiveRecord::Base.connection.execute("DELETE FROM sqlite_sequence WHERE name='bets';")
ActiveRecord::Base.connection.execute("DELETE FROM sqlite_sequence WHERE name='bet_positions';")
ActiveRecord::Base.connection.execute("DELETE FROM sqlite_sequence WHERE name='results';")

puts "✅ Database Cleaned. Starting Seed..."
puts "---------"

# 3. Process the Data
# Initialize meetings variable (empty by default, will use fallback)
meetings = []

# Try to fetch meetings from API if available
begin
  if defined?(F1ApiService)
    service = F1ApiService.new
    meetings = service.get_meetings(2026) || []
    puts "📡 Fetched #{meetings.length} meetings from API"
  end
rescue => e
  puts "⚠️ Could not fetch API data: #{e.message}"
  meetings = []
end

if meetings.any?
  puts "✅ API Data Found! Creating races..."

  meetings.each do |meeting|
    # Logic: Only save "Grand Prix" events (skip pre-season testing)
    next unless meeting[:meeting_name]&.match?(/Grand Prix/i)

    # Parse date and create start_time
    date_start = meeting[:date_start] || meeting[:date]
    start_time = date_start ? Time.parse(date_start.to_s) : Time.current
    year = start_time.year

    Race.create!(
      name: meeting[:meeting_name] || meeting[:name] || "Grand Prix",
      location: meeting[:location] || meeting[:circuit_short_name] || "TBA",
      date: date_start,
      start_time: start_time,
      year: year,
      race_type: "race",  # Must be lowercase per Race model validation
      status: "upcoming",
      # Map the API keys to your new database columns
      circuit_image_url: meeting[:circuit_image] || meeting[:img],
      country_flag_url: meeting[:country_flag],
      api_id: meeting[:meeting_key] || meeting[:api_id]
    )
  end

else
  puts "⚠️ API returned empty for 2026. Deploying Safety Car (Hardcoded Data)..."

  # Fallback List (Just in case the API is empty today)
  # I added generic Wikimedia placeholders so the UI still looks good
  calendar_2026 = [
    { name: "Bahrain GP", location: "Sakhir", date: "2026-03-05", img: "https://upload.wikimedia.org/wikipedia/commons/2/29/Bahrain_International_Circuit--Grand_Prix_Layout.svg" },
    { name: "Saudi Arabian GP", location: "Jeddah", date: "2026-03-19", img: "https://upload.wikimedia.org/wikipedia/commons/5/5c/Jeddah_Street_Circuit_2021.svg" },
    { name: "Australian GP", location: "Melbourne", date: "2026-04-02", img: "https://upload.wikimedia.org/wikipedia/commons/5/50/Albert_Lake_Park_Street_Circuit_in_Melbourne%2C_Australia.svg" },
    { name: "Miami GP", location: "Miami", date: "2026-05-07", img: "https://upload.wikimedia.org/wikipedia/commons/4/42/Miami_International_Autodrome_2022.svg" },
    { name: "Monaco GP", location: "Monaco", date: "2026-05-28", img: "https://upload.wikimedia.org/wikipedia/commons/5/56/Circuit_de_Monaco.svg" },
    { name: "São Paulo GP", location: "Interlagos", date: "2026-11-05", img: "https://upload.wikimedia.org/wikipedia/commons/b/b2/Aut%C3%B3dromo_Jos%C3%A9_Carlos_Pace_interlagos_2008.jpg" }
    # ... Add more if you rely on the fallback often
  ]

  calendar_2026.each do |race|
    # Parse date and create start_time
    date = Date.parse(race[:date])
    start_time = date.to_time.beginning_of_day + 14.hours # Default to 2 PM local time
    year = date.year

    Race.create!(
      name: race[:name],
      location: race[:location],
      date: date,
      start_time: start_time,
      year: year,
      race_type: "race",  # Must be lowercase per Race model validation
      status: "upcoming",
      circuit_image_url: race[:img] # Using the fallback image
    )
  end
end

puts "✅ Race Calibration Complete: #{Race.count} races loaded."
puts "---------"
