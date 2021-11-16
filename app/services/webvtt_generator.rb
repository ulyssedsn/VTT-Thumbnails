# frozen_string_literal: true

class WebvttGenerator
  IMAGE_PER_SEC = 5
  NB_ROWS = 15
  NB_COLUMNS = 15
  SCALE_WIDTH = 128
  SCALE_HEIGHT = 72
  TOTAL_DURATION_PER_MOSAIC = NB_COLUMNS * NB_ROWS * IMAGE_PER_SEC

  attr_reader :directory, :mosaics

  def initialize(mosaics_folder)
    @directory = mosaics_folder
    @mosaics = Dir["#{directory}/*jpg"].sort
  end

  def call
    initiate_webvtt_file
    build_vtt
  end

  private

  def initiate_webvtt_file
    File.write("#{directory}/thumbnails.vtt", "WEBVTT\n\n")
  end

  def build_vtt
    mosaics.each do |mosaic|
      duration = mosaic_duration(mosaic)
      mosaic_end_time = TOTAL_DURATION_PER_MOSAIC + duration
      while duration != mosaic_end_time
        duration = build_vtt_for_a_mosaic(mosaic, duration)
      end
    end
  end

  def build_vtt_for_a_mosaic(mosaic, duration)
    y_coord = 0
    while y_coord < SCALE_HEIGHT * NB_ROWS
      x_coord = 0
      while x_coord < SCALE_WIDTH * NB_COLUMNS
        save_thumbnail_vtt_text(mosaic, x_coord, y_coord, duration)
        x_coord += SCALE_WIDTH
        duration += IMAGE_PER_SEC
      end
      y_coord += SCALE_HEIGHT
    end
    duration
  end

  def save_thumbnail_vtt_text(mosaic, x_coord, y_coord, duration)
    times = "#{seconds_to_timecode(duration)} --> " \
                "#{seconds_to_timecode(duration + IMAGE_PER_SEC)}"
    write_text(times, directory)
    write_text("#{mosaic}#xywh=#{x_coord},#{y_coord},#{SCALE_WIDTH},#{SCALE_HEIGHT}",
               directory,
               "\n")
  end

  def seconds_to_timecode(seconds)
    [seconds / 3600, seconds / 60 % 60, seconds % 60].map do |t|
      t.to_s.rjust(2, '0')
    end.join(':')
  end

  def write_text(value, path, opts = '')
    File.write("#{path}/thumbnails.vtt", "#{value}\n#{opts}", mode: 'a')
  end

  def mosaic_duration(mosaic)
    File.basename(mosaic, '.*').split('_')[1].to_i
  end
end
