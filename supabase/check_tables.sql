SELECT table_name 
FROM information_schema.tables 
WHERE table_schema = 'public' 
AND table_name IN ('leads', 'applications', 'tasks', 'teams', 'user_teams')
ORDER BY table_name;

