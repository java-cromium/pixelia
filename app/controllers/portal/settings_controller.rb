class Portal::SettingsController < Portal::BaseController
  def show
  end

  def update
    filtered = account_params
    # Don't overwrite existing API key with blank
    filtered.delete(:ai_api_key) if filtered[:ai_api_key].blank?

    if @account.update(filtered)
      redirect_to portal_settings_path, notice: "Settings updated successfully."
    else
      render :show, status: :unprocessable_entity
    end
  end

  private

  def account_params
    params.require(:account).permit(:name, :industry, :ai_provider, :ai_api_key)
  end
end
