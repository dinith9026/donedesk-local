class StaticPagesController < ApplicationController
  def insurance
    authorize StaticPage.new
  end

  def payroll
    authorize StaticPage.new
  end

  def background_check
    authorize StaticPage.new
  end

  def compliance_coaching
    authorize StaticPage.new
  end

  def hr_coaching
    authorize StaticPage.new
  end

  def health_insurance_coaching
    authorize StaticPage.new
  end

  def terms
    authorize StaticPage.new
  end

  def privacy_policy
    authorize StaticPage.new
  end

  def logout_or_continue
    authorize StaticPage.new
  end
end
