# frozen_string_literal: true

require 'rails_helper'

describe Ffmpeg do
  include_context 'file paths'

  let(:file_path) { video_mp4 }

  subject { described_class.new(file_path) }

  describe '#initialize' do
    it_behaves_like 'attr_reader', %i(file_path media_info output_path opts)
  end

  describe '#call' do
    context 'when input file is valid' do
      after(:each) do
        FileUtils.rm_rf(subject.output_path.first)
      end

      context 'when it needs to needs a single mosaic' do
        it 'generate one mosaic' do
          output_path = subject.output_path.first
          expect(subject.call).to eq(output_path)
          expect(Dir.children(output_path).count).to eq(1)
          expect(Digest::MD5.hexdigest(Dir.children(output_path).first))
            .to eq('24be784e4cfd6623789978b31c69b22d')
        end
      end

      context 'when it needs to generate multiple mosaics' do
        before do
          stub_const 'Ffmpeg::NB_ROWS', 10
          stub_const 'Ffmpeg::NB_COLUMNS', 10
        end

        it 'generate one mosaic' do
          expect(subject.call).to eq(subject.output_path.first)
          expect(Dir.children(subject.output_path.first).count).to eq(2)
        end
      end
    end

    context 'when input file is not valid' do
      # TODO: When the file has no video
      let(:file_path) { invalid_file }

      it 'raises an error' do
        expect { subject.call }.to raise_exception('not valid input file format')
      end
    end
  end
end
