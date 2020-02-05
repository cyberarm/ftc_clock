class View < CyberarmEngine::GuiState
  def setup
    window.show_cursor = true

    @mouse = Mouse.new(window)
    @clock = Clock.new
    @clock_controller = nil
    @clock.controller = nil

    @menu = flow do
      stack(width: 350, padding: 5) do
        background 0x55004159

        button "Start Match", width: 1.0 do
          @clock_controller = ClockController.new(0, ClockController::FULL_MATCH)
          @clock.controller = @clock_controller
        end

        button "Start Autonomous Only", width: 1.0, margin_top: 40 do
          @clock_controller = ClockController.new(0, ClockController::AUTONOMOUS)
          @clock.controller = @clock_controller
        end

        button "Start Full TeleOp", width: 1.0, margin_top: 40 do
          @clock_controller = ClockController.new(33.0, ClockController::FULL_TELEOP)
          @clock.controller = @clock_controller
        end

        button "Start TeleOp Only", width: 1.0, margin_top: 10 do
          @clock_controller = ClockController.new(41.0, ClockController::TELEOP)
          @clock.controller = @clock_controller
        end

        button "Start TeleOp Endgame Only", width: 1.0, margin_top: 10 do
          @clock_controller = ClockController.new(131.0, ClockController::TELEOP_ENDGAME)
          @clock.controller = @clock_controller
        end

        button "Abort", width: 1.0, margin_top: 40 do
          @clock_controller = nil
          @clock.controller = nil
        end

        button "Exit", width: 1.0, margin_top: 40, background: Gosu::Color.rgb(100, 0, 0), hover: {background: Gosu::Color.rgb(200, 0, 0)} do
          window.close
        end
      end

      stack padding_left: 50 do
        background 0x55004159

        flow do
          label "♫ Now playing: "
          @current_song_label = label "♫ ♫ ♫"
        end

        flow do
          button "←" do
            @jukebox.previous_track
          end

          button "||" do |button|
            if @jukebox.paused?
              button.value = "►"
              @jukebox.play
            else
              button.value = "||"
              @jukebox.pause
            end
          end

          button "■" do
            @jukebox.stop
          end

          button "→" do
            @jukebox.next_track
          end

          button "Music Library", margin_left: 50 do
            if RUBY_PLATFORM.match(/ming|msys|cygwin/)
              # TODO: windows
            elsif RUBY_PLATFORM.match(/linux/)
              system("xdg-open #{ROOT_PATH}/media/music")
            else
              # TODO.
            end
          end
        end
      end
    end

    @jukebox = Jukebox.new(@current_song_label)
  end

  def draw
    super

    @clock.draw
  end

  def update
    super

    @clock.update
    @clock_controller.update if @clock_controller
    @mouse.update
    @jukebox.update

    if @mouse.last_moved < 1.5
      @menu.show unless @menu.visible?
      window.show_cursor = true
    else
      @menu.hide if @menu.visible?
      window.show_cursor = false
    end
  end

  class Mouse
    def initialize(window)
      @window = window
      @last_moved = 0

      @last_position = CyberarmEngine::Vector.new(@window.mouse_x, @window.mouse_y)
    end

    def update
      position = CyberarmEngine::Vector.new(@window.mouse_x, @window.mouse_y)

      if  @last_position != position
        @last_position = position
        @last_moved = Gosu.milliseconds
      end
    end

    def last_moved
      (Gosu.milliseconds - @last_moved) / 1000.0
    end
  end
end
