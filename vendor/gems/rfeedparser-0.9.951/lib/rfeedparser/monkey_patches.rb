class Time
  class << self
    COMMON_YEAR_DAYS_IN_MONTH = [nil, 31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31]

    def days_in_month(month, year = now.year)
      return 29 if month == 2 && ::Date.gregorian_leap?(year)
      COMMON_YEAR_DAYS_IN_MONTH[month]
    end
  end
end
