# frozen_string_literal: true

module Services
  module Utils
    class TimeConverter
      def seconds_to_timecode(seconds)
        [seconds / 3600, seconds / 60 % 60, seconds % 60].map do |t|
          t.to_s.rjust(2, '0')
        end.join(':')
      end
    end
  end
end
