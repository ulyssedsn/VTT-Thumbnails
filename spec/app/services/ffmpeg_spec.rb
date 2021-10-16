# frozen_string_literal: true

require 'rails_helper'

describe Services::Ffmpeg do
  include_context 'resource file_paths'

  let(:file_path) { video_mp4 }

  subject { described_class.new(file_path) }

  describe '#initialize' do
    it_behaves_like 'attr_reader', %i(file_path output_path opts)
  end

  describe '#call' do
    subject { super.call }

    context 'when input file is valid' do

    end

    context 'when input file is not valid' do
      let(:invalid_file) { invalid_file }

      it 'raises an error' do
        expect { subject }.to raise_error('not valid input file format')
      end
    end
  end
end