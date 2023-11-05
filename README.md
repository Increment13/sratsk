# description of data
#### Loan_data
In table Loan_data there is information about short term loans (term is shorter than 5 months) that
were issued from July 2022:
- Loan_id,
- Client_id,
- Start_date – date when loan started,
- Loan_amount – actual principal amount issued,
- Due_date – date when loan needs to be repaid,
- Loan status – status of a loan as at today, 5 – means loan is paid, 4 – means loan is not paid.
- Scoring_score – risk score at the moment of application.
#### Client_data
In table Client_data there is information of a client at the moment of registration:
- Client_id,
- Birthday,
- Gender,
- Monthly salary – income that client fills in.
#### Payment_data
In table Payment_data there is information about loan repayments:
- Loan_id,
- Payment_date – date of a payment,
- Paid_principal – this payment’s principal part,
- Paid_fines – this payment’s fines part,
- Paid_other - this payment’s part that is not principal and not fines (all the loan related fees).

# Results 
1. Data analysis
    - Client_data
        - there are a small number of gaps in the data
        - The data contains a client with monthly_salary exceeding 10 times (hard outlier)
    - Loan_data
        - The data contains gaps in the scoring_score field
        - In the data there are 4 clients that do not meet the criterion of having one short contract (duration <= 1 month)
        - Some clients have non-calendar and non-30 day installations
    - Payment_data
        - from 2019-01-01 to 2022-01-01 non-presentable data, presumably test data
        - we see anomalies for clients with due_date November 2022, there are no payments for clients with 30+dpd and above        
    - General observations
        - 31.8% of unique loan_ids and those present in Loan_data are missing in the Payment_data table (you need to look at the filling logic)
        - 15.4% of unique loan_ids and those present in Payment_data are missing from the Loan_data table (inexplicable, obvious error)
        - Using the isolation forest model and the nearest neighbors method in the ensemble shows ~7% anomalies in the data, detailed analysis is required
2. Metric analysis
    - The share of clients (of the entire portfolio) has dpd30+ 14.7% with a peak value of 19.1%
    - The share of overdue payments (from the entire portfolio) has dpd30+ 12.2% with a peak value of 16.8%
    - There is a trend of increasing overdue
    - In October 2023, we observed a deterioration in recovery; with overdue increasing to 16.8%, we have a minimum recovery rate of 5.11% (7.1% on average) 
3. Offers
    - DC
        - Segment clients for work, the data shows that clients are susceptible to overdue of dpd30+
            - clients aged 20-25 years
            - scoring_score 300-420
        - If calls are not made on weekends, generate additional mailings(sms, chats). Most payments arrive early in the week
        - Increase staff, projected workload increase from December 2023
        - It is necessary to check the MS and spin rate. Presumably, the increase in overdue was not blocked in October 2023
    -Data
        - It is necessary to do additional control of incoming data
