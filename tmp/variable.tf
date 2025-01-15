variable "token" {
    type    = string
    sensitive = true
}

variable "image" {
    type    = string
    default = "fd86601pa1f50ta9dffg"
}

variable "cloud" {
    type    = string
    default = ""
}

variable "folder" {
    type    = string
    default = ""
}

variable "username" {
    type    = string
    default = "user"
}

variable "ssh_public_key" {
    type    = string
    default = ""
}

variable "private_network_a_cidr" {
    type    = string
    default = "10.10.1.0/24"
}