# General: Environment, Subscription, etc.
general = {
  workload    = "sample"
  environment = "dev"
  region      = "westeurope"
  instance    = "01"
  tags = {
    # recommended
    "WorkloadName"       = "Sample"
    "DataClassification" = "General"             # other options: Non-business, Public, General, Confidential, Highly confidential
    "Criticality"        = "Low"                 # other options: Low, Medium, High, Business unit-critical, Mission-critical
    "BusinessUnit"       = "Shared"              # other options: Finance, Marketing, Product XYZ, Corp, Shared
    "OpsCommitment"      = "Workload operations" # other options: Baseline only, Enhanced baseline, Platform operations, Workload operations
    "OpsTeam"            = "Cloud operations"    # other options: Central IT, Cloud operations, ControlCharts team, MSP-{Managed Service Provider name}
    # optional
    "ApplicationName" = "Sample"
    "Approver"        = "patryk.plonka@gmail.com"
    "BudgetAmount"    = "$50"
    "CostCenter"      = "1"
    "DR"              = "Essential" # other options: Mission-critical, Critical, Essential
    "EndDate"         = "2023-12-31"
    "Env"             = "Dev" # other options: Prod, Dev, QA, Stage, Test
    "Owner"           = "patryk.plonka@gmail.com"
    "Requester"       = "patryk.plonka@gmail.com"
    "ServiceClass"    = "Dev" # other options: Dev, Bronze, Silver, Gold
    "StartDate"       = "2023-01-01"
  }
}

