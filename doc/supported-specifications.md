
# Supported Specifications

<a href="https://qiita.com/TakahikoKawasaki/items/83c47c9830097dba2744">実装者による Financial-grade API (FAPI) 解説</a> を踏まえて、現代的な挙動へのアップデートを行う。

<s>Part 1: Baseline だけでよい。</s>  よくない。Baseline は採用されず、英国オープンバンキングでは FAPI 1.0 Part 2: Advanced だけが採用された。技術的にも両者は差が大きく、わざわざ両方を参照せず, Part 2 のみを参照すればよい。

<blockquote cite="https://openid.net/certification/certification-fapi_op_testing/">
  <p>FAPI 1.0 Advanced Final is an evolution of the FAPI RW draft. The ‘read write’ part was removed from the specification name to avoid confusion, due to many ecosystems choosing to use the more secure ‘read write’ profile for read-only operations.
</blockquote>




## OpenID Connect Discovery 1.0 ✓

 - Issuer discovery  ユーザ識別子のドメインパートのホストに対して、次のような `GET` リクエストを投げると、issuer を返す.
```
   GET /.well-known/webfinger?resource=acct:example@example.com&
                              rel=http://openid.net/specs/connect/1.0/issuer
```
   ユーザ識別子のドメインパートが IdP ホストとは限らない。現在ではほとんど用いられない

 - OpenID Provider Configuration  必須✓
   `<issuer>/.well-known/openid-configuration` を `GET` する




## OpenID Connect Core 1.0

 - No.4 Token Endpoint におけるクライアント認証
   + "client_secret_basic" ✓
   + "client_secret_post" ✓
   + "private_key_jwt",  ●●未了. FAPI はこのサポートが必須. マジか. Entra ID (旧 AzureAD) ぐらいしかサポートする IdP はない.

 - No.5 `"private_key_jwt"` で RSA を用いる場合、キーサイズは 2048bit 以上。

 - No.12 過去に認可された scope よりもリクエストされた scope が多ければ、再度ユーザに認可を求める。
 
   テストのため, Fake Users 画面から、認可した scope を削除できるようにする。●●未了
   
 - クライアントが `openid` スコープを要求した場合, `nonce` パラメータが必須。
   レスポンスの ID Token 内に `nonce` を埋め込む. ✓
   
   The Authorization Code Flow では OPTIONAL, The Implicit Flow, Hybrid Flow では REQUIRED だが、前者でもリクエストに含めるべき。

 - クライアントが `openid` スコープを要求しなかった場合, `state` パラメータが必須。ブラウザ cookie に埋め込むことで、CSRF/XSRF 緩和。
   仕様では RECOMMENDED となっている。 
   ●●テスト未了。同様にレスポンスを不正にして、クライアントの様子を確認。




## Proof Key for Code Exchange by OAuth Public Clients (PKCE, RFC 7636) ✓

 - No.7 PKCE (RFC 7636) with `S256`  実装すみ✓

 - 認可リクエストは明示的に `code_challenge_method=S256` を含めなければならない。

 - discovery に `code_challenge_methods_supported` がある。(RFC 8414) ✓

ほかの IdP:
   + Yahoo!  discovery あり. リクエストは任意
   + Azure AD -- 推奨, SPAの場合は必須. https://learn.microsoft.com/ja-jp/entra/identity-platform/v2-oauth2-auth-code-flow
   + Google Identity -- discovery あり. モバイル/デスクトップアプリのみ? https://developers.google.com/identity/protocols/oauth2/native-app?hl=ja
   + LINE    -- discovery あり.




### The OAuth 2.0 Authorization Framework: JWT-Secured Authorization Request (JAR, RFC 9101)

 - クライアントは, `request` パラメータで署名付きの request object を送付。OpenID Connect Core 1.0 で要求されるパラメータであっても、request object の外側のものは無視。✓

 - AS 側でクライアントの公開鍵を使って署名の検証 ●未了

 - `request_uri` パラメータで request object 参照を送付。これは非常に筋が悪い。次の PAR のみをサポート。




### OAuth 2.0 Pushed Authorization Requests (PAR, RFC 9126)

2021年9月に発行された仕様。

まずクライアントが直接認可サーバ (AS) にリクエストを POST, AS がトークンを発行し, リダイレクトを介したリクエスト時は, `request_uri` パラメータにそのトークンを set.

長い長い年月を経て, OAuth 1.0 (2010年) に還ってきた。Temporary Credentials (Request Token and Secret) の取得からの Resource Owner Authorization URI.

<a href="https://web.archive.org/web/20161004175011/https://hueniverse.com/2012/07/26/oauth-2-0-and-the-road-to-hell/">OAuth 2.0 and the Road to Hell</a>
コメントの一つ: https://alexbilbie.github.io/2012/07/oauth-2-0-and-the-road-to-hell/

OAuth 1.0 は "confidential" client type しかサポートしない。Yes, FAPI も同様に "confidential" client type しかサポートしない。

フロー図がある; https://oauth.jp/blog/2014/06/23/csrf-on-twitter-login/ OAuth 1.0 であっても当然, 実装が下手打つと穴ができる。他方、仕様のとおりに実装したら巨大な穴があく OAuth 2.0 は、仕様に穴がある。


