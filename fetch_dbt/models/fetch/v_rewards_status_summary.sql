select
    r.rewardsreceiptstatus,
    r.pointsawardeddate is not null as points_awarded,
    count(*) as ct,
    round(sum(coalesce(r.totalspent, 0)), 2) as sum_spent,
    round(avg(coalesce(r.totalspent, 0)), 2) as avg_spend,
    round(sum(coalesce(r.purchaseditemcount, 0)), 2) as sum_item_counts,
    round(avg(coalesce(r.purchaseditemcount, 0)), 2) as avg_item_counts,
    round(sum(coalesce(i.items_in_receipt_list, 0)), 2) as sum_item_level_count,
    round(avg(coalesce(i.items_in_receipt_list, 0)), 2) as avg_item_level_count
from {{ ref('fact_receipt') }} as r
left join {{ ref('fact_receipt_item') }} as i on r.receipt_id = i.receipt_id
where
    r.userid not in (
        select _id from {{ ref('dim_user') }} where role = 'fetch-staff'
    )
    and i.deleted is not true
    and len(r.rewardsreceiptitemlist) > 0
group by r.rewardsreceiptstatus, points_awarded
