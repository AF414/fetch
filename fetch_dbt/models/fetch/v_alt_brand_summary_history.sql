with agg as (

    select
        date_trunc('month', rri.datescanned) as month_scanned,
        coalesce(b.name, rri.brandcode) as brand_name,
        count(distinct rri.receipt_id) as receipt_count,
        sum(rri.itemprice)
            as total_spent,
        sum(rri.quantitypurchased) as total_items,
        sum(
            case
                when
                    u.createddate > date_trunc('month', rri.datescanned)
                    - interval '6 months'
                    then
                        rri.itemprice
            end
        ) as user_within_last_6mo_total_spent,
        count(
            distinct
            case
                when
                    u.createddate > date_trunc('month', rri.datescanned)
                    - interval '6 months'
                    then rri.receipt_id
            end
        ) as user_within_last_6mo_total_transactions
    from {{ ref('fact_receipt_item') }} as rri
    left join {{ ref('dim_brand') }} as b
        on
            rri.brandcode = b.brandcode
            or rri.barcode = b.barcode
            or (rri.description = b.brandcode)
            -- trying some fuzzy matching ** risk of creating duplicate rows
            or jaro_winkler_similarity(rri.description, b.brandcode) > 0.90
            or (
                rri.rewardsproductpartnerid = b.cpg_oid
                and rri.rewardsproductpartnerid is not null
                and jaro_winkler_similarity(rri.description, b.brandcode)
                > 0.750
            )
    left join
        {{ ref('fact_receipt') }} as r
        on rri.receipt_id = r.receipt_id
    left join {{ ref('dim_user') }} as u on r.userid = u._id
    where
        len(r.rewardsreceiptitemlist) > 0 -- remove empty receipts
        and r.rewardsreceiptstatus not in ('REJECTED') -- remove rejected receipts
        and r.userid not in (
            select _id from {{ ref('dim_user') }} where role = 'fetch-staff' -- remove fetch-staff users
        )
    group by month_scanned, brand_name
),

ext as (

    select
        *,
        dense_rank()
            over (partition by month_scanned order by receipt_count desc)
            as month_receipt_count_rank,
        dense_rank()
            over (partition by month_scanned order by total_spent desc)
            as month_total_spent_rank,
        dense_rank()
            over (partition by month_scanned order by total_items desc)
            as month_total_items_rank
    from agg
)

select
    *,
    lag(month_receipt_count_rank, 1)
        over (partition by brand_name order by month_scanned)
    - month_receipt_count_rank
        as receipt_count_rank_change_mom,
    lag(month_total_spent_rank, 1)
        over (partition by brand_name order by month_scanned)
    - month_total_spent_rank
        as spend_rank_change_mom
from ext

order by month_scanned, month_receipt_count_rank
