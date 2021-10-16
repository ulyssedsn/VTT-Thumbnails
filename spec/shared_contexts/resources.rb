# frozen_string_literal: true

shared_context 'resource file_paths' do
  let(:video_mp4) { Rails.root.join('spec/resources/video_test.mp4').to_s }
  let(:invalid_file) { Rails.root.join('spec/resources/master.m3u8').to_s }
end
