require 'omniauth-oauth2'

module OmniAuth
  module Strategies
    class LinkedIn < OmniAuth::Strategies::OAuth2
      option :name, 'linkedin'

      option :client_options, {
          :site => 'https://api.linkedin.com',
          :authorize_url => 'https://www.linkedin.com/oauth/v2/authorization?response_type=code',
          :token_url => 'https://www.linkedin.com/oauth/v2/accessToken'
      }

      uid { raw_info['id'] }

      info do
        {
            :name => user_name,
            :email => raw_info['emailAddress'],
            :nickname => user_name,
            :first_name => raw_info['firstName'],
            :last_name => raw_info['lastName'],
            :location => raw_info['location'],
            :description => raw_info['headline'],
            :image => raw_info['pictureUrl'],
            :urls => {
                'public_profile' => raw_info['publicProfileUrl']
            }
        }
      end

      extra do
        { 'raw_info' => raw_info }
      end

      def callback_url
        full_host + script_name + callback_path
      end

      def raw_info
        @raw_info ||= access_token.get("/v1/people/~", params: {format: :json, oauth2_access_token: access_token}).parsed
      end

      private

      def user_name
        name = "#{raw_info['firstName']} #{raw_info['lastName']}".strip
        name.empty? ? nil : name
      end
    end
  end
end

OmniAuth.config.add_camelization 'linkedin', 'LinkedIn'
