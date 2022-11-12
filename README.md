# Stroke Risk Prediction Models
Source code for "Predictive Accuracy of Stroke Risk Prediction Models Across Black and White Race, Sex, and Age Groups" (under revision).

The code briefly described below can be used to reproduce the results in the paper assuming the data has been properly formatted and harmonized as described in [data harmonization](https://github.com/duke-harmonization/manual_harmonization).

Main results:

- create_ads.sas: create the analysis dataset
- recalibrating.sas: recalibrate previously published models
- table2.sas: creates tables 2a and 2b
- eTable5.sas: creates eTables 5a and 5b
- eTable6.sas: creates eTables 6a and 6b
- eTable7.sas: creates eTable 7
- eTable8.sas: creates eTable 8
- eFigure2: creates eFigure 2

Supplementary programs:

- formats.sas: contains SAS formats for categorical variables
- recalibration_macro.sas: macro used by recalibrating.sas
- cdx_uno.sas: macro used to create tables reporting c-index
- brier13.sas: macro used to create tables reporting brier score
- obsexp.sas: macro used to create tables reporting observed/expected values
- templates.zip: SAS templates used to create tables

The following tables and figures do not have code:

- Tables 1 and eTable 4: these two descriptive tables are created using proprietary macros that cannot be shared.
- eTables 2, 3 and 4: manually created.
- Figures 1, 2 and 3 and eFigure1: created in MS Excel. No code to share.

All analyses were performed in SAS version 9.4 (TS1M7).