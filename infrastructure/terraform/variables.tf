# Variables de configuración del proyecto

variable "aws_region" {
  description = "Región de AWS"
  type        = string
  default     = "us-east-1"

  validation {
    condition     = can(regex("^us-|^eu-|^ap-", var.aws_region))
    error_message = "Región AWS inválida"
  }
}

variable "environment" {
  description = "Ambiente de deployment"
  type        = string
  default     = "dev"

  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Ambiente debe ser: dev, staging o prod"
  }
}

variable "project" {
  description = "Nombre del proyecto"
  type        = string
  default     = "dinex"

  validation {
    condition     = can(regex("^[a-z][a-z0-9-]*$", var.project))
    error_message = "Nombre debe empezar con letra minúscula"
  }
}

variable "student_name" {
  description = "Nombre del estudiante"
  type        = string
  default     = "Estudiante"
}

# Configuración de API Gateway

variable "api_throttle_rate" {
  description = "Límite de requests por segundo"
  type        = number
  default     = 100

  validation {
    condition     = var.api_throttle_rate >= 1 && var.api_throttle_rate <= 10000
    error_message = "Rate limit debe estar entre 1 y 10000"
  }
}

variable "api_throttle_burst" {
  description = "Límite de burst (picos de tráfico)"
  type        = number
  default     = 50

  validation {
    condition     = var.api_throttle_burst >= 0 && var.api_throttle_burst <= 5000
    error_message = "Burst limit debe estar entre 0 y 5000"
  }
}

# Configuración de CloudWatch

variable "alarm_error_threshold" {
  description = "Número de errores que dispara alarma"
  type        = number
  default     = 5

  validation {
    condition     = var.alarm_error_threshold > 0
    error_message = "Threshold debe ser mayor a 0"
  }
}

variable "additional_tags" {
  description = "Tags adicionales para recursos"
  type        = map(string)
  default     = {}
}
