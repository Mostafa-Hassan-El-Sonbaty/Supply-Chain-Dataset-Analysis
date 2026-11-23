/* Overall Business Analysis*/
WITH item_by_order AS (
    SELECT
        order_id,
        COUNT(*) AS items_count,
        SUM(price) AS sales,
        SUM(freight_value) AS freight
    FROM clean.order_items
    GROUP BY order_id
),

item_kpis AS (
    SELECT
        COUNT(*) AS orders_with_items,
        SUM(items_count) AS total_items,
        SUM(sales) AS total_sales,
        SUM(freight) AS total_freight,
        AVG(sales) AS avg_order_value
    FROM item_by_order
),

order_kpis AS (
    SELECT
        COUNT(*) AS total_orders,
        COUNT(*) FILTER (
            WHERE order_status = 'delivered'
        ) AS delivered_orders,
        COUNT(*) FILTER (
            WHERE order_status = 'canceled'
        ) AS canceled_orders
    FROM clean.orders
),

payment_kpis AS (
    SELECT SUM(payment_value) AS total_payment
    FROM clean.payments
)

SELECT
    o.total_orders,
    i.orders_with_items,
    i.total_items,
    ROUND(i.total_sales::numeric, 2) AS merchandise_sales,
    ROUND(i.total_freight::numeric, 2) AS total_freight,
    ROUND(i.avg_order_value::numeric, 2) AS avg_order_value,
    ROUND(p.total_payment::numeric, 2) AS total_payment,
    o.delivered_orders,
    o.canceled_orders,
    ROUND(
        100.0 * o.delivered_orders /
        NULLIF(o.total_orders, 0), 2
    ) AS delivered_percentage

FROM order_kpis o
CROSS JOIN item_kpis i
CROSS JOIN payment_kpis p;
/* Payment Method Performance */

SELECT
    payment_type,

    COUNT(*) AS payment_records,

    COUNT(DISTINCT order_id) AS unique_orders,

    ROUND(SUM(payment_value)::numeric, 2)
        AS total_payment_value,

    ROUND(
        100.0 * SUM(payment_value) /
        NULLIF(SUM(SUM(payment_value)) OVER (), 0),
        2
    ) AS payment_share_percentage,

    ROUND(
        100.0 * COUNT(*) /
        NULLIF(SUM(COUNT(*)) OVER (), 0),
        2
    ) AS payment_record_share_percentage,

    ROUND(AVG(payment_value)::numeric, 2)
        AS avg_payment_value,

    ROUND(AVG(payment_installments)::numeric, 2)
        AS avg_installments

FROM clean.payments

GROUP BY payment_type

ORDER BY total_payment_value DESC;

/** Sales by Product Category***/
SELECT

    COALESCE(
        t.product_category_name_english,
        p.product_category_name,
        'Unknown'
    ) AS product_category,

    COUNT(*) AS items_sold,

    COUNT(DISTINCT oi.order_id) AS total_orders,

    ROUND(SUM(oi.price)::numeric, 2)
        AS total_sales,

    ROUND(AVG(oi.price)::numeric, 2)
        AS average_item_price,

    ROUND(SUM(oi.freight_value)::numeric, 2)
        AS total_freight

FROM clean.order_items oi

LEFT JOIN clean.products p
    ON oi.product_id = p.product_id

LEFT JOIN clean.translation t
    ON p.product_category_name =
       t.product_category_name

GROUP BY 1

ORDER BY total_sales DESC;
/*Sales by Customer Region**/
WITH sales_per_order AS (

    SELECT
        order_id,
        SUM(price) AS merchandise_sales,
        SUM(freight_value) AS freight
    FROM clean.order_items
    GROUP BY order_id

)

SELECT

    c.customer_state,

    COUNT(DISTINCT o.order_id) AS total_orders,

    ROUND(
        SUM(s.merchandise_sales)::numeric, 2
    ) AS total_sales,

    ROUND(
        SUM(s.freight)::numeric, 2
    ) AS total_freight,

    ROUND(
        AVG(s.merchandise_sales)::numeric, 2
    ) AS average_order_value

FROM clean.orders o

JOIN clean.customers c
    ON o.customer_id = c.customer_id

LEFT JOIN sales_per_order s
    ON o.order_id = s.order_id

GROUP BY c.customer_state

ORDER BY total_sales DESC;

/*Delivery Performance by Region**/
WITH delivery_data AS (

    SELECT

        o.order_id,

        c.customer_state,

        EXTRACT(
            EPOCH FROM (
                o.order_delivered_customer_date -
                o.order_purchase_timestamp
            )
        ) / 86400.0 AS delivery_days,

        EXTRACT(
            EPOCH FROM (
                o.order_delivered_customer_date -
                o.order_estimated_delivery_date
            )
        ) / 86400.0 AS delay_days

    FROM clean.orders o

    JOIN clean.customers c
        ON o.customer_id = c.customer_id

    WHERE o.order_delivered_customer_date IS NOT NULL

      AND o.order_estimated_delivery_date IS NOT NULL

)

SELECT

    customer_state,

    COUNT(*) AS delivered_orders,

    ROUND(AVG(delivery_days)::numeric, 2)
        AS avg_delivery_days,

    COUNT(*) FILTER (
        WHERE delay_days > 0
    ) AS late_orders,

    ROUND(
        100.0 *
        COUNT(*) FILTER (WHERE delay_days > 0) /
        NULLIF(COUNT(*), 0), 2
    ) AS late_delivery_percentage

FROM delivery_data

GROUP BY customer_state

HAVING COUNT(*) >= 100

ORDER BY late_delivery_percentage DESC;
/**Delivery Time vs Customer Satisfaction***/
WITH review_per_order AS (
    SELECT
        order_id,
        AVG(review_score) AS avg_review_score,

        MAX(
            CASE
                WHEN review_score <= 2 THEN 1
                ELSE 0
            END
        ) AS low_review_flag

    FROM clean.reviews
    GROUP BY order_id
),

delivery_data AS (
    SELECT
        o.order_id,

        CASE
            WHEN o.order_delivered_customer_date >
                 o.order_estimated_delivery_date
                THEN 'Late'
            ELSE 'On Time / Early'
        END AS delivery_group,

        r.avg_review_score,
        r.low_review_flag,

        EXTRACT(
            EPOCH FROM (
                o.order_delivered_customer_date -
                o.order_purchase_timestamp
            )
        ) / 86400 AS delivery_duration_days

    FROM clean.orders o

    JOIN review_per_order r
        ON o.order_id = r.order_id

    WHERE o.order_delivered_customer_date IS NOT NULL
      AND o.order_estimated_delivery_date IS NOT NULL
)

SELECT
    delivery_group,

    COUNT(*) AS total_orders,

    ROUND(
        AVG(avg_review_score)::numeric, 2
    ) AS avg_review_score,

    ROUND(
        100.0 * AVG(low_review_flag), 2
    ) AS low_review_percentage,

    ROUND(
        AVG(delivery_duration_days)::numeric, 2
    ) AS avg_delivery_duration_days

FROM delivery_data

GROUP BY delivery_group
ORDER BY delivery_group;
/**Customer Retention — One-time vs Repeat Customers**/
WITH customer_order_count AS (

    SELECT

        c.customer_unique_id,

        COUNT(DISTINCT o.order_id) AS order_count

    FROM clean.customers c

    JOIN clean.orders o

        ON c.customer_id = o.customer_id

    GROUP BY c.customer_unique_id

),

order_sales AS (

    SELECT

        order_id,

        SUM(price) AS sales

    FROM clean.order_items

    GROUP BY order_id

),

customer_segments AS (

    SELECT

        c.customer_unique_id,

        o.order_id,

        s.sales,

        CASE

            WHEN coc.order_count > 1
            THEN 'Repeat Customer'

            ELSE 'One-time Customer'

        END AS customer_segment

    FROM clean.customers c

    JOIN clean.orders o

        ON c.customer_id = o.customer_id

    JOIN customer_order_count coc

        ON c.customer_unique_id = coc.customer_unique_id

    LEFT JOIN order_sales s

        ON o.order_id = s.order_id

)

SELECT

    customer_segment,

    COUNT(DISTINCT customer_unique_id) AS customers,

    COUNT(DISTINCT order_id) AS orders,

    ROUND(SUM(sales)::numeric, 2) AS total_sales,

    ROUND(AVG(sales)::numeric, 2) AS avg_order_value

FROM customer_segments

GROUP BY customer_segment;
/**Monthly Sales Trend**/
WITH item_sales AS (

    SELECT

        order_id,

        SUM(price) AS sales

    FROM clean.order_items

    GROUP BY order_id

),

monthly_sales AS (

    SELECT

        DATE_TRUNC(
            'month',
            o.order_purchase_timestamp
        )::date AS sales_month,

        COUNT(DISTINCT o.order_id) AS total_orders,

        COUNT(DISTINCT i.order_id) AS orders_with_items,

        SUM(i.sales) AS total_sales

    FROM clean.orders o

    LEFT JOIN item_sales i

        ON o.order_id = i.order_id

    GROUP BY 1

),

sales_growth AS (

    SELECT

        sales_month,

        total_orders,

        orders_with_items,

        total_sales,

        LAG(total_sales) OVER (
            ORDER BY sales_month
        ) AS previous_month_sales

    FROM monthly_sales

)

SELECT

    sales_month,

    total_orders,

    orders_with_items,

    ROUND(total_sales::numeric, 2) AS total_sales,

    ROUND(previous_month_sales::numeric, 2)
        AS previous_month_sales,

    ROUND(

        100.0 *

        (total_sales - previous_month_sales) /

        NULLIF(previous_month_sales, 0),

        2

    ) AS monthly_growth_percentage

FROM sales_growth

ORDER BY sales_month;
/**Seller Performance***/
SELECT

    s.seller_id,

    s.seller_state,

    s.seller_city,

    COUNT(DISTINCT oi.order_id) AS total_orders,

    COUNT(*) AS items_sold,

    ROUND(SUM(oi.price)::numeric, 2)
        AS total_sales,

    ROUND(SUM(oi.freight_value)::numeric, 2)
        AS total_freight,

    ROUND(AVG(oi.price)::numeric, 2)
        AS avg_item_price

FROM clean.order_items oi

JOIN clean.sellers s

    ON oi.seller_id = s.seller_id

GROUP BY

    s.seller_id,

    s.seller_state,

    s.seller_city

ORDER BY total_sales DESC

LIMIT 20;
/*Seller Dispatch Deadline Compliance***/
WITH dispatch_data AS (
    SELECT
        oi.order_id,
        oi.order_item_id,
        oi.seller_id,
        oi.shipping_limit_date,
        o.order_delivered_carrier_date,

        CASE
            WHEN o.order_delivered_carrier_date >
                 oi.shipping_limit_date
                THEN 'Late Dispatch'
            ELSE 'On-Time Dispatch'
        END AS dispatch_status,

        EXTRACT(
            EPOCH FROM (
                o.order_delivered_carrier_date -
                oi.shipping_limit_date
            )
        ) / 86400 AS dispatch_delay_days

    FROM clean.order_items oi

    JOIN clean.orders o
        ON oi.order_id = o.order_id

    WHERE o.order_status IN ('shipped', 'delivered')
      AND o.order_delivered_carrier_date IS NOT NULL
)

SELECT
    dispatch_status,
    COUNT(*) AS total_items,

    ROUND(
        100.0 * COUNT(*) /
        SUM(COUNT(*)) OVER (), 2
    ) AS percentage,

    ROUND(
        AVG(dispatch_delay_days)
        FILTER (
            WHERE dispatch_status = 'Late Dispatch'
        )::numeric, 2
    ) AS avg_delay_days

FROM dispatch_data

GROUP BY dispatch_status
ORDER BY total_items DESC;
/**Order Status & Cancellation Overview**/
SELECT

    order_status,

    COUNT(*) AS total_orders,

    ROUND(

        100.0 * COUNT(*) /

        SUM(COUNT(*)) OVER (),

        2

    ) AS percentage

FROM clean.orders

GROUP BY order_status

ORDER BY total_orders DESC;
/**Delivery Delay Days & Delivery Status **/
SELECT
    order_id,
    order_delivered_customer_date,
    order_estimated_delivery_date,

    EXTRACT(
        EPOCH FROM (
            order_delivered_customer_date -
            order_estimated_delivery_date
        )
    ) / 86400 AS delivery_delay_days,

    CASE
        WHEN order_delivered_customer_date IS NULL
            THEN 'Not Delivered'
        WHEN order_delivered_customer_date >
             order_estimated_delivery_date
            THEN 'Late'
        ELSE 'On Time / Early'
    END AS delivery_status

FROM clean.orders;

/*Dispatch Delay Days */
SELECT
    oi.order_id,
    oi.order_item_id,
    oi.seller_id,
    oi.shipping_limit_date,
    o.order_delivered_carrier_date,

    EXTRACT(
        EPOCH FROM (
            o.order_delivered_carrier_date -
            oi.shipping_limit_date
        )
    ) / 86400 AS dispatch_delay_days

FROM clean.order_items oi
JOIN clean.orders o
    ON oi.order_id = o.order_id
WHERE o.order_delivered_carrier_date IS NOT NULL;
