#! /usr/bin/env ruby

module WorkingTime

class Interval

  attr :start, true
  attr :stop, true
  attr :duration, true
  attr :log, true

  def initialize(start, stop) 
    @start = start
    @stop  = stop
    @duration = hours_between
  end

  # Calculates the number of seconds in a work day between two times in the same day
  def seconds_between(start, stop)
 
    # we need this to be a float   
    duration = 0.0
  
    # we just return if the start comes after the stop
    return duration if start > stop

    # If it's a weekday, examine it.
    if WORKING_DAYS.include? start.wday

      # If it's inside working hours, calculate
      if WORKING_HOURS.include? start.hour

        # Figure out how many seconds between now and then
        hours, mins, secs, ignore_fractions = Date::day_fraction_to_time(stop - start)
        duration = hours * 60 * 60 + mins * 60 + secs

      end

    end

    return duration
  end

  def hours_between
  
    #LOG.puts "Calculating: #{@start} to #{@stop}" if DEBUG

    # Our placeholder in seconds   
    duration = 0.0

    start_date = Date.new(@start.year, @start.mon, @start.day)
    stop_date  = Date.new(@stop.year, @stop.mon, @stop.day)

    if start_date == stop_date

      # If we closed it in the same day, we need to do a simple calculation
      result = seconds_between(@start,@stop)
      duration += result
      #LOG.puts "Same day: #{@start} to #{@stop} (#{result / 3600})" if DEBUG

    else 

      # Loop over each day
      start_date.upto(stop_date) do |date|
        
        #LOG.puts "Looking at: #{date}"
        start_work_time = DateTime.new(date.year, date.mon, date.day, WORKING_HOURS[0])
        stop_work_time  = DateTime.new(date.year, date.mon, date.day, WORKING_HOURS[-1])

        # If we are looking at the first day, we only want to count from the create time, to the end of the working day
        if date == start_date
          result = seconds_between(@start,stop_work_time)
          duration += result
          #LOG.puts "Start date: #{@start} to #{stop_work_time} (#{result / 3600})" if DEBUG
        # If we are looking at the end date we only want to count from the beginning of the day to the close time
        elsif date == stop_date
          result = seconds_between(start_work_time,@stop)
          duration += result
          #LOG.puts "Stop date: #{start_work_time} to #{@stop} (#{result / 3600})" if DEBUG
        # Otherwise we assume this date falls between start and end
        else
          result = seconds_between(start_work_time,stop_work_time)
          duration += result
          #LOG.puts "In-between date: #{start_work_time} to #{stop_work_time} (#{result / 3600 })" if DEBUG 
        end

      end

    end

    #LOG.puts ""
    return duration / 3600
  end
 
end

end
