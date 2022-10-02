module ApplicationHelper
  def reachability(rec)
    return '<div class="badge badge-warning">不達</div>'.html_safe if rec.unreachable

    '<div class="badge badge-success">有効</div>'.html_safe
  end
end
