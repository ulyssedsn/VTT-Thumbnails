# frozen_string_literal: true

class WebvttGenerator

  attr_reader :directory, :mosaics

  def initialize(mosaics_folder, video_mediainfo)
    @directory = mosaics_folder
    @mosaics = Dir["#{directory}/*jpeg"].sort_by{ |f| File.mtime(f) }
    @config = Rails.configuration.config
    @total_duration_per_mosaic = @config[:nb_columns] * @config[:nb_rows] * @config[:image_per_sec]
    @scale_height = (@config[:scale_width] / (video_mediainfo.width/video_mediainfo.height.to_f)).floor
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
      mosaic_end_time = @total_duration_per_mosaic + duration
      while duration != mosaic_end_time
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
        duration += @config[:image_per_sec]
      end
      y_coord += @scale_height
    end
    duration
  end

  def save_thumbnail_vtt_text(mosaic, x_coord, y_coord, duration)
    times = "#{seconds_to_timecode(duration)} --> " \
                "#{seconds_to_timecode(duration + @config[:image_per_sec])}"
    write_text(times, directory)
    write_text("#{mosaic}#xywh=#{x_coord},#{y_coord},#{@config[:scale_width]},#{@scale_height}",
               directory,
               "\n")
  end

  def seconds_to_timecode(seconds)
    [(seconds / 3600).floor, (seconds / 60 % 60).floor, seconds % 60].map do |t|
      t.to_s.rjust(2, '0')
    end.join(':').concat(("%.3f" % (seconds-seconds.to_i))[1..-1])
  end

  def write_text(value, path, opts = '')
    File.write("#{path}/thumbnails.vtt", "#{value}\n#{opts}", mode: 'a')
  end

  def mosaic_duration(mosaic)
    File.basename(mosaic, '.*').split('_')[1].to_i
  end
end
