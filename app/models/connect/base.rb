
class Connect::Base < ApplicationRecord
  self.abstract_class = true
  belongs_to :account
end
