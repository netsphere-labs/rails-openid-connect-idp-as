# -*- coding:utf-8 -*-

# uninitialized constant #<Class:FbGraph2>::HTTPClient 対策
require 'httpclient'

# undefined method `filter_request' for an instance of FbGraph2::RequestFilter::Authenticator 対策
# rack-oauth2 v2 で `filter_request()` が削除されている。復元する
module Rack
  module OAuth2
    class AccessToken
      class Authenticator
# Callback called in HTTPClient (before sending a request)
        # request:: HTTP::Message
        def filter_request(request)
          @token.authenticate(request)
        end

        # Callback called in HTTPClient (after received a response)
        # response:: HTTP::Message
        # request::  HTTP::Message
        def filter_response(response, request)
          # nothing to do
        end
      end
    end
  end
end


class Connect::Facebook < Connect::Base
  validates :identifier,   presence: true, uniqueness: true
  validates :access_token, presence: true, uniqueness: true

  # @return [FbGraph2::User] ユーザによって許可されたデータ.
  #         email も得られないことがあることに注意. Mandatory にできない。
  # {
  #   id: 略,
  #   raw_attributes: {"name": 略, ...},
  #   access_token: 略,
  #   name: "堀川 久",
  #   email: "hisashi.horikawa@gmail.com",
  #   first_name: "久",
  #   last_name: "堀川",
  #   gender: "male",
  #   birthday: Dateオブジェクト,
  #   location: FbGraph2::Pageオブジェクト,
  #   age_range: FbGraph2::Struct::AgeRangeオブジェクト
  # }
  # 言語が取れていない。
  def me
    # どのようなフィールドがあるかは, グラフAPIを見よ.
    # https://developers.facebook.com/docs/graph-api/
    @me ||= FbGraph2::User.me(self.access_token).fetch(
                fields:[:name, :email, :first_name, :last_name,
                        :location, :languages, :gender, :birthday, :age_range])
  end


  class << self
    def config
      return @config if @config

      # Ruby 3.1 で YAML (psych) 4.0.0 がバンドル。非互換.
      @config = YAML.load_file("#{Rails.root}/config/connect/facebook.yml",
                               aliases: true)[Rails.env].symbolize_keys
      if Rails.env.production?
        @config.merge!(
            client_id:     ENV['fb_client_id'],
            client_secret: ENV['fb_client_secret']
          )
      end
      return @config
    end

    def auth
      FbGraph2::Auth.new config[:client_id], config[:client_secret]
    end

    # Facebook client-side は Implicit Flow なので, 必ずトークンの検証が必要.
    # これを怠ると, token hijacking される。
    # Facebook サイトの文書は, 相互に異なったことが書いてあったり、
    # そもそも検証が必要ということを強調しておらず、ひどい。
    def authenticate(cookies, dummy)
      # fb_graph2 では, from_cookie() 内で, SignedRequest の検証を自動的に行う.
      # client_secret のハッシュ値との比較。
      # => なので, client_secret が必要。
      begin
        _auth_ = auth.from_cookie(cookies)
      rescue FbGraph2::Auth::SignedRequest::VerificationFailed
        # ユーザが [キャンセル] を押した場合
        return [nil, :user_canceled]
      end
      # DEBUG #<FbGraph2::Auth::SignedRequest:0x000xxx @payload_str=...
      print _auth_.inspect 
      connect = find_or_initialize_by(identifier: _auth_.user.identifier)
      print connect.inspect # DEBUG
      connect.access_token = _auth_.access_token.access_token
      if !connect.me.email
        return [nil, :email_not_permitted]
      end
      
      account = connect.account || Account.find_by_email(connect.me.email) ||
                Account.new(email: connect.me.email)
      Account.transaction do
        account.facebook = connect  # Google が先にあった場合
        account.name = connect.me.name
        account.save!
        connect.save!
      end # transaction

      return account
    end
  end

end # class Connect::Facebook
