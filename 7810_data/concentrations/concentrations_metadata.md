# concentrations_metadata.md

These fields are all produced by the Li-Cor Smart Chamber,
except for `obs` and `TIMESTAMP`, which are added by the `fluxfinder` package
used to read the raw files.

Data documentation: https://www.licor.com/env/support/Smart-Chamber/topics/data-files.html#Data2

| Column name | Description |
| ----------- | ----------- |
| label | Label of observation, entered by user |
| obs | Observation number in file |
| remark | Remark, entered by user |
| Chamber | Smart Chamber model |
| Version | Smart Chamber software version |
| InstrumentModel | IRGA analyzer |
| InstrumentSerialNumber | IRGA serial number |
| RepNum | Repetition (within observation) number |
| DeadBand | Dead band time, s |
| Area | Soil surface area, cm2 |
| Offset | Collar offset, cm |
| ChamVolume | Chamber volume, cm3 |
| IrgaVolume | Gas analyzer optical bench volume including tubing, cm3 |
| TotalVolume | Total system volume, cm3 |
| gps_time | GPS Time (seconds since 05 Jan 1980) |
| latitude | Latitude of measurement, degrees N |
| longitude | Longitude of measurement, degrees E |
| gps_hdop | GPS dilution of precision |
| altitude | Altitude of measurement, m |
| gps_sats | GPS number of satellites? |
| TimeZone | Time zone of data |
| chamber_p | Chamber pressure, kPa |
| chamber_p_t | Chamber pressure sensor temperature, degrees C |
| chamber_t | Chamber temperature, degrees C |
| soil_t | Thermocouple soil temperature, degrees C |
| soilp_c | Stevens probe soil electrical conductivity, S/m |
| soilp_m | Stevens probe soil moisture, m3/m3 |
| soilp_t | Stevens probe soil temperature, degrees C |
| ch4 | Methane concentration, ppbv |
| co2 | Carbon dioxide concentration, ppmv |
| h2o | Water vapor mole fraction, mmol/mol |
| err | Error code from LI-78xx |
| ch4_F_o | Exponential fit computed CH4 flux, nmol/m2/s |
| ch4_F_cv | Flux coefficient of variance, % |
| ch4_t_o | t0 term for the exponential fit, s |
| ch4_C_o | Initial CH4 concentration, ppbv |
| ch4_a | Alpha term for the exponential fit |
| ch4_C_x | C∞ term for the exponential fit |
| ch4_iter | Number of iterations for convergence of exponential model? |
| ch4_sei | Standard error of the intercept of the concentration vs. time curve, % |
| ch4_ses | Standard error of the slope of the concentration vs. time curve, % |
| ch4_r2 | CH4 flux model R2 |
| ch4_slope | Slope of CH4 observations, ppbv/s |
| ch4_domain | Number of data points in the observation length |
| ch4_n | Number of data points used for exponential curve fitting |
| co2_F_o | Exponential fit computed CH4 flux, µmol/m2/s |
| co2_F_cv | Flux coefficient of variance, % |
| co2_t_o | t0 term for the exponential fit, s |
| co2_C_o | Initial CO2 concentration, ppmv |
| co2_a | Alpha term for the exponential fit |
| co2_C_x | C∞ term for the exponential fit |
| co2_iter | Number of iterations for convergence of exponential model? |
| co2_sei | Standard error of the intercept of the concentration vs. time curve, % |
| co2_ses | Standard error of the slope of the concentration vs. time curve, % |
| co2_r2 | CO2 flux model R2 |
| co2_slope | Slope of CO2 observations, ppmv/s |
| co2_domain | Number of data points in the observation length |
| co2_n | Number of data points used for exponential curve fitting |
| TIMESTAMP | Timestamp of observations, within time zone |
