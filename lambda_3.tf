
data "archive_file" "lambda_zip" {
  type        = "zip"
  source_dir  = "${path.root}/lambda/"
  output_path = "${path.root}/lambda.zip"
}

# Lambda
resource "aws_lambda_function" "lambda" {
  filename         = "./lambda.zip"
  function_name    = "${var.lambda_name}"
  role             = "${aws_iam_role.main.arn}"
  handler          = "main.lambda_handler"
  runtime          = "python3.7"
  environment {
    variables = {
      INSTANCE_PRIVATE_IP = "${aws_instance.ec2_instance.private_ip}",
      LOG_GROUP = "${aws_cloudwatch_log_group.lambda_log_group.name}",
      LOG_STREAM = "${aws_cloudwatch_log_stream.main.name}"
    }
  }
#   source_code_hash = "${data.archive_file.lambda_zip.output_base64sha256}"
  vpc_config {
    # Every subnet should be able to reach an EFS mount target in the same Availability Zone. Cross-AZ mounts are not permitted.
    subnet_ids         = [aws_subnet.private.id]
    security_group_ids = [aws_security_group.ssh-allowed.id]
  }
}


# CloudWatch 
resource "aws_cloudwatch_log_group" "lambda_log_group" {
  name = "/aws/lambda/${var.lambda_name}"

  retention_in_days = 30
}
resource "aws_cloudwatch_log_stream" "main" {
  name           = "promethium-challenge"
  log_group_name = "${aws_cloudwatch_log_group.lambda_log_group.name}"
}

resource "aws_cloudwatch_event_rule" "every_one_minute" {
  name                = "every-one-minute"
  description         = "Fires every one minutes"
  schedule_expression = "rate(1 minute)"
}

resource "aws_cloudwatch_event_target" "check_foo_every_one_minute" {
  rule      = "${aws_cloudwatch_event_rule.every_one_minute.name}"
  target_id = "lambda"
  arn       = "${aws_lambda_function.lambda.arn}"
}

resource "aws_lambda_permission" "allow_cloudwatch_to_call_check_foo" {
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = "${aws_lambda_function.lambda.function_name}"
  principal     = "events.amazonaws.com"
  source_arn    = "${aws_cloudwatch_event_rule.every_one_minute.arn}"
}

resource "aws_iam_role" "main" {
  name = "iam_for_lambda"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_policy" "network_interface" {
  name        = "network-test-policy"
  description = "A tnw est policy"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "ec2:DescribeNetworkInterfaces",
        "ec2:CreateNetworkInterface",
        "ec2:DeleteNetworkInterface",
        "ec2:DescribeInstances",
        "ec2:AttachNetworkInterface"
      ],
      "Resource": "*"
    }
  ]
}
EOF
}

resource "aws_iam_policy" "policy" {
  name        = "test-policy"
  description = "A test policy"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "Stmt1612246350581",
      "Action": [
        "logs:*"
      ],
      "Effect": "Allow",
      "Resource": "arn:aws:logs:*:*:*"
    }
  ]
}
EOF
}

resource "aws_iam_policy_attachment" "test-attach" {
  name       = "test-attachment"
  roles      = [aws_iam_role.main.name]
  policy_arn = aws_iam_policy.policy.arn
}

resource "aws_iam_policy_attachment" "test-attach_nw" {
  name       = "test-nw"
  roles      = [aws_iam_role.main.name]
  policy_arn = aws_iam_policy.network_interface.arn
}
