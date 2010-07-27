require 'helper'

class TestWorkingTime < Test::Unit::TestCase
  def test_same_day_hours_left
    remaining = WorkingTime::DateTime.parse("2009-07-23T12:00:00+00:00").hours_left
    assert_equal(6, remaining)
  end 

  def test_multi_day_add_hours
    start = WorkingTime::DateTime.parse("2009-07-23T12:00:00+00:00")
    stop  = WorkingTime::DateTime.parse("2009-07-24T11:00:00+00:00")
    start = start + WorkingTime::Hour.new(10)
    assert_equal(stop.to_s,start.to_s)
  end

  def test_multi_month_add_hours
    start = WorkingTime::DateTime.parse("2009-07-23T12:00:00+00:00")
    stop  = WorkingTime::DateTime.parse("2009-08-31T15:00:00+00:00")
    start = start + WorkingTime::Hour.new(300)
    assert_equal(stop.to_s,start.to_s)
  end

  def test_start_of_business
    today = WorkingTime::DateTime.parse("2009-07-23T12:12:15-07:00").open_of_business
    start = WorkingTime::DateTime.parse("2009-07-23T08:00:00-07:00")
    assert_equal(start.to_s,today.to_s)
  end

  def test_datetime_now_class
    assert_equal("WorkingTime::DateTime", WorkingTime::DateTime.now.class.to_s)
  end

  def test_after_hours_add
    start = WorkingTime::DateTime.parse("2009-07-23T23:00:00+00:00")
    stop  = WorkingTime::DateTime.parse("2009-07-24T18:00:00+00:00")
    start = start + WorkingTime::Hour.new(10)
    assert_equal(stop.to_s,start.to_s)
  end

  def test_after_hours_completion
    start = WorkingTime::DateTime.parse("2009-07-23T23:00:00+00:00")
    stop  = WorkingTime::DateTime.parse("2009-07-27T08:00:00+00:00")
    start = start + WorkingTime::Hour.new(11)
    assert_equal(stop.to_s,start.to_s)
  end

  def test_multi_day_rollover
    start = WorkingTime::DateTime.parse("2009-09-23T13:14:00+00:00")
    stop  = WorkingTime::DateTime.parse("2009-09-24T10:14:00+00:00")
    start = start + WorkingTime::Hour.new(8)
    assert_equal(stop.to_s,start.to_s)
  end

  def test_close_of_week
    start = WorkingTime::DateTime.parse("2009-09-23T13:14:00+00:00")
    stop  = WorkingTime::DateTime.parse("2009-09-25T18:00:00+00:00")
    start = start.close_of_week
    assert_equal(stop.to_s,start.to_s)
  end

  def test_close_of_next_week
    start = WorkingTime::DateTime.parse("2009-09-23T13:14:00+00:00")
    stop  = WorkingTime::DateTime.parse("2009-10-02T18:00:00+00:00")
    start = start.close_of_next_week
    assert_equal(stop.to_s,start.to_s)
  end
end

class TestWorkingTimeInterval < Test::Unit::TestCase

  def test_same_day_close
    start = DateTime.parse("2009-07-29T18:30:00+00:00")
    stop  = DateTime.parse("2009-07-29T22:00:00+00:00")

    interval = WorkingTime::Interval.new(start,stop)
    assert_equal(3.5, interval.duration)
  end

  def test_multi_day_close_no_weekend
    start = DateTime.parse("2009-07-23T12:00:00+00:00")
    stop  = DateTime.parse("2009-07-24T12:00:00+00:00")

    interval = WorkingTime::Interval.new(start,stop)
    assert_equal(10.0, interval.duration)
  end

  def test_multi_day_close_weekend
    start = DateTime.parse("2009-07-23T12:00:00+00:00")
    stop  = DateTime.parse("2009-07-27T12:00:00+00:00")

    interval = WorkingTime::Interval.new(start,stop)
    assert_equal(20.0, interval.duration)
  end

  def test_multi_day_after_hours
    start = DateTime.parse("2009-07-28T18:59:00+00:00")
    stop  = DateTime.parse("2009-07-29T16:00:00+00:00")

    interval = WorkingTime::Interval.new(start,stop)
    assert_equal(8.0, interval.duration)
  end
end