class Portal::EcommerceStoresController < ApplicationController
  before_action :authenticate_user!

  def index
    @pagy, @ecommerce_stores = pagy(policy_scope(EcommerceStore))
  end

  def show
    @ecommerce_store = EcommerceStore.find(params[:id])
    authorize @ecommerce_store
  end
end
