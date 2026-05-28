module BillingHelper
  def stripe_publishable_key
    ENV.fetch("STRIPE_PUBLISHABLE_KEY", "pk_test_placeholder")
  end

  def plan_badge_class(plan)
    case plan
    when "growth"  then "bg-indigo-500/15 text-indigo-400"
    when "starter" then "bg-cyan-500/15 text-cyan-400"
    else "bg-slate-700 text-slate-400"
    end
  end

  def subscription_status_class(status)
    case status
    when "active"   then "text-emerald-400"
    when "trialing" then "text-cyan-400"
    when "past_due" then "text-amber-400"
    when "canceled" then "text-red-400"
    else "text-slate-400"
    end
  end
end
