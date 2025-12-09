DO $$
DECLARE
    v_tenant_id UUID := gen_random_uuid();
    v_lead_id UUID;
    v_application_id UUID;
    v_lead_id2 UUID;
    v_application_id2 UUID;
    v_lead_id3 UUID;
    v_application_id3 UUID;
BEGIN
    INSERT INTO leads (tenant_id, owner_id, name, email, stage)
    VALUES (v_tenant_id, NULL, 'John Doe', 'john@example.com', 'new')
    RETURNING id INTO v_lead_id;

    INSERT INTO leads (tenant_id, owner_id, name, email, stage)
    VALUES (v_tenant_id, NULL, 'Jane Smith', 'jane@example.com', 'contacted')
    RETURNING id INTO v_lead_id2;

    INSERT INTO leads (tenant_id, owner_id, name, email, stage)
    VALUES (v_tenant_id, NULL, 'Mike Johnson', 'mike@example.com', 'qualified')
    RETURNING id INTO v_lead_id3;

    INSERT INTO applications (tenant_id, lead_id, program, status, payment_status)
    VALUES (v_tenant_id, v_lead_id, 'Computer Science', 'pending', 'unpaid')
    RETURNING id INTO v_application_id;

    INSERT INTO applications (tenant_id, lead_id, program, status, payment_status)
    VALUES (v_tenant_id, v_lead_id2, 'Business Administration', 'under_review', 'paid')
    RETURNING id INTO v_application_id2;

    INSERT INTO applications (tenant_id, lead_id, program, status, payment_status)
    VALUES (v_tenant_id, v_lead_id3, 'Data Science', 'pending', 'unpaid')
    RETURNING id INTO v_application_id3;

    INSERT INTO tasks (tenant_id, related_id, title, description, type, status, due_at) VALUES
    (v_tenant_id, v_application_id, 'Call John Doe', 'Follow up call regarding application', 'call', 'pending', NOW() + INTERVAL '1 hour'),
    (v_tenant_id, v_application_id, 'Email John Doe', 'Send application details and next steps', 'email', 'pending', NOW() + INTERVAL '2 hours'),
    (v_tenant_id, v_application_id, 'Review John Application', 'Review documents and credentials', 'review', 'pending', NOW() + INTERVAL '3 hours'),
    (v_tenant_id, v_application_id2, 'Call Jane Smith', 'Discuss program details', 'call', 'pending', NOW() + INTERVAL '4 hours'),
    (v_tenant_id, v_application_id2, 'Review Jane Application', 'Final review of submitted documents', 'review', 'pending', NOW() + INTERVAL '5 hours'),
    (v_tenant_id, v_application_id3, 'Email Mike Johnson', 'Send welcome package', 'email', 'pending', NOW() + INTERVAL '6 hours'),
    (v_tenant_id, v_application_id3, 'Call Mike Johnson', 'Schedule orientation call', 'call', 'pending', NOW() + INTERVAL '7 hours'),
    (v_tenant_id, v_application_id, 'Review Application Materials', 'Check all submitted documents', 'review', 'pending', NOW() + INTERVAL '8 hours'),
    (v_tenant_id, v_application_id2, 'Email Follow Up', 'Send additional information', 'email', 'pending', NOW() + INTERVAL '9 hours');
END $$;
