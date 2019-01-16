#-----networking/main.tf-----

data "aws_availability_zones" "available" {} ## Provê acesso a uma lista de AZs que podem ser acessadas na região 

resource "aws_vpc" "tf_vpc" {
  cidr_block           = "${var.vpc_cidr}"
  enable_dns_support   = true              ## habilito suporte a DNS no VPC
  enable_dns_hostnames = true              ## habilito suporte a hostnames no VPC

  tags {
    Name = "tf_vpc"
  }
}

resource "aws_internet_gateway" "tf_IGW" {
  vpc_id = "${aws_vpc.tf_vpc.id}" ## Associo meu IGW ao VPC criado

  tags {
    Name = "tf_igw"
  }
}

resource "aws_route_table" "tf_public_rt" {
  vpc_id = "${aws_vpc.tf_vpc.id}" ## Associo a route table ao VPC

  route { ## adiciono roteamento
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.tf_IGW.id}" ## Essa tabela de roteamento é pública e aponta para a internet
  }

  tags {
    Name = "tf_public"
  }
}

# O recurso aws_default_route_table não é criado pelo Terraform. Quando se cria um VPC
# uma route table é criada por padrão. Esse recurso apenas o adota no terraform para ser gerenciado
resource "aws_default_route_table" "tf_private_rt" { 
  default_route_table_id = "${aws_vpc.tf_vpc.default_route_table_id}" ## O default_route_table_id associa ao VPC o id da tabela padrão.

  tags {
    Name = "tf_private"
  }
}

# O recurso aws_subnet cria subredes
resource "aws_subnet" "tf_public_subnet" {
  count                   = 2 # através do count posso escalar configurações criando mais de um recurso sem repetir linhas de configuração. Aqui ele está hardcoded mas posso colocar em uma variável
  vpc_id                  = "${aws_vpc.tf_vpc.id}" # Para criar uma subrede preciso associa-la a um VPC. 
  cidr_block              = "${var.public_cidrs[count.index]}" #Aqui esta a mágica do count. No arquivo variables.tf eu defino ela como uma lista, e uso o count para iterar sobre essa lista. O tamanho dela já foi pré-definido através da variável count. 
  map_public_ip_on_launch = true # Defino como True se quero que as instâncias quando lançadas tenham associadas a ela um ip público. Por default ela é deixada como false.
  availability_zone       = "${data.aws_availability_zones.available.names[count.index]}" # Itero nas subredes associando elas a zonas diferentes

  tags {
    Name = "tf_public_${count.index + 1}"
  }
}

#O recurso aws_route_table_association cria uma associação entre subredes e tabelas de roteamento. Adiciona as subredes na tabela de roteamento.
resource "aws_route_table_association" "tf_public_assoc" {
  count          = "${aws_subnet.tf_public_subnet.count}"# como vou associar as subredes criadas anteriormente, pego a quantidade usada para poder usar. 
  subnet_id      = "${aws_subnet.tf_public_subnet.*.id[count.index]}" #Pego o id das duas subredes com o *
  route_table_id = "${aws_route_table.tf_public_rt.id}"# ID da tabela de roteamento para associar
}

# O recurso aws_security_group cria um security group e associo ele ao VPC
resource "aws_security_group" "tf_public_sg" {
  name        = "tf_public_sg"
  description = "Used for access to the public instances"
  vpc_id      = "${aws_vpc.tf_vpc.id}"

  #SSH

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["${var.accessip}"]
  }

  #HTTP

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["${var.accessip}"]
  }
  egress {
    from_port   = 0             #libera todas as portas
    to_port     = 0
    protocol    = "-1"          # sintaxe para libera tudo
    cidr_blocks = ["0.0.0.0/0"]
  }
}
