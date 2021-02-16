begin
  require_relative "../cyberarm_engine/lib/cyberarm_engine"
rescue LoadError
  require "cyberarm_engine"
end

ROOT_PATH = File.expand_path(__dir__)
REMOTE_CONTROL_MODE = ARGV.join.include?("--remote-control")
SAMPLES = {}

require_relative "lib/view"
require_relative "lib/clock"
require_relative "lib/event_handlers"
require_relative "lib/clock_controller"
require_relative "lib/jukebox"
require_relative "lib/theme"
require_relative "lib/clock_proxy"
require_relative "lib/logger"
require_relative "lib/particle_emitter"
require_relative "lib/randomizer"

if REMOTE_CONTROL_MODE
  require "socket"

  require_relative "lib/net/client"
  require_relative "lib/net/connection"
  require_relative "lib/net/packet_handler"
  require_relative "lib/net/packet"
  require_relative "lib/net/server"
end

class FtcClock < CyberarmEngine::Window
  attr_accessor :redraw_screen, :server

  def initialize
    if REMOTE_CONTROL_MODE
      super(width: (Gosu.screen_width * 0.9).to_i, height: (Gosu.screen_height * 0.8).to_i, fullscreen: false, resizable: true)
    else
      super(width: Gosu.screen_width, height: Gosu.screen_height, fullscreen: true)
    end

    Dir[ROOT_PATH + "/media/*.*"].each do |sound|
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
