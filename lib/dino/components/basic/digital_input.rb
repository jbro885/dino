module Dino
  module Components
    module Basic
      class DigitalInput
        include Setup::SinglePin
        include Setup::Input
        include Mixins::Reader
        include Mixins::Poller
        include Mixins::Listener

        def after_initialize(options={})
          super(options)
          _listen
        end

        def _read
          board.digital_read(self.pin)
        end

        def _listen(divider=4)
          divider ||= 4
          board.digital_listen(self.pin, divider)
        end

        def on_high(&block)
          add_callback(:high) do |data|
            block.call(data) if data.to_i == board.high
          end
        end

        def on_low(&block)
          add_callback(:low) do |data|
            block.call(data) if data.to_i == board.low
          end
        end

        def high?; state == board.high end
        def low?;  state == board.low  end
      end
    end
  end
end
