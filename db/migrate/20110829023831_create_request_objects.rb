
# https://www.rfc-editor.org/rfc/rfc9101.html
# RFC 9101
# The OAuth 2.0 Authorization Framework: JWT-Secured Authorization Request (JAR)
# August 2021

class CreateRequestObjects < ActiveRecord::Migration[6.1]
  def change
    create_table :request_objects do |t|
      # JSON
      t.text :request_parameters, null:false

      # PAR の場合のみ
      t.datetime :expires_at

      # PAR の場合のみ
      # "urn:ietf:params:oauth:request_uri:" に続ける
      t.string :reference_value, index: {unique: true}
      
      t.timestamps
    end
  end
end
