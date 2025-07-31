# Vercel Example / Tutorial

The dotenvx website has a good (non-terraform) [Vercel deployment][dotenvx vercel] example using the Vercel CLI to create the deployment, and setting a `DOTENV_PRIVATE_KEY_PRODUCTION` environment variable (also via the Vercel CLI).

That approach is perfectly valid, and has its advantages:

* The `DOTENV_PRIVATE_KEY_PRODUCTION` environment variable can be used at other points in the Vercel deployment process to decrypt `*.env.production` properties.
  For example:
  * When Vercel is running the `nextjs build` command.
  * When running server-side functions (i.e. at runtime).

That approach also has its limitations:

* Properties from `.env.*` files are not available to terraform, and so cannot be used to configure terraform resources.
* Requires the Vercel project to already exist.
* Peculiar to Vercel deployments.
* The JS codebase needs to be modified to include the [@dotenvx/dotenvx][@dotenvx/dotenvx] library
  * All references to `process.env` need to be changed to `dotenvx.get()` calls

The approach outlined in this example below can easily be modified for other (non-vercel) multi-environment terraform deployments.

This example builds on the [simple][simple] example to create a vercel deployment using terraform, with:

* The [Vercel terraform][vercel tf] provider
* `preview`, `development` , and `production` Vercel environment variables managed by dotenvx
  * via `.env.preview` , `.env.development` , and `.env.production` files respectively.
  * each `.env.*` file is associated with the Vercel deployment environment of the same name.

## Instructions

1. Create a `terraform/` folder:

    ```bash
    mkdir terraform
    ```

2. Change to the `terraform/` folder:

    ```bash
    cd terraform
    ```

3. From the `terraform/` folder, go through the steps in the [simple][simple] example to create the various `.env.*` files and terraform files.

4. Remove `main.tf` (we'll be using `dotenvx.tf` instead, and re-creating `main.tf` later):

    ```bash
    rm terraform/main.tf
    ```

5. Create a `dotenvx.tf` file:

    ```bash
    touch dotenvx.tf
    ```

    Edit the `dotenvx.tf` file to include the `dotenvx` module multiple times: once for each Vercel environment, and once for the main environment i.e. Vercel itself:

    ```hcl
    # load the main .env file with dotenvx, for the main environment e.g. vercel API keys etc
    module "dotenvx" {
      source         = "cunneen/dotenvx/dotenvx"
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

    ```

6. Change back to the top-level folder:

    ```bash
    cd ..
    ```

7. Create empty `.env.preview`, `.env.development` and `.env.production` files in the top-level folder:

    ```bash
    touch .env.preview
    touch .env.development
    touch .env.production
    ```

8. Move the `.env` and `.env.keys` files (from the [simple][simple] example) from the `terraform/` folder into the top-level folder:

    ```bash
    mv terraform/.env .env
    mv terraform/.env.keys .env.keys
    ```

9. Add a `VERCEL_ENVIRONMENT` environment variable to each of the `env/.env*` files, with the appropriate values `preview`, `development` and `production`, by passing the `-f <filename>` flag to dotenvx:

    ```bash
    dotenvx set VERCEL_ENVIRONMENT preview -f .env.preview 
    dotenvx set VERCEL_ENVIRONMENT development -f .env.development 
    dotenvx set VERCEL_ENVIRONMENT production -f .env.production 
    ```

    Note: there's no real need to encrypt these particular values, we could have just edited the files directly. This is just for illustrative purposes.

10. Add your encrypted `VERCEL_API_TOKEN` value to the `.env` file. You can get this from your [vercel settings][vercel]:

    ```bash
    dotenvx set VERCEL_API_TOKEN <your vercel api token> -f .env
    ```

11. Now all our dotenvx files are in place, we can create the vercel project.

    Add a `.vercelignore` file so that your `.env.keys` file is ignored by Vercel deployments :

    ```bash
    echo ".env.keys" >> .vercelignore
    ```

12. Change to the `terraform/` folder:

    ```bash
    cd terraform
    ```

13. Create a new `main.tf` file:

    ```hcl
    terraform {
        required_providers {
            vercel = {
            source = "vercel/vercel"
            version = "~> 3.8.0"
            }
        }
    }
    ```

14. Create a new `vercel.tf` file that reads the `VERCEL_API_TOKEN` value from the `.env` file:

    ```hcl
    provider "vercel" {
        api_token = module.dotenvx.env["VERCEL_API_TOKEN"]
    }
    ```

15. Edit the `vercel.tf` file and add the following content, to create a vercel project and populate its environment variables:

    ```hcl
    # ... add this after the vercel provider block

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
    ```

16. Run `terraform init` and `terraform plan`:

    ```bash
    terraform init
    ```

    Check the output, and if it's OK, run:

    ```bash
    terraform plan
    ```

17. If the output of `terraform plan` looks good, run `terraform apply`:

    ```bash
    terraform apply
    ```

18. Navigate to your [vercel project](https://vercel.com/) and check that the environment variables have been created for each environment from your dotenvx files.

### Optional : Create a vercel deployment

1. Change back to the top-level folder:

    ```bash
    cd ..
    ```

2. Now we're going to create a vercel deployment:

    We'll download the example from <https://github.com/vercel/examples/tree/main/solutions/html> into our `site/` folder.

    Run the following commands from the top-level folder of your project.

    ```bash
    # sparse-clone the vercel examples repo
    git clone --depth=1 --filter=blob:none https://github.com/vercel/examples.git --sparse examples
    cd examples
    git sparse-checkout init --cone
    git sparse-checkout set solutions/html
    mv examples/solutions/html site
    rm -rf examples
    ```

3. Now you should have a `site/` folder with the vercel example in it. Navigate back to the `terraform/` folder:

    ```bash
    cd terraform
    ```

4. Edit the `vercel.tf` file and add the following content, to create a (production) vercel deployment:

    ```hcl
    # ... add this after the `vercel_project_environment_variables` block:

    data "vercel_project_directory" "html-terraform-demo" {
      path = "../site"
    }
    
    resource "vercel_deployment" "html-terraform-demo" {
      project_id  = vercel_project.html-terraform-demo.id
      files       = data.vercel_project_directory.html-terraform-demo.files
      path_prefix = "../site"
      production  = true
    }
    ```

5. Run `terraform plan` and `terraform apply`:

    ```bash
    terraform plan
    terraform apply
    ```

6. Open your vercel dashboard and confirm that the deployment is live. You may have to wait a few seconds for the deployment to be ready.

7. You can run `terraform destroy` to delete all the resources created by terraform.

<!-- links -->

[@dotenvx/dotenvx]: https://www.npmjs.com/package/@dotenvx/dotenvx
[dotenvx vercel]: https://dotenvx.com/docs/platforms/vercel
[simple]: ../simple/README.md
[vercel]: https://vercel.com/account/tokens
[vercel tf]: https://registry.terraform.io/providers/vercel
