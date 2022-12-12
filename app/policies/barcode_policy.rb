class BarcodePolicy < ApplicationPolicy
  def create?
    user
  end
end
