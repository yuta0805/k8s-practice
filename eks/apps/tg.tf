resource "aws_alb_target_group" "tg" {
  name     = "test-hamada-tg"
  port     = 30080
  protocol = "HTTP"
  vpc_id   = data.terraform_remote_state.vpc.outputs.vpc_id
}
