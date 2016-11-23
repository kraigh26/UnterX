module ServiceClient
  module Authentication
    class TokenCreator
      def create(auth_context:, secret:, expires_at:)
        raise NotImplementedError.new("create method not implemented")
      end
    end
  end
end
