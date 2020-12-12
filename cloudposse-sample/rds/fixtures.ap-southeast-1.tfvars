enabled = true

region = "ap-southeast-1"

namespace = "my"

stage = "test"

name = "rds-cluster"

instance_type = "db.t3.large"

cluster_family = "aurora-postgresql11"

cluster_size = 2

deletion_protection = false

autoscaling_enabled = false

engine = "aurora-postgresql"

engine_mode = "provisioned"

db_name = "test_db"

admin_user = "root"

admin_password = "password"

enhanced_monitoring_role_enabled = true

rds_monitoring_interval = 30

include_self_ingress_rule = true