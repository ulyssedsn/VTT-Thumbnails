# frozen_string_literal: true

require 'fileutils'
require 'securerandom'
require 'byebug'

module Services
  class Ffmpeg
    attr_reader :file_path, :output_path, :opts

    ACCEPTED_FORMATS = %w(.mp4).freeze

    def initialize(file_path, opts = {})
      @file_path = file_path
      @opts = opts
      @output_path = setup_output_dir
    end

    def call
      check_input
      create_mosaic
    end

    private

    def check_input
      return if ACCEPTED_FORMATS.include? File.extname(file_path)

      fail 'not valid input file format'
    end

    def setup_output_dir
      FileUtils.mkdir_p("/tmp/mosaic/#{SecureRandom.hex(10)}")
    end

    def create_mosaic
      system command.to_s
    end

    def command
      "ffmpeg -y -i #{file_path} -filter_complex \"select='not(mod(n,120))'," \
      'scale=128:72,tile=11x11" -frames:v 1 -qscale:v 3 ' \
      "-an #{output_path.first}/mosaic.jpg"
    end
  end
end
