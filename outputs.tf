output "api_gateway_invoke_url2" {
  description = "The invoke URL for the API Gateway stage."
  value       = module.api_gateway.apigateway_invoke_url2
}

output "cognito_user_pool_id" {
  description = "The ID of the Cognito User Pool."
  value       = module.cognito.cognito_user_pool_id
}

output "cognito_user_pool_client_id" {
  description = "The ID of the Cognito User Pool Client."
  value       = module.cognito.cognito_app_client_id
}

output "apprunner_service_url" {
  description = "Mock Quest quanhub url"
  value       = module.mock_quanum_hub.service_url
}

output "nlb_dns_name" {
  description = "DNS name of nlb"
  value       = module.ecs_processor.nlb_dns_name
}

output "dynamodb_table_name" {
  description = "Name of the dynamodb table"
  value       = module.dynamodb.dynamodb_id
}
