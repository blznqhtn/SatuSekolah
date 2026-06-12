DROP TABLE IF EXISTS torrent_metadata;
DROP TABLE IF EXISTS canteen_discounts;
DROP TABLE IF EXISTS canteen_item_ingredients;
ALTER TABLE canteen_orders DROP COLUMN IF EXISTS delivery_method;
ALTER TABLE canteen_orders DROP COLUMN IF EXISTS preorder_date;
ALTER TABLE canteen_shops DROP COLUMN IF EXISTS allow_delivery;
ALTER TABLE canteen_shops DROP COLUMN IF EXISTS base_delivery_fee;
DROP TABLE IF EXISTS pkl_final_reports;
DROP TABLE IF EXISTS pkl_final_report_settings;
DROP TABLE IF EXISTS pkl_journals;
DROP TABLE IF EXISTS pkl_mentoring_schedules;
DROP TABLE IF EXISTS pkl_mentorships;

DROP TABLE IF EXISTS ribbon_borrowings;
DROP TABLE IF EXISTS menstrual_cycles;
DROP TABLE IF EXISTS health_settings;

ALTER TABLE health_records DROP COLUMN height;
ALTER TABLE health_records DROP COLUMN weight;
ALTER TABLE health_records DROP COLUMN hearing;
ALTER TABLE health_records DROP COLUMN vision;
ALTER TABLE health_records DROP COLUMN dental;
ALTER TABLE health_records DROP COLUMN hemoglobin;
DROP TABLE IF EXISTS pkl_monitorings;
DROP TABLE IF EXISTS performance_settings;
DROP TABLE IF EXISTS scientific_journals;
DROP TABLE IF EXISTS book_borrowings;
DROP TABLE IF EXISTS books;
DROP TABLE IF EXISTS library_settings;



