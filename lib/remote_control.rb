begin
  require_relative "../cyberarm_engine/lib/cyberarm_engine"
rescue LoadError
  require "cyberarm_engine"
end

require "socket"

require_relative "net/client"
require_relative "net/connection"
require_relative "net/packet_handler"
require_relative "net/packet"

require_relative "logger"
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
      theme(THEME)

      @connection = ClockNet::Connection.new(proxy_object: self)
      @connection.connect

      at_exit do
        @connection&.close
      end

      background 0xff_008000
      banner "Hello World"

      button "Start Match", text_size: 48 do
        start_clock(:full_match)
      end

      button "Abort Clock" do
        @connection.puts(ClockNet::PacketHandler.packet_abort_clock)
      end

      @title = edit_line "FIRST Tech Challenge"

      button "Change Title" do
        @connection.puts(ClockNet::PacketHandler.packet_set_clock_title(@title.value.strip))
      end
    end

    def start_clock(mode)
      @connection.puts(ClockNet::PacketHandler.packet_start_clock(mode.to_s))
    end
  end
end