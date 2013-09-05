require 'spec_helper'

describe Heybill::CLI do
  context '#providers' do
    let(:output) { capture(:stdout) { subject.providers } }
    it 'returns a list of all providers' do
      Heybill::Provider.stub(:all).and_return(
        2.times.collect { |i| OpenStruct.new({name: "acme#{i}"}) }
      )
      expect(output).to include('Acme0')
      expect(output).to include('Acme1')
    end
  end
end