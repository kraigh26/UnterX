module ServiceClient
  module Middleware
    IDENTITY = ->() {}

    class JwtAuthenticator < MiddlewareBase

      def initialize(disable:, secret:, token_creator:, default_auth_context: IDENTITY)
        @_disabled = disable
        @_secret = secret
        @_default_auth_context = default_auth_context

        if token_creator.is_a?(Authentication::TokenCreator)
          @_token_creator = token_creator
        else
          raise "auth_token_creator needs to be an instance of ServiceAuthTokenCreator. Was: #{token_creator.class.name}"
        end
      end

      def enter(ctx)
        unless @_disabled
          auth_context = ctx[:opts][:auth_context] || @_default_auth_context.call
          token = @_token_creator.create(auth_context: auth_context, secret: @_secret, expires_at: 5.minutes.from_now)
          ctx[:req][:headers]["Authorization"] = "Token #{token}"
        end
        ctx
      end
    end
  end
end
