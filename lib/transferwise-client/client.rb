module TransferwiseClient
  # Create quote
  class Client
    def self.connect(auth_key)
      http_request = HttpRequest.new(auth_key)
      profile_request = ProfileRequest.new
      http_response = http_request.send_get_request(profile_request)
      profile_response = Response.new(http_response).response
      raise 'Cannot connect' if profile_response.empty?

      TransferwiseClient::Client.new(auth_key, profile_response)
    end

    attr_reader :profiles

    def initialize(auth_key, profiles)
      @profiles = profiles
      @http_request = HttpRequest.new(auth_key)
    end

    def create_account(profile_id, currency, account_holder_name, type, details)
      account_request = AccountRequest.new(profile_id, currency, account_holder_name, type, details)
      return nil unless account_request.valid?

      transferwise_response = @http_request.send_request(account_request)
      Account.new(Response.new(transferwise_response).response.to_h)
    end

    def create_quote(profile_id, source, target, target_amount)
      quote_request = QuoteRequest.new(profile_id, source, target, target_amount)
      return nil unless quote_request.valid?

      transferwise_response = @http_request.send_request(quote_request)
      Quote.new(Response.new(transferwise_response).response.to_h)
    end

    def create_transfer(quote_id, target_account_id, customer_transaction_id, reference)
      transfer_request = TransferRequest.new(quote_id, target_account_id, customer_transaction_id,
                                             reference)
      return nil unless transfer_request.valid?

      transferwise_response = @http_request.send_request(transfer_request)
      Transfer.new(Response.new(transferwise_response).response.to_h)
    end

    def fund(transfer_id)
      http_response = @http_request.fund_transfer(transfer_id)
      puts http_response.body
      Response.new(http_response).response
    end
  end
end