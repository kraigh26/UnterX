# Custom Domain Cookie

# Credits from this code go to Nader (http://stackoverflow.com/questions/4060333/what-does-rails-3-session-store-domain-all-really-do)


# Set the cookie domain to the custom domain if it's present

class ActionDispatch::Cookies::CookieJar
  def self.build(request)
    env = request.env
    key_generator = env[ActionDispatch::Cookies::GENERATOR_KEY]
    options = options_for_env env

    host = request.host
    secure = request.ssl?

    options[:__request] = request

    new(key_generator, host, secure, options).tap do |hash|
      hash.update(request.cookies)
    end
  end

  def initialize(key_generator, host = nil, secure = false, options = {})
    @key_generator = key_generator
    @set_cookies = {}
    @delete_cookies = {}
    @host = host
    @secure = secure
    @options = options
    @cookies = {}
    @committed = false
    @request = options[:__request]
  end

  def update_cookies_from_jar

    ### See this: https://github.com/rails/rails/commit/75a121a2c5470e2bfc7347567a8dc5f89b3812ca

    request_jar = @request.cookie_jar.instance_variable_get(:@cookies)
    set_cookies = request_jar #.reject { |k,_| @delete_cookies.key?(k) }

    @cookies.update set_cookies if set_cookies
  end
end

class CustomDomainCookie
  def initialize(app, default_domain)
    @app = app
    @default_domain = default_domain.split(':').first
  end

  def call(env)
    if env["HTTP_HOST"]
      host = env["HTTP_HOST"].split(':').first
    else
      host = nil
    end
    request = ActionDispatch::Request.new(env)

    cookie_domain = custom_domain?(host) ? ".#{host}" : "#{@default_domain}"

    if true && request.cookie_jar["_sharetribe_session_newnewnew3"]
      binding.pry
      request.cookie_jar["_sharetribe_session_newnewnew4"] = {value: request.cookie_jar["_sharetribe_session_newnewnew3"], domain: cookie_domain}
      request.cookie_jar.delete("_sharetribe_session_newnewnew3", domain: cookie_domain)
    end

    env["rack.session.options"][:domain] = cookie_domain

    return @app.call(env)
  end

  def custom_domain?(host)
    return false if host.nil?
    host !~ /#{@default_domain.sub(/^\./, '')}/i
  end
end
