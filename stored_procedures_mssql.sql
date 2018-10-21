use goldeneye
go
create procedure create_survey
  @name as varchar(50),
  @description as text,
  @tags as text
  as
    insert into "create"
	("name","description",tags)
	values
    (@name, @description, @tags)
go

create procedure delete_survey
  @id int
  as
    delete from survey
      where id = @id;
  go

create procedure create_question
  @text_in text,
  @type int,
  @r_type int,
  @s_id int,
  @order int
  as
    insert into question
      ("text", type, r_type, s_id, "order")
        values
      (@text_in, @type, @r_type, @s_id, @order);
  go

create procedure add_answer
  @s_id int,
  @q_id int,
  @resp text
  as
    insert into response
      (s_id, q_id, resp)
        values
      (@s_id, @q_id, @resp);
  go

create procedure add_choice
  @letter varchar(10),
  @val text,
  @q_id int
as
  insert into choice
  (letter,val,q_id)
  values
  (@letter, @val, @q_id)
