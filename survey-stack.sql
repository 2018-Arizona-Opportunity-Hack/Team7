create schema goldeneye;
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
);
DELIMITER //

create procedure create_survey(in in_name varchar(50), in in_description text, in in_tags text)
  begin
    insert into survey(`name`,`description`,`tags`) values (in_name, in_description, in_tags);
  end
  //

create procedure delete_survey(in in_id int)
  begin
    delete from survey
      where id = in_id;
  end
  //

create procedure create_question(in in_text text, in in_type int, in in_r_type int, in in_s_id int)
  begin
    insert into question
      (`text`, `type`, `r_type`, `s_id`)
        values
      (in_text, in_type, in_r_type, in_s_id);
  end
  //

create procedure add_answer(in in_s_id int, in in_q_id int, in in_resp text)
  begin
    insert into response
      (s_id, q_id, resp)
        values
      (in_s_id, in_q_id, in_resp);
  end
  //

create procedure add_choice(in in_letter varchar(10), in in_val text, in in_q_id int)
  begin
    insert into choice
      (letter,val,q_id)
        values
      (in_letter, in_val, in_q_id);
  end
  //

DELIMITER ;
