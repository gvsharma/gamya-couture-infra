# Bootstrap uses local state. Do not store bootstrap state in the bucket it creates
# until you have run bootstrap once and optionally migrated manually.
terraform {
  backend "local" {
    path = "terraform.tfstate"
  }
}
