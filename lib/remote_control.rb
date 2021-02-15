begin
  require_relative "../cyberarm_engine/lib/cyberarm_engine"
rescue LoadError
  require "cyberarm_engine"
end

require "drb/drb"

require_relative "remote_api"
require_relative "theme"

class RemoteControlWindow < CyberarmEngine::Window
  def setup
    push_state(View)
  end

  def needs_cursor?
    true
  end

  class View < CyberarmEngine::GuiState
    def setup
      DRb.start_service

      @remote_api = DRbObject.new_with_uri(RemoteAPI::URI)

      theme(THEME)

      background 0xff_008000
      banner "Hello World"

      button "Start Match", text_size: 48 do
        @remote_api.start_clock(:full_match)
      end

      button "Change Title" do
        @remote_api.set_title("Hello World!")
      end
    end
  end
end