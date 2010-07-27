module WorkingTime
  # 8am to 6pm
  WORKING_HOURS = (8..18).to_a

  # Monday to Friday
  WORKING_DAYS  = (1..5).to_a

  require 'date'
  require 'working_time/date'
  require 'working_time/interval'
end

