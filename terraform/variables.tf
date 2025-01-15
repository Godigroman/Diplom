variable "token" {
    type    = string
    sensitive = true
}
variable "cloud" {
    type    = string
    default = "b1g97rak33tdsb2b9ifj"
}

variable "folder" {
    type    = string
    default = "b1gd1lp4smdsudqmgljb"
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
    default = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQC28fobe+FGo8iis8L3n9n7anumCkSLfbMml4/cEb+CgvxKrFlUA+D8Ibvcp5lcMhfToQAyHF3CurPi8ajBVWIklt9bPiLSwh6PSv+d6Q9GNQZMevj9va6saT/8z+o47QvyJ794R2Du8EOK5CGt/i+9BtTG1ya8LqUJQW1TL32UISPltMmkzZ5iKnD7POZ1n1bZ9MdlRJrck0XVBNtlMdwxYtv9GXp3x9PgGc3fiOpMDHRx2s4hSmk7ceHNdjRokUTk3WzKcd4Ih5BezEdswFA2kTJkN7mHumanJOEshI5m6eo++WixJ1sxQzqoJ5r7jni1ZNf9O2OOYhaVH0M+B/qhg+oe8kXhPWDwpy7OVj/tSrzspKEPMG/MpaSLh91BmcGWUSfBx6Z0rzSMBWxnBPUg6ZDibp2k/o6sVUgzsXSCjI+6O+7Oe0BY2Yd4CzYWR/ChFSxG2jyocpYDKKjnX9aW4u2oArxd/+PqoBVv1unHhOr/YgTPi0R8KKf50/e9ZWc="
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
