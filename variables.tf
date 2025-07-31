variable "env_filepath" {
    type = string
    description = "the path to the .env file, relative to `env_folderpath` if specified, or the terraform root directory ($${path.root}) otherwise."
    default = null
    validation {
        condition =  (var.env_filepath == null) || ( (var.env_filepath != "") && fileexists("${(var.env_folderpath != null && var.env_folderpath != "") ? var.env_folderpath : path.root}/${var.env_filepath}"))
        error_message = "The .env file does not exist in the specified folder."
    }
}

variable "env_folderpath" {
    type = string
    description = "The path to the folder containing the .env file(s). if empty, defaults to the terraform root directory ($${path.root})."
    default = null
}

variable "is_nextjs_convention" {
    type = bool
    default = false
    description = "true to use dotenvx with --convention=nextjs"
}

variable "should_ignore_missing_env_file" {
    type = bool
    default = true
    description = "true to suppress errors for missing env files (i.e. pass --ignore=MISSING_ENV_FILE to dotenvx)"
}