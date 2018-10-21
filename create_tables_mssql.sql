use goldeneye
go
begin transaction

create table survey
(
  id int identity(1,1) primary key not null,
  name varchar(50) not null,
  description text null,
  tags text null
)

create table question
(
  id int identity(1,1) primary key not null,
  "text" text not null,
  type int not null,
  r_type int not null,
  s_id int foreign key references survey(id) not null,
  "order" int not null
)

create table choice
(
  id int identity(1,1) primary key not null,
  letter varchar(10),
  val text not null,
  q_id int foreign key references question(id) not null,
)


create table response
(
  id int identity(1,1) primary key not null,
  s_id int not null,
  q_id int foreign key references question(id) not null,
  resp text null
)
commit;
