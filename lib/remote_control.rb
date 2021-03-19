begin
  require_relative "../../cyberarm_engine/lib/cyberarm_engine"
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

ROOT_PATH = File.expand_path("..", __dir__)

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

      banner "ClockNet Remote Control", text_align: :center, width: 1.0
      stack(width: 0.5) do
        title "Hostname"
        @hostname = edit_line "localhost", width: 1.0
        title "Port"
        @port = edit_line "4567", width: 1.0

        @connect = button "Connect", width: 1.0, margin_top: 20 do
          begin
            @connection = ClockNet::Connection.new(hostname: @hostname.value, port: Integer(@port.value), proxy_object: RemoteProxy.new(window))
            @connection.connect
            window.connection = @connection

            @connect.enabled = false
          end
        end
      end
    end

    def update
      super

      if window.connection
        push_state(Controller) if window.connection.connected?

        window.connection = nil if window.connection.client.socket_error?
      else
        @connect.enabled = true
      end
    end
  end

  class Controller < CyberarmEngine::GuiState
    def setup
      theme(THEME)

      at_exit do
        @connection&.close
      end

      @jukebox_volume = 1.0
      @jukebox_sound_effects = true
      @randomizer_visible = false

      window.connection.proxy_object.register(:track_changed, method(:track_changed))
      window.connection.proxy_object.register(:volume_changed, method(:volume_changed))
      window.connection.proxy_object.register(:clock_changed, method(:clock_changed))
      window.connection.proxy_object.register(:randomizer_changed, method(:randomizer_changed))

      background Palette::TACNET_NOT_CONNECTED

      banner "ClockNet Remote Control", text_align: :center, width: 1.0

      flow width: 1.0, height: 1.0 do
        stack width: 0.5 do
          title "Match", width: 1.0, text_align: :center
          button "Start Match", width: 1.0, text_size: 48, margin_bottom: 50 do
            start_clock(:full_match)
          end

          title "Practice", width: 1.0, text_align: :center
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
            sleep 1 # let packet escape before closing
            exit
          end
        end

        stack width: 0.495 do
          title "Clock Title", width: 1.0, text_align: :center

          stack width: 0.9, margin_left: 50 do
            @title = edit_line "FIRST TECH CHALLENGE", width: 1.0

            button "Update", width: 1.0, margin_bottom: 50 do
              window.connection.puts(ClockNet::PacketHandler.packet_set_clock_title(@title.value.strip))
            end
          end

          title "JukeBox", width: 1.0, text_align: :center
          stack width: 0.9, margin_left: 50 do
            flow width: 1.0 do
              tagline "Now Playing: "
              @track_name = tagline ""
            end

            flow width: 1.0 do
              tagline "Volume: "
              @volume = tagline "100%"
            end

            flow width: 1.0 do
              button get_image("#{ROOT_PATH}/media/icons/previous.png") do
                window.connection.puts(ClockNet::PacketHandler.packet_jukebox_previous_track)
              end

              button get_image("#{ROOT_PATH}/media/icons/right.png") do |button|
                if @jukebox_playing
                  window.connection.puts(ClockNet::PacketHandler.packet_jukebox_pause)
                  button.value = get_image("#{ROOT_PATH}/media/icons/right.png")
                  @jukebox_playing = false
                else
                  window.connection.puts(ClockNet::PacketHandler.packet_jukebox_play)
                  button.value = get_image("#{ROOT_PATH}/media/icons/pause.png")
                  @jukebox_playing = true
                end
              end

              button get_image("#{ROOT_PATH}/media/icons/stop.png") do
                window.connection.puts(ClockNet::PacketHandler.packet_jukebox_stop)
              end

              button get_image("#{ROOT_PATH}/media/icons/next.png") do
                window.connection.puts(ClockNet::PacketHandler.packet_jukebox_next_track)
              end

              button get_image("#{ROOT_PATH}/media/icons/minus.png"), margin_left: 20 do
                @jukebox_volume -= 0.1
                @jukebox_volume = 0.1 if @jukebox_volume < 0.1
                window.connection.puts(ClockNet::PacketHandler.packet_jukebox_set_volume(@jukebox_volume))
              end

              button get_image("#{ROOT_PATH}/media/icons/plus.png") do
                @jukebox_volume += 0.1
                @jukebox_volume = 0.1 if @jukebox_volume < 0.1
                window.connection.puts(ClockNet::PacketHandler.packet_jukebox_set_volume(@jukebox_volume))
              end

              button get_image("#{ROOT_PATH}/media/icons/musicOn.png"), margin_left: 20, tip: "Toggle Sound Effects" do |button|
                if @jukebox_sound_effects
                  button.value = get_image("#{ROOT_PATH}/media/icons/musicOff.png")
                  @jukebox_sound_effects = false
                else
                  button.value = get_image("#{ROOT_PATH}/media/icons/musicOn.png")
                  @jukebox_sound_effects = true
                end

                window.connection.puts(ClockNet::PacketHandler.packet_jukebox_set_sound_effects(@jukebox_sound_effects))
              end
            end

            button "Open Music Library", width: 1.0 do
              path = "#{ROOT_PATH}/media/music"

              if RUBY_PLATFORM.match(/ming|msys|cygwin/)
                system("explorer \"#{path.gsub("/", "\\")}\"")
              elsif RUBY_PLATFORM.match(/linux/)
                system("xdg-open \"#{ROOT_PATH}/media/music\"")
              else
                # TODO.
              end
            end
          end

          stack width: 0.9, margin_left: 50, margin_top: 20 do
            flow width: 1.0 do
              title "Clock: "
              @clock_label = title "0:123456789"
              @clock_label.width
              @clock_label.value = "0:00"
            end

            flow width: 1.0 do
              title "Randomizer: "
              @randomizer_label = title "Not Visible"
            end

            button "Randomizer", width: 1.0, **DANGEROUS_BUTTON do
              @randomizer_visible = !@randomizer_visible

              window.connection.puts(ClockNet::PacketHandler.packet_randomizer_visible(@randomizer_visible))
            end
          end
        end
      end
    end

    def update
      super

      return if window.connection.connected?

      # We've lost connection, unset window's connection object
      # and send user back to connect screen to to attempt to
      # reconnect
      window.connection = nil
      pop_state
    end

    def start_clock(mode)
      window.connection.puts(ClockNet::PacketHandler.packet_start_clock(mode.to_s))
    end

    def track_changed(name)
      @track_name.value = name
    end

    def volume_changed(float)
      @volume.value = "#{float.round(1) * 100.0}%"
    end

    def clock_changed(string)
      @clock_label.value = string
    end

    def randomizer_changed(boolean)
      @randomizer_label.value = "Visible" if boolean
      @randomizer_label.value = "Not Visible" unless boolean
    end
  end
end