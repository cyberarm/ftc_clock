class Jukebox
  MUSIC = Dir.glob(ROOT_PATH + "/media/music/*.*").freeze

  if File.exist?(ROOT_PATH + "/media/skystone")
    BEEPS_AND_BOOPS = Dir.glob(ROOT_PATH + "/media/skystone/*.*").freeze
  end

  def initialize(clock, current_track_label, current_volume_label)
    @clock = clock
    @current_track_label = current_track_label
    @current_volume_label = current_volume_label

    @order = MUSIC.shuffle
    @now_playing = ""
    @playing = false
    @song = nil
    @volume = 1.0
    @last_check_time = Gosu.milliseconds

    @last_sfx_time = Gosu.milliseconds
    @sfx_random_interval = generate_sfx_period
    @play_sfx = true

    if defined?(BEEPS_AND_BOOPS)
      BEEPS_AND_BOOPS.each do |beep|
        SAMPLES[beep] = Gosu::Sample.new(beep)
      end
    end
  end

  def update
    return unless Gosu.milliseconds - @last_check_time >= 2000.0
    @last_check_time = Gosu.milliseconds

    @song.volume = @volume if @song

    if @song && !@song.playing? && !@song.paused?
      next_track if @playing
    end

    if @play_sfx && defined?(BEEPS_AND_BOOPS)
      play_sfx
    end
  end

  def play_sfx
    if Gosu.milliseconds - @last_sfx_time >= @sfx_random_interval
      @last_sfx_time = Gosu.milliseconds
      @sfx_random_interval = generate_sfx_period

      SAMPLES[BEEPS_AND_BOOPS.sample].play unless @clock.active?
    end
  end

  def generate_sfx_period
    rand(15..120) * 1000.0
    # rand(5..10) * 1000.0
  end

  def toggle_sfx
    @play_sfx = !@play_sfx
  end

  def play
    if @song && @song.paused?
      @song.play
    else
      return false unless @order.size > 0

      @current_song = @order.first
      @song = Gosu::Song.new(@current_song)
      @song.play
      @order.rotate!(1)
    end

    @current_track_label.value = File.basename(current_track)
    @playing = true
  end

  def pause
    @playing = false
    @song.pause if @song
  end

  def song
    @song
  end

  def stop
    @song.stop if @song
    @current_track_label.value = "♫ ♫ ♫"
    @playing = false
  end

  def previous_track
    return false unless @order.size > 0

    @song.stop if @song
    @order.rotate!(-1)
    @current_song = @order.first
    @song = Gosu::Song.new(@current_song)
    @song.play

    @current_track_label.value = File.basename(current_track)
    @playing = true
  end

  def next_track
    return false unless @order.size > 0

    @song.stop if @song
    @current_song = @order.first
    @song = Gosu::Song.new(@current_song)
    @song.play
    @order.rotate!(1)

    @current_track_label.value = File.basename(current_track)
    @playing = true
  end

  def current_track
    @current_song
  end

  def lower_volume
    @volume -= 0.1
    @volume = @volume.clamp(0.1, 1.0)
    @current_volume_label.value = "#{(@volume * 100).round}%"
  end

  def increase_volume
    @volume += 0.1
    @volume = @volume.clamp(0.1, 1.0)
    @current_volume_label.value = "#{(@volume * 100).round}%"
  end
end
