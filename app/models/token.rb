require 'httparty'

class Token
  include HTTParty

  # attr_reader :token # not necessary because i will never call .token on an instance of this class

  def initialize
  	token_server = "http://api.inrix.com/Traffic/Inrix.ashx"

  	vendor_id = ENV["VENDOR_ID"]
  	consumer_id = ENV["CONSUMER_ID"]

  	@token = Token.get("#{token_server}?action=GetSecurityToken&VendorID=#{vendor_id}&ConsumerID=#{consumer_id}").parsed_response["Inrix"]["AuthResponse"]["AuthToken"]
  	@server_path = Token.get("#{token_server}?action=GetSecurityToken&VendorID=#{vendor_id}&ConsumerID=#{consumer_id}").parsed_response["Inrix"]["AuthResponse"]["ServerPaths"]["ServerPath"]
  end

  def value
  	@token["__content__"]
  end

  def valid?
  	current_time = Time.now.localtime
  	expire_time = Time.parse(@token["expiry"]).localtime

  	if current_time < expire_time
  		return true
  	else
  		return false
  	end
  end

  def api_server
		@server_path[0]["__content__"]
  end

  def tiles_server
  	@server_path[1]["__content__"]
  end

end

