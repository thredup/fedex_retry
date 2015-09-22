require 'spec_helper'

describe FedexTrackingClient do
  subject do 
    FedexTrackingClient::Tracker.new({
      key: '1234',
      password: 'password',
      account_number: 'something',
      meter: '1234',
      mode: 'test'
    }) 
  end

  let(:tracking_numbers) { ["1", "2", "3", "4", "5"] }

  let(:fedex_connection) { instance_double("Fedex::Shipment") }

  before do
    allow(fedex_connection).to receive(:track).and_raise(Fedex::RateError)
    subject.instance_variable_set(:@fedex, fedex_connection)
  end

  it 'tracks packages using any number of tracking numbers' do
    expect(fedex_connection).to receive(:track).at_least(tracking_numbers.count).times
    expect { subject.track(tracking_numbers) }.to raise_error(FedexTrackingClient::NoWorkingTrackingNumberError)
  end
end
