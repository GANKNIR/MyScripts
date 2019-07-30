variable "cidr" {
  description = "The CIDR block for the VPC."
}

variable "external_subnets" {
  description = "List of external subnets"
  type        = "list"
}

variable "internal_subnets" {
  description = "List of internal subnets"
  type        = "list"
}

variable "environment" {
  description = "Environment tag, e.g prod"
}

variable "availability_zones" {
  description = "List of availability zones"
  type        = "list"
}

variable "name" {
  description = "Name tag, e.g stack"
  default     = "stack"
}

variable "use_nat_instances" {
  description = "If true, use EC2 NAT instances instead of the AWS NAT gateway service."
  default     = false
}


/**VPC*/

resource "aws_vpc" "main" {
  cidr_block           = "${var.cidr}"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags {
    Name        = "${var.name}"
    Environment = "${var.environment}"
  }
}

/**Gateways*/

resource "aws_internet_gateway" "main" {
  vpc_id = "${aws_vpc.main.id}"

  tags {
    Name        = "${var.name}"
    Environment = "${var.environment}"
  }
}
resource "aws_security_group" "nat_instances" {
  # Create this only if using NAT instances, vs. the NAT gateway service.
  count       = "${0 + var.use_nat_instances}"
  name        = "nat"
  description = "Allow traffic from clients into NAT instances"

  ingress {
    from_port   = 0
    to_port     = 65535
    protocol    = "udp"
    cidr_blocks = "${var.internal_subnets}"
  }

  ingress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = "${var.internal_subnets}"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  vpc_id = "${aws_vpc.main.id}"
}

/** Subnets*/

resource "aws_subnet" "internal" {
  vpc_id            = "${aws_vpc.main.id}"
  cidr_block        = "${element(var.internal_subnets, count.index)}"
  availability_zone = "${element(var.availability_zones, count.index)}"
  count             = "${length(var.internal_subnets)}"

  tags {
    Name        = "${var.name}-${format("internal-%03d", count.index+1)}"
    Environment = "${var.environment}"
  }
}

resource "aws_subnet" "external" {
  vpc_id                  = "${aws_vpc.main.id}"
  cidr_block              = "${element(var.external_subnets, count.index)}"
  availability_zone       = "${element(var.availability_zones, count.index)}"
  count                   = "${length(var.external_subnets)}"
  map_public_ip_on_launch = true

  tags {
    Name        = "${var.name}-${format("external-%03d", count.index+1)}"
    Environment = "${var.environment}"
  }
}

/** Route tables/

resource "aws_route_table" "external" {
  vpc_id = "${aws_vpc.main.id}"

  tags {
    Name        = "${var.name}-external-001"
    Environment = "${var.environment}"
  }
}

resource "aws_route" "external" {
  route_table_id         = "${aws_route_table.external.id}"
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = "${aws_internet_gateway.main.id}"
}
/** Outputs*/

// The VPC ID
output "id" {
  value = "${aws_vpc.main.id}"
}

// The VPC CIDR
output "cidr_block" {
  value = "${aws_vpc.main.cidr_block}"
}

// A comma-separated list of subnet IDs.
output "external_subnets" {
  value = ["${aws_subnet.external.*.id}"]
}

// A list of subnet IDs.
output "internal_subnets" {
  value = ["${aws_subnet.internal.*.id}"]
}

// The default VPC security group ID.
output "security_group" {
  value = "${aws_vpc.main.default_security_group_id}"
}

// The list of availability zones of the VPC.
output "availability_zones" {
  value = ["${aws_subnet.external.*.availability_zone}"]
}

// The internal route table ID.
output "internal_rtb_id" {
  value = "${join(",", aws_route_table.internal.*.id)}"
}

// The external route table ID.
output "external_rtb_id" {
  value = "${aws_route_table.external.id}"
}
