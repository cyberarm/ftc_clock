require_relative "../cyberarm_engine/lib/cyberarm_engine"

ROOT_PATH = File.expand_path(__dir__)
SAMPLES = {}

require_relative "lib/view"
require_relative "lib/clock"
require_relative "lib/event_handlers"
require_relative "lib/clock_controller"
require_relative "lib/jukebox"

class FtcClock < CyberarmEngine::Engine
  def initialize
    super(width: Gosu.screen_width, height: Gosu.screen_height, fullscreen: true, update_interval: 1000.0/24)

    sounds = Dir[ROOT_PATH + "/media/*.*"].each do |sound|
      if File.basename(sound).split(".").last =~ /wav|ogg/
        SAMPLES[sound] = Gosu::Sample.new(sound)
      end
    end

    push_state(View)
  end
end

FtcClock.new.show unless defined?(Ocra)
