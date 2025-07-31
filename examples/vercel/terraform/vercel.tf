
provider "vercel" {
  # Or omit this for the api_token to be read
  # from the VERCEL_API_TOKEN environment variable
  api_token = module.dotenvx.env["VERCEL_API_TOKEN"]

  # Optional default team for all resources
  # team = "my-team-id"
}

# create the vercel project
resource "vercel_project" "html-terraform-demo" {
  name = "html-terraform-demo"
}

# define the environment variables in the vercel project, from our dotenvx configurations
resource "vercel_project_environment_variables" "html-terraform-demo" {
  project_id = vercel_project.html-terraform-demo.id

  variables = concat(flatten([
    # each environment name
    for i, envname in local.envs : [
      # each environment variable defined in the module for that environment
      for k, v in module.dotenvx_env[envname].env : {
        key    = k
        value  = v
        target = [envname]
      }
    ]]),
    [
      # each environment variable defined in .env file
      for k, v in module.dotenvx.env : {
        key    = k
        value  = v
        target = local.envs # apply to all environments
      }
    ]
  )
}

data "vercel_project_directory" "html-terraform-demo" {
  path = "../site"
}

resource "vercel_deployment" "html-terraform-demo" {
  project_id  = vercel_project.html-terraform-demo.id
  files       = data.vercel_project_directory.html-terraform-demo.files
  path_prefix = "../site"
  production  = true
}
