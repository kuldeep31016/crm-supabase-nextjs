-- LearnLynk RLS Policies Migration
-- Enables Row Level Security and creates policies for all tables

-- ============================================
-- ENABLE ROW LEVEL SECURITY
-- ============================================
ALTER TABLE leads ENABLE ROW LEVEL SECURITY;
ALTER TABLE applications ENABLE ROW LEVEL SECURITY;
ALTER TABLE tasks ENABLE ROW LEVEL SECURITY;
ALTER TABLE teams ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_teams ENABLE ROW LEVEL SECURITY;

-- ============================================
-- LEADS TABLE POLICIES
-- ============================================

-- SELECT Policy: Counselor can read leads assigned to them or their team, Admin can read all
CREATE POLICY "leads_select_policy" ON leads
FOR SELECT
USING (
    -- Admin can see all leads
    (auth.jwt() ->> 'role') = 'admin'
    OR
    -- Counselor can see their own leads
    owner_id = auth.uid()
    OR
    -- Counselor can see leads owned by teammates
    owner_id IN (
        SELECT ut2.user_id 
        FROM user_teams ut1
        JOIN user_teams ut2 ON ut1.team_id = ut2.team_id
        WHERE ut1.user_id = auth.uid()
    )
);

-- INSERT Policy: Admin can insert any lead, Counselor can only insert leads assigned to themselves
CREATE POLICY "leads_insert_policy" ON leads
FOR INSERT
WITH CHECK (
    -- Admin can insert any lead
    (auth.jwt() ->> 'role') = 'admin'
    OR
    -- Counselor can only insert leads owned by themselves
    (
        (auth.jwt() ->> 'role') = 'counselor'
        AND owner_id = auth.uid()
    )
);

-- UPDATE Policy: Admin can update any lead, Counselor can only update their own leads
CREATE POLICY "leads_update_policy" ON leads
FOR UPDATE
USING (
    (auth.jwt() ->> 'role') = 'admin'
    OR owner_id = auth.uid()
)
WITH CHECK (
    (auth.jwt() ->> 'role') = 'admin'
    OR owner_id = auth.uid()
);

-- DELETE Policy: Only Admin can delete leads
CREATE POLICY "leads_delete_policy" ON leads
FOR DELETE
USING (
    (auth.jwt() ->> 'role') = 'admin'
);

-- ============================================
-- APPLICATIONS TABLE POLICIES
-- ============================================

-- SELECT Policy: Users can read applications for leads they have access to
CREATE POLICY "applications_select_policy" ON applications
FOR SELECT
USING (
    -- Admin can see all applications
    (auth.jwt() ->> 'role') = 'admin'
    OR
    -- Users can see applications for leads they own
    lead_id IN (
        SELECT id FROM leads
        WHERE owner_id = auth.uid()
        OR owner_id IN (
            SELECT ut2.user_id 
            FROM user_teams ut1
            JOIN user_teams ut2 ON ut1.team_id = ut2.team_id
            WHERE ut1.user_id = auth.uid()
        )
    )
);

-- INSERT Policy: Users can insert applications for leads they own
CREATE POLICY "applications_insert_policy" ON applications
FOR INSERT
WITH CHECK (
    (auth.jwt() ->> 'role') = 'admin'
    OR
    lead_id IN (
        SELECT id FROM leads WHERE owner_id = auth.uid()
    )
);

-- UPDATE Policy: Users can update applications for leads they own
CREATE POLICY "applications_update_policy" ON applications
FOR UPDATE
USING (
    (auth.jwt() ->> 'role') = 'admin'
    OR
    lead_id IN (
        SELECT id FROM leads WHERE owner_id = auth.uid()
    )
)
WITH CHECK (
    (auth.jwt() ->> 'role') = 'admin'
    OR
    lead_id IN (
        SELECT id FROM leads WHERE owner_id = auth.uid()
    )
);

-- DELETE Policy: Only Admin can delete applications
CREATE POLICY "applications_delete_policy" ON applications
FOR DELETE
USING (
    (auth.jwt() ->> 'role') = 'admin'
);

-- ============================================
-- TASKS TABLE POLICIES
-- ============================================

-- SELECT Policy: Users can read tasks for applications they have access to
CREATE POLICY "tasks_select_policy" ON tasks
FOR SELECT
USING (
    (auth.jwt() ->> 'role') = 'admin'
    OR
    related_id IN (
        SELECT id FROM applications
        WHERE lead_id IN (
            SELECT id FROM leads
            WHERE owner_id = auth.uid()
            OR owner_id IN (
                SELECT ut2.user_id 
                FROM user_teams ut1
                JOIN user_teams ut2 ON ut1.team_id = ut2.team_id
                WHERE ut1.user_id = auth.uid()
            )
        )
    )
    OR
    assigned_to = auth.uid()
);

-- INSERT Policy: Users can insert tasks for applications they have access to
CREATE POLICY "tasks_insert_policy" ON tasks
FOR INSERT
WITH CHECK (
    (auth.jwt() ->> 'role') = 'admin'
    OR
    related_id IN (
        SELECT id FROM applications
        WHERE lead_id IN (
            SELECT id FROM leads WHERE owner_id = auth.uid()
        )
    )
);

-- UPDATE Policy: Users can update tasks assigned to them or for applications they own
CREATE POLICY "tasks_update_policy" ON tasks
FOR UPDATE
USING (
    (auth.jwt() ->> 'role') = 'admin'
    OR
    assigned_to = auth.uid()
    OR
    related_id IN (
        SELECT id FROM applications
        WHERE lead_id IN (
            SELECT id FROM leads WHERE owner_id = auth.uid()
        )
    )
)
WITH CHECK (
    (auth.jwt() ->> 'role') = 'admin'
    OR
    assigned_to = auth.uid()
    OR
    related_id IN (
        SELECT id FROM applications
        WHERE lead_id IN (
            SELECT id FROM leads WHERE owner_id = auth.uid()
        )
    )
);

-- DELETE Policy: Only Admin can delete tasks
CREATE POLICY "tasks_delete_policy" ON tasks
FOR DELETE
USING (
    (auth.jwt() ->> 'role') = 'admin'
);

-- ============================================
-- TEAMS TABLE POLICIES
-- ============================================

-- SELECT Policy: Users can see teams they belong to
CREATE POLICY "teams_select_policy" ON teams
FOR SELECT
USING (
    (auth.jwt() ->> 'role') = 'admin'
    OR
    id IN (
        SELECT team_id FROM user_teams WHERE user_id = auth.uid()
    )
);

-- INSERT Policy: Only Admin can create teams
CREATE POLICY "teams_insert_policy" ON teams
FOR INSERT
WITH CHECK (
    (auth.jwt() ->> 'role') = 'admin'
);

-- UPDATE Policy: Only Admin can update teams
CREATE POLICY "teams_update_policy" ON teams
FOR UPDATE
USING (
    (auth.jwt() ->> 'role') = 'admin'
)
WITH CHECK (
    (auth.jwt() ->> 'role') = 'admin'
);

-- DELETE Policy: Only Admin can delete teams
CREATE POLICY "teams_delete_policy" ON teams
FOR DELETE
USING (
    (auth.jwt() ->> 'role') = 'admin'
);

-- ============================================
-- USER_TEAMS TABLE POLICIES
-- ============================================

-- SELECT Policy: Users can see their own team memberships
CREATE POLICY "user_teams_select_policy" ON user_teams
FOR SELECT
USING (
    (auth.jwt() ->> 'role') = 'admin'
    OR
    user_id = auth.uid()
    OR
    team_id IN (
        SELECT team_id FROM user_teams WHERE user_id = auth.uid()
    )
);

-- INSERT Policy: Only Admin can add users to teams
CREATE POLICY "user_teams_insert_policy" ON user_teams
FOR INSERT
WITH CHECK (
    (auth.jwt() ->> 'role') = 'admin'
);

-- DELETE Policy: Only Admin can remove users from teams
CREATE POLICY "user_teams_delete_policy" ON user_teams
FOR DELETE
USING (
    (auth.jwt() ->> 'role') = 'admin'
);

