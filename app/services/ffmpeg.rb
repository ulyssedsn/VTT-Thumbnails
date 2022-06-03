# frozen_string_literal: true

class Ffmpeg
  attr_reader :file_path, :media_info, :output_path, :opts

  ACCEPTED_FORMATS = %w(.mp4).freeze
  IMAGE_PER_SEC = 15
  NB_ROWS = 15
  NB_COLUMNS = 15
  SCALE_WIDTH = 128
  SCALE_HEIGHT = 72

  def initialize(file_path, opts = {})
    @file_path = file_path
    @media_info = MediaInfo.from(file_path).video
    @opts = opts
    @output_path = setup_output_dir
  end

  def call
    check_input
    create_mosaics
  end

  private

  def check_input
    return if ACCEPTED_FORMATS.include?(File.extname(file_path)) || file_path.starts_with?('http')

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
      ss = t
      t += total_duration_per_mosaic
    end

    output_path.first
  end

  def mosaic_values
    total_duration_per_mosaic = NB_COLUMNS * NB_ROWS * IMAGE_PER_SEC
    nb_mosaic_needed = ((media_info.duration / 1000.0) / total_duration_per_mosaic).ceil
    [total_duration_per_mosaic, nb_mosaic_needed]
  end

  def command(start_time, trim)
    "ffmpeg -y -ss #{start_time} -t #{trim} -i \"#{file_path}\" -vf \"select=" \
    "not(mod(n\\,#{media_info.framerate.to_i * IMAGE_PER_SEC}))," \
    "scale=#{SCALE_WIDTH}:#{SCALE_HEIGHT},tile=#{NB_COLUMNS}x#{NB_ROWS}\" " \
    "-frames 1 -q:v 15 -an #{output_path.first}/mosaic_#{start_time}.webp"
  end
end
