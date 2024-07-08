
# Request Objects をデータベースに保存する必要なくない?
#    -> (1) PAR: RFC 9126 OAuth 2.0 Pushed Authorization Requests
#           の場合は, データベースに保存が必要
#       (2) "claims" リクエストパラメータがある場合。OIDC Section 5.5

# https://www.rfc-editor.org/rfc/rfc9101.html
# RFC 9101
# The OAuth 2.0 Authorization Framework: JWT-Secured Authorization Request (JAR)
# August 2021
#
# JAR は, OpenID Connect Core 1.0 の規定を大幅に変更している。
# 認可リクエストパラメータを署名付き JWT にまとめる。

class RequestObject < ApplicationRecord
  #has_one :access_token_request_object
  #has_one :access_token, through: :access_token_request_object
  #has_one :authorization_request_object
  #has_one :authorization, through: :authorization_request_object
  #has_one :id_token_request_object
  #has_one :id_token, through: :id_token_request_object

  REQUEST_URI_SCHEME = "urn:ietf:params:oauth:request_uri:"

  # `PS256`: RSASSA-PSS + MGF1 のバリエーションで, SHA-256 を使用. RFC 7518
  # `ES256`: NIST 曲線 P-256 および SHA-256 を使⽤した ECDSA. 通常はこれ.
  # RSASSA-PSS, ECDSA は署名の暗号アルゴリズム, マスク生成関数 MGF1
  SIGNING_ALG_VALUES_SUPPORTED = [:PS256, :ES256]
  
  # `before_save` だと遅い
  before_validation :check

  attr_accessor :client
  attr_accessor :params

=begin
  def to_request_object
    OpenIDConnect::RequestObject.decode(
      jwt_string,
      (access_token || authorization).client.secret
    )
  end
=end
  
  
  def self.find_or_build_from_params(params, defaults = {})
    raise TypeError if params.nil?
    
    client = Client.find_by_identifier(params['client_id']) ||
             raise(Rack::OAuth2::Server::Authorize::BadRequest.new('client_id'))
    # 両方は不可
    if !params['request'].blank? && !params['request_uri'].blank?
      raise Rack::OAuth2::Server::Authorize::BadRequest.new("Both of `request` and `request_uri`")
    end
    
    if !params['request'].blank?
      # リクエストオブジェクト外のパラメータは全部無視. JAR section 6.3
      # 署名アルゴリズムは `PS256` もしくは `ES256` のどちらか FAPI 1.0 Part 2, Section 8.6
      # `OpenIDConnect::RequestObject.decode()` メソッドもよくない。alg を制限できない。
      # `params` を差し替え
      params = JSON::JWT.decode(params['request'], client.client_public_keys,
                                SIGNING_ALG_VALUES_SUPPORTED) 
      if params.client_id != client.identifier
        raise(Rack::OAuth2::Server::Authorize::BadRequest)
      end
    elsif !params['request_uri'].blank?
      # ここで `OpenIDConnect::RequestObject.fetch()` を呼び出してはいけない
      # DDoS 攻撃してしまう.
      #  -> かならず PAR <https://www.rfc-editor.org/rfc/rfc9126.html> として
      #     扱わなければならない.
      if params['request_uri'].index(REQUEST_URI_SCHEME) != 0
        raise Rack::OAuth2::Server::Authorize::BadRequest.new('uri scheme')
      end
      ret = find_by_reference_value(
                        params['request_uri'][REQUEST_URI_SCHEME.length .. -1] )
      if !ret || ret.client_id != client.identifier
        raise(Rack::OAuth2::Server::Authorize::BadRequest)
      end
      return ret
    else
      # 伝統的なリクエストパラメータ
    end
    
    ret = RequestObject.new
    ret.client = client
    ret.params = params

    return ret
  end


private
  # for `before_validation`
  def check
    self.request_parameters = params.to_json
  end
  
end
