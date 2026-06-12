ALTER TABLE users 
DROP INDEX idx_users_tenant_identifier,
DROP COLUMN identifier;

ALTER TABLE users 
ADD COLUMN username VARCHAR(100) UNIQUE,
ADD COLUMN nisn VARCHAR(50) UNIQUE,
ADD COLUMN npk VARCHAR(50) UNIQUE;

CREATE INDEX idx_users_tenant_username ON users(tenant_id, username);
