# data dictionary

### market_id -

A city/region in which DoorDash operates, e.g., Los Angeles, given in the data as an id

### created_at -

Timestamp in UTC when the order was submitted by the consumer to DoorDash. (Note this timestamp is in UTC, but in case you need it, the actual timezone of the region was US/Pacific)

### actual_delivery_time -

Timestamp in UTC when the order was delivered to the consumer Store features

### store_id -

an id representing the restaurant the order was submitted for

### store_primary_category -

cuisine category of the restaurant, e.g., italian, asian

### order_protocol -

a store can receive orders from DoorDash through many modes. This field represents an id denoting the protocol Order features

### total_items -

total number of items in the order

### subtotal -

total value of the order submitted (in cents)

### num_distinct_items -

number of distinct items included in the order

### min_item_price -

price of the item with the least cost in the order (in cents)



```markdown
the UTC−8 conversion is exact for every row.
```

