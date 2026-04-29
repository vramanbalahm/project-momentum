-- Schema v14 — household_restrictions table
-- Household-level ingredient restrictions (allergy / dislike) — applies to all members
-- Run this on food_momentum_db

CREATE TABLE IF NOT EXISTS public.household_restrictions (
    id              uuid DEFAULT gen_random_uuid() NOT NULL,
    house_id        uuid NOT NULL,
    ingredient_id   integer NOT NULL,
    restriction_type varchar(20) NOT NULL CHECK (restriction_type IN ('Allergy', 'Dislike')),
    updated_by      uuid,
    updated_at      timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT household_restrictions_pkey PRIMARY KEY (id),
    CONSTRAINT household_restrictions_house_fkey
        FOREIGN KEY (house_id) REFERENCES public.household_master(household_id) ON DELETE CASCADE,
    CONSTRAINT household_restrictions_ingredient_fkey
        FOREIGN KEY (ingredient_id) REFERENCES public.ingredient_catalog(id) ON DELETE CASCADE,
    CONSTRAINT household_restrictions_unique
        UNIQUE (house_id, ingredient_id, restriction_type)
);

CREATE INDEX IF NOT EXISTS idx_household_restrictions_house
    ON public.household_restrictions(house_id);

COMMENT ON TABLE public.household_restrictions IS
    'Household-level ingredient restrictions — ingredients no one in the family eats. '
    'Applied globally to all meal suggestions regardless of individual member restrictions.';
