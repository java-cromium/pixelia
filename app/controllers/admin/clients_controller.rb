class Admin::ClientsController < Admin::BaseController
  before_action :set_client, only: [:show, :edit, :update, :destroy]

  def index
    @pagy, @clients = pagy(policy_scope(Client).order(:name))
    authorize Client
  end

  def show
    authorize @client
    @projects = ActsAsTenant.without_tenant { @client.projects }
    @users = @client.users
  end

  def new
    @client = Client.new
    authorize @client
  end

  def create
    @client = Client.new(client_params)
    authorize @client
    if @client.save
      redirect_to admin_client_path(@client), notice: "Client created successfully."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    authorize @client
  end

  def update
    authorize @client
    if @client.update(client_params)
      redirect_to admin_client_path(@client), notice: "Client updated successfully."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    authorize @client
    @client.destroy
    redirect_to admin_clients_path, notice: "Client deleted."
  end

  private

  def set_client
    @client = Client.find(params[:id])
  end

  def client_params
    params.require(:client).permit(:name, :industry, :status)
  end
end
