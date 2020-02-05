class Jukebox
  MUSIC = Dir.glob(ROOT_PATH + "/media/music/*.*").freeze

  def initialize(label)
    @label = label

    @order = MUSIC.shuffle
    @now_playing = ""
    @playing = false
  end

  private def song
    Gosu::Song.current_song
  end

  def update
    if @playing && !song
      next_track
    end

  end

  def play
    if song && song.paused?
      song.play
    else
      return false unless @order.size > 0

      @current_song = @order.first
      Gosu::Song.new(@order.first).play
      @order.rotate!(1)
    end

    @label.value = File.basename(current_track)
    @playing = true
  end

  def pause
    song.pause if song
    @playing = false
  end

  def paused?
    song ? song.paused? : true
  end

  def stop
    song.stop if song
    @label.value = "♫ ♫ ♫"
    @playing = false
  end

  def previous_track
    return false unless @order.size > 0

    @order.rotate!(-1)
    @current_song = @order.first
    Gosu::Song.new(@order.first).play

    @label.value = File.basename(current_track)
    @playing = true
  end

  def next_track
    return false unless @order.size > 0


    @current_song = @order.first
    Gosu::Song.new(@order.first).play
    @order.rotate!(1)

    @label.value = File.basename(current_track)
    @playing = true
  end

  def current_track
    @current_song
  end
end