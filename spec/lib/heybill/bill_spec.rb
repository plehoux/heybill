require 'spec_helper'

describe Heybill::Bill do
  subject { Heybill::Bill.new('Happy Xmas corp', Date.new(2012,12,25)) } 
  context '#file_name' do
    it 'formats file name' do
      expect(subject.file_name).to eq '2012-12-25 Happy Xmas corp.pdf' 
    end
  end
end