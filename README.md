# CityLens - AI drived tool to answers questions about Boston

## Overview
CityLens is a data-driven urban intelligence platform that analyzes whether public policies in Boston have measurable impacts on crime trends and transportation.

## Problem Statement

Urban data (traffic, crime, air quality) and public policy data (government reports, regulatory documents) are fragmented across multiple platforms. Users lack a unified interface to query structured data and contextual policy explanations together.

CivicPulse AI integrates structured city metrics with unstructured public reports and enables natural language querying with traceable, data-backed explanations.

## The project integrates:
- Boston Crime Data (2018–2025)

- Boston Government Policy Data

- Snowflake Data Warehouse

- ELT Data Engineering Pipeline

- Generative AI (LLM-based policy impact explanation)

## Architecture Overview

1. Data Ingestion Layer

- Crime raw data → ETL → Canonical Schema

- Policy PDFs → Chunking → Embedding


2. Storage Layer

- Structured tables (crime, housing, transport)

- Vectorized policy documents

3. Retrieval Layer

- SQL-based analytics

- Vector similarity search


4. LLM Synthesis Layer

- Cortex COMPLETE


5. Presentation Layer

- Natural language answer

- Evidence citation

## Technology Use

We selected Snowflake as our structured data warehouse because:

Native support for semi-structured data (JSON)

Scalable compute-storage separation

Enterprise-grade governance and security

Strong SQL analytics capability

Easy integration with Python connector

Suitable for canonical fact-based schema design

Alternative considered:

PostgreSQL → Lower cost but less scalable for large analytical workloads

BigQuery → Similar features but Snowflake offers more flexibility in external stages


## Current Progress
- Canonical schema designed

- Initial datasets loaded into warehouse

- ETL scripts implemented

- Basic RAG pipeline implemented

- Hybrid retrieval under development