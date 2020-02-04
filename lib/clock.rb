class Clock
  CLOCK_SIZE = 500
  SAMPLES = {}
  def initialize
    @text = CyberarmEngine::Text.new(":1234567890", size: 500, align: :center)
    @text.width # trigger font-eager loading

    @controller = nil
  end

  def controller=(controller)
    @controller = controller
  end

  def draw
    @text.draw
  end

  def update
    if @controller
      @text.text = clock_time(@controller.time_left)
    else
      @text.text = "0:00"
    end
  end

  def clock_time(time_left)
    minutes = (time_left / 60.0).to_s.split(".").first.to_i
    if minutes == 0 && (time_left >= 59.4)
      minutes+=1
    elsif minutes == 1 && (time_left >= 119.4)
      minutes+=1
    end

    seconds = time_left.round % 60
    seconds = "0#{seconds}" if seconds < 10

    return "#{minutes}:#{seconds}" if time_left.round.even?
    return "#{minutes}<c=999999>:</c>#{seconds}" if time_left.round.odd?
  end
end
