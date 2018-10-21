use goldeneye;
create table survey
(
  id int auto_increment primary key not null,
  name varchar(50) not null,
  description text null,
  tags text null
);

create table question
(
  id int auto_increment primary key not null,
  `text` text not null,
  type int not null,
  r_type int not null,
  s_id int not null,
  foreign key (s_id)
	references survey(id)
);

create table choice
(
  id int auto_increment primary key not null,
  letter varchar(10),
  val text not null,
  q_id int not null,
  foreign key (q_id)
	references question(id)
);


create table response
(
  id int auto_increment primary key not null,
  s_id int not null,
  q_id int not null,
  resp text null,
  foreign key (q_id)
	references question(id)
)
