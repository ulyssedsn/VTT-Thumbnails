# frozen_string_literal: true


module Media
  class Info
    attr_reader :info

    def initialize(file_path)
      @info = MediaInfo.from(file_path)
    end

    def duration
      @duration ||= info.video.duration / 1_000
    end

    def frame_rate
      @frame_rate ||= info.video.framerate.to_i
    end
  end
end
