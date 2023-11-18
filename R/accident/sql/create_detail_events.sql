CREATE TABLE IF NOT EXISTS detail_events (
  detail_event_id INTEGER PRIMARY KEY GENERATED BY DEFAULT AS IDENTITY,
  event_id INTEGER REFERENCES general_events(event_id),
  party_order SMALLINT,
  party_classification_category_main_category_name_vehicle VARCHAR(255),
  party_classification_category_sub_category_name_vehicle VARCHAR(255),
  party_gender_name VARCHAR(255),
  party_age_at_time_of_accident SMALLINT,
  protective_equipment_name VARCHAR(255),
  mobile_phone_or_computer_or_other_similar_device_name VARCHAR(255),
  party_action_status_main_category_name VARCHAR(255),
  party_action_status_sub_category_name VARCHAR(255),
  vehicle_impact_location_main_category_name_initial VARCHAR(255),
  vehicle_impact_location_sub_category_name_initial VARCHAR(255),
  vehicle_impact_location_main_category_name_other VARCHAR(255),
  vehicle_impact_location_sub_category_name_other VARCHAR(255),
  cause_classification_main_category_name_individual VARCHAR(255),
  cause_classification_sub_category_name_individual VARCHAR(255),
  hit_and_run_category_name VARCHAR(255)
);