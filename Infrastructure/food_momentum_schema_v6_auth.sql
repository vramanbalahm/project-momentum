-- ============================================================
-- Schema v6 — Authentication & User Management
-- Date: 2026-04-19
-- Adds: users table, refresh_tokens table
--       household_master additions for auth
-- ============================================================

-- 1. Role type enum
CREATE TYPE public.user_role AS ENUM (
    'platform_admin',
    'household_admin',
    'household_member'
);

-- 2. Household master additions
ALTER TABLE public.household_master
    ADD COLUMN IF NOT EXISTS is_active         BOOLEAN DEFAULT true,
    ADD COLUMN IF NOT EXISTS subscription_tier VARCHAR(20) DEFAULT 'free'
                             CHECK (subscription_tier IN ('free', 'premium')),
    ADD COLUMN IF NOT EXISTS phone_number      VARCHAR(20),
    ADD COLUMN IF NOT EXISTS onboarding_done   BOOLEAN DEFAULT false,
    ADD COLUMN IF NOT EXISTS admin_user_id     UUID;  -- set after first user created

COMMENT ON COLUMN public.household_master.is_active IS
    'Active/inactive status. Inactive households cannot log in.';
COMMENT ON COLUMN public.household_master.subscription_tier IS
    'free = basic features, premium = swap/copy and advanced features.';
COMMENT ON COLUMN public.household_master.admin_user_id IS
    'UUID of the household admin user. Set on first registration.';

-- 3. Users table
CREATE TABLE IF NOT EXISTS public.users (
    user_id         UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    house_id        UUID NOT NULL REFERENCES public.household_master(household_id) ON DELETE CASCADE,
    email           VARCHAR(255) NOT NULL UNIQUE,
    name            VARCHAR(120) NOT NULL,
    password_hash   TEXT NOT NULL,
    role            public.user_role DEFAULT 'household_member' NOT NULL,
    is_active       BOOLEAN DEFAULT true,
    created_at      TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    last_login_at   TIMESTAMP,
    created_by      UUID  -- user_id of admin who created this member (null for self-registered admin)
);

CREATE INDEX IF NOT EXISTS idx_users_email    ON public.users(email);
CREATE INDEX IF NOT EXISTS idx_users_house_id ON public.users(house_id);

COMMENT ON TABLE public.users IS
    'Authentication users. household_admin self-registers and creates household_members.';
COMMENT ON COLUMN public.users.created_by IS
    'NULL for self-registered household_admin. Set to admin user_id for household_members.';

-- 4. Refresh tokens table
CREATE TABLE IF NOT EXISTS public.refresh_tokens (
    id          UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id     UUID NOT NULL REFERENCES public.users(user_id) ON DELETE CASCADE,
    house_id    UUID NOT NULL REFERENCES public.household_master(household_id) ON DELETE CASCADE,
    token_hash  VARCHAR(64) NOT NULL UNIQUE,
    expires_at  TIMESTAMP NOT NULL,
    revoked     BOOLEAN DEFAULT false,
    created_at  TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_refresh_tokens_hash ON public.refresh_tokens(token_hash);

COMMENT ON TABLE public.refresh_tokens IS
    'Hashed refresh tokens. One row per issued token. Revoked on logout or refresh.';

-- 5. Link household_members to users (optional — for existing members)
ALTER TABLE public.household_members
    ADD COLUMN IF NOT EXISTS user_id   UUID REFERENCES public.users(user_id),
    ADD COLUMN IF NOT EXISTS is_active BOOLEAN DEFAULT true;

COMMENT ON COLUMN public.household_members.user_id IS
    'Links physical household member to their login user account. NULL if no login.';
