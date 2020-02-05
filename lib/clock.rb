class Clock
  CLOCK_SIZE = Gosu.screen_height
  TITLE_SIZE = 128

  def initialize
    @title = CyberarmEngine::Text.new(ARGV.size > 0 ? ARGV.first : "FIRST TECH CHALLENGE", size: TITLE_SIZE, text_shadow: true, y: 10, color: Gosu::Color::GRAY)
    @title.x = $window.width / 2 - @title.width / 2

    @text = CyberarmEngine::Text.new(":1234567890", size: CLOCK_SIZE, text_shadow: true, shadow_size: 2, shadow_color: Gosu::Color::GRAY)
    @text.width # trigger font-eager loading

    @title.z, @text.z = -1, -1

    @controller = nil
  end

  def controller=(controller)
    @controller = controller
  end

  def draw
    @title.draw
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

  def active?
    if @controller
      @controller.clock? || @controller.countdown?
    else
      return false
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

    if time_left < 30.0
      if @controller.countdown?
        @text.color = Gosu::Color.rgb(150, 75, 0)
      else
        @text.color = Gosu::Color.rgb(150, 0, 0)
      end
    else
      @text.color = Gosu::Color::WHITE
    end

    return "#{minutes}:#{seconds}" if time_left.round.even?
    return "#{minutes}<c=999999>:</c>#{seconds}" if time_left.round.odd?
  end
end
