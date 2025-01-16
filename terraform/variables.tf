variable "token" {
    type    = string
    sensitive = true
}
variable "cloud" {
    type    = string
    default = "b1gd6ngnp37vlfjbjhqk"
}

variable "folder" {
    type    = string
    default = "b1gpukb43o9veh81tdjh"
}

variable "image" {
    type    = string
    default = "fd86601pa1f50ta9dffg"
}

variable "username" {
    type    = string
    default = "user"
}

variable "ssh_public_key" {
    type    = string    
}

variable "private_network_a_cidr" {
    type    = string
    default = "10.10.1.0/24"
}

variable "private_network_b_cidr" {
    type    = string
    default = "10.10.2.0/24"
}

variable "private_network_d_cidr" {
    type    = string
    default = "10.10.4.0/24"
}
