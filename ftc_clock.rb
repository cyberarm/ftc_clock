begin
  require_relative "../cyberarm_engine/lib/cyberarm_engine"
rescue LoadError
  require "cyberarm_engine"
end

ROOT_PATH = File.expand_path(__dir__)
DUAL_SCREEN_MODE = ARGV.join.include?("--dual-screen-mode")
SAMPLES = {}

require_relative "lib/view"
require_relative "lib/clock"
require_relative "lib/event_handlers"
require_relative "lib/clock_controller"
require_relative "lib/jukebox"
require_relative "lib/theme"
require_relative "lib/clock_proxy"
require_relative "lib/logger"

if DUAL_SCREEN_MODE
  require "socket"

  require_relative "lib/net/client"
  require_relative "lib/net/connection"
  require_relative "lib/net/packet_handler"
  require_relative "lib/net/packet"
  require_relative "lib/net/server"
end

class FtcClock < CyberarmEngine::Window
  attr_accessor :redraw_screen
  def initialize
    if DUAL_SCREEN_MODE
      super(width: Gosu.screen_width * 0.9, height: Gosu.screen_height * 0.8, fullscreen: false, resizable: true)
    else
      super(width: Gosu.screen_width, height: Gosu.screen_height, fullscreen: true)
    end

    sounds = Dir[ROOT_PATH + "/media/*.*"].each do |sound|
      if File.basename(sound).split(".").last =~ /wav|ogg/
        SAMPLES[sound] = Gosu::Sample.new(sound)
      end
    end

    @redraw_screen = true
    push_state(View)
  end

  def needs_redraw?
    @redraw_screen
  end
end

FtcClock.new.show unless defined?(Ocra)
