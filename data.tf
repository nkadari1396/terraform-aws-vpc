data "aws_availability_zones" "available" {
  state = "available"
}

data "aws_vpc" "default" {
  default = true
}

#data "aws_route_table" "default" {
  #vpc_id = data.aws_vpc.default.id
#}



# this data source is good, if you have a single routable, what if you dont know how many route rout_tables
#are there in vpc at that time we need to use a filter function

#data "aws_route_table" "default" {
  #vpc_id = data.aws_vpc.default.id
#}

data "aws_route_table" "main"{
  vpc_id = data.aws_vpc.default.id
  filter {
    name = "association.main"
    values = ["true"]
  }
}