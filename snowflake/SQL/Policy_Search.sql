-- ================================
-- 1️⃣ 语义搜索（Top-K）
-- ================================

WITH query_embedding AS (
    SELECT SNOWFLAKE.CORTEX.EMBED_TEXT_768(
        'snowflake-arctic-embed-m',
        'youth violence prevention programs'
    ) AS Q_VEC
)

SELECT
    POLICY_ID,
    SOURCE_FILE,
    PAGE_NUMBER,
    CHUNK_TEXT,
    VECTOR_COSINE_SIMILARITY(EMBEDDING, Q_VEC) AS SCORE
FROM POLICY_DOCUMENTS, query_embedding
ORDER BY SCORE DESC
LIMIT 5;


-- ================================
-- 2️⃣ 跨政策平均相关度分析
-- ================================

WITH query_embedding AS (
    SELECT SNOWFLAKE.CORTEX.EMBED_TEXT_768(
        'snowflake-arctic-embed-m',
        'mental health initiatives'
    ) AS Q_VEC
)

SELECT
    POLICY_ID,
    AVG(VECTOR_COSINE_SIMILARITY(EMBEDDING, Q_VEC)) AS AVG_SCORE
FROM POLICY_DOCUMENTS, query_embedding
GROUP BY POLICY_ID
ORDER BY AVG_SCORE DESC;
