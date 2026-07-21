class ServicesController < ApplicationController
  before_action :set_lead

  def cabinet_refacing; end
  def cabinet_repainting; end
  def cabinet_installation; end
  def cabinet_customize_repair; end
  def custom_closets; end
  def countertops; end

  private

  def set_lead
    @lead = Lead.new
  end
end
