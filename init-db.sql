-- Headwind MDM Database Initialization
-- This script ensures the database and user are properly configured

-- Create database if it doesn't exist (this will be handled by environment variables)
-- The database and user should already be created by Docker environment variables

-- Grant all privileges to the hmdm user
GRANT ALL PRIVILEGES ON DATABASE hmdm TO hmdm;

-- Set proper encoding and locale
ALTER DATABASE hmdm SET timezone TO 'UTC';

-- Enable required extensions if needed
-- CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Log completion
SELECT 'Database initialization completed' AS status; 