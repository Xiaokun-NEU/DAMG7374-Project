
WITH params AS (
    SELECT 'How is Boston addressing violent crime in recent years?' AS QUESTION
),

-- 2️⃣ 生成查询 embedding
query_embedding AS (
    SELECT 
        QUESTION,
        SNOWFLAKE.CORTEX.EMBED_TEXT_768(
            'snowflake-arctic-embed-m',
            QUESTION
        ) AS Q_VEC
    FROM params
),

-- 3️⃣ 向量检索 Top 5 最相关段落
top_chunks AS (
    SELECT
        p.POLICY_ID,
        p.SOURCE_FILE,
        p.PAGE_NUMBER,
        p.CHUNK_TEXT,
        VECTOR_COSINE_SIMILARITY(p.EMBEDDING, q.Q_VEC) AS SCORE,
        q.QUESTION
    FROM POLICY_DOCUMENTS p,
         query_embedding q
    ORDER BY SCORE DESC
    LIMIT 5
),

-- 4️⃣ 合并文本上下文
combined_text AS (
    SELECT 
        LISTAGG(CHUNK_TEXT, ' ') AS FULL_CONTEXT,
        MAX(QUESTION) AS QUESTION
    FROM top_chunks
)

-- 5️⃣ 用 AI 生成最终回答
SELECT SNOWFLAKE.CORTEX.COMPLETE(
    'snowflake-arctic',
    'Based on the following official Boston policy documents, answer clearly and professionally.

    Question: ' || QUESTION || '

    Context:
    ' || FULL_CONTEXT
) AS AI_RESPONSE
FROM combined_text;
