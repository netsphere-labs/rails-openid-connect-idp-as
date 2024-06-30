# -*- coding:utf-8 -*-

# クライアントリクエストでユーザが認証したとき、何の scope について認可したのか
# Scope が増えたときは再度認可が必要.
class AuthorizationScope < ApplicationRecord
  belongs_to :authorization
  belongs_to :scope

  validates :authorization, presence: true
  validates :scope,         presence: true
end
