module ApplicationHelper
  def admin_user?
    # TODO: Implement admin role check (e.g., user.admin? or user.email.in?(ADMIN_EMAILS))
    # For now, return false - can be extended with admin field in User model
    current_user&.email&.include?('admin') || false
  end

  def user_financial_balance
    return 0.0 unless user_signed_in?
    
    # Calculate balance from championship results for current year
    current_year = Date.today.year
    championship_result = current_user.championship_results.find_by(year: current_year)
    
    # Convert points to financial balance (1 point = R$ 1.00, or adjust as needed)
    (championship_result&.points || 0).to_f
  end

  def format_date_pt_br(date)
    return nil unless date
    
    months = {
      1 => 'janeiro', 2 => 'fevereiro', 3 => 'março', 4 => 'abril',
      5 => 'maio', 6 => 'junho', 7 => 'julho', 8 => 'agosto',
      9 => 'setembro', 10 => 'outubro', 11 => 'novembro', 12 => 'dezembro'
    }
    
    "#{date.day} de #{months[date.month]} de #{date.year}"
  end
end