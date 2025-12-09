-- Quick Test Data Script
-- Run this in Supabase SQL Editor to create sample tasks for today

-- Step 1: Get your user ID (run this first and note the ID)
-- SELECT id, email FROM auth.users;

-- Step 2: Create test data (replace YOUR_USER_ID with the ID from Step 1)
DO $$
DECLARE
    v_user_id UUID;
    v_tenant_id UUID := gen_random_uuid();
    v_lead_id UUID;
    v_application_id UUID;
BEGIN
    -- Get first user (or replace with your specific user ID)
    SELECT id INTO v_user_id FROM auth.users LIMIT 1;
    
    IF v_user_id IS NULL THEN
        RAISE EXCEPTION 'No users found. Please create a user first.';
    END IF;
    
    -- Create a lead
    INSERT INTO leads (tenant_id, owner_id, name, email, phone, stage)
    VALUES (v_tenant_id, v_user_id, 'Test Lead', 'test@example.com', '123-456-7890', 'new')
    RETURNING id INTO v_lead_id;
    
    -- Create an application
    INSERT INTO applications (tenant_id, lead_id, program, status, payment_status)
    VALUES (v_tenant_id, v_lead_id, 'Computer Science', 'pending', 'unpaid')
    RETURNING id INTO v_application_id;
    
    -- Create a task due TODAY (in 1 hour)
    INSERT INTO tasks (tenant_id, related_id, title, description, type, status, due_at)
    VALUES (
        v_tenant_id,
        v_application_id,
        'Call Test Lead',
        'Follow up call with test lead',
        'call',
        'pending',
        NOW() + INTERVAL '1 hour'
    );
    
    -- Create another task due TODAY (in 2 hours)
    INSERT INTO tasks (tenant_id, related_id, title, description, type, status, due_at)
    VALUES (
        v_tenant_id,
        v_application_id,
        'Email Test Lead',
        'Send application details email',
        'email',
        'pending',
        NOW() + INTERVAL '2 hours'
    );
    
    RAISE NOTICE '✅ Test data created successfully!';
    RAISE NOTICE 'Refresh your dashboard to see the tasks.';
END $$;

