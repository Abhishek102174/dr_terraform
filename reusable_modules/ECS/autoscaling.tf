resource "aws_appautoscaling_target" "autoscaling_target" {
  count              = var.enable_autoscaling ? 1 : 0
  max_capacity       = var.autoscaling_config.max_capacity
  min_capacity       = var.autoscaling_config.min_capacity
  resource_id        = "service/${local.cluster_name}/${aws_ecs_service.service.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}

resource "aws_appautoscaling_policy" "autoscaling_policy" {
  count              = var.enable_autoscaling ? 1 : 0
  name               = "${var.name}-scaling-policy"
  policy_type        = var.autoscaling_policy_type
  service_namespace  = aws_appautoscaling_target.autoscaling_target[0].service_namespace
  resource_id        = aws_appautoscaling_target.autoscaling_target[0].resource_id
  scalable_dimension = aws_appautoscaling_target.autoscaling_target[0].scalable_dimension
  
  target_tracking_scaling_policy_configuration {
    target_value       = var.autoscaling_config.target_value
    scale_in_cooldown  = var.autoscaling_scale_in_cooldown
    scale_out_cooldown = var.autoscaling_scale_out_cooldown
    predefined_metric_specification {
      predefined_metric_type = var.autoscaling_metric_type
    }
  }
}
