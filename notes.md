### first meeting notes:

L-U: replace unknown with No

zerotroponin probs most usefull for troponin

CT:DA outpatient testing
 - or AN:AT

ignore AW:BD

can use ED and hospital lengths of stay instead of values in BH/BI (EDlos/hoslos)

DO:on are the outcomes to be used

control variables:
	> time from site start (start date is different from each hospital)
	

### Endpoints

#### Primary outcome 

- Hospital length of stay for patients with a presentation troponin <=2 
- Hoslos and zero_trop<=2 

#### Secondary outcomes (these endpoints need to be calculated for patients with a presentation troponin <=2 and for the entire cohort).  

- The proportion of patients discharged from hospital within 4 hours of presentation and without a subsequent AMI within 30 days  
  - Hoslos and thirtyevents 



- A cumulative composite endpoint of all-cause mortality, new non-fatal AMI within 30 days, or unplanned revascularisation within 30 days.  
  - Thirtyevents 

- Hospital length of stay, hospital representations and in-patient admissions over 6 months 
  - Hoslos, presentation_number, inpatientadmissions 

inpatient admission column = whtehr they weent from ED to inpatietn
  > no need for a separate inpatientadmissions ep

- Downstream testing: Stress testing, echocardiography, coronary angiography, coronary CT angiography up to 6 months after presentation 
  - EST through to MRI, then Outpatient_est through to outpatient MRI 
  - The EST through to MRI could be in any of the index or representations  

  - We would need a composite plus a table with the individual tests.  

  > no model
  > table reporting each of them separately (EST:MRI)
    > group_by(pt_id) |> recode outcomes as 1 if any in the next 6 months
    > and another for if any test over the 6 months
    > just used for descriptive comparison between interventiona dn non-intervention groups and counts of patients


- Cost effectiveness: incorporating healthcare utilisation up to 6 months after presentation and health-related quality of life 

  - Ignore this 

 
- Patient reported outcomes (quality of life) and patient experiences 6 months after presentation 

  - Experience_1 experience_2, eq5d_1 to eq5d_5 
    > EQ5D gets summed together
    > patient experience questions get reported separately
  - Just descriptives required I think! 


### meeting on 29-08-24

testing model
- get rid of admit_days_since_2019 from model
- try traditional interrupted time series model with linear effect of time since site start and interaction on `intervention` as a factor (try for primary outcomes first: hoslos and earlydisch_no30d_event); include some visualisation for interrupted time series too
- investigate more flexible splines for the time since site start
- double check coding of ep_6month_readmission_n

repeat cardiac ax, eq5d, patient-experience tables for both inpatient and outpatient with the lod cohort 
<!-- data_first_presentation_low_trop <- data |>
    filter(
      presentation_no == 1,
      troponin <= troponin_lod
    ) -->
