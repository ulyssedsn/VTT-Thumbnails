# frozen_string_literal: true

class Ffmpeg
  attr_reader :file_path, :media_info, :output_path, :opts

  def initialize(file_path, opts = {})
    @file_path = file_path
    @media_info = MediaInfo.from(file_path).video
    @opts = opts
    @output_path = setup_output_dir
    @config = Rails.configuration.config
  end

  def call
    check_input
    create_mosaics
  end

  private

  def check_input
    return if @config[:accepted_format].include?(File.extname(file_path)) || file_path.starts_with?('http')

    fail 'not valid input file format'
  end

  def setup_output_dir
    FileUtils.mkdir_p("/tmp/mosaic/#{SecureRandom.hex(10)}")
  end

  def create_mosaics
    total_duration_per_mosaic, nb_mosaic_needed = mosaic_values
    nb_proceed_mosaic = 0
    ss = 0
    t = total_duration_per_mosaic

    while nb_proceed_mosaic != nb_mosaic_needed
      t = t > media_info.duration / 1_000 ? media_info.duration / 1_000 : t
      p Time.now
      p command(ss, t).to_s
      system command(ss, t).to_s
      p Time.now

      nb_proceed_mosaic += 1
      ss += t
    end

    [output_path.first, @media_info]
  end

  def mosaic_values
    total_duration_per_mosaic = @config[:nb_columns] * @config[:nb_rows] * @config[:image_per_sec]
    nb_mosaic_needed = ((media_info.duration / 1000.0) / total_duration_per_mosaic).ceil
    [total_duration_per_mosaic, nb_mosaic_needed]
  end

  def command(start_time, trim)
    "ffmpeg  -analyzeduration 100000000 -probesize 100000000 -hide_banner -loglevel error " \
    "-y -ss #{start_time} -t #{trim} -i \"#{file_path}\" -vf \"select=" \
    "not(mod(n\\,#{media_info.framerate.to_i * @config[:image_per_sec]}))," \
    "scale=#{@config[:scale_width]}:-1,tile=#{@config[:nb_columns]}x#{@config[:nb_rows]}\" " \
    "-frames 1 -q:v 10 -an #{output_path.first}/mosaic_#{start_time}.jpeg"
  end
end
