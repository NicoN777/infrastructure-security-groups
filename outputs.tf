
output "ssh_sg_out" {
  value = aws_security_group.ssh_sg
}


output "internet_facing_elb_sg_out" {
  value = module.internet_facing_elb_sg
}


output "web_servers_sg_out" {
  value = module.web_servers_sg
}