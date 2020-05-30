
class Connect::Fake < Connect::Base

  def userinfo
    OpenIDConnect::ResponseObject::UserInfo.new(
      name:         'Fake Account',
      email:        'fake@example.com',
      address:      'Shibuya, Tokyo, Japan',
      profile:      'http://example.com/fake',
      locale:       'ja_JP',
      phone_number: '+81 (3) 1234 5678',
      verified: false
    )
  end

  class << self
    def authenticate
      connect = new()
      Account.transaction do
        Account.create!(fake: connect)
        connect.save!
      end # transaction
      
      return connect.account
    end
  end
end
