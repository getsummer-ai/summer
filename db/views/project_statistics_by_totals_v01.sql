SELECT project_id,
       trackable_type,
       trackable_id,
       SUM(clicks)::BIGINT as clicks,
       SUM(views)::BIGINT as views
FROM project_statistics ps
GROUP BY project_id, trackable_type, trackable_id
