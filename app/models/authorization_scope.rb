# -*- coding:utf-8 -*-

# 中間テーブル
class AuthorizationScope < ApplicationRecord
  belongs_to :authorization
  belongs_to :scope

  validates :authorization, presence: true
  validates :scope,         presence: true
end
