module RacesHelper
  def race_display_name(race)
    place = extract_place_from_name(race.name)

    "Grande Prêmio #{place}"
  end

  def country_name_pt_br(race)
    return "" if race.name.blank?

    country_map = {
      "Australian" => "Austrália",
      "Chinese" => "China",
      "Japanese" => "Japão",
      "Singapore" => "Singapura",
      "British" => "Reino Unido",
      "Italian" => "Itália",
      "Mexico City" => "México",
      "Spanish" => "Espanha",
      "Canadian" => "Canadá",
      "United States" => "Estados Unidos",
      "Azerbaijan" => "Azerbaijão",
      "Dutch" => "Holanda",
      "Hungarian" => "Hungria",
      "Belgian" => "Bélgica",
      "Austrian" => "Áustria",
      "Saudi Arabian" => "Arábia Saudita",
      "Qatar" => "Qatar",
      "Miami" => "Estados Unidos",
      "Monaco" => "Mônaco",
      "São Paulo" => "Brasil",
      "Las Vegas" => "Estados Unidos",
      "Abu Dhabi" => "Emirados Árabes",
      "Barcelona" => "Espanha",
      "Bahrain" => "Bahrein"
    }

    key = country_map.keys.find { |k| race.name.include?(k) }
    country_map[key] || race.name.gsub(" Grand Prix", "")
  end

  def circuit_name(race)
    return race.location if race.location.present?
    
    # Fallback: extract from race name
    circuit_map = {
      "Australian" => "Albert Park",
      "Chinese" => "Shanghai International Circuit",
      "Japanese" => "Suzuka International Racing Course",
      "Singapore" => "Marina Bay Street Circuit",
      "British" => "Silverstone Circuit",
      "Italian" => "Autodromo Nazionale di Monza",
      "Mexico City" => "Autódromo Hermanos Rodríguez",
      "Spanish" => "Circuit de Barcelona-Catalunya",
      "Canadian" => "Circuit Gilles Villeneuve",
      "United States" => "Circuit of the Americas",
      "Azerbaijan" => "Baku City Circuit",
      "Dutch" => "Circuit Zandvoort",
      "Hungarian" => "Hungaroring",
      "Belgian" => "Circuit de Spa-Francorchamps",
      "Austrian" => "Red Bull Ring",
      "Saudi Arabian" => "Jeddah Corniche Circuit",
      "Qatar" => "Lusail International Circuit",
      "Miami" => "Miami International Autodrome",
      "Monaco" => "Circuit de Monaco",
      "São Paulo" => "Autódromo José Carlos Pace",
      "Las Vegas" => "Las Vegas Strip Circuit",
      "Abu Dhabi" => "Yas Marina Circuit",
      "Barcelona" => "Circuit de Barcelona-Catalunya",
      "Bahrain" => "Bahrain International Circuit"
    }

    key = circuit_map.keys.find { |k| race.name.include?(k) }
    circuit_map[key] || race.name.gsub(" Grand Prix", "")
  end

  def format_date_range(race)
    return nil unless race.date_start.present? || race.date_end.present?
    
    start_date = race.date_start&.to_date
    end_date = race.date_end&.to_date
    
    return nil unless start_date || end_date
    
    # If only one date is available, use it
    if start_date && !end_date
      return format_short_date(start_date)
    elsif end_date && !start_date
      return format_short_date(end_date)
    end
    
    # Both dates available
    start_date ||= end_date
    end_date ||= start_date
    
    months = {
      1 => 'JAN', 2 => 'FEV', 3 => 'MAR', 4 => 'ABR',
      5 => 'MAI', 6 => 'JUN', 7 => 'JUL', 8 => 'AGO',
      9 => 'SET', 10 => 'OUT', 11 => 'NOV', 12 => 'DEZ'
    }
    
    if start_date.month == end_date.month
      # Same month: "27 - 29 MAR"
      "#{start_date.day} - #{end_date.day} #{months[start_date.month]}"
    else
      # Different months: "28 FEV - 1 MAR"
      "#{start_date.day} #{months[start_date.month]} - #{end_date.day} #{months[end_date.month]}"
    end
  end

  def format_short_date(date)
    months = {
      1 => 'JAN', 2 => 'FEV', 3 => 'MAR', 4 => 'ABR',
      5 => 'MAI', 6 => 'JUN', 7 => 'JUL', 8 => 'AGO',
      9 => 'SET', 10 => 'OUT', 11 => 'NOV', 12 => 'DEZ'
    }
    
    "#{date.day} #{months[date.month]}"
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
