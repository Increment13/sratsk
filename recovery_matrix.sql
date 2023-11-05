with data_recovery as(
select
	a.loan_id,
	a.start_date,
	a.due_date,
	sum(case when payment_date <= due_date then paid_principal else 0 end) paid_before_due,
	sum(case when payment_date>due_date then paid_principal else 0 end) recovery_total,
	sum(case when payment_date >= DATEADD(day, 1, due_date) and payment_date<DATEADD(day, 15, due_date) then paid_principal else 0 end) recovery_01_15,
	sum(case when payment_date >= DATEADD(day, 15, due_date) and payment_date<DATEADD(day, 30, due_date) then paid_principal else 0 end) recovery_15_30,
	sum(case when payment_date >= DATEADD(day, 30, due_date) and payment_date<DATEADD(day, 45, due_date) then paid_principal else 0 end) recovery_30_45,
	sum(case when payment_date >= DATEADD(day, 45, due_date) and payment_date<DATEADD(day, 60, due_date) then paid_principal else 0 end) recovery_45_60,
	sum(case when payment_date >= DATEADD(day, 60, due_date) and payment_date<DATEADD(day, 90, due_date) then paid_principal else 0 end) recovery_60_90
from
	sratsk.loan_data a
left join sratsk.payment_data b
on
	a.loan_id = b.loan_id
where
	a.due_date<'2023-11-01'
group by
	a.loan_id,
	a.start_date,
	a.due_date), 
data_coolection as (
select
	dateadd(month, datediff(month, 0, rec.due_date), 0) month_due, 
	rec.loan_id,
	lnd.loan_amount,
	rec.paid_before_due,
	rec.recovery_total,
	rec.recovery_01_15,
	rec.recovery_15_30,
	rec.recovery_30_45,
	rec.recovery_45_60,
	rec.recovery_60_90,	
	lnd.loan_amount - rec.paid_before_due as overdue_amount_01_15, 
	lnd.loan_amount - rec.paid_before_due - rec.recovery_01_15 as overdue_amount_15_30,
	lnd.loan_amount - rec.paid_before_due - rec.recovery_01_15 - recovery_15_30 as overdue_amount_30_45,
	lnd.loan_amount - rec.paid_before_due - rec.recovery_01_15 - recovery_15_30 - recovery_30_45 as overdue_amount_45_60,
	lnd.loan_amount - rec.paid_before_due - rec.recovery_01_15 - recovery_15_30 - recovery_30_45 - recovery_45_60 as overdue_amount_60_90,
	lnd.loan_amount - rec.paid_before_due - rec.recovery_total as overdue_amount,
	case
		when (lnd.loan_amount - rec.paid_before_due) > 0 then 1
		else 0
	end dpd_01_15,
	case
		when (lnd.loan_amount - rec.paid_before_due - rec.recovery_01_15) > 0 then 1
		else 0
	end dpd_15_30,
	case
		when (lnd.loan_amount - rec.paid_before_due - rec.recovery_01_15 - rec.recovery_15_30) > 0 then 1
		else 0
	end dpd_30_45,
	case
		when (lnd.loan_amount - rec.paid_before_due - rec.recovery_01_15 - rec.recovery_15_30 - rec.recovery_30_45) > 0 then 1
		else 0
	end dpd_45_60,
	case
		when (lnd.loan_amount - rec.paid_before_due - rec.recovery_01_15 - rec.recovery_15_30 - rec.recovery_30_45 - recovery_45_60) > 0 then 1
		else 0
	end dpd_60_90,
	1 cnt
from
	sratsk.loan_data lnd
join data_recovery rec 
on
	lnd.loan_id = rec.loan_id)
select
	month_due,
	avg(dpd_01_15) share_dpd_01_15,
	avg(dpd_15_30) share_dpd_15_30,
	avg(dpd_30_45) share_dpd_30_45,
	avg(dpd_45_60) share_dpd_45_60,
	sum(overdue_amount_01_15)/ sum(loan_amount) share_overdue_01_15,
	sum(overdue_amount_15_30)/ sum(loan_amount) share_overdue_15_30,
	sum(overdue_amount_30_45)/ sum(loan_amount) share_overdue_30_45,
	sum(overdue_amount_45_60)/ sum(loan_amount) share_overdue_45_60,
	sum(recovery_01_15)/ sum(overdue_amount_01_15) share_recovery_01_15,
	sum(recovery_15_30)/ sum(overdue_amount_15_30) share_recovery_15_30,
	sum(recovery_30_45)/ sum(overdue_amount_30_45) share_recovery_30_45,
	sum(recovery_45_60)/ sum(overdue_amount_45_60) share_recovery_45_60
from
	data_coolection
group by
	month_due
order by 1