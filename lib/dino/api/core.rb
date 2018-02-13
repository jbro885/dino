module Dino
  module API
    module Core
      include Helper

      DIVIDERS = [1, 2, 4, 8, 16, 32, 64, 128]

      # CMD = 0
      def set_pin_mode(pin, mode)
        pin, value = convert_pin(pin), mode == :out ? 0 : 1
        write Dino::Message.encode command: 0,
                                   pin: convert_pin(pin),
                                   value: value
      end

      # CMD = 1
      def digital_write(pin,value)
        write Message.encode command: 1, pin: convert_pin(pin), value: value
      end

      # CMD = 2
      def digital_read(pin)
        write Message.encode command: 2, pin: convert_pin(pin)
      end

      # CMD = 3
      def analog_write(pin,value)
        write Message.encode command: 3, pin: convert_pin(pin), value: value
      end

      # CMD = 4
      def analog_read(pin)
        write Message.encode command: 4, pin: convert_pin(pin)
      end

      def set_pullup(pin, pullup)
        pin = convert_pin(pin)
        pullup ? digital_write(pin, @high) : digital_write(pin, @low)
      end

      # CMD = 7
      def set_listener(pin, state=:off, options={})
        mode    = options[:mode]    || :digital
        divider = options[:divider] || 8

        unless [:digital, :analog].include? mode
          raise "Mode must be either digital or analog"
        end
        unless DIVIDERS.include? divider
          raise "Listener divider must be in #{DIVIDERS.inspect}"
        end

        # Create a bit mask for the settings we want to use. Gets sent in value.
        mask = 0
        mask |= 0b10000000 if (state == :on)
        mask |= 0b01000000 if (mode == :analog)
        mask |= Math.log2(divider).to_i

        write Message.encode(command: 7, pin: convert_pin(pin), value: mask)
      end

      # Convenience methods by wrapping set_listener with old defaults.
      def digital_listen(pin, divider=4)
        set_listener(pin, :on, mode: :digital, divider: divider)
      end

      def analog_listen(pin, divider=16)
        set_listener(pin, :on, mode: :analog, divider: divider)
      end

      def stop_listener(pin)
        set_listener(pin, :off)
      end
    end
  end
end
