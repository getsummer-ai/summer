SELECT pas.project_url_id,
       SUM(pas.clicks)::BIGINT as clicks,
       SUM(pas.views)::BIGINT as views
FROM project_article_statistics pas
GROUP BY pas.project_url_id
