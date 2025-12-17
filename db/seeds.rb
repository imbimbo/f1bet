# db/seeds.rb
require 'faker'

puts "Clearing database..."
[BetPosition, Bet, Result, Race, Driver, ChampionshipResult, User].each(&:delete_all)

# ----------------------
# Users
# ----------------------
puts "Creating users..."
users = 5.times.map do |i|
  User.create!(
    name: Faker::Name.name,
    email: "user#{i+1}@f1.com",
    password: "password",
    password_confirmation: "password"
  )
end

# ----------------------
# Drivers
# ----------------------
puts "Creating drivers..."
teams = ["Mercedes", "Red Bull", "Ferrari", "McLaren", "Alfa Romeo", "AlphaTauri", "Aston Martin", "Haas", "Williams", "Alpine"]
drivers = 10.times.map do |i|
  Driver.create!(
    name: "#{Faker::Name.first_name} #{Faker::Name.last_name}",
    team: teams[i % teams.size]
  )
end

# ----------------------
# Races
# ----------------------
puts "Creating races..."
race_data = [
  {name: "GP de São Paulo", location: "Interlagos", date: Date.new(2025,3,24)},
  {name: "GP de Mônaco", location: "Monte Carlo", date: Date.new(2025,5,25)},
  {name: "GP da Itália", location: "Monza", date: Date.new(2025,9,7)},
  {name: "GP do Japão", location: "Suzuka", date: Date.new(2025,10,12)},
  {name: "GP da Bélgica", location: "Spa", date: Date.new(2025,8,30)}
]

race_types = %w[qualifying sprint race]

races = race_data.each_with_index.map do |data, i|
  Race.create!(
    name: data[:name],
    location: data[:location],
    date: data[:date],
    start_time: data[:date].to_datetime + 14.hours,
    round_number: i+1,
    year: data[:date].year,
    race_type: race_types.sample,  # random valid race_type
    status: "upcoming"
  )
end

# ----------------------
# Championship Results
# ----------------------
puts "Creating championship results..."
users.each do |user|
  ChampionshipResult.create!(
    user: user,
    year: 2025,
    points: rand(0..300),
    rank: nil
  )
end

# ----------------------
# Bets and BetPositions
# ----------------------
puts "Creating bets..."
users.each do |user|
  races.each do |race|
    bet = Bet.create!(
      user: user,
      race: race,
      points: rand(0..25)
    )

    drivers.shuffle.each_with_index do |driver, idx|
      BetPosition.create!(
        bet: bet,
        driver: driver,
        position: idx + 1
      )
    end
  end
end

# ----------------------
# Race Results
# ----------------------
puts "Creating race results..."
races.each do |race|
  drivers.shuffle.each_with_index do |driver, idx|
    Result.create!(
      race: race,
      driver: driver,
      position: idx + 1,
      points: [25,18,15,12,10,8,6,4,2,1][idx] || 0
    )
  end
end

puts "Seeds finished!"
#
# New seed file to fetch drivers from OpenF1 API
# service = F1ApiService.new

# puts "Fetching drivers from OpenF1..."
# drivers_data = service.get_drivers

# drivers_data.each do |data|
#   driver = Driver.find_or_create_by(api_id: data[:driver_number]) do |d|
#     d.name = data[:full_name]
#     d.team = data[:team_name]
#   end

#   if driver.persisted?
#       puts "  ✅ [#{driver.api_id}] #{driver.name} - #{driver.team}"
#   else
#       puts "  ❌ Failed to save: #{data[:full_name]} - #{driver.errors.full_messages.join(', ')}"
#   end
# end

# puts "Database populated. Total Drivers: #{Driver.count}"

# # New seed fetching race calendar from OpenF1 API
# # db/seeds.rb
# p# db/seeds.rb
# puts "---------"
# puts "🏎️  Starting Race Import..."

# service = F1ApiService.new
# # Fetch ALL sessions (Practice, Quali, Race, etc.)
# all_sessions = service.get_schedule

# puts "API returned #{all_sessions.count} total sessions."

# # Helper method to normalize session name to valid race_type
# def normalize_race_type(session_name)
#   return "race" if session_name.match?(/Race/i) && !session_name.match?(/Sprint/i)
#   return "sprint" if session_name.match?(/Sprint/i)
#   return "qualifying" if session_name.match?(/Qualifying/i)
#   nil
# end

# all_sessions.each do |session|


#   # 1. Filter: Keep Race, Qualifying, and Sprint
#   # We use regex match? to catch "Sprint Qualifying" or "Sprint Shootout"
#   next unless session[:session_name].match?(/Race|Qualifying|Sprint/)

#   # Normalize race_type to valid value
#   race_type = normalize_race_type(session[:session_name])
#   next unless race_type # Skip if we can't determine a valid race_type

#   # Parse date_start to get datetime and year
#   date_start = session[:date_start]
#   next unless date_start # Skip if date_start is missing

#   start_time = date_start.is_a?(String) ? DateTime.parse(date_start) : date_start
#   year = start_time.year

#   # 2. Create the Race
#   # We use find_or_initialize_by so we can see errors before saving
#   race = Race.find_or_initialize_by(api_id: session[:session_key])

#   race.name = session[:circuit_short_name]
#   race.location = session[:location]
#   race.date = start_time.to_date
#   race.start_time = start_time
#   race.year = year
#   race.race_type = race_type
#   race.status ||= "upcoming"

#   # 3. Save and Report
#   if race.save
#     puts "✅ #{race.name} -> #{race.location} (#{race.race_type.capitalize})"
#   else
#     # This will now tell you EXACTLY why it failed (e.g. "Date can't be blank")
#     puts "  ❌ Failed: #{session[:location]} - #{race.errors.full_messages.join(', ')}"
#   end
# end

# puts "---------"
# puts "🏁 FINAL COUNT: #{Race.count} races in database."
