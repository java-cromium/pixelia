class Admin::EcommerceStoresController < Admin::BaseController
  before_action :set_store, only: [:show, :edit, :update, :destroy]

  def index
    @pagy, @stores = pagy(ActsAsTenant.without_tenant { EcommerceStore.includes(:project, project: :client).order(:platform) })
  end

  def show
  end

  def new
    @store = EcommerceStore.new
  end

  def create
    ActsAsTenant.without_tenant do
      @store = EcommerceStore.new(store_params)
      if @store.save
        redirect_to admin_ecommerce_store_path(@store), notice: "Store created successfully."
      else
        render :new, status: :unprocessable_entity
      end
    end
  end

  def edit
  end

  def update
    filtered = store_params
    filtered = filtered.except(:api_key) if filtered[:api_key].blank?
    filtered = filtered.except(:api_secret) if filtered[:api_secret].blank?

    if @store.update(filtered)
      redirect_to admin_ecommerce_store_path(@store), notice: "Store updated successfully."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @store.destroy
    redirect_to admin_ecommerce_stores_path, notice: "Store deleted."
  end

  private

  def set_store
    ActsAsTenant.without_tenant do
      @store = EcommerceStore.find(params[:id])
    end
  end

  def store_params
    params.require(:ecommerce_store).permit(:project_id, :client_id, :platform, :store_url, :api_key, :api_secret)
  end
end
