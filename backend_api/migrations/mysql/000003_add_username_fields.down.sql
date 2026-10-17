DROP INDEX idx_users_tenant_username ON users;

ALTER TABLE users
DROP COLUMN npk,
DROP COLUMN nisn,
DROP COLUMN username;
