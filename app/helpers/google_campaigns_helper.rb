module GoogleCampaignsHelper
  def campaign_status_class(status)
    case status
    when "enabled" then "text-emerald-400"
    when "paused"  then "text-amber-400"
    when "draft"   then "text-cyan-400"
    when "removed" then "text-red-400"
    else "text-slate-400"
    end
  end

  def campaign_status_dot(status)
    case status
    when "enabled" then "bg-emerald-400"
    when "paused"  then "bg-amber-400"
    when "draft"   then "bg-cyan-400"
    when "removed" then "bg-red-400"
    else "bg-slate-400"
    end
  end
end
