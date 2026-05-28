class Portal::BillingController < Portal::BaseController
  def show
    @subscription = @account.pay_customers&.first&.subscriptions&.active&.first
    @charges = @account.pay_customers&.first&.charges&.order(created_at: :desc)&.limit(10) || []
  end

  def checkout
    plan = params[:plan]
    price_id = Account::PLAN_PRICES[plan]

    unless price_id
      redirect_to portal_billing_path, alert: "Invalid plan selected."
      return
    end

    pay_customer = @account.set_payment_processor(:stripe)

    checkout_session = pay_customer.checkout(
      mode: "subscription",
      line_items: [{ price: price_id, quantity: 1 }],
      success_url: portal_billing_success_url(plan: plan),
      cancel_url: portal_billing_url
    )

    redirect_to checkout_session.url, allow_other_host: true, status: :see_other
  end

  def success
    plan = params[:plan]
    if plan.present? && Account::PLANS.include?(plan)
      @account.update!(plan: plan, subscription_status: "active")
    end

    redirect_to portal_billing_path, notice: "Subscription activated! Welcome to #{plan&.capitalize}."
  end

  def portal
    pay_customer = @account.set_payment_processor(:stripe)
    session = pay_customer.billing_portal(return_url: portal_billing_url)
    redirect_to session.url, allow_other_host: true, status: :see_other
  end
end
