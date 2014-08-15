module PaypalHelper

  Paypal.sandbox!

  def self.accounts
    {
      mplaceadmin: { username: "", password: "", signature: "" },
      seller: { username: "", password: "", signature: "" }
    }
  end

  def self.build_request(account)
    Paypal::Express::Request.new(account)
  end

  def self.build_set_express_checkout(amount)
    Paypal::Payment::Request.new(
      :action => "Sale",
      :currency_code => "EUR",
      :amount => amount,
      :description => "A Wonderful Used Green Shovel",
      :custom_fields => {
        SOLUTIONTYPE: "Sole", # Don't require paypal login to pay
        LANDINGPAGE: "Billing", # By default, offer credit card fields instead of paypal login page
        REQCONFIRMSHIPPING: 0, # Don't require a confirmed shipping address
        NOSHIPPING: 1 # Don't show shipping address fields in Paypal
      }
    )
  end

  def self.build_payment_authorization
    Paypal::Payment::Request.new(
      :action => "Authorization",
      :billing_type => :MerchantInitiatedBilling,
      :billing_agreement_description => "Marketplace sales commission",
      :custom_fields => {
        REQCONFIRMSHIPPING: 0, # Don't require a confirmed shipping address
        NOSHIPPING: 1 # Don't show shipping address fields in Paypal
      }
    )
  end

  def self.set_express_checkout!(request, payment_request, success, cancel)
    request.setup(payment_request, success, cancel)
  end

  def self.get_checkout_details!(request, token)
    request.details(token)
  end

  def self.do_checkout!(request, token, payer_id, payment_request)
    request.checkout!(token, payer_id, payment_request)
  end


  def self.request_payment!(amount)
    begin
      request = build_request(accounts[:seller])
      payment_request = build_set_express_checkout(amount)
      response = set_express_checkout!(request, payment_request, "http://www.foo.bar/success", "http://www.foo.bar/cancel")
      puts "redirect_uri: #{response.redirect_uri}"
      payment_request
    rescue Paypal::Exception::APIError => e
      puts e.message
      puts e.response
      puts e.response.details
    end
  end


  def self.checkout_payment!(token, payer_id, payment_request)
    begin
      request = build_request(accounts[:seller])
      co_details = get_checkout_details!(request, token)
      puts "Checkout details: "
      puts({payer: co_details.payer, amount: co_details.amount}.to_s)
      do_checkout!(request, token, payer_id, payment_request)
    rescue Paypal::Exception::APIError => e
      puts e.message
      puts e.response
      puts e.response.details
    end
  end

  def self.request_billing_agreement!
    begin
      req = build_request(accounts[:mplaceadmin])
      billing_agreement_req = build_payment_authorization
      response = set_express_checkout!(req, billing_agreement_req, "http://www.fo.bar/success", "http://www.foo.bar/cancel")
      puts "redirect_uri: #{response.redirect_uri}"
    rescue Paypal::Exception::APIError => e
      puts e.message
      puts e.response
      puts e.response.details
    end
  end

  def self.create_billing_agreement!(token)
    begin
      req = build_request(accounts[:mplaceadmin])
      response = req.agree!(token)
      puts "agreement id: #{response.billing_agreement.identifier}"
    rescue Paypal::Exception::APIError => e
      puts e.message
      puts e.response
      puts e.response.details
    end
  end

  def self.charge!(amount, agreement_id)
    begin
      req = build_request(accounts[:mplaceadmin])
      req.charge!(agreement_id, amount, :currency_code => "EUR")
    rescue Paypal::Exception::APIError => e
      puts e.message
      puts e.response
      puts e.response.details
    end
  end


end
