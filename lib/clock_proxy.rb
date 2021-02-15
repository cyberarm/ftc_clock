class ClockProxy
  def initialize(clock, jukebox)
    @clock = clock
    @jukebox = jukebox
  end

  def start_clock(mode)
    @clock.controller = case mode
    when :full_match
      ClockController.new(0, ClockController::FULL_MATCH)
    when :autonomous
      ClockController.new(0, ClockController::AUTONOMOUS)
    when :full_teleop
      ClockController.new(33.0, ClockController::FULL_TELEOP)
    when :teleop_only
      ClockController.new(41.0, ClockController::TELEOP)
    when :endgame_only
      ClockController.new(131.0, ClockController::TELEOP_ENDGAME)
    else
      nil
    end
  end

  def abort_clock
    @clock.controller = nil
  end

  def set_clock_title(string)
    @clock.title.text = string.to_s
    pp string
    @clock.title.x = $window.width / 2 - @clock.title.width / 2
  end

  def get_clock_title(string)
    @clock.title
  end

  def jukebox_previous_track
    @jukebox.previous_track
  end

  def jukebox_next_track
    @jukebox.next_track
  end

  def jukebox_stop
    @jukebox.stop
  end

  def jukebox_play
  end

  def jukebox_pause
  end

  def jukebox_sound_effects(boolean)
    @jukebox.toggle_sfx(boolean)
  end

  def shutdown!
  end
end