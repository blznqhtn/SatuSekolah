ALTER TABLE users
ADD COLUMN username VARCHAR(100) UNIQUE AFTER email,
ADD COLUMN nisn VARCHAR(50) UNIQUE AFTER username,
ADD COLUMN npk VARCHAR(50) UNIQUE AFTER nisn;

CREATE INDEX idx_users_tenant_username ON users(tenant_id, username);
