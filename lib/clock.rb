class Clock
  attr_accessor :running

  def initialize
    $window.elements << self
    @text = Text.new("02:30", size: 488, alignment: :center)
    @text.y = ($window.height/2)-(@text.height/4)*3
    @time = (60*2+30).to_f
    @running = false
    @wall_time = Time.now
  end

  def draw
    @text.draw
  end

  def update
    pause if @time <= 0.0
    update_clock
    @wall_time = Time.now
    @text.text = "#{time}"
  end

  def time
    minutes = (@time/60.0).to_s.split(".").first.to_i
    minutes = "0#{minutes}" if minutes < 10
    seconds = @time.round % 60
    seconds = "0#{seconds}" if seconds < 10
    "#{minutes}:#{seconds}"
  end

  def update_clock
    if @running
      # puts "Time: #{@time}, wall_time: #{Time.now-@wall_time}, FPS: #{Gosu.fps}"
      @time-=Time.now-@wall_time
    end
  end

  def start(mode = :normal)
    @wall_time = Time.now
    case mode
    when :normal
      @time = (60*2+30).to_f
      @running = true
    when :teleop
      @time = (60*2).to_f
      @running = true
    when :autonomous
      @time = (30).to_f
      @running = true
    when :resume
      @running = true
    end
  end

  def pause
    @running = false
  end

  def reset
    @mode = :paused
    @running = false
    @time = (60*2+30).to_f
  end
end
