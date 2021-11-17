# frozen_string_literal: true

shared_examples_for 'attr_accessor' do |attribute_name|
  it_behaves_like 'attr_reader', attribute_name
  it_behaves_like 'attr_writer', attribute_name
end

shared_examples_for 'attr_reader' do |attribute_names|
  it "responds to #{attribute_names}" do
    Array(attribute_names).each do |attribute_name|
      expect(subject).to respond_to attribute_name.to_sym
    end
  end
end

shared_examples_for 'attr_writer' do |attribute_names|
  it "responds to #{attribute_names}=" do
    Array(attribute_names).each do |attribute_name|
      expect(subject).to respond_to "#{attribute_name}=".to_sym
    end
  end
end
