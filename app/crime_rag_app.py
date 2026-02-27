import streamlit as st

try:
    from snowflake.snowpark.context import get_active_session
    session = get_active_session()
except:
    from snowflake.snowpark import Session
    session = Session.builder.config('connection_name', 'default').create()

st.title("Boston Crime & Policy Q&A")
st.caption("Ask questions about Boston crime data and city policies")

question = st.text_input("Enter your question:", placeholder="e.g., Which district has the most violent crime?")

if st.button("Ask", type="primary") and question:
    with st.spinner("Searching and generating answer..."):
        query = f"""
        WITH query_embedding AS (
            SELECT SNOWFLAKE.CORTEX.EMBED_TEXT_768('snowflake-arctic-embed-m', '{question.replace("'", "''")}') AS Q_VEC
        ),
        policy_results AS (
            SELECT 'POLICY' AS SOURCE_TYPE, SOURCE_FILE AS SOURCE_NAME, CHUNK_TEXT AS CONTENT,
                   VECTOR_COSINE_SIMILARITY(EMBEDDING, q.Q_VEC) AS SCORE
            FROM DAMG7374_CRIME_DATE.PUBLIC.POLICY_DOCUMENTS p, query_embedding q
        ),
        crime_results AS (
            SELECT 'CRIME_DATA' AS SOURCE_TYPE, SUMMARY_TYPE || ': ' || DIMENSION_VALUE AS SOURCE_NAME,
                   SUMMARY_TEXT AS CONTENT, VECTOR_COSINE_SIMILARITY(EMBEDDING, q.Q_VEC) AS SCORE
            FROM DAMG7374_CRIME_DATE.PUBLIC.CRIME_SUMMARIES c, query_embedding q
        ),
        top_chunks AS (
            SELECT * FROM (SELECT * FROM policy_results UNION ALL SELECT * FROM crime_results)
            ORDER BY SCORE DESC LIMIT 8
        ),
        combined AS (
            SELECT LISTAGG('[' || SOURCE_TYPE || ' - ' || SOURCE_NAME || ']: ' || CONTENT, CHR(10)||CHR(10)) AS CTX
            FROM top_chunks
        )
        SELECT SNOWFLAKE.CORTEX.COMPLETE('snowflake-arctic',
            'You are an expert on Boston crime data and city policies. Answer clearly with specific numbers when available.
            
Question: {question.replace("'", "''")}

Context:
' || CTX) AS RESPONSE
        FROM combined
        """
        
        result = session.sql(query).collect()
        
        if result and result[0]['RESPONSE']:
            st.subheader("Answer")
            st.write(result[0]['RESPONSE'])

with st.expander("Example questions"):
    st.markdown("""
- Which district has the most violent crime?
- What are Boston's policies on gun violence?
- How has crime changed over the years?
- What is the most common crime in Dorchester?
""")
