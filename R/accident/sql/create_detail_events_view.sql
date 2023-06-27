CREATE VIEW detail_events_view AS
SELECT 
  event_id,
  party_order,
  party_classification_category_main_category_name_vehicle,
  party_classification_category_sub_category_name_vehicle,
  party_gender_name,
  party_age_at_time_of_accident,
  protective_equipment_name,
  mobile_phone_or_computer_or_other_similar_device_name,
  party_action_status_sub_category_name,
  vehicle_impact_location_main_category_name_initial,
  vehicle_impact_location_sub_category_name_initial,
  cause_classification_main_category_name_individual,
  cause_classification_sub_category_name_individual,
  hit_and_run_category_name
FROM detail_events;
