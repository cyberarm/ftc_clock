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
require_relative "remote_proxy"

class RemoteControlWindow < CyberarmEngine::Window
  attr_accessor :connection

  def setup
    push_state(NetConnect)
  end

  def needs_cursor?
    true
  end

  class NetConnect < CyberarmEngine::GuiState
    def setup
      theme(THEME)

      background Palette::TACNET_NOT_CONNECTED

      title "ClockNet"
      flow(width: 1.0) do
      end

      button "Connect" do
        begin
          @connection = ClockNet::Connection.new(proxy_object: RemoteProxy.new(window))
          @connection.connect
          window.connection = @connection

          push_state(Controller)
        end
      end
    end
  end

  class Controller < CyberarmEngine::GuiState
    def setup
      theme(THEME)

      at_exit do
        @connection&.close
      end

      background Palette::TACNET_NOT_CONNECTED

      banner "ClockNet Remote Control", text_align: :center, width: 1.0

      flow width: 1.0, height: 1.0 do
        stack width: 0.5 do
          title "Match"
          button "Start Match", width: 1.0, text_size: 48, margin_bottom: 50 do
            start_clock(:full_match)
          end

          title "Practice"
          button "Autonomous", width: 1.0 do
            start_clock(:autonomous)
          end
          button "TeleOp with Countdown", width: 1.0 do
            start_clock(:full_teleop)
          end
          button "TeleOp", width: 1.0 do
            start_clock(:teleop_only)
          end
          button "TeleOp Endgame", width: 1.0, margin_bottom: 50 do
            start_clock(:endgame_only)
          end

          button "Abort Clock", width: 1.0 do
            window.connection.puts(ClockNet::PacketHandler.packet_abort_clock)
          end

          button "Shutdown", width: 1.0, **DANGEROUS_BUTTON do
            window.connection.puts(ClockNet::PacketHandler.packet_shutdown)
            sleep 1
            exit
          end
        end

        stack width: 0.495 do
          title "Clock Title"

          @title = edit_line "FIRST TECH CHALLENGE", width: 1.0

          button "Change Title", width: 1.0 do
            window.connection.puts(ClockNet::PacketHandler.packet_set_clock_title(@title.value.strip))
          end
        end
      end
    end

    def start_clock(mode)
      window.connection.puts(ClockNet::PacketHandler.packet_start_clock(mode.to_s))
    end
  end
end