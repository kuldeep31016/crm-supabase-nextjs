DO $$
DECLARE
    v_tenant_id UUID := gen_random_uuid();
    v_lead_id UUID;
    v_application_id UUID;
BEGIN
    INSERT INTO leads (tenant_id, owner_id, name, email, stage)
    VALUES (v_tenant_id, NULL, 'Test Lead', 'test@example.com', 'new')
    RETURNING id INTO v_lead_id;

    INSERT INTO applications (tenant_id, lead_id, program, status, payment_status)
    VALUES (v_tenant_id, v_lead_id, 'Computer Science', 'pending', 'unpaid')
    RETURNING id INTO v_application_id;

    INSERT INTO tasks (tenant_id, related_id, title, description, type, status, due_at) VALUES
    (v_tenant_id, v_application_id, 'Call Test Lead', 'Follow up call', 'call', 'pending', NOW() + INTERVAL '1 hour'),
    (v_tenant_id, v_application_id, 'Email Test Lead', 'Send details', 'email', 'pending', NOW() + INTERVAL '2 hours'),
    (v_tenant_id, v_application_id, 'Review Application', 'Review documents', 'review', 'pending', NOW() + INTERVAL '3 hours');
END $$;
