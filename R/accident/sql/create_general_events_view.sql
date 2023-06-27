CREATE VIEW general_events_view AS
SELECT
  event_id,
  occurrence_date,
  longitude,
  latitude,
  accident_category_name,
  handling_unit_name_police_department_level,
  location,
  accident_location_sub_category_name,
  road_obstacle_obstacle_name,
  road_obstacle_visibility_quality_name,
  road_obstacle_visibility_name,
  traffic_light_signal_type_name,
  traffic_light_signal_action_name,
  accident_type_and_category_main_category_name,
  accident_type_and_category_sub_category_name,
  cause_classification_main_category_name_primary,
  cause_classification_sub_category_name_primary,
  number_of_deaths,
  number_of_injuries
FROM general_events;
