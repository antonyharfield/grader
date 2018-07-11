ALTER TABLE fluent MODIFY id VARBINARY(16) NOT NULL;
ALTER TABLE fluent MODIFY batch BIGINT(20) NOT NULL;
ALTER TABLE fluent CHANGE created_at createdAt DATETIME(6) NOT NULL;
ALTER TABLE fluent CHANGE updated_at updatedAt DATETIME(6) NOT NULL;

#UPDATE TABLE fluent SET id = UNHEX(REPLACE(UUID(),'-',''));
#select UNHEX(REPLACE(UUID(),'-','')) bin;

ALTER TABLE users CHANGE last_login lastLogin DATETIME DEFAULT NULL;
ALTER TABLE users CHANGE has_image hasImage TINYINT(1) unsigned NOT NULL DEFAULT '0';

ALTER TABLE events CHANGE user_id userID INT(10) unsigned NOT NULL;
ALTER TABLE events CHANGE starts_at startsAt DATETIME DEFAULT NULL;
ALTER TABLE events CHANGE ends_at endsAt DATETIME DEFAULT NULL;
ALTER TABLE events CHANGE language_restriction languageRestriction VARCHAR(255) DEFAULT NULL;
ALTER TABLE events CHANGE short_description shortDescription VARCHAR(1000) DEFAULT NULL;
ALTER TABLE events CHANGE has_image hasImage TINYINT(1) unsigned NOT NULL DEFAULT '0';
ALTER TABLE events CHANGE scoring_system scoringSystem INT(11) NOT NULL DEFAULT '0';
ALTER TABLE events CHANGE scores_hidden_before_end scoresHiddenBeforeEnd INT(11) NOT NULL DEFAULT '0';
ALTER TABLE events MODIFY languageRestriction VARCHAR(32) DEFAULT NULL;

ALTER TABLE event_problems CHANGE event_id eventID INT(10) unsigned NOT NULL;
ALTER TABLE event_problems CHANGE problem_id problemID INT(10) unsigned NOT NULL;

ALTER TABLE problems CHANGE comparison_method comparisonMethod VARCHAR(16) NOT NULL;
ALTER TABLE problems CHANGE comparison_ignores_spaces comparisonIgnoresSpaces TINYINT(1) unsigned NOT NULL;
ALTER TABLE problems CHANGE comparison_ignores_breaks comparisonIgnoresBreaks TINYINT(1) unsigned NOT NULL;

ALTER TABLE problem_cases CHANGE problem_id problemID INT(10) unsigned NOT NULL;

ALTER TABLE result_cases CHANGE submission_id submissionID INT(10) unsigned NOT NULL;
ALTER TABLE result_cases CHANGE problem_case_id problemCaseID INT(10) unsigned NOT NULL;

ALTER TABLE submissions CHANGE event_problem_id eventProblemID INT(10) unsigned NOT NULL;
ALTER TABLE submissions CHANGE user_id userID INT(10) unsigned NOT NULL;
ALTER TABLE submissions CHANGE compiler_output compilerOutput VARCHAR(255) NOT NULL;
ALTER TABLE submissions CHANGE created_at createdAt DATETIME NOT NULL;
ALTER TABLE submissions CHANGE updated_at updatedAt DATETIME NOT NULL;
ALTER TABLE submissions MODIFY language VARCHAR(32) NOT NULL;
