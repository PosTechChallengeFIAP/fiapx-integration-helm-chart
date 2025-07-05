provider "mysql" {
  endpoint = local.aurora_db_endpoint
  username = "springuser"
  password = var.db_password
}

resource "mysql_database" "user_management_db" {
  name = "user_management_db"
}