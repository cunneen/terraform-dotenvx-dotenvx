# load the main .env file with dotenvx, for the main environment e.g. vercel API keys etc
module "dotenvx" {
  source         = "../../.."
  env_folderpath = ".."
}

# we'll loop through the vercel env names and pull out the env vars for each one
locals {
  # vercel environment names
  envs = ["development", "preview", "production"]
}

# load .env.* for each specified environment
module "dotenvx_env" {
  for_each       = toset(local.envs)
  source         = "../../.."
  env_filepath   = ".env.${each.value}"
  env_folderpath = ".."
  should_ignore_missing_env_file = false
}
