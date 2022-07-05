# frozen_string_literal: true

class WebvttGenerator

  attr_reader :directory, :mosaics, :file_duration, :frame_interval_duration

  def initialize(mosaics_folder, video_mediainfo, file_duration, frame_interval_duration)
    @directory = mosaics_folder
    @mosaics = Dir["#{directory}/*jpeg"].sort_by{ |f| File.mtime(f) }
    @config = Rails.configuration.config
    @file_duration = file_duration
    @total_duration_per_mosaic = @config[:nb_columns] * @config[:nb_rows] * @config[:image_per_sec]
    @scale_height = (@config[:scale_width] / (video_mediainfo.width/video_mediainfo.height.to_f)).floor
    @frame_interval_duration = frame_interval_duration
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
    mosaics.each_with_index do |mosaic, index|
      duration = file_duration * index
      mosaic_end_time = file_duration * (index + 1)
      while duration <= mosaic_end_time
        duration = build_vtt_for_a_mosaic(mosaic, duration)
      end
    end
  end

  def build_vtt_for_a_mosaic(mosaic, duration)
    y_coord = 0
    while y_coord < @scale_height * @config[:nb_rows]
      x_coord = 0
      while x_coord < @config[:scale_width] * @config[:nb_columns]
        save_thumbnail_vtt_text(mosaic, x_coord, y_coord, duration)
        x_coord += @config[:scale_width]
        duration += frame_interval_duration
      end
      y_coord += @scale_height
    end
    duration
  end

  def save_thumbnail_vtt_text(mosaic, x_coord, y_coord, duration)
    times = "#{seconds_to_string(duration)} --> " \
                "#{seconds_to_string(duration + frame_interval_duration)}"
    write_text(times, directory)
    write_text("#{mosaic}#xywh=#{x_coord},#{y_coord},#{@config[:scale_width]},#{@scale_height}",
               directory,
               "\n")
  end

  def secs_to_hms(secs)
    h = (secs / 3600).floor
    m = ((secs - h * 3600) / 60).floor
    s = (secs - h * 3600 - m * 60).round(3)
    [h, m, s]
  end

  def seconds_to_string(seconds)
    return unless seconds
    return seconds if seconds.to_s.include?(':')

    '%02d:%02d:%06.3f' % secs_to_hms(seconds)
  end

  def write_text(value, path, opts = '')
    File.write("#{path}/thumbnails.vtt", "#{value}\n#{opts}", mode: 'a')
  end
end
