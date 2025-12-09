DROP POLICY IF EXISTS tasks_select_policy ON tasks;

CREATE POLICY tasks_select_policy ON tasks
FOR SELECT USING (true);

