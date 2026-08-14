DROP TABLE IF EXISTS schedule_changes;

ALTER TABLE class_schedules
DROP COLUMN room,
DROP COLUMN activity_type,
DROP COLUMN activity_name,
DROP COLUMN description,
DROP COLUMN link;
