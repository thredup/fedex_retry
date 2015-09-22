require "fedex_tracking_client/version"
require "fedex_tracking_client/no_working_tracking_number_error"
require "bundler"

Bundler.require(:default, ENV['RAILS_ENV'] || :development)

module FedexTrackingClient
  class Tracker
    def initialize(connection_props)
      create_connection_handle(connection_props)
    end

    # Check each tracking number and return the first successful response
    def track(tracking_numbers = [])
      return unless tracking_numbers.any?
      number = tracking_numbers.pop
      resp = @fedex.track(tracking_number: number)
      resp.first if resp && resp.any?
    rescue ::Fedex::RateError
      if tracking_numbers.count.zero?
        raise FedexTrackingClient::NoWorkingTrackingNumberError
      else
        retry
      end
    end

    private
    def create_connection_handle(props)
      @fedex ||= ::Fedex::Shipment.new(key: props[:key],
                                       password: props[:password],
                                       account_number: props[:account_number],
                                       meter: props[:meter],
                                       mode: props[:mode])
    end
  end
end
