# OpenIDConnectOp Sample

A sample OpenID Connect Provider (OP or IdP) using the `openid_connect` gem.

Ruby on Rails 6.1. See https://www.nslabs.jp/digital-identity.rhtml


## Resources

For this sample:
 * View source on GitHub:   https://github.com/netsphere-labs/openid_connect_sample/

For more information, see readme and wiki for `openid_connect` gem:

* https://github.com/nov/openid_connect


Also of interest, the corresponding sample RP:
 * [OmniAuth2, OpenID Connect sample](https://gitlab.com/netsphere/rails-examples/-/tree/main/omniauth-oidc-rp-sample) the Authorization Code Flow, the Implicit Flow. And, Single Logout (SLO) based on OpenID Connect RP-Initiated Logout 1.0.
 * [OpenID Connect - Implicit Flow Relying Party (RP) sample](https://github.com/netsphere-labs/openid-connect-implicit-flow-rp-sample/)


## Live Example

Nov has this sample running on Heroku: https://connect-op.herokuapp.com

To see it in action right now:

* visit [Nov's Sample RP on Heroku](https://connect-rp.herokuapp.com)
* enter `connect-op.herokuapp.com` in the form
* press "Discover"
* the RP will use the OP to authenticate


## How to Run This Example on Your Machine

### Requirements

 - Ruby on Rails v6.1
 - fb_graph2
 - openid_connect

This sample application does not use "omniauth-openid-connect" gem.


### Localhost

To run this in development mode on your local machine:

* Download (or fork or clone) this repo
* `bundle install` (see "Note" section below if you get "pg"-gem-related problems)

`config/database.yml.sample` ファイルを `config/database.yml` にコピーして、適宜編集。

<pre>
  # su postgres
  $ createdb --owner rails --encoding utf-8 openid-connect-sample_dev
</pre>

<pre>
  $ rails db:migrate
  $ rails db:seed
</pre>

  If you have SQLite installed, `db:create` is not needed.

* modify `config/connect/id_token/issuer.yml` -- change `issuer` to `http://localhost:3000`
```
  $ <kbd>bundle exec rails server -p 3000</kbd>
```

production 環境の場合は, 次のようにする.

  $ RAILS_ENV=production bin/rails assets:precompile

次のようなシェルスクリプトを作る

```
export g_client_id=クライアントid
export g_client_secret=クライアントsecret
RAILS_ENV=production passenger start
```



Facebook
   Copy `config/connect/facebook.yml` from `facebook.yml.sample`
   Set `client_id` and `client_secret`
   
Point your browser at http://localhost:3000

If you download and run [the sample RP server](https://connect-rp.herokuapp.com),
you can have it use this OP (use `localhost:3000` in the "Discover" field).
The two servers on localhost must run on different ports.

Obviously, external servers will not be able to connect to an OP that is running on localhost.


### On a public server

To run it on a public server, the steps are the same as for localhost, except
you will set `issuer` in the issuer.yml config file to your domain name.

Once it's running, you can use [Nov's Sample RP on Heroku](https://connect-rp.herokuapp.com)
to discover and connect to it.


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
