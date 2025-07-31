# dotenvx terraform module

This terraform module reads encrypted properties from a [dotenvx](https://dotenvx.com) .env file, and makes the decrypted values available for use in other terraform resources at the `terraform plan` stage.

## Prerequisites

1. [dotenvx](https://dotenvx.com/docs/install) must be installed locally.
2. You must have a `.env` file in your terraform project directory.
3. If your `.env` file contains encrypted values, the appropriate dotenvx `.env.keys` files must also exist in your terraform project directory.

## Usage

```hcl
module "dotenvx" {
  source = "cunneen/dotenvx/dotenvx"
  env_filepath = ".env"
}
```

### Minimal Example

Given a dotenvx `.env` file containing an encrypted property pair `HELLO="World"`:

  ```properties
  #/-------------------[DOTENV_PUBLIC_KEY]--------------------/
  #/            public-key encryption for .env files          /
  #/       [how it works](https://dotenvx.com/encryption)     /
  #/----------------------------------------------------------/
  DOTENV_PUBLIC_KEY="02e5bad70eff555ef6a053ac7080cfd7a85f2465854adbe61f3a944d8fed5782f6"
  
  # .env
  HELLO=encrypted:BGPJlkdSWf3iiOsKGL/vnYTPj6fYiQJRC765jDtAmcysaIUF9OUwUr+u+k0zc4URHNO2J4bF3aqskJvXnQvcG/  Gt7cxg15eIIMoZYxBdt2M9hqVrcgYKa1LLttlNNzlcjHrPiNsp
  ```

  together with a `dotenvx.tf` file:

  ```hcl
  module "dotenvx" {
    source = "cunneen/dotenvx/dotenvx"
    env_filepath = ".env"
  }
  ```

  You can then reference the `HELLO` property in other terraform resources:

  ```hcl
  output "HELLO" {
    value = module.dotenvx.env["HELLO"]
  }
  ```

### More Examples

See the [examples](./examples/) directory for more examples including:

- [Simple](./examples/simple/)
- [Vercel](./examples/vercel/)

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_external"></a> [external](#requirement\_external) | ~> 2.3 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_external"></a> [external](#provider\_external) | ~> 2.3 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [external_external.env](https://registry.terraform.io/providers/hashicorp/external/latest/docs/data-sources/external) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_env_filepath"></a> [env\_filepath](#input\_env\_filepath) | the path to the .env file, relative to `env_folderpath` if specified, or the terraform root directory (${path.root}) otherwise. | `string` | `null` | no |
| <a name="input_env_folderpath"></a> [env\_folderpath](#input\_env\_folderpath) | The path to the folder containing the .env file(s). if empty, defaults to the terraform root directory (${path.root}). | `string` | `null` | no |
| <a name="input_is_nextjs_convention"></a> [is\_nextjs\_convention](#input\_is\_nextjs\_convention) | true to use dotenvx with --convention=nextjs | `bool` | `false` | no |
| <a name="input_should_ignore_missing_env_file"></a> [should\_ignore\_missing\_env\_file](#input\_should\_ignore\_missing\_env\_file) | true to suppress errors for missing env files (i.e. pass --ignore=MISSING\_ENV\_FILE to dotenvx) | `bool` | `true` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_env"></a> [env](#output\_env) | A map of (decrypted) environment variable names to their (string) values. |
<!-- END_TF_DOCS -->