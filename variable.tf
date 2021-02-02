variable "vpc_cidr" {
    default = "10.100.0.0/16"
    description = "vpc cidr"
    type = string
}

variable "subnet_public_cidr" {
  default = "10.100.1.0/24"
}

variable "subnet_private_cidr" {
  default = "10.100.2.0/24"
}

variable "ami_id" {

    default = "ami-047a51fa27710816e"
  
}

variable "lambda_name" {

    default = "promethium"

}
