-- checksum calculation 
-- (https://www.gs1.org/services/how-calculate-check-digit-manually)
with initial as (
    select
        receipt_id,
        barcode,
        split(lpad(barcode, 14, '0'), '')::float[14] as v
    from fact_receipt_item
),

dot as (
    select
        *,
        v[-1] as csum,
        array_dot_product(
            v, [3, 1, 3, 1, 3, 1, 3, 1, 3, 1, 3, 1, 3, 0]::float[14]
        ) as n
    from initial
)

select
    *,
    (n + 9) - ((n + 9) % 10) - n as calc_csum,
    (n + 9) - ((n + 9) % 10) - n = csum as checksum_result
from dot
where
    checksum_result = false
    and len(barcode) >= 12
    and not regexp_matches(barcode, '([a-zA-Z]+)')
order by barcode;
