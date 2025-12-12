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
