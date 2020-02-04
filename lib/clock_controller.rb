class ClockController
  SAMPLES = {}
  Event = Struct.new(:event, :trigger_after, :arguments)

  include EventHandlers

  FULL_MATCH = [
    Event.new(:change_clock, 0.0, "2:30"),
    Event.new(:change_countdown, 0.0, ":03"),
    Event.new(:change_display, 0.0, :countdown),
    Event.new(:start_countdown, 0.0),
    Event.new(:play_sound, 0.0, :autonomous_countdown),
    Event.new(:change_display, 3.0, :clock),
    Event.new(:play_sound, 3.0, :autonomous_start),
    Event.new(:change_display, 3.0, :clock),
    Event.new(:stop_countdown, 3.0),
    Event.new(:start_clock, 3.0, :clock),
  ]
  def initialize(events = [])
    @events = events
    @last_update = 0

    @elapsed_time = 0
    @display = :clock

    @clock_time = 0.0
    @countdown_time = 0.0

    @clock_running = false
    @countdown_running = false
  end

  def update
    update_active_timer(Gosu.milliseconds - @last_update)

    @last_update = Gosu.milliseconds
  end

  def update_active_timer(dt)
    if @clock_running
      @clock_time -= dt
    elsif @countdown_running
      @countdown_time -= dt
    end
  end

  def time_left
    if @clock_running
      return @clock_time
    elsif @countdown_running
      return @countdown_time
    else
      return 60 * 2 + 30
    end
  end

  def play_sound(sound)
    path = nil
    case sound
    when :autonomous_countdown
    when :autonomous_start
      path = "./media/charge.wav"
    when :autonomous_ended
      path = "./media/endauto.wav"
    when :teleop_pickup_controllers
    when :teleop_countdown
    when :teleop_started
      path = "./media/firebell.wav"
    when :end_game
      path = "./media/factwhistle.wav"
    when :end_match
      path = "./media/endmatch.wav"
    end

    if path && File.exist?(path)
      SAMPLES[path] = Gosu::Sample.new(path) unless SAMPLES[path].is_a?(Gosu::Sample)
      SAMPLES[path].play
    end
  end
end