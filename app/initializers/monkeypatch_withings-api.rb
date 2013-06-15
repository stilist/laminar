# Taken from:
# https://github.com/audreyvu/diabetes/blob/31e1093df747e4c75cbe34487d84b66c21733393/config/initializers/patches/withings_client.rb
# https://github.com/audreyvu/diabetes/blob/31e1093df747e4c75cbe34487d84b66c21733393/config/initializers/patches/withings_query.rb
#
# No stated license.

module Withings
  module Api

    module Constants
      WEIGHT = 1
      HEIGHT = 4
      FAT_FREE_MASS = 5
      FAT_RATIO = 6
      FAT_MASS = 8
      DIASTOLIC_BLOOD_PRESSURE = 9
      SYSTOLIC_BLOOD_PRESSURE = 10
      HEART_PULSE = 11
      BODY_SCALE = 1
      BLOOD_PRESSURE_MONITOR = 4

      SUBHUB = 'v2/withings/subhub'
    end

    class Client
      include OAuthBase, Withings::Api::Constants

      @client_token     = nil
      @client_secret    = nil
      @consumer_key     = nil
      @consumer_secret  = nil
      @withings_user_id = nil

      @consumer_token   = nil
      @access_token     = nil

      def initialize( arguments )
        ommitted_parameters = [:consumer_key, :consumer_secret, :client_token, :client_secret, :uid] - arguments.keys
        if ommitted_parameters.size > 0
          raise "You must supply the required options: #{ommitted_parameters.join(',')}"
        end

        @client_token = arguments[:client_token]
        @client_secret = arguments[:client_secret]
        @consumer_key = arguments[:consumer_key]
        @consumer_secret = arguments[:consumer_secret]
        @withings_user_id = arguments[:uid]
      end

      def fetch(path, params = {})
        # Added by stilist
        params[:publickey] = ENV["WITHINGS_PUBLIC_KEY"]

        puts path
        response = oauth_http_request!(consumer_token, access_token, { path: path, parameters: params })
        JSON.parse( response.body )
        #0	Operation was successfull
        #2555	An unknown error occured
        #247	The userid is either absent or incorrect
        #250	The provided userid and/or Oauth credentials do not match.
        #293	The callback URL is either absent or incorrect
        #304	The comment is either absent or incorrect
        #305	Too many notifications are already set
      end

      def consumer_token
        @consumer_token ||= ConsumerToken.new( @consumer_key, @consumer_secret )
      end

      def access_token
        @access_token ||= AccessToken.new( @client_token, @client_secret )
      end

      def get_all_data
        fetch( "/measure?action=getmeas&userid=#{@withings_user_id}" )
      end

      def get_all_data_range( start_time, end_time )
        fetch( "/measure?action=getmeas&userid=#{@withings_user_id}&startdate=#{start_time}&enddate=#{end_time}" )
      end

      def get_blood_pressure_data
        fetch( "/measure?action=getmeas&userid=#{@withings_user_id}&devtype=4" )
      end

      def get_blood_pressure_data_updated_since( last_update )
        fetch( "/measure?action=getmeas&userid=#{@withings_user_id}&devtype=4&lastupdate=#{last_update.to_i}" )
      end

      def get_blood_pressure_data_range( start_time, end_time )
        fetch( "/measure?action=getmeas&userid=#{@withings_user_id}&devtype=4&startdate=#{start_time}&enddate=#{end_time}" )
      end

      def get_weight_data
        fetch( "/measure?action=getmeas&userid=#{@withings_user_id}&devtype=1" )
      end

      def get_weight_data_updated_since( last_update )
        fetch( "/measure?action=getmeas&userid=#{@withings_user_id}&devtype=1&lastupdate=#{last_update.to_i}" )
      end

      def get_weight_data_range( start_time, end_time )
        fetch( "/measure?action=getmeas&userid=#{@withings_user_id}&devtype=1&startdate=#{start_time}&enddate=#{end_time}" )
      end

      def old_subscribe_to_feeds
        results = []
        [BODY_SCALE, BLOOD_PRESSURE_MONITOR].each do |device|
          end_point = CGI.escape("https://#{HOST_NAME}/#{SUBHUB}/#{device}")
          comment = URI.encode("Subscribe to Withings data feed: #{device}")
          puts "Subscribing " +  "/notify?action=subscribe&userid=#{@withings_user_id}&callbackurl=#{end_point}&appli=#{device}&comment=#{comment}"
          results << fetch("/notify?action=subscribe&userid=#{@withings_user_id}&callbackurl=#{end_point}&appli=#{device}&comment=#{comment}")
        end
        results
      end

      def list_subscriptions
        fetch( "/notify?action=list&userid=#{@withings_user_id}" )
      end

      def old_get_subscriptions
        results = []
        [BODY_SCALE, BLOOD_PRESSURE_MONITOR].each do |device|
          end_point = CGI.escape("https://#{HOST_NAME}/#{SUBHUB}/#{device}")
          puts "https://#{HOST_NAME}/#{SUBHUB}/#{device}"
          results << fetch("/notify?action=get&userid=#{@withings_user_id}&callbackurl=#{end_point}&appli=#{device}")
        end
        results
      end

      def old_revoke_subscriptions
        results = []
        [BODY_SCALE, BLOOD_PRESSURE_MONITOR].each do |device|
          end_point = CGI.escape("https://#{HOST_NAME}/#{SUBHUB}/#{device}")
          puts "Revoking Subscription " + "/notify?action=revoke&userid=#{@withings_user_id}&callbackurl=#{end_point}&appli=#{device}"
          results << fetch("/notify?action=revoke&userid=#{@withings_user_id}&callbackurl=#{end_point}&appli=#{device}")
        end
        results
      end

      def subscribe_to_feeds
        results = []
        [BODY_SCALE].each do |device|
          end_point = CGI.escape("https://#{HOST_NAME}/#{SUBHUB}/#{device}")
          comment = URI.encode("Subscribe to Withings data feed: #{device}")
          puts "Subscribing " +  "/notify?action=subscribe&userid=#{@withings_user_id}&callbackurl=#{end_point}&appli=#{device}&comment=#{comment}"
          results << fetch("/notify?action=subscribe&userid=#{@withings_user_id}&callbackurl=#{end_point}&appli=#{device}&comment=#{comment}")
        end
        results
      end

      def get_subscriptions
        results = []
        [BODY_SCALE].each do |device|
          end_point = CGI.escape("https://#{HOST_NAME}/#{SUBHUB}/#{device}")
          puts "https://#{HOST_NAME}/#{SUBHUB}/#{device}"
          results << fetch("/notify?action=get&userid=#{@withings_user_id}&callbackurl=#{end_point}&appli=#{device}")
        end
        results
      end

      def revoke_subscriptions
        results = []
        [BODY_SCALE].each do |device|
          end_point = CGI.escape("https://#{HOST_NAME}/#{SUBHUB}/#{device}")
          puts "Revoking Subscription " + "/notify?action=revoke&userid=#{@withings_user_id}&callbackurl=#{end_point}&appli=#{device}"
          results << fetch("/notify?action=revoke&userid=#{@withings_user_id}&callbackurl=#{end_point}&appli=#{device}")
        end
        results
      end

    end
  end
end
