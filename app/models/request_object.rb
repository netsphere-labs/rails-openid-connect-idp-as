
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

  # `before_save` だと遅い
  before_validation :check
  
  def to_request_object
    OpenIDConnect::RequestObject.decode(
      jwt_string,
      (access_token || authorization).client.secret
    )
  end

  def params
    @params ||= request_parameters ? JSON.parse(request_parameters) : {}
  end
  
private
  # for `before_validation`
  def check
    self.request_parameters = params.to_json
  end
  
end
