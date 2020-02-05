class ClockController
  Event = Struct.new(:event, :trigger_after, :arguments)

  include EventHandlers

  def self.create_event(event, trigger_after, arguments = nil)
    arguments = [arguments] unless arguments.is_a?(Array) || arguments == nil

    Event.new(event, trigger_after, arguments)
  end

  AUTONOMOUS = [
    create_event(:change_clock, 0.0, "2:30"),
    create_event(:change_countdown, 0.0, "0:03"),
    create_event(:change_display, 0.0, :countdown),
    create_event(:start_countdown, 0.0),
    create_event(:play_sound, 0.0, :autonomous_countdown),
    create_event(:change_display, 3.0, :clock),
    create_event(:play_sound, 3.0, :autonomous_start),
    create_event(:change_display, 3.0, :clock),
    create_event(:stop_countdown, 3.0),
    create_event(:start_clock, 3.0),
    create_event(:play_sound, 33.0, :autonomous_ended),
    create_event(:stop_clock, 33.0),
  ].freeze

  PRE_TELEOP = [
    create_event(:change_countdown, 33.0, "0:08"),
    create_event(:change_display, 33.0, :countdown),
    create_event(:start_countdown, 33.0),
    create_event(:play_sound, 34.5, :teleop_pickup_controllers),
    create_event(:play_sound, 38.0, :teleop_countdown),
    create_event(:stop_countdown, 41.0),
  ].freeze

  TELEOP_ENDGAME = [
    create_event(:change_clock, 131.0, "0:30"),
    create_event(:start_clock, 131.0),
    create_event(:play_sound, 131.0, :end_game),
    create_event(:play_sound, 158.0, :teleop_countdown),
    create_event(:play_sound, 161.0, :end_match),
    create_event(:stop_clock, 161.0),
  ].freeze

  TELEOP = [
    create_event(:change_clock, 41.0, "2:00"),
    create_event(:play_sound, 41.0, :teleop_started),
    create_event(:change_display, 41.0, :clock),
    create_event(:start_clock, 41.0),
    TELEOP_ENDGAME
  ].flatten.freeze

  FULL_TELEOP = [
    PRE_TELEOP,
    TELEOP,
    TELEOP_ENDGAME,
  ].flatten.freeze

  FULL_MATCH = [
    # Autonomous
    AUTONOMOUS,
    FULL_TELEOP
  ].flatten.freeze

  def initialize(elapsed_time = 0, events = [])
    @events = events.dup
    @last_update = Gosu.milliseconds

    @elapsed_time = elapsed_time
    @display = :clock

    @clock_time = 0.0
    @countdown_time = 0.0

    @clock_running = false
    @countdown_running = false
  end

  def update
    dt = (Gosu.milliseconds - @last_update) / 1000.0
    update_active_timer(dt)

    @events.select { |event| event.trigger_after <= @elapsed_time }.each do |event|
      @events.delete(event)

      if event.arguments
        self.send(event.event, *event.arguments)
      else
        self.send(event.event)
      end
    end

    @last_update = Gosu.milliseconds
  end

  def update_active_timer(dt)
    if @clock_running
      @clock_time -= dt
    elsif @countdown_running
      @countdown_time -= dt
    end

    @elapsed_time += dt
  end

  def clock?
    @clock_running
  end

  def countdown?
    @countdown_running
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

    if path && File.exist?(path)
      SAMPLES[path] = Gosu::Sample.new(path) unless SAMPLES[path].is_a?(Gosu::Sample)
      SAMPLES[path].play
    else
      warn "WARNING: Sample for #{sound.inspect} could not be found at '#{path}'"
    end
  end
end