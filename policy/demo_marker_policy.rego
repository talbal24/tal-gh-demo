package env0

pending[msg] {
  resource := input.plan.resource_changes[_]
  resource.address == "null_resource.pr_plan_demo"
  
  # null_resource recreates on trigger change (delete+create), not update
  actions := resource.change.actions
  actions != ["no-op"]

  before := resource.change.before.triggers.demo_pr_marker
  after  := resource.change.after.triggers.demo_pr_marker
  before != after

  msg := sprintf(
    "PR marker changed from '%v' to '%v' — human approval required before applying.",
    [before, after]
  )
}

allow[msg] {
  count(pending) == 0
  msg := "No PR marker change detected — auto-approved."
}
