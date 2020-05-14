
class Connect::Base < ActiveRecord::Base
  self.abstract_class = true
  belongs_to :account
end
