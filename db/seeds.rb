puts "---------"
puts "💣 Clearing Database..."

BetPosition.destroy_all
Bet.destroy_all
Result.destroy_all
ChampionshipResult.destroy_all
RaceDriver.destroy_all
Race.destroy_all
Driver.destroy_all

puts "✅ Database Cleaned."
puts "---------"

service = F1ApiService.new

# =====================
# DRIVERS
# =====================

puts "👨‍🚀 Importing drivers..."

drivers = service.get_drivers rescue []

if drivers.any?
  drivers.each do |data|
    Driver.find_or_create_by!(api_id: data[:driver_number]) do |d|
      d.name = data[:full_name]
      d.team = data[:team_name]
      d.headshot_url = data[:headshot_url]
    end
  end
else
  puts "⚠️ Driver API empty — fallback"

  [
    { api_id: 1, name: "Max Verstappen", team: "Red Bull" },
    { api_id: 16, name: "Charles Leclerc", team: "Ferrari" },
    { api_id: 44, name: "Lewis Hamilton", team: "Ferrari" }
  ].each do |driver|
    Driver.create!(driver)
  end
end

puts "✅ #{Driver.count} drivers loaded."
puts "---------"

# =====================
# RACES (Qualifying + Race only)
# =====================

puts "🏁 Importing races..."

meetings = service.get_meetings(2026) rescue []

if meetings.any?
  meetings.each do |meeting|
    next unless meeting[:meeting_name]&.match?(/Grand Prix/i)

    sessions = service.get_sessions(meeting[:meeting_key]) || []

    sessions.each do |session|
      session_type = session[:session_type]&.downcase
      next unless %w[race qualifying].include?(session_type)

      next if session[:date_start].blank?

      start_time = Time.parse(session[:date_start])

      Race.find_or_create_by!(api_session_id: session[:session_key]) do |race|
        race.name = meeting[:meeting_name]
        race.location = meeting[:location] || meeting[:circuit_short_name]
        race.date = start_time.to_date
        race.start_time = start_time
        race.year = start_time.year
        race.race_type = session_type
        race.status = "upcoming"
        race.circuit_image_url = meeting[:circuit_image]
        race.country_flag_url = meeting[:country_flag]
        race.api_id = meeting[:meeting_key]
      end
    end
  end
else
  puts "⚠️ Meeting API empty — fallback calendar"

  [
    { name: "Bahrain GP", location: "Sakhir", date: "2026-03-05" },
    { name: "Saudi GP", location: "Jeddah", date: "2026-03-19" }
  ].each do |race|
    start = Date.parse(race[:date]).to_time + 14.hours

    %w[qualifying race].each do |type|
      Race.create!(
        name: race[:name],
        location: race[:location],
        date: start.to_date,
        start_time: start,
        year: start.year,
        race_type: type,
        status: "upcoming"
      )
    end
  end
end

puts "✅ #{Race.count} sessions loaded."
puts "---------"

# =====================
# LINK DRIVERS TO RACES
# =====================

puts "🔗 Linking drivers to races..."

Race.find_each do |race|
  Driver.find_each do |driver|
    RaceDriver.find_or_create_by!(
      race: race,
      driver: driver
    )
  end
end

puts "✅ Drivers linked."

# =====================
# DEV ONLY — SHIFT TIMES TO FUTURE
# =====================

if Rails.env.development?
  Race.update_all(start_time: 2.days.from_now)
  puts "⏱️ Dev: moved races into future"
end

puts "---------"
puts "🏁 Seed complete."
