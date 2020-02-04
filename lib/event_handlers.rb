module EventHandlers
  def start_clock
    @clock_running = true
  end

  def stop_clock
    @clock_running = false
  end

  def change_clock(value)
    @clock_time = time_from_string(value)
  end

  def start_countdown
    @countdown_running = true
  end

  def stop_countdown
    @countdown_running = false
  end


  def change_countdown(value)
    @countdown_time = time_from_string(value)
  end

  def change_display(display)
  end

  private def time_from_string(string)
    split = string.split(":")
    minutes = Integer(split.first) * 60
    seconds = Integer(split.last)

    return minutes + seconds
  end
end