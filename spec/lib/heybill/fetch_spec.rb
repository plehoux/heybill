require 'spec_helper'

describe Heybill::Fetch do
  let(:fake_provider_class) { Class.new {def self.fetch(options); puts 'whatt' end} } 
  
  before do
    stub_const('Heybill::Providers::Acme', fake_provider_class)
    Heybill::Provider.stub(:all).and_return([OpenStruct.new(name: 'acme')])
    load './lib/heybill/fetch.rb'
  end

  context '#{provider.name}' do
    it 'exists' do
      expect(subject.respond_to? :acme).to be_true
    end
  end

  context '#method_missing' do
    let(:output) { capture(:stdout) { subject.not_acme } }
    it 'alerts user that there is no such provider' do
      Heybill::Provider.stub(:all).and_return([])
      expect(output).to include('No provider called')
    end
  end
end