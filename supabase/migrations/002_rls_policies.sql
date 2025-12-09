ALTER TABLE leads ENABLE ROW LEVEL SECURITY;
ALTER TABLE applications ENABLE ROW LEVEL SECURITY;
ALTER TABLE tasks ENABLE ROW LEVEL SECURITY;
ALTER TABLE teams ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_teams ENABLE ROW LEVEL SECURITY;

CREATE POLICY leads_select_policy ON leads
FOR SELECT USING (
    (auth.jwt() ->> 'role') = 'admin'
    OR owner_id = auth.uid()
    OR owner_id IN (
        SELECT ut2.user_id
        FROM user_teams ut1
        JOIN user_teams ut2 ON ut1.team_id = ut2.team_id
        WHERE ut1.user_id = auth.uid()
    )
);

CREATE POLICY leads_insert_policy ON leads
FOR INSERT WITH CHECK (
    (auth.jwt() ->> 'role') = 'admin'
    OR (
        (auth.jwt() ->> 'role') = 'counselor'
        AND owner_id = auth.uid()
    )
);

CREATE POLICY leads_update_policy ON leads
FOR UPDATE USING (
    (auth.jwt() ->> 'role') = 'admin'
    OR owner_id = auth.uid()
)
WITH CHECK (
    (auth.jwt() ->> 'role') = 'admin'
    OR owner_id = auth.uid()
);

CREATE POLICY leads_delete_policy ON leads
FOR DELETE USING ((auth.jwt() ->> 'role') = 'admin');

CREATE POLICY applications_select_policy ON applications
FOR SELECT USING (
    (auth.jwt() ->> 'role') = 'admin'
    OR lead_id IN (
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

CREATE POLICY applications_insert_policy ON applications
FOR INSERT WITH CHECK (
    (auth.jwt() ->> 'role') = 'admin'
    OR lead_id IN (
        SELECT id FROM leads WHERE owner_id = auth.uid()
    )
);

CREATE POLICY applications_update_policy ON applications
FOR UPDATE USING (
    (auth.jwt() ->> 'role') = 'admin'
    OR lead_id IN (
        SELECT id FROM leads WHERE owner_id = auth.uid()
    )
)
WITH CHECK (
    (auth.jwt() ->> 'role') = 'admin'
    OR lead_id IN (
        SELECT id FROM leads WHERE owner_id = auth.uid()
    )
);

CREATE POLICY applications_delete_policy ON applications
FOR DELETE USING ((auth.jwt() ->> 'role') = 'admin');

CREATE POLICY tasks_select_policy ON tasks
FOR SELECT USING (
    (auth.jwt() ->> 'role') = 'admin'
    OR related_id IN (
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
    OR assigned_to = auth.uid()
);

CREATE POLICY tasks_insert_policy ON tasks
FOR INSERT WITH CHECK (
    (auth.jwt() ->> 'role') = 'admin'
    OR related_id IN (
        SELECT id FROM applications
        WHERE lead_id IN (
            SELECT id FROM leads WHERE owner_id = auth.uid()
        )
    )
);

CREATE POLICY tasks_update_policy ON tasks
FOR UPDATE USING (
    (auth.jwt() ->> 'role') = 'admin'
    OR assigned_to = auth.uid()
    OR related_id IN (
        SELECT id FROM applications
        WHERE lead_id IN (
            SELECT id FROM leads WHERE owner_id = auth.uid()
        )
    )
)
WITH CHECK (
    (auth.jwt() ->> 'role') = 'admin'
    OR assigned_to = auth.uid()
    OR related_id IN (
        SELECT id FROM applications
        WHERE lead_id IN (
            SELECT id FROM leads WHERE owner_id = auth.uid()
        )
    )
);

CREATE POLICY tasks_delete_policy ON tasks
FOR DELETE USING ((auth.jwt() ->> 'role') = 'admin');

CREATE POLICY teams_select_policy ON teams
FOR SELECT USING (
    (auth.jwt() ->> 'role') = 'admin'
    OR id IN (
        SELECT team_id FROM user_teams WHERE user_id = auth.uid()
    )
);

CREATE POLICY teams_insert_policy ON teams
FOR INSERT WITH CHECK ((auth.jwt() ->> 'role') = 'admin');

CREATE POLICY teams_update_policy ON teams
FOR UPDATE USING ((auth.jwt() ->> 'role') = 'admin')
WITH CHECK ((auth.jwt() ->> 'role') = 'admin');

CREATE POLICY teams_delete_policy ON teams
FOR DELETE USING ((auth.jwt() ->> 'role') = 'admin');

CREATE POLICY user_teams_select_policy ON user_teams
FOR SELECT USING (
    (auth.jwt() ->> 'role') = 'admin'
    OR user_id = auth.uid()
);

CREATE POLICY user_teams_insert_policy ON user_teams
FOR INSERT WITH CHECK ((auth.jwt() ->> 'role') = 'admin');

CREATE POLICY user_teams_delete_policy ON user_teams
FOR DELETE USING ((auth.jwt() ->> 'role') = 'admin');
