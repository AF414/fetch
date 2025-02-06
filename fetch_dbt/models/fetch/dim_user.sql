{{
  config(
    materialized = 'table',
    )
}}
select distinct columns(*) from (
    select
        * replace (
            _id."$oid" as _id,
            epoch_ms(createddate."$date") as createddate,
            epoch_ms(lastlogin."$date") as lastlogin
        )
    from
        read_json(
            'https://fetch-hiring.s3.amazonaws.com/analytics-engineer/ineeddata-data-modeling/users.json.gz',
            format = 'newline_delimited',
            ignore_errors = True
        )
)
where _id is not Null
