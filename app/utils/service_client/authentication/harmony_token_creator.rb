module ServiceClient
  module Authentication
    class HarmonyTokenCreator < TokenCreator

      AuthContext = EntityUtils.define_builder(
        [:marketplace_id, :uuid, :mandatory],
        [:actor_id, :uuid, :mandatory]
      )

      def create(auth_context:, secret:, expires_at:)
        context = AuthContext.call(auth_context)
        payload = {
          marketplaceId: context[:marketplace_id],
          actorId: context[:actor_id]
        }

        JWTUtils.encode(payload, secret, exp: expires_at)
      end
    end
  end
end
