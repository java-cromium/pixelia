class Admin::AccountsController < Admin::BaseController
  before_action :set_account, only: [:show, :edit, :update, :destroy]

  def index
    @pagy, @accounts = pagy(policy_scope(Account).order(:name))
    authorize Account
  end

  def show
    authorize @account
    @users = @account.users
    @stores = ActsAsTenant.without_tenant { @account.ecommerce_stores }
    @sites = @account.sites
  end

  def new
    @account = Account.new
    authorize @account
  end

  def create
    @account = Account.new(account_params)
    authorize @account
    if @account.save
      redirect_to admin_account_path(@account), notice: "Account created successfully."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    authorize @account
  end

  def update
    authorize @account
    if @account.update(account_params)
      redirect_to admin_account_path(@account), notice: "Account updated successfully."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    authorize @account
    @account.destroy
    redirect_to admin_accounts_path, notice: "Account deleted."
  end

  private

  def set_account
    @account = Account.find(params[:id])
  end

  def account_params
    params.require(:account).permit(:name, :industry, :status, :plan, :subscription_status)
  end
end
