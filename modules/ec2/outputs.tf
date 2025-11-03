output "front_instance_ids" {
  value = {
    for name, instance in aws_instance.public_instance :
    name => instance.id
    if contains(["vm-front-pub-1", "vm-front-pub-2"], name)
  }
}