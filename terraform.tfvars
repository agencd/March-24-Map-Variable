security_groups = {
    name_of_sg = "web_security_group"
    description = "Security Group for Web servers"
    ingress = [
        {
            "protocol" = "tcp"
            "to_port" = 22
            "from_port" = 22
            "cidr_blocks" = ["66.30.254.27/32"]
        }
    ]
}