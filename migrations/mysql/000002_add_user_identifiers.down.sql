ALTER TABLE users 
DROP INDEX idx_users_tenant_username,
DROP COLUMN username,
DROP COLUMN nisn,
DROP COLUMN npk;

ALTER TABLE users 
ADD COLUMN identifier VARCHAR(100);

CREATE INDEX idx_users_tenant_identifier ON users(tenant_id, identifier);
