module MetaCampaignsHelper
  def meta_campaign_status_class(status)
    case status
    when "active"   then "text-emerald-600 dark:text-emerald-400 bg-emerald-500/15"
    when "paused"   then "text-amber-600 dark:text-amber-400 bg-amber-500/15"
    when "draft"    then "text-slate-600 dark:text-slate-400 bg-slate-200 dark:bg-slate-700"
    when "archived" then "text-slate-500 bg-slate-200 dark:bg-slate-700"
    when "deleted"  then "text-red-600 dark:text-red-400 bg-red-500/15"
    else "text-slate-600 dark:text-slate-400 bg-slate-200 dark:bg-slate-700"
    end
  end

  def meta_campaign_status_dot(status)
    case status
    when "active"   then "bg-emerald-400"
    when "paused"   then "bg-amber-400"
    when "draft"    then "bg-slate-400 dark:bg-slate-500"
    when "archived" then "bg-slate-400 dark:bg-slate-500"
    when "deleted"  then "bg-red-400"
    else "bg-slate-400 dark:bg-slate-500"
    end
  end
end
