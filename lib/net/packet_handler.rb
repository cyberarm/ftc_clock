class ClockNet
  class PacketHandler
    TAG = "ClockNet|PacketHandler"
    def initialize(host_is_a_connection: false, proxy_object:)
      @host_is_a_connection = host_is_a_connection
      @proxy_object = proxy_object
    end

    def handle(message)
      packet = Packet.from_stream(message)

      if packet
        log.i(TAG, "Received packet of type: #{packet.type}")
        hand_off(packet)
      else
        log.d(TAG, "Rejected raw packet: #{message}")
      end
    end

    def hand_off(packet)
      case packet.type
      when :handshake
        handle_handshake(packet)
      when :heartbeat
        handle_heartbeat(packet)
      when :error
        handle_error(packet)

      when :start_clock
        handle_start_clock(packet)
      when :abort_clock
        handle_abort_clock(packet)
      when :get_clock_title
        handle_get_clock_title(packet)
      when :set_clock_title
        handle_set_clock_title(packet)
      else
        log.d(TAG, "No hand off available for packet type: #{packet.type}")
      end
    end

    def handle_handshake(packet)
      if @host_is_a_connection
      end
    end

    # TODO: Reset socket timeout
    def handle_heartbeat(packet)
    end

    # TODO: Handle errors
    def handle_error(packet)
      title, message = packet.body.split(Packet::PROTOCOL_SEPERATOR, 2)
      log.e(TAG, "Remote error: #{title}: #{message}")
    end

    def handle_start_clock(packet)
      unless @host_is_a_connection
        @proxy_object.start_clock(packet.body.to_sym)
      end
    end

    def handle_abort_clock(packet)
      unless @host_is_a_connection
        @proxy_object.abort_clock
      end
    end

    def self.packet_handshake(client_uuid)
      Packet.create(Packet::PACKET_TYPES[:handshake], client_uuid)
    end

    def self.packet_heartbeat
      Packet.create(Packet::PACKET_TYPES[:heartbeat], Packet::PROTOCOL_HEARTBEAT)
    end

    def self.packet_error(error_code, message)
      Packet.create(Packet::PACKET_TYPES[:error], error_code.to_s, message.to_s)
    end

    def self.packet_start_clock(mode)
      Packet.create(Packet::PACKET_TYPES[:start_clock], mode.to_s)
    end

    def self.packet_abort_clock
      Packet.create(Packet::PACKET_TYPES[:abort_clock])
    end

    def self.packet_set_clock_title(string)
      Packet.create(Packet::PACKET_TYPES[:set_clock_title], string.to_s)
    end

    def self.packet_get_clock_title
      Packet.create(Packet::PACKET_TYPES[:get_clock_title])
    end

    def self.packet_clock_title(string)
      Packet.create(Packet::PACKET_TYPES[:clock_title], string.to_s)
    end
  end
end
