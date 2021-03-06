class Token

  def initialize
  	token_server = "http://api.inrix.com/Traffic/Inrix.ashx"
  	vendor_id = ENV["VENDOR_ID"]
  	consumer_id = ENV["CONSUMER_ID"]
  	@token = Rails.cache.fetch(["token", token_server, vendor_id, consumer_id], expires_in: 56.minutes) do
      HTTParty.get("#{token_server}?action=GetSecurityToken&VendorID=#{vendor_id}&ConsumerID=#{consumer_id}")["Inrix"]["AuthResponse"]
    end
  end

  def value
  	@token["AuthToken"]["__content__"]
  end

  def api_server
		@token["ServerPaths"]["ServerPath"][0]["__content__"]
  end

end

