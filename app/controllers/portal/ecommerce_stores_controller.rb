class Portal::EcommerceStoresController < Portal::BaseController
  def index
    @pagy, @ecommerce_stores = pagy(policy_scope(EcommerceStore))
  end

  def show
    @ecommerce_store = EcommerceStore.find(params[:id])
    authorize @ecommerce_store
  end
end
