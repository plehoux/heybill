require 'spec_helper'

describe Heybill::Provider do
  subject { Heybill::Provider.new(from: 'june 2012', to: 'april 2013', save_to: '~/') }

  context '#initialize' do
    it 'initializes @to, @from & @save_to with good type' do
      expect(subject.instance_variable_get :@to).to      be_an_instance_of Date
      expect(subject.instance_variable_get :@from).to    be_an_instance_of Date
      expect(subject.instance_variable_get :@save_to).to be_an_instance_of Pathname
    end
  end

  context '#fetch' do
    let(:output) { capture(:stdout) { subject.fetch } }
    it 'does not output step info if it is a question' do
      subject.class.ask(:email) { true }
      expect(output).to_not include 'Email...'
    end

    it 'outputs step info if it is not a question' do
      subject.class.log_in { true }
      expect(output).to include 'Log in...'
    end

    it 'outputs a failed message if step block returns false' do
      subject.class.log_in { false }
      expect(output).to include 'There was a problem'
    end

    it 'does not outputs a failed message if step block returns true' do
      subject.class.log_in { true }
      expect(output).to_not include 'There was a problem'
    end
  end

  describe 'class methods' do
    subject { Heybill::Provider }

    context '.ask' do
      it 'creates an ask_* instance method' do
        subject.ask(:username)
        expect(subject.method_defined? :ask_username).to be_true
      end
    end

    context '.log_in' do
      it 'creates a log_in instance method' do
        subject.log_in
        expect(subject.method_defined? :log_in).to be_true
      end
    end

    context '.fetch_bills' do
      it 'creates a fetch_bills instance method' do
        subject.fetch_bills
        expect(subject.method_defined? :fetch_bills).to be_true
      end
    end

    context '.steps' do
      it 'returns @steps class instance variable' do
        subject.instance_variable_set(:@steps, [1,2])
        expect(subject.steps).to eq [1,2]
      end
    end

    context '.instance_define_method' do
      it 'pushes name argument in class instance variable @steps' do
        subject.instance_define_method(:ask_email)
        subject.instance_define_method(:ask_username)
        expect(subject.instance_variable_get :@steps).to include :ask_email
        expect(subject.instance_variable_get :@steps).to include :ask_username
      end

      it 'creates an instance method' do
        subject.instance_define_method(:ask_username)
        expect(subject.method_defined? :ask_username).to be_true
      end
    end

    context '.all' do
      it 'returns an array of providers' do
        Dir.stub(:[]).and_return(['./acme1.rb','./acme2.rb'])
        expect(subject.all.length).to be 2
        expect(subject.all.first.name).to eq 'acme1'
        expect(subject.all.first.path).to eq './acme1.rb'
        expect(subject.all.last.name).to eq 'acme2'
        expect(subject.all.last.path).to eq './acme2.rb'
      end
    end
  end
end