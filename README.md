
bugs:
 - <s>response から email が drop する。ユーザの承諾の保存辺りが不味そう</s> fixed.
 
●●未了
 - `registration_endpoint` 動的な登録の再実装
 - `end_session_endpoint` シングルログアウト (SLO) の実装
 - `"refresh_token"` grant type. トークン有効期限の延長.



# Rails OpenID Connect IdP AS (former OpenID Connect OP Sample)

## What's this?

A sample authorization server acting as an OpenID Connect identity provider (OP or IdP) using the `openid_connect` gem. The Authorization Code Flow with PKCE, the Implicit Flow and the Hybrid Flow are supported.

クライアントの開発のため、複数のユーザを切り替えて払い出す。デバッグのため、正常なレスポンスだけでなく、異常なレスポンスも返す。

See https://www.nslabs.jp/digital-identity.rhtml

PKCE に対応。検証に失敗するとクライアントに 次のエラーを返す:
```
invalid_grant :: The provided access grant is invalid, expired, or revoked (e.g. invalid assertion, expired authorization token, bad end-user password credentials, or mismatching authorization code and redirection URI).
```



## How to Run 

### Requirements

 - Ruby on Rails v7.2
 - <s>fb_graph2</s> 廃れた. Koala によるサンプル; https://gitlab.com/netsphere/rails-examples/-/tree/main/rails7/facebook-login/
 - sorcery   ※認証フレームワークは何でもよい。
 - openid_connect

This IdP does not use "omniauth-openid-connect" or "doorkeeper-openid_connect" gem.


### Localhost

To run this in development mode on your local machine:

 1. Download (or fork or clone) this repo

 2. `bundle install` (see "Note" section below if you get "pg"-gem-related problems)

 3. `config/database.yml.sample` ファイルを `database.yml` にコピーして、適宜編集。

 4. Setup database
 
<pre>
  # su postgres
  $ createdb --owner DBユーザ名 --encoding utf-8 openid-connect-sample_dev
</pre>

<pre>
  $ bin/rails db:migrate
  $ bin/rails db:seed
</pre>

 5. Copy `config/connect/facebook.yml.sample` to `facebook.yml`. And Google's.

Set `client_id` and `client_secret`
Sorcery による OpenID Connect Login, Facebook Login のサンプルを兼ねている。

  
 6. Modify `config/connect/id_token/issuer.yml` -- change `issuer` value to `http://localhost:4000`

 7. Run!
  
```
  $ bin/rails assets:precompile
  $ bundle exec rails server -p 3000
```

production 環境の場合は, 次のようにしてコンパイルする。

```
  $ RAILS_ENV=production bin/rails assets:precompile
```

次のようなシェルスクリプトを作る

```bash
export g_client_id=クライアントid
export g_client_secret=クライアントsecret
RAILS_ENV=production passenger start
```




## 使い方

 1. Facebook または Google でログインする

Admin user としてログインする。払い出すユーザは "Fake Users" から確認できる。


 2. [Register New Client...] から, RPを登録する。

`redirect_uri` は複数登録可能。

 3. RP側で, `client_id`, `client_secret` を登録する。

 4. RP 側からログイン可能か確認する。
    この IdP では、払い出すユーザを都度選択するようになっている。




## Copyright

Copyright (c) 2011 nov matake. See `MIT-LICENSE` for details.

Copyright (c) 2020-2021,2024 Hisashi Horikawa.




## Resources

This IdP:
 * View source on GitHub:   https://github.com/netsphere-labs/rails-openid-connect-idp-as/

For more information, see readme and wiki for `openid_connect` gem:
 * https://github.com/nov/openid_connect/

OAuth 2.0 server library:
 * https://github.com/nov/rack-oauth2/

Also of interest, the corresponding sample RP:
 * [Rails OpenID Connect RP Sample](https://github.com/netsphere-labs/rails-openid-connect-rp-sample/) the Authorization Code Flow, the Implicit Flow. And, Single Logout (SLO) based on OpenID Connect RP-Initiated Logout 1.0.





## Topic: OpenSSL v3.0 (Fedora 36, CentOS Stream 9)

`openid_connect` gem が依存する `json-jwt` 1.13.0 で次のエラーが発生. <code>OpenSSL::PKey::PKeyError</code> 型. 

<pre>
<code>rsa#set_key=</code> is incompatible with OpenSSL 3.0
</pre>

OpenSSL の仕様変更により ruby/openssl v3.0 のいくつかのメソッドが取り除かれた。とはいえ、Ruby v2.x のときからそれらのメソッドは非推奨 deprecated になっており、しかも OpenSSL v3.0 との組み合わせでは動かない。

関連 issue: <a href="https://github.com/nov/json-jwt/issues/100">Add OpenSSL 3 support · Issue #100 · nov/json-jwt</a>






####


Obviously, external servers will not be able to connect to an OP that is running on localhost.


### On a public server

To run it on a public server, the steps are the same as for localhost, except
you will set `issuer` in the issuer.yml config file to your domain name.



## Notes

* The Gemfile includes gem 'pg' (for PostgreSQL), but you can remove it.
  Nov uses PostgreSQL for his Heroku deployment, but the default DB configs are all SQLite.
* The Facebook link won't work unless you register your app with them.



