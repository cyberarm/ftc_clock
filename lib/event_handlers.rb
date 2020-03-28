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

def play_sound(sound)
    path = nil
    case sound
    when :autonomous_countdown
      path = "media/3-2-1.wav"
    when :autonomous_start
      path = "media/charge.wav"
    when :autonomous_ended
      path = "media/endauto.wav"
    when :teleop_pickup_controllers
      path = "media/Pick_Up_Controllers.wav"
    when :teleop_countdown
      path = "media/3-2-1.wav"
    when :teleop_started
      path = "media/firebell.wav"
    when :end_game
      path = "media/factwhistle.wav"
    when :end_match
      path = "media/endmatch.wav"
    end

    path = "#{ROOT_PATH}/#{path}"

    if path && File.exist?(path) && !File.directory?(path)
      SAMPLES[path] = Gosu::Sample.new(path) unless SAMPLES[path].is_a?(Gosu::Sample)
      SAMPLES[path].play
    else
      warn "WARNING: Sample for #{sound.inspect} could not be found at '#{path}'"
    end
  end
end