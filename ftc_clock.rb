require "cyberarm_engine"

require_relative "lib/view"
require_relative "lib/clock"
require_relative "lib/event_handlers"
require_relative "lib/clock_controller"

ROOT_PATH = File.expand_path(__dir__)

class FtcClock < CyberarmEngine::Engine
  def initialize
    super(width: Gosu.screen_width, height: Gosu.screen_height, fullscreen: true, update_interval: 1000.0/24)

    push_state(View)
  end
end

FtcClock.new.show
