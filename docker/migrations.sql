# Add language column 24/8/2017
alter table submissions add column language varchar(255) not null after user_id;
update submissions set language = "swift";

