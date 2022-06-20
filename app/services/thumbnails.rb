# frozen_string_literal: true

class Thumbnails
  attr_reader :video_path

  def initialize(video_path)
    @video_path = video_path
  end

  def call
    mosaics_folder, video_mediainfo = Ffmpeg.new(video_path).call
    WebvttGenerator.new(mosaics_folder, video_mediainfo).call
    "THUMBNAIL WEBVTT Generated in #{mosaics_folder}"
  rescue => e
    raise e
  end
end
