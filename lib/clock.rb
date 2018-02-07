class Clock
  attr_accessor :running
  attr_reader :time

  def initialize
    $window.elements << self
    @text = Text.new("2:30", size: 488, alignment: :center)
    @text.y = ($window.height/2)-(@text.height/4)*3
    @time = (60*2+30).to_f
    @running = false
    @wall_time = Time.now
  end

  def draw
    @text.draw
  end

  def update
    @running = false if @time <= 0.0
    update_clock
    @wall_time = Time.now
    @text.text = "#{clock_time}"
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
    "#{minutes}:#{seconds}"
  end

  def update_clock
    if @running
      @time-=Time.now-@wall_time
      @time = 0 if @time < 0
    end
  end

  def start(mode = :normal)
    @wall_time = Time.now
    case mode
    when :normal
      @time = (60*2+30).to_f
      @text.color = Gosu::Color::WHITE
    when :teleop
      @time = (60*2).to_f
      @text.color = Gosu::Color::BLUE
    when :autonomous
      @time = (30).to_f
      @text.color = Gosu::Color::RED
    when :resume
    end
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
    @text.color = Gosu::Color::WHITE
    @time = (60*2+30).to_f
  end
end
