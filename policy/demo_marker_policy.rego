package env0

# Require approval when the PR-plan demo marker resource is being changed.
# This fires whenever demo_pr_marker is updated (the null_resource trigger changes).

pending[msg] {
  resource := input.plan.resource_changes[_]
  resource.address == "null_resource.pr_plan_demo"
  resource.change.actions[_] == "update"
  
  before := resource.change.before.triggers.demo_pr_marker
  after  := resource.change.after.triggers.demo_pr_marker
  before != after
  
  msg := sprintf(
    "PR marker changed from '%v' to '%v' — human approval required before applying.",
    [before, after]
  )
}

# Default: allow everything else automatically
allow {
  count(pending) == 0
}
