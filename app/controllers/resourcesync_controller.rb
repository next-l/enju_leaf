class ResourcesyncController < ApplicationController
  skip_after_action :verify_authorized

  def capabilitylist
  end

  def resourcelist
  end

  def changelist
  end

  def resourcedump
  end
end
