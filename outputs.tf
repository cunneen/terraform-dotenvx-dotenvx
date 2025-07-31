
# Output the results of running the data source. This is a map of environment
# variable names to their values.
output "env" {
  value = data.external.env.result
  description = <<-EOT
        A map of (decrypted) environment variable names to their (string) values.
		EOT
}
