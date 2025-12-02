# Sistema de Tracking DINEX - Infraestructura Serverless
# Proyecto Individual - Infraestructura como Código

terraform {
  required_version = ">= 1.6.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  # TODO: Implementar backend remoto en S3
  # backend "s3" {
  #   bucket         = "dinex-terraform-state"
  #   key            = "dev/terraform.tfstate"
  #   region         = "us-east-1"
  #   dynamodb_table = "terraform-locks"
  # }
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Project     = "dinex-tracking"
      Environment = var.environment
      ManagedBy   = "Terraform"
      Owner       = var.student_name
      Course      = "InfrastructureAsCode"
    }
  }
}

data "aws_caller_identity" "current" {}

# ============================================================================
# DYNAMODB TABLE
# ============================================================================

resource "aws_dynamodb_table" "tracking" {
  name         = "${var.project}-tracking-${var.environment}"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "tracking_id"

  attribute {
    name = "tracking_id"
    type = "S"
  }

  # Auto-elimina registros después de 30 días
  ttl {
    attribute_name = "expiry"
    enabled        = true
  }

  # Cifrado en reposo
  server_side_encryption {
    enabled = true
  }

  # TODO: Agregar Point-in-time recovery para producción
  # TODO: Considerar Global Secondary Index si se necesita buscar por otros campos

  tags = {
    Name = "${var.project}-tracking-table"
  }
}

# ============================================================================
# IAM ROLE Y POLICIES
# ============================================================================

resource "aws_iam_role" "lambda_role" {
  name = "${var.project}-lambda-role-${var.environment}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "lambda.amazonaws.com"
      }
    }]
  })

  tags = {
    Name = "${var.project}-lambda-role"
  }
}

resource "aws_iam_role_policy" "lambda_policy" {
  name = "${var.project}-lambda-policy"
  role = aws_iam_role.lambda_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "dynamodb:GetItem",
          "dynamodb:PutItem",
          "dynamodb:Query",
          "dynamodb:UpdateItem",
          "dynamodb:Scan"
        ]
        Resource = aws_dynamodb_table.tracking.arn
      },
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "arn:aws:logs:${var.aws_region}:${data.aws_caller_identity.current.account_id}:*"
      },
      {
        Effect   = "Allow"
        Action   = ["sns:Publish"]
        Resource = aws_sns_topic.notifications.arn
      }
    ]
  })
}

# ============================================================================
# LAMBDA FUNCTION
# ============================================================================

resource "aws_lambda_function" "tracking" {
  filename         = "${path.module}/../../application/lambda/tracking/deployment.zip"
  function_name    = "${var.project}-tracking-${var.environment}"
  role             = aws_iam_role.lambda_role.arn
  handler          = "index.handler"
  runtime          = "python3.11"
  source_code_hash = filebase64sha256("${path.module}/../../application/lambda/tracking/deployment.zip")
  timeout          = 10
  memory_size      = 256

  environment {
    variables = {
      TABLE_NAME  = aws_dynamodb_table.tracking.name
      ENVIRONMENT = var.environment
      SNS_TOPIC   = aws_sns_topic.notifications.arn
    }
  }

  tags = {
    Name = "${var.project}-tracking-function"
  }

  depends_on = [
    aws_iam_role_policy.lambda_policy,
    aws_cloudwatch_log_group.tracking
  ]
}

resource "aws_cloudwatch_log_group" "tracking" {
  name              = "/aws/lambda/${var.project}-tracking-${var.environment}"
  retention_in_days = 7

  tags = {
    Name = "${var.project}-tracking-logs"
  }
}

# ============================================================================
# API GATEWAY
# ============================================================================

resource "aws_apigatewayv2_api" "api" {
  name          = "${var.project}-api-${var.environment}"
  protocol_type = "HTTP"

  cors_configuration {
    allow_origins = ["*"]
    allow_methods = ["GET", "POST", "OPTIONS"]
    allow_headers = ["Content-Type", "Authorization"]
    max_age       = 300
  }

  tags = {
    Name = "${var.project}-api"
  }
}

resource "aws_apigatewayv2_stage" "api" {
  api_id      = aws_apigatewayv2_api.api.id
  name        = var.environment
  auto_deploy = true

  access_log_settings {
    destination_arn = aws_cloudwatch_log_group.api_gateway.arn
    format = jsonencode({
      requestId   = "$context.requestId"
      ip          = "$context.identity.sourceIp"
      requestTime = "$context.requestTime"
      httpMethod  = "$context.httpMethod"
      routeKey    = "$context.routeKey"
      status      = "$context.status"
    })
  }

  default_route_settings {
    throttling_burst_limit = var.api_throttle_burst
    throttling_rate_limit  = var.api_throttle_rate
  }

  tags = {
    Name = "${var.project}-api-stage"
  }

  depends_on = [aws_cloudwatch_log_group.api_gateway]
}

resource "aws_cloudwatch_log_group" "api_gateway" {
  name              = "/aws/apigateway/${var.project}-${var.environment}"
  retention_in_days = 7

  tags = {
    Name = "${var.project}-api-gateway-logs"
  }
}

resource "aws_apigatewayv2_integration" "tracking" {
  api_id                 = aws_apigatewayv2_api.api.id
  integration_type       = "AWS_PROXY"
  integration_uri        = aws_lambda_function.tracking.invoke_arn
  integration_method     = "POST"
  payload_format_version = "2.0"
  timeout_milliseconds   = 10000
}

# ============================================================================
# API ROUTES
# ============================================================================

resource "aws_apigatewayv2_route" "get_tracking" {
  api_id    = aws_apigatewayv2_api.api.id
  route_key = "GET /tracking"
  target    = "integrations/${aws_apigatewayv2_integration.tracking.id}"
}

resource "aws_apigatewayv2_route" "post_tracking" {
  api_id    = aws_apigatewayv2_api.api.id
  route_key = "POST /tracking"
  target    = "integrations/${aws_apigatewayv2_integration.tracking.id}"
}

resource "aws_apigatewayv2_route" "health" {
  api_id    = aws_apigatewayv2_api.api.id
  route_key = "GET /health"
  target    = "integrations/${aws_apigatewayv2_integration.tracking.id}"
}

resource "aws_lambda_permission" "api_gateway_tracking" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.tracking.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.api.execution_arn}/*/*"
}

# ============================================================================
# SNS TOPIC
# ============================================================================

resource "aws_sns_topic" "notifications" {
  name         = "${var.project}-notifications-${var.environment}"
  display_name = "DINEX Tracking Notifications"

  tags = {
    Name = "${var.project}-notifications-topic"
  }
}

# TODO: Configurar suscripción de email
# resource "aws_sns_topic_subscription" "email" {
#   topic_arn = aws_sns_topic.notifications.arn
#   protocol  = "email"
#   endpoint  = "tu-email@example.com"
# }

# ============================================================================
# CLOUDWATCH ALARM
# ============================================================================

resource "aws_cloudwatch_metric_alarm" "lambda_errors" {
  alarm_name          = "${var.project}-lambda-errors-${var.environment}"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "Errors"
  namespace           = "AWS/Lambda"
  period              = 300
  statistic           = "Sum"
  threshold           = var.alarm_error_threshold
  alarm_description   = "Alerta cuando Lambda tiene más de ${var.alarm_error_threshold} errores"
  treat_missing_data  = "notBreaching"

  dimensions = {
    FunctionName = aws_lambda_function.tracking.function_name
  }

  alarm_actions = [aws_sns_topic.notifications.arn]

  tags = {
    Name = "${var.project}-lambda-errors-alarm"
  }
}

# TODO: Agregar alarmas adicionales (latencia, throttles)
