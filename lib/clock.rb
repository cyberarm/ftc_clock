class Clock
  CLOCK_SIZE = 500
  SAMPLES = {}
  attr_accessor :running
  attr_reader :time

  def initialize
    $window.elements << self
    # Preload characters to prevent really long draw calls when first running clock.
    cache = Text.new(":0123456789", size: CLOCK_SIZE, alignment: :center)
    cache = nil
    @text = Text.new("2:30", size: CLOCK_SIZE, alignment: :center, shadow_size: 2)
    @text.y = ($window.height/2)-(@text.height/4)*3
    @time = (60*2+30).to_f
    @running = false
    @period_pause = false
    @mode = :paused
    @wall_time = Time.now
  end

  def draw
    @text.draw
  end

  def update
    @running = false if @time <= 0.0
    update_clock
    @wall_time = Time.now
    @text.text = "#{clock_time}" unless @text.text == clock_time
  end

  def clock_time
    minutes = (@time/60.0).to_s.split(".").first.to_i
    if minutes == 0 && (@time >= 59.4)
      minutes+=1
    elsif minutes == 1 && (@time >= 119.4)
      minutes+=1
    end
    # minutes = "0#{minutes}" if minutes < 10
    seconds = @time.round % 60
    seconds = "0#{seconds}" if seconds < 10
    return "#{minutes}:#{seconds}" if @time.round.even?
    return "#{minutes}<c=999999>:</c>#{seconds}" if @time.round.odd?
  end

  def update_clock
    if @running
      @time-=Time.now-@wall_time
      @time = 0 if @time < 0
      play_sound(:end_match) if @time <= 0.0 && @mode != :autonomous
      play_sound(:autonomous_ended) if @time <= 0.0 && @mode == :autonomous
      @text.color = Gosu::Color.rgb(139,0,0) if @time.round < 30
      if @mode == :normal && @time.round == 120 && !@period_pause
        play_sound(:autonomous_ended)
        @running = false
        @period_pause = true
        $window.pause.text.text = "Resume"
      end
    end
  end

  def start(mode = :normal)
    @wall_time = Time.now
    case mode
    when :normal
      @mode = :normal
      @period_pause = false
      @time = (60*2+30).to_f
      @text.color = Gosu::Color::WHITE
    when :teleop
      @mode = :teleop
      @time = (60*2).to_f
      @text.color = Gosu::Color::WHITE
    when :autonomous
      @mode = :autonomous
      @time = (30).to_f
      @text.color = Gosu::Color::WHITE
    when :resume
    end
    play_sound(:start_match)
    @running = true
  end

  def pause
    if @running
      @running = false
    else
      @running = true
    end
  end

  def reset
    @mode = :paused
    @running = false
    @period_pause = false
    @text.color = Gosu::Color::WHITE
    @time = (60*2+30).to_f
  end

  def play_sound(sound)
    path = nil
    case sound
    when :start_match
      path = "./media/charge.wav"
    when :autonomous_ended
      path = "./media/endauto.wav"
    when :end_match
      path = "./media/endmatch.wav"
    end
    if path && File.exist?(path)
      SAMPLES[path] = Gosu::Sample.new(path) unless SAMPLES[path].is_a?(Gosu::Sample)
      SAMPLES[path].play
    end
  end
end
