# modules/eks/variables.tf
variable "vpc_id" {
  description = "The VPC ID where the EKS cluster will be created."
  type        = string
}

variable "subnet_ids" {
  description = "A list of subnet IDs for the EKS cluster."
  type        = list(string)
}

variable "control_plane_subnet_ids" {
  description = "A list of subnet IDs specifically for the EKS control plane."
  type        = list(string)
}
