class View < CyberarmEngine::GuiState
  attr_reader :clock

  def setup
    window.show_cursor = true

    @redraw_screen = true
    @mouse = Mouse.new(window)
    @clock = Clock.new
    @clock.controller = nil
    @last_clock_display_value = @clock.value

    @particle_emitters = [
      ParticleEmitter.new
    ]

    @last_clock_state = @clock.active?

    theme(THEME)

    @menu_container = flow width: 1.0 do
      stack(width: 0.35, padding: 5) do
        background 0x55004159

        title "Match", width: 1.0, text_align: :center
        button "Start Match", width: 1.0, margin_bottom: 50 do
          @clock_proxy.start_clock(:full_match)
        end

        title "Practice", width: 1.0, text_align: :center
        button "Autonomous", width: 1.0 do
          @clock_proxy.start_clock(:autonomous)
        end

        button "TeleOp with Countdown", width: 1.0 do
          @clock_proxy.start_clock(:full_teleop)
        end

        button "TeleOp", width: 1.0 do
          @clock_proxy.start_clock(:teleop_only)
        end

        button "TeleOp Endgame", width: 1.0 do
          @clock_proxy.start_clock(:endgame_only)
        end

        button "Abort Clock", width: 1.0, margin_top: 50 do
          @clock_proxy.abort_clock
        end

        button "Shutdown", width: 1.0, **DANGEROUS_BUTTON do
          window.close
        end
      end

      stack width: 0.4, padding_left: 50 do
        background 0x55004159

        flow do
          label "♫ Now playing:"
          @current_song_label = label "♫ ♫ ♫"
        end

        flow do
          label "Volume:"
          @current_volume_label = label "100%"
        end

        flow do
          button get_image("#{ROOT_PATH}/media/icons/previous.png") do
            @jukebox.previous_track
          end

          button get_image("#{ROOT_PATH}/media/icons/pause.png") do |button|
            if @jukebox.song && @jukebox.song.paused?
              button.value = get_image("#{ROOT_PATH}/media/icons/right.png")
              @jukebox.play
            elsif !@jukebox.song
              button.value = get_image("#{ROOT_PATH}/media/icons/right.png")
              @jukebox.play
            else
              button.value = get_image("#{ROOT_PATH}/media/icons/pause.png")
              @jukebox.pause
            end
          end

          button get_image("#{ROOT_PATH}/media/icons/stop.png") do
            @jukebox.stop
          end

          button get_image("#{ROOT_PATH}/media/icons/next.png") do
            @jukebox.next_track
          end

          button get_image("#{ROOT_PATH}/media/icons/minus.png"), margin_left: 20 do
            @jukebox.set_volume(@jukebox.volume - 0.1)
          end

          button get_image("#{ROOT_PATH}/media/icons/plus.png") do
            @jukebox.set_volume(@jukebox.volume + 0.1)
          end

          button "Open Music Library", margin_left: 50 do
            if RUBY_PLATFORM.match(/ming|msys|cygwin/)
              system("explorer #{ROOT_PATH}/media/music")
            elsif RUBY_PLATFORM.match(/linux/)
              system("xdg-open #{ROOT_PATH}/media/music")
            else
              # TODO.
            end
          end

          button get_image("#{ROOT_PATH}/media/icons/musicOn.png"), margin_left: 50, tip: "Toggle Sound Effects" do |button|
            boolean = @jukebox.set_sfx(!@jukebox.play_sfx?)

            if boolean
              button.value = get_image("#{ROOT_PATH}/media/icons/musicOn.png")
            else
              button.value = get_image("#{ROOT_PATH}/media/icons/musicOff.png")
            end
          end
        end

        stack width: 1.0 do
          button "Randomizer", width: 1.0, **DANGEROUS_BUTTON do
            unless @clock.active?
              push_state(Randomizer)
            end
          end
        end
      end
    end

    @jukebox = Jukebox.new(@clock)

    @clock_proxy = ClockProxy.new(@clock, @jukebox)

    if REMOTE_CONTROL_MODE
      @server = ClockNet::Server.new(proxy_object: @clock_proxy)
      @server.start
      window.server = @server
    end
  end

  def draw
    @particle_emitters.each(&:draw)
    @clock.draw

    super
  end

  def update
    super
    window.redraw_screen = @redraw_screen

    @clock.update
    @mouse.update
    @jukebox.update
    @particle_emitters.each(&:update)

    if @last_clock_state != @clock.active?
      @particle_emitters.each { |emitter| @clock.active? ? emitter.clock_active! : emitter.clock_inactive! }
    end

    if REMOTE_CONTROL_MODE
      @menu_container.hide
    else
      if @mouse.last_moved < 1.5
        @menu_container.show unless @menu_container.visible?
        window.show_cursor = true
        #@redraw_screen = true
      else
        @menu_container.hide if @menu_container.visible?
        window.show_cursor = false
        #@redraw_screen = false
      end
    end

    if @clock.value != @last_clock_display_value
      @last_clock_display_value = @clock.value
      @redraw_screen = true
    end

    if @last_track_name != @jukebox.current_track
      track_changed(@jukebox.current_track)
    end

    if @last_volume != @jukebox.volume
      volume_changed(@jukebox.volume)
    end

    @last_track_name = @jukebox.current_track
    @last_volume = @jukebox.volume
    @last_clock_state = @clock.active?
  end

  def button_down(id)
    super

    @mouse.button_down(id)
  end

  def track_changed(name)
    @current_song_label.value = File.basename(name)
  end

  def volume_changed(float)
    @current_volume_label.value = "#{(float.round(1) * 100.0).round}%"
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

    def button_down(id)
      case id
      when Gosu::MS_LEFT, Gosu::MS_MIDDLE, Gosu::MS_RIGHT
        @last_moved = Gosu.milliseconds
      end
    end

    def last_moved
      (Gosu.milliseconds - @last_moved) / 1000.0
    end
  end
end
