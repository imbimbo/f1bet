class F1ApiService
  BASE_URL = "https://api.openf1.org/v1"

  def initialize
    @conn = Faraday.new(url: BASE_URL) do |faraday|
      faraday.request :json
      faraday.response :json, parser_options: { symbolize_names: true }
      faraday.adapter Faraday.default_adapter
    end
  end

  def get_drivers
    response = @conn.get("drivers") do |req|
      req.params['session_key'] = 9839
    end
    response.body
  end

  # app/services/f1_api_service.rb
  def get_schedule
  # 1. Use 2024 to get a FULL calendar for testing
  # 2. Remove 'session_name' so we get Quali + Sprint too
    response = @conn.get('sessions') do |req|
      req.params['year'] = 2025
    end
    response.body
  end

  def get_sessions(meeting_key)
    response = @conn.get("sessions") do |req|
      req.params["meeting_key"] = meeting_key
    end
    response.body || []
  end

  def get_meetings(year = 2026)
    response = @conn.get("meetings") do |req|
      req.params['year'] = year
    end
    response.body || []
  end
end
