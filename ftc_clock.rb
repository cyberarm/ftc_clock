require "gosu"
require_relative "lib/text"
require_relative "lib/button"
require_relative "lib/clock"

class FtcClock < Gosu::Window
  attr_reader :elements, :mouse_last_moved, :clock
  Mouse = Struct.new(:x, :y)

  def initialize
    super(Gosu.screen_width, Gosu.screen_height, true, 1000.0/24)
    $window = self
    @elements = []
    @fps = Text.new("FPS: 0", size: 18, color: Gosu::Color::GRAY)
    @title = Text.new("#{ARGV.size > 0 ? ARGV[0].upcase : 'First Tech Challenge'.upcase}", font: "Sans Serif", size: 96, y: 10, alignment: :center, color: Gosu::Color::WHITE)
    @mouse_last_moved = Time.now
    @show_cursor = true
    @mouse = Mouse.new(self.mouse_x, self.mouse_y)

    @clock = Clock.new

    Button.new("Start", alignment: :center, y: self.height-300) do
      @clock.start
    end
    pause = Button.new("Pause", alignment: :center, y: self.height-200) do |button|
      if @clock.time.round(1) != 0.0 && @clock.time.round(1) != 150.0
        @clock.pause
        button.text.text = "Resume" if !@clock.running
        button.text.text = "Pause" if @clock.running
      end
    end
    Button.new("Reset", alignment: :center, y: self.height-100) do
      pause.text.text = "Pause"
      @clock.reset
    end


    Button.new("TelOp Only", alignment: :right, y: self.height-200) do
      @clock.start(:teleop)
    end
    Button.new("Autonomous Only", alignment: :right, y: self.height-100) do
      @clock.start(:autonomous)
    end
  end

  def draw
    @fps.draw if should_render?
    @title.draw
    @elements.each(&:draw)
  end

  def update
    @mouse_last_moved = Time.now unless @mouse.x == self.mouse_x && @mouse.y == self.mouse_y
    @mouse.x, @mouse.y = self.mouse_x, self.mouse_y
    should_render? ? @show_cursor = true : @show_cursor = false
    @fps.text = "FPS: #{Gosu.fps}"
    @elements.each(&:update)
  end

  def should_render?
    if Time.now-@mouse_last_moved >= 1.5 && @clock.running
      false
    else
      true
    end
  end

  def needs_cursor?
    @show_cursor
  end

  def button_up(id)
    super
    @elements.each do |e|
      e.button_up(id) if defined?(e.button_up)
    end
  end
end

FtcClock.new.show
