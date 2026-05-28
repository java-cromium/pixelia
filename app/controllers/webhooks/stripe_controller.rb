class Webhooks::StripeController < ApplicationController
  skip_before_action :verify_authenticity_token
  skip_before_action :authenticate_user!, raise: false

  def create
    payload = request.body.read
    sig_header = request.env["HTTP_STRIPE_SIGNATURE"]
    endpoint_secret = ENV.fetch("STRIPE_WEBHOOK_SECRET", "whsec_placeholder")

    begin
      event = Stripe::Webhook.construct_event(payload, sig_header, endpoint_secret)
    rescue JSON::ParserError
      head :bad_request and return
    rescue Stripe::SignatureVerificationError
      head :bad_request and return
    end

    case event.type
    when "customer.subscription.created", "customer.subscription.updated"
      handle_subscription_update(event.data.object)
    when "customer.subscription.deleted"
      handle_subscription_deleted(event.data.object)
    when "invoice.payment_failed"
      handle_payment_failed(event.data.object)
    end

    head :ok
  end

  private

  def handle_subscription_update(subscription)
    account = find_account_by_stripe_customer(subscription.customer)
    return unless account

    plan = determine_plan(subscription)
    status = map_stripe_status(subscription.status)

    account.update!(plan: plan, subscription_status: status)
  end

  def handle_subscription_deleted(subscription)
    account = find_account_by_stripe_customer(subscription.customer)
    return unless account

    account.update!(plan: "free", subscription_status: "canceled")
  end

  def handle_payment_failed(invoice)
    account = find_account_by_stripe_customer(invoice.customer)
    return unless account

    account.update!(subscription_status: "past_due")
  end

  def find_account_by_stripe_customer(customer_id)
    Account.find_by(stripe_customer_id: customer_id) ||
      Pay::Customer.find_by(processor: :stripe, processor_id: customer_id)&.owner
  end

  def determine_plan(subscription)
    price_id = subscription.items.data.first&.price&.id
    Account::PLAN_PRICES.key(price_id) || "starter"
  end

  def map_stripe_status(status)
    case status
    when "active" then "active"
    when "trialing" then "trialing"
    when "past_due" then "past_due"
    when "canceled", "unpaid", "incomplete_expired" then "canceled"
    else "active"
    end
  end
end
