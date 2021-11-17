# frozen_string_literal: true

shared_examples_for 'StandardError' do
  it { is_expected.to be_a(StandardError) }
end

shared_examples_for 'raise exception' do |exception|
  it "raises #{exception}" do
    expect { subject }.to raise_exception(exception)
  end
end

shared_examples_for 'raise exception call method' do |exception|
  it "raises #{exception}" do
    expect { call_method }.to raise_exception(exception)
  end
end

shared_examples_for 'raise exception with message' do |exception|
  it "raises #{exception}" do
    expect { subject }.to raise_exception(exception).with_message(exception_message)
  end
end
