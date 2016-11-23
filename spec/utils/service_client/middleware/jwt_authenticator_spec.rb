require 'active_support/all'
require 'uuidtools'
require 'possibly'
require 'jwt'

[
  "app/services/result",
  "app/utils/entity_utils",
  "app/utils/uuid_utils",
  "app/utils/jwt_utils",
  "app/utils/hash_utils",
  "app/utils/service_client/client",
  "app/utils/service_client/middleware/middleware_base",
  "app/utils/service_client/middleware/jwt_authenticator",
  "app/utils/service_client/authentication/token_creator",
  "app/utils/service_client/authentication/harmony_token_creator",
].each { |file| require_relative "../../../../#{file}" }

describe ServiceClient::Middleware::JwtAuthenticator do

  SECRET = "secret"

  def req_token(context)
    context[:req][:headers]["Authorization"].split(" ")[1]
  end

  def token_data(token)
    res = JWTUtils.decode(token, SECRET, verify_sub: false)
    if res.success
      res.data
    end
  end

  let(:harmony_token_creator) { ServiceClient::Authentication::HarmonyTokenCreator.new }

  it "encodes an authorization header" do
    authenticator = ServiceClient::Middleware::JwtAuthenticator.new(disable: false, token_creator: harmony_token_creator, secret: SECRET)

    m_id = UUIDUtils.create
    a_id = UUIDUtils.create
    auth_context = {
      marketplace_id: m_id,
      actor_id: a_id
    }

    ctx = authenticator.enter({req: {headers: {}},
                               opts: {auth_context: auth_context}})
    expect(token_data(req_token(ctx))).to eq({"marketplaceId" => m_id.to_s,
                                              "actorId"       => a_id.to_s})
  end

  it "fails with a missing auth context" do
    authenticator = ServiceClient::Middleware::JwtAuthenticator.new(disable: false, token_creator: harmony_token_creator, secret: SECRET)

    ctx = {req: {headers: {}}, opts: {}}
    expect { authenticator.enter(ctx) }.to raise_error(TypeError)
  end

  it "fails with an invalid missing auth context" do
    authenticator = ServiceClient::Middleware::JwtAuthenticator.new(disable: false, token_creator: harmony_token_creator, secret: SECRET)

    auth_context = {
      marketplace_id: 1,
      actor_id: 2
    }
    ctx = {req: {headers: {}}, opts: {auth_context: auth_context}}
    expect { authenticator.enter(ctx) }.to raise_error(ArgumentError)
  end

  it "calls lambda to fetch the auth context" do
    m_id = UUIDUtils.create
    a_id = UUIDUtils.create

    default_auth_context = ->() {
      {
        marketplace_id: m_id,
        actor_id: a_id
      }
    }

    authenticator = ServiceClient::Middleware::JwtAuthenticator.new(
      disable: false, token_creator: harmony_token_creator, secret: SECRET, default_auth_context: default_auth_context)

    ctx = authenticator.enter({req: {headers: {}},
                               opts: {}})
    expect(token_data(req_token(ctx))).to eq({"marketplaceId" => m_id.to_s,
                                              "actorId"       => a_id.to_s})
  end

end
