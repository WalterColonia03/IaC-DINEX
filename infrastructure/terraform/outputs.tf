# Outputs del proyecto

output "api_endpoint" {
  description = "URL del API Gateway"
  value       = "${aws_apigatewayv2_api.api.api_endpoint}/${var.environment}"
}

output "api_usage" {
  description = "Ejemplos de uso"
  value = <<-EOT

  Ejemplos de uso:

  Health check:
  curl "${aws_apigatewayv2_api.api.api_endpoint}/${var.environment}/health"

  Consultar tracking:
  curl "${aws_apigatewayv2_api.api.api_endpoint}/${var.environment}/tracking?tracking_id=TRK001"

  Actualizar tracking:
  curl -X POST ${aws_apigatewayv2_api.api.api_endpoint}/${var.environment}/tracking \
    -H "Content-Type: application/json" \
    -d '{"tracking_id":"TRK001","location":"Lima","status":"IN_TRANSIT"}'

  EOT
}

output "dynamodb_table_name" {
  description = "Nombre de la tabla DynamoDB"
  value       = aws_dynamodb_table.tracking.name
}

output "dynamodb_table_arn" {
  description = "ARN de la tabla DynamoDB"
  value       = aws_dynamodb_table.tracking.arn
}

output "lambda_function_name" {
  description = "Nombre de la función Lambda"
  value       = aws_lambda_function.tracking.function_name
}

output "lambda_arn" {
  description = "ARN de la función Lambda"
  value       = aws_lambda_function.tracking.arn
}

output "sns_topic_arn" {
  description = "ARN del topic SNS"
  value       = aws_sns_topic.notifications.arn
}

output "cloudwatch_logs_url" {
  description = "URL de logs en CloudWatch"
  value       = "https://console.aws.amazon.com/cloudwatch/home?region=${var.aws_region}#logsV2:log-groups/log-group/${replace(aws_cloudwatch_log_group.tracking.name, "/", "$252F")}"
}

output "project_info" {
  description = "Información del proyecto"
  value = {
    project     = var.project
    environment = var.environment
    region      = var.aws_region
    student     = var.student_name
  }
}
