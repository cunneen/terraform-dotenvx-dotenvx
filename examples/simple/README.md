# Simple Example

1. Ensure `dotenvx` is installed:

    ```bash
    command -v dotenvx > /dev/null 2>&1 && echo "dotenvx IS installed." || {
      echo "Error: dotenvx is NOT installed." >&2
    }
    ```

2. Create a `.env` file containing an encrypted property pair `HELLO="World"`:

    ```bash
    echo "HELLO=World" > .env
    dotenvx encrypt .env
    ```

3. Ensure the `.env.keys` file is ignored by git:

    ```bash
    dotenvx ext gitignore --pattern .env.keys
    ```

    Your `.env` file should now look like this (with different encryption keys and values):

    ```properties
    #/-------------------[DOTENV_PUBLIC_KEY]--------------------/
    #/            public-key encryption for .env files          /
    #/       [how it works](https://dotenvx.com/encryption)     /
    #/----------------------------------------------------------/
    DOTENV_PUBLIC_KEY="0306644b110b64d34f95f79f0d13fa206f2b6aae9da95c12537a3cc235e729a816"

    # .env
    HELLO=encrypted:BG3/jj0xnXasqr1iE3C/4Gu0fVC6sOoACHxc+5y3ZT8Hd3ykxdypCcQm2/zL5ILjpdKHYK5KcXE8II8j9pvrQt/Me3UMJOCElEzFvIo1UdWTDaS4z51HeAb7tFTKzvt2vKyAfZog
    ```

4. Create a terraform `main.tf` file to include the `dotenvx` module, and add an `output` block to display the decrypted `HELLO` value:

    ```hcl
    module "dotenvx" {
        source = "cunneen/dotenvx/dotenvx"
        env_filepath = ".env"
    }

    output "HELLO" {
       value = module.dotenvx.env["HELLO"]
    }
    ```

5. Initialize the terraform project:

    ```bash
    terraform init
    ```

6. Run the terraform plan:

    ```bash
    terraform plan
    ```

    You should see the decrypted `HELLO` value displayed in the console output:

    ```shell-session
    $ terraform plan
    module.dotenvx.data.external.env: Reading...
    module.dotenvx.data.external.env: Read complete after 0s [id=-]
    
    Changes to Outputs:
      + HELLO = "World"
    
    You can apply this plan to save these new output values to the     Terraform state, without changing any real infrastructure.
    
    ──────────────────────────────────────────────────────────────────    ──────────────────────────────────────────────────────────────────    ───────────────────────────────────────────
    
    Note: You didn't use the -out option to save this plan, so     Terraform can't guarantee to take exactly these actions if you     run "terraform apply" now.
    ```
