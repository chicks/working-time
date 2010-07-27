module WorkingTime

  class Hour 
    attr :value
    def initialize(num)
      @value = num
    end
    def to_i
      @value
    end
  end

  class Date < Date
    def + (n)
      case n
      when Numeric; 
        new_date = self.class.new!(@ajd + n, @of, @sg)
        if new_date.is_work_day?
          return new_date
        else
          until new_date.is_work_day?
            #puts "incrementing days! #{new_date}"
            n += 1
            new_date = self.class.new!(@ajd + n, @of, @sg)
          end
          return new_date
        end
      end
      raise TypeError, 'expected numeric'
    end

    def is_work_day?
      # check the day of week
      WORKING_DAYS.include? self.cwday
    end

  end

  class Time < Time

  #  def to_time() getlocal end

    def to_date
      jd = Date.civil_to_jd(year, mon, mday, Date::ITALY)
      Date.new!(Date.jd_to_ajd(jd, 0, 0), 0, Date::ITALY)
    end

    def to_datetime
      jd = WorkingTime::DateTime.civil_to_jd(year, mon, mday, DateTime::ITALY)
      fr = WorkingTime::DateTime.time_to_day_fraction(hour, min, [sec, 59].min) +
     usec.to_r/86400000000
      of = utc_offset.to_r/86400
      WorkingTime::DateTime.new!(WorkingTime::DateTime.jd_to_ajd(jd, fr, of), of, DateTime::ITALY)
    end

    private :to_date, :to_datetime

  end

  # Lets just modify the basic DateTime class
  class DateTime < DateTime 

    def self.now  (sg=ITALY) WorkingTime::Time.now.__send__(:to_datetime).new_start(sg) end

    # Returns the number of hours left in the day. 
    def hours_left
      remaining = WorkingTime::Interval.new(self, close_of_business)
      return remaining.duration
    end

    def mins_left
      hours_left * 60
    end

    def secs_left
      hours_left * 3600
    end

    def open_of_business
      self.class.new(self.year, self.mon, self.day, WORKING_HOURS[0], 0, 0, @of, @sg)
    end

    def close_of_business
      self.class.new(self.year, self.mon, self.day, WORKING_HOURS[-1], 0, 0, @of, @sg)
    end

    def close_of_week
      date = Date.new(self.year, self.mon, self.day)
      date = date.next until date.cwday == WORKING_DAYS[-1]
      self.class.new(date.year, date.mon, date.day, WORKING_HOURS[-1], 0, 0, @of, @sg)
    end

    def close_of_next_week
      date = Date.commercial(year, cweek + 1, cwday)
      date = date.next until date.cwday == WORKING_DAYS[-1]
      self.class.new(date.year, date.mon, date.day, WORKING_HOURS[-1], 0, 0, @of, @sg)
    end

    def is_working_time?
      # check the day of week
      if WORKING_DAYS.include? cwday
        #check the hour
        if WORKING_HOURS.include? hour
          return true
        else
          return false
        end
      else
        return false
      end
    end

    # override addition
    def + (n)
      case n
      when Numeric; return self.class.new!(@ajd + n, @of, @sg)
      when WorkingTime::Hour

        cur_hour = self.hour
        hours_remaining = n.to_i

        min  = self.min
        sec  = self.sec

        date = Date.new(self.year,self.mon,self.day)

        # if our initial value is before the start of the work day, set the cur_hour to the start of the workday
        if cur_hour < WORKING_HOURS[0]
          cur_hour = WORKING_HOURS[0]
        # if our initial value is after the end of the current work day, set the cur_hour to the start of the NEXT workday
        elsif cur_hour > WORKING_HOURS[-1]
          cur_hour = WORKING_HOURS[0]
          date = date.next
        end

        #puts "Incrementing #{self}"
        # Add hours to the current hour, incrementing the day until we run out of hours
        while hours_remaining > 0
          until cur_hour == WORKING_HOURS[-1] || hours_remaining < 1
            hours_remaining -= 1
            cur_hour        += 1
            #puts "Cur: #{cur_hour} / Rem: #{hours_remaining}"
          end
          if hours_remaining > 0
            hours_remaining -= 1
            cur_hour = WORKING_HOURS[0]
            # go to the next day
            date = date.next
            #puts "Rolling Date: #{date} #{cur_hour}"
          end
        end
        return self.class.new(date.year, date.mon, date.day, cur_hour, min, sec, @of, @sg)
      end
      raise TypeError, 'expected numeric or hour'
    end

    def to_gm_time
      to_time(new_offset, :gm)
    end

    def to_local_time
      to_time(new_offset(DateTime.now.offset-offset), :local)
    end

    private
      def to_time(dest, method)
        #Convert a fraction of a day to a number of microseconds
        usec = (dest.sec_fraction * 60 * 60 * 24 * (10**6)).to_i
        Time.send(method, dest.year, dest.month, dest.day, dest.hour, dest.min, dest.sec, usec)
      end


  end

end
