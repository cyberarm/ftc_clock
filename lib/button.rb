class Button
  PADDING = 10
  attr_reader :text

  def initialize(text, options={}, &block)
    $window.elements << self
    @block = block
    @text  = Text.new(text, options)
    @background_color = options[:background_color] ? options[:background_color] : Gosu::Color.rgb(20,20,150)
    @hover_color = options[:hover_color] ? options[:hover_color] : Gosu::Color.rgb(50,50,250)

    @active_background_color = @background_color
  end

  def draw
    @text.draw
    $window.draw_rect(@text.x-PADDING, @text.y-PADDING, @text.width+PADDING*2, @text.height+PADDING*2, @active_background_color)
  end

  def update
    if mouse_over?
      @active_background_color = @hover_color
    else
      @active_background_color = @background_color
    end
  end

  def button_up(id)
    if mouse_over? && id == Gosu::MsLeft
      @block.call(self) if @block
    end
  end

  def mouse_over?
    if $window.mouse_x.between?(@text.x-PADDING, @text.x+@text.width+PADDING)
      if $window.mouse_y.between?(@text.y-PADDING, @text.y+@text.height+PADDING)
        true
      else
        false
      end
    else
      false
    end
  end
end
