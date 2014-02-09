class Token
  include HTTParty

  # attr_reader :token # not necessary because i will never call .token on an instance of this class

  def initialize
  	token_server = "http://api.inrix.com/Traffic/Inrix.ashx"

  	vendor_id = ENV["VENDOR_ID"]
  	consumer_id = ENV["CONSUMER_ID"]

  	@token = Rails.cache.fetch(["tokenqwer", token_server, vendor_id, consumer_id], expires_in: 56.minutes) do
        Token.get("#{token_server}?action=GetSecurityToken&VendorID=#{vendor_id}&ConsumerID=#{consumer_id}").parsed_response["Inrix"]["AuthResponse"]
      end
  end

  def value
  	@token["AuthToken"]["__content__"]
  end

  def valid?
  	current_time = Time.now.localtime
  	expire_time = Time.parse(@token["AuthToken"]["expiry"]).localtime

  	if current_time < expire_time
  		return true
  	else
  		return false
  	end
  end

  def api_server
		@token["ServerPaths"]["ServerPath"][0]["__content__"]
  end

  def tiles_server
  	@token["ServerPaths"]["ServerPath"][1]["__content__"]
  end

end

