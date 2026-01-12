class ChampionshipResultService
  def self.recalculate!(year)
    User.find_each do |user|
      points = user.bets.joins(:race).where(races: { year: year }).sum(:points)
      ChampionshipResult
        .find_or_initialize_by(user: user, year: year)
        .update!(points: points)
    end
  end
end
