# EFS Outputs
output "efs_id" {
  description = "ID of the EFS file system"
  value       = module.efs.file_system_id
}

output "efs_dns_name" {
  description = "DNS name of the EFS file system"
  value       = module.efs.file_system_dns_name
}

output "efs_access_points" {
  description = "Access point IDs for EFS"
  value       = module.efs.access_point_ids
}

output "efs_mount_targets" {
  description = "Mount target IDs for EFS"
  value       = module.efs.mount_target_ids
}

# Mount Commands
output "mount_commands" {
  description = "Commands to mount EFS file system"
  value = {
    basic_mount = "sudo mount -t efs ${module.efs.file_system_id}:/ /mnt/efs"
    tls_mount   = "sudo mount -t efs -o tls ${module.efs.file_system_id}:/ /mnt/efs"
    access_point_mounts = {
      for name, id in module.efs.access_point_ids :
      name => "sudo mount -t efs -o tls,accesspoint=${id} ${module.efs.file_system_id}:/ /mnt/efs-${name}"
    }
  }
}