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
    return if @config[:accepted_format].include?(File.extname(file_path)) ||
      file_path.starts_with?('http')

    fail 'not valid input file format'
  end

  def setup_output_dir
    FileUtils.mkdir_p("/tmp/mosaic/#{SecureRandom.hex(10)}")
  end

  def create_mosaics
    nb_proceed_mosaic = 0
    ss = 0
    while nb_proceed_mosaic != nb_mosaic_needed
      p command(ss, file_duration).to_s
      system command(ss, file_duration).to_s
      nb_proceed_mosaic += 1
      ss += file_duration
    end

    [output_path.first, @media_info, file_duration, frame_interval_duration]
  end

  def nb_mosaic_needed
    @nb_mosaic_needed ||= ((media_info.duration / 1000.0) / file_duration).ceil
  end

  def command(start_time, trim)
    "ffmpeg  -analyzeduration 100000000 -probesize 100000000 -hide_banner " \
    "-y -ss #{start_time} -t #{trim} -i \"#{file_path}\" -vf \"select=" \
    "not(mod(n\\,#{frame_interval}))," \
    "scale=#{@config[:scale_width]}:#{(@config[:scale_width] / (@media_info.width/@media_info.height.to_f)).floor}," \
    "tile=#{@config[:nb_columns]}x#{@config[:nb_rows]}#{hdr_to_sdr_conversion}\" " \
    "-frames 1 -q:v #{@config[:quality]} -an #{output_path.first}/mosaic_#{start_time.round}.jpeg"
  end

  def file_duration
    @file_duration ||= @config[:nb_columns] * @config[:nb_rows] * frame_interval_duration
  end

  def frame_interval_duration
    frame_interval.to_f / media_info.framerate
  end

  def frame_interval
    @frame_interval ||= (@config[:image_per_sec] * media_info.framerate).floor
  end

  def hdr_to_sdr_conversion
    return '' unless @media_info.hdr_format_compatibility
    p "HDR Detected !"

    ",zscale=transferin=smpte2084:" \
    "#{matrix_in_config}primariesin=bt2020:rangein=limited:" \
    "transfer=linear:npl=100,format=gbrpf32le,zscale=primaries=bt709," \
    "tonemap=tonemap=hable:desat=0,zscale=transfer=bt709:matrix=bt709:" \
    "range=limited,format=yuv420p"
  end

  def matrix_in_config
    return '' unless @media_info.matrix_coefficients

    'matrixin=bt2020nc:'
  end
end
