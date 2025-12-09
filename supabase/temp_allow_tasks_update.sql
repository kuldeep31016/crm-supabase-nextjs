DROP POLICY IF EXISTS tasks_update_policy ON tasks;

CREATE POLICY tasks_update_policy ON tasks
FOR UPDATE USING (true)
WITH CHECK (true);
