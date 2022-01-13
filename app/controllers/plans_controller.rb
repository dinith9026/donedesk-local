class PlansController < ApplicationController
  def new
    @account = find_account
    authorize current_account, :new_plan?
    @form = PlanForm.new
  end

  def create
    @account = find_account
    authorize current_account, :new_plan?
    @form = PlanForm.from_params(plan_params)

    ReplaceAccountPlan.call(@form, @account) do
      on(:ok)      { |acc| set_flash_success_and_redirect_to(acc) }
      on(:invalid) { set_flash_error_and_render(:new) }
    end
  end

  private

  def plan_params
    params.require(:plan).permit(:monthly_price, :max_employees)
  end

  def find_account
    FindAccount.new(params[:account_id]).query
  end
end
