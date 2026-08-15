module Admin
  class AccountController < BaseController
    def show
    end

    def update
      if current_user.valid_password?(params[:current_password])
        if current_user.update(password: params[:new_password], password_confirmation: params[:new_password_confirmation])
          bypass_sign_in(current_user)
          redirect_to admin_account_path, notice: "Password updated."
        else
          flash.now[:alert] = current_user.errors.full_messages.join(", ")
          render :show, status: :unprocessable_entity
        end
      else
        flash.now[:alert] = "Current password is incorrect."
        render :show, status: :unprocessable_entity
      end
    end
  end
end
