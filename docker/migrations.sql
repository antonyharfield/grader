# Add language column 24/8/2017
alter table submissions add column language varchar(255) not null after user_id;
update submissions set language = "swift";

# Fix collations 13/5/2018
ALTER DATABASE grader CHARACTER SET utf8 COLLATE utf8_general_ci;
SET foreign_key_checks = 0;
ALTER TABLE events CONVERT TO CHARACTER SET utf8 COLLATE utf8_general_ci;
ALTER TABLE event_problems CONVERT TO CHARACTER SET utf8 COLLATE utf8_general_ci;
ALTER TABLE fluent CONVERT TO CHARACTER SET utf8 COLLATE utf8_general_ci;
ALTER TABLE problems CONVERT TO CHARACTER SET utf8 COLLATE utf8_general_ci;
ALTER TABLE problem_cases CONVERT TO CHARACTER SET utf8 COLLATE utf8_general_ci;
ALTER TABLE result_cases CONVERT TO CHARACTER SET utf8 COLLATE utf8_general_ci;
ALTER TABLE submissions CONVERT TO CHARACTER SET utf8 COLLATE utf8_general_ci;
ALTER TABLE users CONVERT TO CHARACTER SET utf8 COLLATE utf8_general_ci;
SET foreign_key_checks = 1;
