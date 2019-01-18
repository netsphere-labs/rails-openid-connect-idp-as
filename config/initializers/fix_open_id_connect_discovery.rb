# -*- coding:utf-8 -*-

# For openid_connect v0.9.2, v1.1.3, v1.1.5.
#
# issuer: https://accounts.google.com
# の場合に, http でアクセスしてしまって not found になってしまうのを修正。

# fix bug: lost 'https' scheme
class OpenIDConnect::Discovery::Provider::Config::Resource < SWD::Resource
  # @param uri issuer のURL
  #            例 https://accounts.google.com
  def initialize uri
    @scheme = uri.scheme # add
    @host = uri.host
    @port = uri.port # unless [80, 443].include?(uri.port)
    @path = File.join uri.path, '.well-known/openid-configuration'
    attr_missing!
  end

  def endpoint
    # SWD.url_builder が URI::HTTP になってしまっている
    # 引数で scheme を選択できない。クラスを選ぶ
    case @scheme
    when 'https'
      # [userinfo, host, port, path, query, fragment]
      URI::HTTPS.build [nil, host, port, path, nil, nil]
    when 'http'
      URI::HTTP.build [nil, host, port, path, nil, nil]
    else
      raise URI::BadURIError
    end
  rescue URI::Error => e
    raise SWD::Exception.new(e.message)
  end
end
