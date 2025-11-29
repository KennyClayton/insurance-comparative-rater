-- Insurance Comparative Rater System
-- Analytical SQL Queries
-- Author: Kenny Clayton
-- Date: November 2025

-- ========================================
-- CARRIER PERFORMANCE ANALYSIS
-- ========================================

-- Query 1: View carrier performance summary
SELECT * FROM carrier_performance_summary;

-- Query 2: Find fastest responding carrier
SELECT 
    carrier_name,
    avg_response_time
FROM carriers
WHERE status = 'Active'
ORDER BY avg_response_time
LIMIT 1;

-- Query 3: Count tests by status
SELECT 
    test_status,
    COUNT(*) as count,
    ROUND(COUNT(*)::DECIMAL / (SELECT COUNT(*) FROM api_test_results) * 100, 2) as percentage
FROM api_test_results
GROUP BY test_status
ORDER BY count DESC;

-- Query 4: Identify carriers with failed tests
SELECT DISTINCT
    c.carrier_name,
    c.api_endpoint,
    t.test_case_id,
    t.error_details,
    t.test_date
FROM carriers c
JOIN api_test_results t ON c.carrier_id = t.carrier_id
WHERE t.test_status = 'FAIL'
ORDER BY t.test_date DESC;

-- Query 5: Average response time by carrier with test count
SELECT 
    c.carrier_name,
    COUNT(t.test_id) as total_tests,
    ROUND(AVG(t.response_time), 2) as avg_response_time,
    MIN(t.response_time) as fastest_response,
    MAX(t.response_time) as slowest_response
FROM carriers c
LEFT JOIN api_test_results t ON c.carrier_id = t.carrier_id
WHERE t.test_status = 'PASS'
GROUP BY c.carrier_id, c.carrier_name
ORDER BY avg_response_time;

-- Query 6: Test results with carrier details
SELECT 
    t.test_case_id,
    c.carrier_name,
    t.test_date,
    t.response_time,
    t.test_status,
    t.error_details,
    t.tested_by
FROM api_test_results t
JOIN carriers c ON t.carrier_id = c.carrier_id
ORDER BY t.test_date DESC;

-- Query 7: Carriers meeting performance SLA (<3 seconds)
SELECT 
    carrier_name,
    avg_response_time,
    CASE 
        WHEN avg_response_time < 3.0 THEN 'Meets SLA'
        ELSE 'Below SLA'
    END as sla_status
FROM carriers
WHERE status = 'Active'
ORDER BY avg_response_time;

-- ========================================
-- BUSINESS INSIGHTS
-- ========================================

-- Query 8: Success rate analysis with recommendations
SELECT 
    c.carrier_name,
    COUNT(t.test_id) as total_tests,
    COUNT(CASE WHEN t.test_status = 'PASS' THEN 1 END) as passed,
    ROUND((COUNT(CASE WHEN t.test_status = 'PASS' THEN 1 END)::DECIMAL / COUNT(t.test_id) * 100), 2) as success_rate,
    CASE 
        WHEN ROUND((COUNT(CASE WHEN t.test_status = 'PASS' THEN 1 END)::DECIMAL / COUNT(t.test_id) * 100), 2) >= 95 THEN 'Production Ready'
        WHEN ROUND((COUNT(CASE WHEN t.test_status = 'PASS' THEN 1 END)::DECIMAL / COUNT(t.test_id) * 100), 2) >= 75 THEN 'Needs Monitoring'
        ELSE 'Requires Investigation'
    END as recommendation
FROM carriers c
LEFT JOIN api_test_results t ON c.carrier_id = t.carrier_id
GROUP BY c.carrier_id, c.carrier_name
ORDER BY success_rate DESC;
