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

      def self.create_from_model(user: nil, community:, secret:, expires_at:)
        role =
          if user.nil?
            nil
          elsif user.has_admin_rights?
            :admin
          else
            :user
          end

        self.new.create(
          auth_context: {
            marketplace_id: community.uuid_object,
            actor_id: user&.uuid_object || UUIDUtils.v0_uuid,
            actor_role: role
          },
          secret: secret,
          expires_at: expires_at
        )
      end
    end
  end
end
