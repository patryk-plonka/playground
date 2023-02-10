variable "general" {
  type = object({
    workload    = string
    environment = string
    region      = string
    instance    = string
    tags        = map(string)
  })
}
