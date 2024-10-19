SELECT project_id,
       trackable_type,
       trackable_id,
       SUM(clicks)::BIGINT as clicks,
       SUM(views)::BIGINT as views,
       DATE_TRUNC('month', project_statistics.date_hour)::DATE as month
FROM project_statistics
GROUP BY project_id,
         trackable_type,
         trackable_id,
         DATE_TRUNC('month', project_statistics.date_hour)::DATE
