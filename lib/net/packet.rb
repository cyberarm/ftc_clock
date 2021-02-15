class ClockNet
  SYNC_INTERVAL = 250
  HEARTBEAT_INTERVAL = 1_500

  class Packet
    PROTOCOL_VERSION = 1
    PROTOCOL_SEPERATOR = "|"
    PROTOCOL_HEARTBEAT = "heartbeat"

    PACKET_TYPES = {
      handshake: 0,
      heartbeat: 1,
      error: 2,
      shutdown: 3,

      start_clock: 10,
      abort_clock: 11,

      set_clock_title: 20,
      get_clock_title: 21,
      clock_title: 22,

      jukebox_previous_track: 30,
      jukebox_next_track: 31,
      juke_box_stop: 32,
      juke_box_play: 33,
      juke_box_pause: 34,
      juke_box_get_sound_effects: 35,
      juke_box_set_sound_effects: 36,
      juke_box_sound_effects: 37,

      juke_box_set_volume: 37,
      juke_box_get_volume: 38,
      juke_box_volume: 39,
      jukebox_get_song_name: 40,
      jukebox_song_name: 41
    }

    def self.from_stream(message)
      slice = message.split("|", 4)

      if slice.size < 4
        warn "Failed to split packet along first 4 " + PROTOCOL_SEPERATOR + ". Raw return: " + slice.to_s
        return nil
      end

      if slice.first != PROTOCOL_VERSION.to_s
        warn "Incompatible protocol version received, expected: " + PROTOCOL_VERSION.to_s + " got: " + slice.first
        return nil
      end

      unless valid_packet_type?(Integer(slice[1]))
        warn "Unknown packet type detected: #{slice[1]}"
        return nil
      end

      protocol_version = Integer(slice[0])
      type = PACKET_TYPES.key(Integer(slice[1]))
      content_length = Integer(slice[2])
      body = slice[3]

      raise "Type is #{type.inspect} [#{type.class}]" unless type.is_a?(Symbol)

      return Packet.new(protocol_version, type, content_length, body)
    end

    def self.create(packet_type, body)
      Packet.new(PROTOCOL_VERSION, PACKET_TYPES.key(packet_type), body.length, body)
    end

    def self.valid_packet_type?(packet_type)
      PACKET_TYPES.values.find { |t| t == packet_type }
    end

    attr_reader :protocol_version, :type, :content_length, :body
    def initialize(protocol_version, type, content_length, body)
      @protocol_version = protocol_version
      @type = type
      @content_length = content_length
      @body = body
    end

    def encode_header
      string = ""
      string += protocol_version.to_s
      string += PROTOCOL_SEPERATOR
      string += PACKET_TYPES[type].to_s
      string += PROTOCOL_SEPERATOR
      string += content_length.to_s
      string += PROTOCOL_SEPERATOR

      return string
    end

    def valid?
      true
    end

    def to_s
      "#{encode_header}#{body}"
    end
  end
end