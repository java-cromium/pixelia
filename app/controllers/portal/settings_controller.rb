class Portal::SettingsController < Portal::BaseController
  def show
  end

  def update
    if @account.update(account_params)
      redirect_to portal_settings_path, notice: "Settings updated successfully."
    else
      render :show, status: :unprocessable_entity
    end
  end

  private

  def account_params
    params.require(:account).permit(:name, :industry)
  end
end
