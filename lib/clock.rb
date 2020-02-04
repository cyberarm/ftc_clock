class Clock
  CLOCK_SIZE = Gosu.screen_height

  def initialize
    @text = CyberarmEngine::Text.new(":1234567890", size: CLOCK_SIZE, text_shadow: true, shadow_size: 2, shadow_color: Gosu::Color::GRAY)
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

    @text.x = $window.width / 2 - @text.textobject.text_width("0:00") / 2
    @text.y = $window.height / 2 - @text.height / 2
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
