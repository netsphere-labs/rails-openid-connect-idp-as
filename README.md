# OpenIDConnectOp Sample

A sample OpenID Connect Provider (OP or IdP) using the `openid_connect` gem. The Authorization Code Flow and the Implicit Flow.

Ruby on Rails 6.1. See https://www.nslabs.jp/digital-identity.rhtml



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
Copyright (c) 2021 Hisashi Horikawa.
