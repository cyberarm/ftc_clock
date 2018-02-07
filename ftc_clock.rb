require "gosu"
require_relative "lib/text"
require_relative "lib/button"
require_relative "lib/clock"

class FtcClock < Gosu::Window
  attr_reader :elements

  def initialize
    super(Gosu.screen_width, Gosu.screen_height, true)
    $window = self
    @elements = []

    @clock = Clock.new

    Button.new("Start", alignment: :center, y: self.height-300) do |button|
      @clock.start
    end
    Button.new("Pause", alignment: :center, y: self.height-200) do |button|
      @clock.pause
    end
    Button.new("Reset", alignment: :center, y: self.height-100) do
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
    @elements.each(&:draw)
  end

  def update
    @elements.each(&:update)
  end

  def needs_cursor?
    true
  end

  def button_up(id)
    super
    @elements.each do |e|
      e.button_up(id) if defined?(e.button_up)
    end
  end
end

FtcClock.new.show
