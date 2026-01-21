module RacesHelper
  def race_display_name(race)
    place = extract_place_from_name(race.name)

    "Grande Prêmio #{place}"
  end

  private

  def extract_place_from_name(name)
    return "" if name.blank?

    map = {
      "Australian" => "da Austrália",
      "Chinese" => "da Shanghai",
      "Japanese" => "de Suzuka",
      "Singapore" => "de Singapura",
      "British" => "de Silverstone",
      "Italian" => "de Monza",
      "Mexico City" => "do México",
      "Spanish" => "da Espanha",
      "Canadian" => "do Canadá",
      "United States" => "dos Estados Unidos",
      "Azerbaijan" => "de Baku",
      "Dutch" => "da Holanda",
      "Hungarian" => "da Hungria",
      "Belgian" => "de Spa-Francorchamps",
      "Austrian" => "da Áustria",
      "Saudi Arabian" => "de Jeddah",
      "Qatar" => "do Qatar",
      "Miami" => "de Miami",
      "Monaco" => "de Mônaco",
      "São Paulo" => "de Interlagos",
      "Las Vegas" => "de Las Vegas",
      "Abu Dhabi" => "de Abu Dhabi",
      "Barcelona" => "de Barcelona",
      "Bahrain" => "do Bahrein"
    }


    key = map.keys.find { |k| name.include?(k) }
    map[key] || name.gsub(" Grand Prix", "")
  end

  # app/helpers/races_helper.rb
  def next_race_display_name(race)
    race.present? ? race_display_name(race) : "Season Over"
  end

end
