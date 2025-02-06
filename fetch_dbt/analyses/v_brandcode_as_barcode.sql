select
    cpg_oid,
    count(*) as ct
from
    dim_brand
where
    regexp_matches(brandcode, '\d{12}')
    and brandcode not like 'TEST%'
    and brandcode = barcode
group by cpg_oid
