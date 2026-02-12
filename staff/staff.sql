INSERT INTO staff_users (
    org_id, 
    staff_id,
    first_name, 
    last_name, 
    initials, 
    role, 
    pin_hash
) VALUES 
/* 1. The Nurse (Matching ID from Ethel's log) */
(
    'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 
    'nurse.sarah', 
    'Sarah', 
    'Jenkins', 
    'SJ', 
    'Nurse', 
    '$2a$12$eXAmPL3Ha5H_fake_hash_value_for_pin_1234' 
),

/* 2. Carer 1 */
(
    'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 
    'carer.david', 
    'David', 
    'Lister', 
    'DL', 
    'Carer', 
    '$2a$12$eXAmPL3Ha5H_fake_hash_value_for_pin_5678'
),

/* 3. Carer 2 */
(
    'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 
    'carer.kelly', 
    'Kelly', 
    'Brook', 
    'KB', 
    'Carer', 
    '$2a$12$eXAmPL3Ha5H_fake_hash_value_for_pin_9012'
),

/* 4. Carer 3 */
(
    'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 
    'carer.mo', 
    'Mohammed', 
    'Ali', 
    'MA', 
    'Carer', 
    '$2a$12$eXAmPL3Ha5H_fake_hash_value_for_pin_3456'
);