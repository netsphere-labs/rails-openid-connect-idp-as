# -*- coding:utf-8 -*-

class Connect::Facebook < Connect::Base
  validates :identifier,   presence: true, uniqueness: true
  validates :access_token, presence: true, uniqueness: true

  def me
    @me ||= FbGraph2::User.me(self.access_token).fetch
  end

  def userinfo
    attributes = {
      id:       identifier,
      name:     me.name,
      email:    me.email,
      address:  me.location.try(:name),
      profile:  me.link,
      picture:  me.picture,
      locale:   me.locale,
      verified: me.verified
    }
    attributes[:gender] = me.gender if ['male', 'female'].include?(me.gender)
    OpenIDConnect::ResponseObject::UserInfo.new attributes
  end

  class << self
    def config
      unless @config
        @config = YAML.load_file("#{Rails.root}/config/connect/facebook.yml")[Rails.env].symbolize_keys
        if Rails.env.production?
          @config.merge!(
            client_id:     ENV['fb_client_id'],
            client_secret: ENV['fb_client_secret']
          )
        end
      end
      @config
    end

    def auth
      FbGraph2::Auth.new config[:client_id], config[:client_secret]
    end

    # Facebook client-side は Implicit Flow なので, 必ずトークンの検証が必要.
    # これを怠ると, token hijacking される。
    # Facebook サイトの文書は, 相互に異なったことが書いてあったり、
    # そもそも検証が必要ということを強調しておらず、ひどい。
    def authenticate(cookies)
      # fb_graph2 では, from_cookie() 内で, SignedRequest の検証を自動的に行う.
      # client_secret のハッシュ値との比較。
      # => なので, client_secret が必要。
      _auth_ = auth.from_cookie(cookies)
      print _auth_.inspect # DEBUG
      connect = find_or_initialize_by(identifier: _auth_.user.identifier)
      print connect.inspect # DEBUG
      connect.access_token = _auth_.access_token.access_token
      Account.transaction do 
        connect.account || Account.create!(facebook: connect)
        connect.save!
      end # transaction
      return connect.account
    end
  end

end # class Connect::Facebook
