{{
  config(
    materialized = 'table',
    )
}}
select
    * replace (trim(brandCode) as brandCode),
    _id."$oid" as brand_id,
    cpg."$id"."$oid" as cpg_oid,
    cpg."$ref" as cpg_ref
from
    read_json(
        'https://fetch-hiring.s3.amazonaws.com/analytics-engineer/ineeddata-data-modeling/brands.json.gz',
        format = 'newline_delimited',
        ignore_errors = True
    )

where brandCode not like 'TEST%'
