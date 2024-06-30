
# OpenIDConnect OP (IdP) Sample

## What's this?

A sample OpenID Connect provider (OP or IdP) using the `openid_connect` gem. The Authorization Code Flow and the Implicit Flow.

クライアントの開発のため、複数のユーザを切り替えて払い出す。デバッグのため、正常なレスポンスだけでなく、異常なレスポンスも返す。

See https://www.nslabs.jp/digital-identity.rhtml

Ruby on Rails 6.1. 




## サポートする仕様

### OpenID Connect Discovery 1.0 ✓

 - Issuer discovery  ユーザ識別子のドメインパートのホストに対して、次のような `GET` リクエストを投げると、issuer を返す.
```
   GET /.well-known/webfinger?resource=acct:example@example.com&
                              rel=http://openid.net/specs/connect/1.0/issuer
```
   ユーザ識別子のドメインパートが IdP ホストとは限らない。現在ではほとんど用いられない

 - OpenID Provider Configuration
   `<issuer>/.well-known/openid-configuration` を `GET` する


<a href="https://qiita.com/TakahikoKawasaki/items/83c47c9830097dba2744">実装者による Financial-grade API (FAPI) 解説</a> を踏まえて、現代的な挙動へのアップデートを行うこと。Part 1: Baseline だけでよい。


 - No.4 クライアント認証
```json
"token_endpoint_auth_methods_supported": [
    "client_secret_post",
    "private_key_jwt",  ●●未了. このサポートが必須. マジか. Entra ID (旧 AzureAD) ぐらいしかサポートする IdP はないようだが.
    "client_secret_basic"
  ],
```

No.5 `"private_key_jwt"` で RSA を用いる場合、キーサイズは 2048bit 以上。

 - No.7 PKCE (RFC 7636) with `S256`: ●●未了. このサポートが必須. 
   認可リクエストは明示的に `code_challenge_method=S256` を含めなければならない。
   discovery に `code_challenge_methods_supported` がある。(RFC 8414)
   + Yahoo!  discovery あり. リクエストは任意
   + Azure AD -- 推奨, SPAの場合は必須. https://learn.microsoft.com/ja-jp/entra/identity-platform/v2-oauth2-auth-code-flow
   + Google Identity -- discovery あり. モバイル/デスクトップアプリのみ? https://developers.google.com/identity/protocols/oauth2/native-app?hl=ja
   + LINE    -- discovery あり.

●● rack-oauth2 パッケージにサーバ側の PKCE サポートがある。これを使うか

 - No.12 過去に認可された scope よりもリクエストされた scope が多ければ、再度ユーザに認可を求める。
   Fake Users 画面から、認可した scope を削除できるようにする。●●未了
   
 - クライアントが `openid` スコープを要求した場合, `nonce` パラメータが必須。
   レスポンスの ID Token 内に `nonce` を埋め込む.
   The Authorization Code Flow では OPTIONAL, The Implicit Flow では REQUIRED だが、前者でもリクエストに含めるべき。
   ●●未了。わざとレスポンスから `nonce` を抜いて、きちんとクライアントが確認しているかを見れるようにする。

 - クライアントが `openid` スコープを要求しなかった場合, `state` パラメータが必須。ブラウザ cookie に埋め込むことで、CSRF/XSRF 緩和。
   仕様では RECOMMENDED となっている。 
   ●●未了。同様にレスポンスを不正にして、クライアントの様子を確認。




## OpenSSL v3.0 (Fedora 36, CentOS Stream 9)

`openid_connect` gem が依存する `json-jwt` 1.13.0 で次のエラーが発生. <code>OpenSSL::PKey::PKeyError</code> 型. 

<pre>
rsa#set_key= is incompatible with OpenSSL 3.0
</pre>

OpenSSL の仕様変更により ruby/openssl v3.0 のいくつかのメソッドが取り除かれた。とはいえ、Ruby v2.x のときからそれらのメソッドは非推奨 deprecated になっており、しかも OpenSSL v3.0 との組み合わせでは動かない。

関連 issue: <a href="https://github.com/nov/json-jwt/issues/100">Add OpenSSL 3 support · Issue #100 · nov/json-jwt</a>

修正待つしかなさそう。




## Resources

For this sample:
 * View source on GitHub:   https://github.com/netsphere-labs/openid_connect_sample/

For more information, see readme and wiki for `openid_connect` gem:
 * https://github.com/nov/openid_connect/

OAuth 2.0 server library:
 * https://github.com/nov/rack-oauth2/


Also of interest, the corresponding sample RP:
 * [OmniAuth2, OpenID Connect RP sample](https://gitlab.com/netsphere/rails-examples/-/tree/main/omniauth-oidc-rp-sample/) the Authorization Code Flow, the Implicit Flow. And, Single Logout (SLO) based on OpenID Connect RP-Initiated Logout 1.0.

 * [OpenID Connect - Implicit Flow Relying Party (RP) sample](https://github.com/netsphere-labs/openid-connect-implicit-flow-rp-sample/)



## How to Run This Example on Your Machine

### Requirements

 - Ruby on Rails v6.1
 - fb_graph2
 - sorcery
 - openid_connect

This sample application does not use "omniauth-openid-connect" gem.


### Localhost

To run this in development mode on your local machine:

 1. Download (or fork or clone) this repo

 2. `bundle install` (see "Note" section below if you get "pg"-gem-related problems)

 3. `config/database.yml.sample` ファイルを `database.yml` にコピーして、適宜編集。

 4. Setup database
 
<pre>
  # su postgres
  $ createdb --owner rails --encoding utf-8 openid-connect-sample_dev
</pre>

<p><kbd>rake db:migrate</kbd>, <kbd>rake db:seed</kbd> でもよい。

<pre>
  $ rails db:migrate
  $ rails db:seed
</pre>

 5. Copy `config/connect/facebook.yml.sample` to `facebook.yml`. And Google's.

Set `client_id` and `client_secret`
Sorcery による OpenID Connect Login, Facebook Login のサンプルを兼ねている。

  
 6. Modify `config/connect/id_token/issuer.yml` -- change `issuer` value to `http://localhost:3000`

 7. Run!
  
```
  $ bin/yarn
  $ bundle exec rails server -p 3000
```

production 環境の場合は, まず、次のようにしてコンパイルする。

```
  $ RAILS_ENV=production bin/rails assets:precompile
```

次のようなシェルスクリプトを作る

```bash
export g_client_id=クライアントid
export g_client_secret=クライアントsecret
RAILS_ENV=production passenger start
```


### 使い方

 1. Facebook または Google でログインする

Admin user としてログインする。

 2. [Register New Client...] から, RPを登録する。

redirect_uri は複数登録可能。

 3. RP側で, client_id, client_secret を登録する。


To see it in action right now:

* press "Discover"
* the RP will use the OP to authenticate



   
Point your browser at http://localhost:3000


Obviously, external servers will not be able to connect to an OP that is running on localhost.


### On a public server

To run it on a public server, the steps are the same as for localhost, except
you will set `issuer` in the issuer.yml config file to your domain name.



## Notes

* The Gemfile includes gem 'pg' (for PostgreSQL), but you can remove it.
  Nov uses PostgreSQL for his Heroku deployment, but the default DB configs are all SQLite.
* The Facebook link won't work unless you register your app with them.


## Centos OpenSSL Complications

Centos' default OpenSSL package does not include some Elliptic Curve algorithms for patent reasons.
Unfortunately, the gem dependency `json-jwt` calls on one of those excluded algorithms.

If you see `uninitialized constant OpenSSL::PKey::EC` when you try to run the server,
this is your problem. You need to rebuild OpenSSL to include those missing algorithms.

This problem is beyond the scope of this README, but
[this question on StackOverflow](http://stackoverflow.com/questions/32790297/uninitialized-constant-opensslpkeyec-from-ruby-on-centos/32790298#32790298)
may be of help.


## Copyright

Copyright (c) 2011 nov matake. See LICENSE for details.

Copyright (c) 2020-2021,2024 Hisashi Horikawa.
