# frozen_string_literal: true

module Services
  class Ffmpeg
    attr_reader :file_path, :media_info, :output_path, :opts

    ACCEPTED_FORMATS = %w(.mp4).freeze
    IMAGE_PER_SEC = 5
    NB_ROWS = 15
    NB_COLUMNS = 15

    def initialize(file_path, opts = {})
      @file_path = file_path
      @media_info = Services::Media::Info.new(file_path)
      @opts = opts
      @output_path = setup_output_dir
    end

    def call
      check_input
      create_mosaics
    end

    private

    def check_input
      return if ACCEPTED_FORMATS.include? File.extname(file_path)

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
        t = t > media_info.duration ? media_info.duration : t

        system command(ss, t).to_s
        nb_proceed_mosaic += 1
        ss = t
        t += total_duration_per_mosaic
      end
    end

    def mosaic_values
      total_duration_per_mosaic = NB_COLUMNS * NB_ROWS * IMAGE_PER_SEC
      nb_mosaic_needed = (media_info.duration / total_duration_per_mosaic).ceil
      [total_duration_per_mosaic, nb_mosaic_needed]
    end

    def command(start_time, trim)
      "ffmpeg -y -skip_frame nokey -i #{file_path} -vf \"select=" \
      "'between(t,#{start_time},#{trim})'," \
      "setpts=#{media_info.framerate * IMAGE_PER_SEC}," \
      "scale=128:72,tile=#{NB_COLUMNS}x#{NB_ROWS}\" -frames:v 1 -qscale:v 3 " \
      "-an #{output_path.first}/mosaic_#{start_time}.jpg"
    end
  end
end
