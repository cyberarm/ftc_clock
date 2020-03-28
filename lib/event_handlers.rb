module EventHandlers
  ### Clock ###
  def start_clock
    @clock_running = true
  end

  def stop_clock
    @clock_running = false
  end

  def change_clock(value)
    @clock_time = time_from_string(value)
  end

  ### Countdown ###
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

  def change_color(color)
    out = case color
    when :white
      Gosu::Color::WHITE
    when :orange
      Gosu::Color.rgb(150, 75, 0)
    when :red
      Gosu::Color.rgb(150, 0, 0)
    end

    @display_color = out
  end

  private def time_from_string(string)
    split = string.split(":")
    minutes = (split.first.to_i) * 60
    seconds = (split.last.to_i)

    return minutes + seconds
  end
end