-- TEST PROJECT ONLY: fictional orders, placeholder customers and sample stock.
-- Run in Supabase SQL Editor as project owner, after the existing setup.
-- Do not rerun setup.sql. This example is intentionally excluded from setup.sql.
-- Existing orders, customer accounts, selling prices and store settings are preserved.
-- Adds remaining sample units to existing stock; confirms seeded products' test prices.
-- Rerunning this file is a no-op. Cleanup: supabase/examples/remove-analytics.sql.
begin;
do $seed$
declare
 data jsonb := $sample_payload${
  "users": [
    {
      "id": "30000000-0000-4000-8000-000000000001",
      "role": "customer",
      "full_name": "Demo Motorist 01",
      "email": "sample-buyer-1@example.invalid",
      "phone": "0100000000",
      "business_type": "personal",
      "is_active": true,
      "created_at": "2026-07-25T09:21:21.350Z",
      "sample_data": true
    },
    {
      "id": "30000000-0000-4000-8000-000000000002",
      "role": "customer",
      "full_name": "Demo Workshop 02",
      "email": "sample-buyer-2@example.invalid",
      "phone": "0100000000",
      "business_type": "workshop",
      "is_active": true,
      "created_at": "2026-07-25T09:21:21.350Z",
      "sample_data": true
    },
    {
      "id": "30000000-0000-4000-8000-000000000003",
      "role": "customer",
      "full_name": "Demo Parts Shop 03",
      "email": "sample-buyer-3@example.invalid",
      "phone": "0100000000",
      "business_type": "retailer",
      "is_active": true,
      "created_at": "2026-07-25T09:21:21.350Z",
      "sample_data": true
    },
    {
      "id": "30000000-0000-4000-8000-000000000004",
      "role": "customer",
      "full_name": "Demo Distributor 04",
      "email": "sample-buyer-4@example.invalid",
      "phone": "0100000000",
      "business_type": "distributor",
      "is_active": true,
      "created_at": "2026-07-25T09:21:21.350Z",
      "sample_data": true
    },
    {
      "id": "30000000-0000-4000-8000-000000000005",
      "role": "customer",
      "full_name": "Demo Motorist 05",
      "email": "sample-buyer-5@example.invalid",
      "phone": "0100000000",
      "business_type": "personal",
      "is_active": true,
      "created_at": "2026-07-25T09:21:21.350Z",
      "sample_data": true
    },
    {
      "id": "30000000-0000-4000-8000-000000000006",
      "role": "customer",
      "full_name": "Demo Workshop 06",
      "email": "sample-buyer-6@example.invalid",
      "phone": "0100000000",
      "business_type": "workshop",
      "is_active": true,
      "created_at": "2026-07-25T09:21:21.350Z",
      "sample_data": true
    },
    {
      "id": "30000000-0000-4000-8000-000000000007",
      "role": "customer",
      "full_name": "Demo Parts Shop 07",
      "email": "sample-buyer-7@example.invalid",
      "phone": "0100000000",
      "business_type": "retailer",
      "is_active": true,
      "created_at": "2026-07-25T09:21:21.350Z",
      "sample_data": true
    },
    {
      "id": "30000000-0000-4000-8000-000000000008",
      "role": "customer",
      "full_name": "Demo Distributor 08",
      "email": "sample-buyer-8@example.invalid",
      "phone": "0100000000",
      "business_type": "distributor",
      "is_active": true,
      "created_at": "2026-07-25T09:21:21.350Z",
      "sample_data": true
    },
    {
      "id": "30000000-0000-4000-8000-000000000009",
      "role": "customer",
      "full_name": "Demo Motorist 09",
      "email": "sample-buyer-9@example.invalid",
      "phone": "0100000000",
      "business_type": "personal",
      "is_active": true,
      "created_at": "2026-07-25T09:21:21.350Z",
      "sample_data": true
    },
    {
      "id": "30000000-0000-4000-8000-000000000010",
      "role": "customer",
      "full_name": "Demo Workshop 10",
      "email": "sample-buyer-10@example.invalid",
      "phone": "0100000000",
      "business_type": "workshop",
      "is_active": true,
      "created_at": "2026-07-25T09:21:21.350Z",
      "sample_data": true
    },
    {
      "id": "30000000-0000-4000-8000-000000000011",
      "role": "customer",
      "full_name": "Demo Parts Shop 11",
      "email": "sample-buyer-11@example.invalid",
      "phone": "0100000000",
      "business_type": "retailer",
      "is_active": true,
      "created_at": "2026-07-25T09:21:21.350Z",
      "sample_data": true
    },
    {
      "id": "30000000-0000-4000-8000-000000000012",
      "role": "customer",
      "full_name": "Demo Distributor 12",
      "email": "sample-buyer-12@example.invalid",
      "phone": "0100000000",
      "business_type": "distributor",
      "is_active": true,
      "created_at": "2026-07-25T09:21:21.350Z",
      "sample_data": true
    }
  ],
  "orders": [
    {
      "id": "ace72735-4e00-4b48-8c0a-e2af54e720e4",
      "order_number": 10001,
      "customer_id": "30000000-0000-4000-8000-000000000001",
      "status": "awaiting_payment",
      "payment_status": "awaiting",
      "address": {
        "name": "Demo Motorist 01",
        "phone": "0100000000",
        "line1": "Demo address — not for delivery",
        "city": "Petaling Jaya",
        "postcode": "47300",
        "state": "Selangor"
      },
      "subtotal_cents": 13000,
      "discount_cents": 0,
      "shipping_cents": 1500,
      "total_cents": 14500,
      "payment_instructions": {
        "bank_name": "DEMO — DO NOT TRANSFER",
        "bank_account_name": "FICTIONAL EXAMPLE ONLY",
        "bank_account_number": "0000000000"
      },
      "payment_reference": null,
      "paid_verified_by": null,
      "payment_note": null,
      "carrier": null,
      "tracking_number": null,
      "received_at": null,
      "cancel_reason": null,
      "idempotency_key": "35ecffbb-0065-4e82-9a33-e0582d43a1b6",
      "created_at": "2026-10-28T07:21:21.350Z",
      "updated_at": "2026-10-28T07:21:21.350Z",
      "expires_at": "2026-10-29T07:21:21.350Z",
      "items": [
        {
          "id": "5168d90c-747e-4598-b9d9-74984f19bbfe",
          "order_id": "ace72735-4e00-4b48-8c0a-e2af54e720e4",
          "product_id": "toyota-fully-synthetic-0w-20-engine-oil-4l",
          "name": "Toyota Fully Synthetic 0W-20 Engine Oil 4L",
          "sku": "GL-0001",
          "category": "Engine Oil",
          "quantity": 1,
          "price_cents": 13000,
          "line_total_cents": 13000
        }
      ],
      "events": [
        {
          "id": "76483e33-3bb3-4843-9f26-52da44b1c0b4",
          "order_id": "ace72735-4e00-4b48-8c0a-e2af54e720e4",
          "event": "order_created",
          "actor_id": "30000000-0000-4000-8000-000000000001",
          "note": "Fictional example: inventory reserved.",
          "created_at": "2026-10-28T07:21:21.350Z"
        }
      ],
      "sample_data": true
    },
    {
      "id": "c57f4ff3-53a5-42f3-8689-8cf37bcbb750",
      "order_number": 10002,
      "customer_id": "30000000-0000-4000-8000-000000000002",
      "status": "awaiting_payment",
      "payment_status": "submitted",
      "address": {
        "name": "Demo Workshop 02",
        "phone": "0100000000",
        "line1": "Demo address — not for delivery",
        "city": "Petaling Jaya",
        "postcode": "47300",
        "state": "Selangor"
      },
      "subtotal_cents": 18800,
      "discount_cents": 0,
      "shipping_cents": 1500,
      "total_cents": 20300,
      "payment_instructions": {
        "bank_name": "DEMO — DO NOT TRANSFER",
        "bank_account_name": "FICTIONAL EXAMPLE ONLY",
        "bank_account_number": "0000000000"
      },
      "payment_reference": "SAMPLE-NO-TRANSFER-2",
      "paid_verified_by": null,
      "payment_note": null,
      "carrier": null,
      "tracking_number": null,
      "received_at": null,
      "cancel_reason": null,
      "idempotency_key": "ae4da8e8-e2e5-4f94-ab27-533fc5d3e81e",
      "created_at": "2026-10-28T06:21:21.350Z",
      "updated_at": "2026-10-28T06:31:21.350Z",
      "expires_at": "2026-10-29T06:21:21.350Z",
      "items": [
        {
          "id": "93807e15-2f9f-4d82-9e42-4b5b7bf83b43",
          "order_id": "c57f4ff3-53a5-42f3-8689-8cf37bcbb750",
          "product_id": "cabin-filter-for-proton-x50",
          "name": "Cabin Filter for Proton X50",
          "sku": "GL-0009",
          "category": "Filters",
          "quantity": 4,
          "price_cents": 2500,
          "line_total_cents": 10000
        },
        {
          "id": "02b8e799-3613-4909-a839-7409d87fdb44",
          "order_id": "c57f4ff3-53a5-42f3-8689-8cf37bcbb750",
          "product_id": "bendix-dot-4-brake-and-clutch-fluid-1l",
          "name": "Bendix DOT 4 Brake and Clutch Fluid 1L",
          "sku": "GL-0003",
          "category": "Brake Fluid",
          "quantity": 4,
          "price_cents": 2200,
          "line_total_cents": 8800
        }
      ],
      "events": [
        {
          "id": "2f9dd11f-067f-4e72-a669-542e0f62292a",
          "order_id": "c57f4ff3-53a5-42f3-8689-8cf37bcbb750",
          "event": "order_created",
          "actor_id": "30000000-0000-4000-8000-000000000002",
          "note": "Fictional example: inventory reserved.",
          "created_at": "2026-10-28T06:21:21.350Z"
        },
        {
          "id": "791d6bad-d3ad-4eec-a4fc-42c4db9b388a",
          "order_id": "c57f4ff3-53a5-42f3-8689-8cf37bcbb750",
          "event": "payment_submitted",
          "actor_id": "30000000-0000-4000-8000-000000000002",
          "note": "Fictional bank reference; no transfer occurred.",
          "created_at": "2026-10-28T06:31:21.350Z"
        }
      ],
      "sample_data": true
    },
    {
      "id": "8ab13ab2-7111-457b-b8f0-d90b887ff222",
      "order_number": 10003,
      "customer_id": "30000000-0000-4000-8000-000000000003",
      "status": "awaiting_payment",
      "payment_status": "rejected",
      "address": {
        "name": "Demo Parts Shop 03",
        "phone": "0100000000",
        "line1": "Demo address — not for delivery",
        "city": "Petaling Jaya",
        "postcode": "47300",
        "state": "Selangor"
      },
      "subtotal_cents": 130400,
      "discount_cents": 0,
      "shipping_cents": 0,
      "total_cents": 130400,
      "payment_instructions": {
        "bank_name": "DEMO — DO NOT TRANSFER",
        "bank_account_name": "FICTIONAL EXAMPLE ONLY",
        "bank_account_number": "0000000000"
      },
      "payment_reference": "SAMPLE-NO-TRANSFER-3",
      "paid_verified_by": null,
      "payment_note": "Example amount mismatch.",
      "carrier": null,
      "tracking_number": null,
      "received_at": null,
      "cancel_reason": null,
      "idempotency_key": "bf2a2b7d-c76a-4b35-a4ea-926ce7de75f7",
      "created_at": "2026-10-28T05:21:21.350Z",
      "updated_at": "2026-10-28T05:41:21.350Z",
      "expires_at": "2026-10-29T05:21:21.350Z",
      "items": [
        {
          "id": "9cb48de7-f128-4d70-b3bc-9b5e14b19f9f",
          "order_id": "8ab13ab2-7111-457b-b8f0-d90b887ff222",
          "product_id": "castrol-gtx-ultraclean-15w-40-engine-oil-4l",
          "name": "Castrol GTX Ultraclean 15W-40 Engine Oil 4L",
          "sku": "GL-0004",
          "category": "Engine Oil",
          "quantity": 8,
          "price_cents": 9500,
          "line_total_cents": 76000
        },
        {
          "id": "8ee5942d-b74d-495a-ac4d-95baecd1b9d4",
          "order_id": "8ab13ab2-7111-457b-b8f0-d90b887ff222",
          "product_id": "proton-cvt-transmission-fluid-1l",
          "name": "Proton CVT Transmission Fluid 1L",
          "sku": "GL-0005",
          "category": "Transmission Fluid",
          "quantity": 8,
          "price_cents": 5500,
          "line_total_cents": 44000
        },
        {
          "id": "40184bc6-5dbe-4f13-a96f-684962b705f2",
          "order_id": "8ab13ab2-7111-457b-b8f0-d90b887ff222",
          "product_id": "dexron-iii-atf-d3-transmission-fluid-1l",
          "name": "Dexron III ATF D3 Transmission Fluid 1L",
          "sku": "GL-0035",
          "category": "Transmission Fluid",
          "quantity": 8,
          "price_cents": 1300,
          "line_total_cents": 10400
        }
      ],
      "events": [
        {
          "id": "83ebeb01-f73d-469e-93d5-d971d6eecd57",
          "order_id": "8ab13ab2-7111-457b-b8f0-d90b887ff222",
          "event": "order_created",
          "actor_id": "30000000-0000-4000-8000-000000000003",
          "note": "Fictional example: inventory reserved.",
          "created_at": "2026-10-28T05:21:21.350Z"
        },
        {
          "id": "5c0b4b0b-6dd0-43dd-af93-2a6aa28b79aa",
          "order_id": "8ab13ab2-7111-457b-b8f0-d90b887ff222",
          "event": "payment_submitted",
          "actor_id": "30000000-0000-4000-8000-000000000003",
          "note": "Fictional bank reference; no transfer occurred.",
          "created_at": "2026-10-28T05:31:21.350Z"
        },
        {
          "id": "06450297-3d28-49e4-a048-c60d556ebf2a",
          "order_id": "8ab13ab2-7111-457b-b8f0-d90b887ff222",
          "event": "payment_rejected",
          "actor_id": "seed-worker",
          "note": "Example transfer amount does not match the order.",
          "created_at": "2026-10-28T05:41:21.350Z"
        }
      ],
      "sample_data": true
    },
    {
      "id": "f3f689f7-3776-44e8-9b28-943c9386f0b1",
      "order_number": 10004,
      "customer_id": "30000000-0000-4000-8000-000000000004",
      "status": "processing",
      "payment_status": "verified",
      "address": {
        "name": "Demo Distributor 04",
        "phone": "0100000000",
        "line1": "Demo address — not for delivery",
        "city": "Petaling Jaya",
        "postcode": "47300",
        "state": "Selangor"
      },
      "subtotal_cents": 115500,
      "discount_cents": 0,
      "shipping_cents": 0,
      "total_cents": 115500,
      "payment_instructions": {
        "bank_name": "DEMO — DO NOT TRANSFER",
        "bank_account_name": "FICTIONAL EXAMPLE ONLY",
        "bank_account_number": "0000000000"
      },
      "payment_reference": "SAMPLE-NO-TRANSFER-4",
      "paid_verified_by": "seed-worker",
      "payment_note": null,
      "carrier": null,
      "tracking_number": null,
      "received_at": null,
      "cancel_reason": null,
      "idempotency_key": "ce827f74-8b10-418f-b373-976b16193b9f",
      "created_at": "2026-10-25T05:00:00.000Z",
      "updated_at": "2026-10-25T05:20:00.000Z",
      "expires_at": "2026-10-26T05:00:00.000Z",
      "items": [
        {
          "id": "fc1f523c-e881-4ad9-a4ba-f3c1ab8d7251",
          "order_id": "f3f689f7-3776-44e8-9b28-943c9386f0b1",
          "product_id": "trw-gdb7986-front-brake-pads",
          "name": "TRW GDB7986 Front Brake Pads",
          "sku": "GL-0045",
          "category": "Brake Pads",
          "quantity": 15,
          "price_cents": 7700,
          "line_total_cents": 115500
        }
      ],
      "events": [
        {
          "id": "39d56167-df8d-4b9f-905b-94a41d51eea9",
          "order_id": "f3f689f7-3776-44e8-9b28-943c9386f0b1",
          "event": "order_created",
          "actor_id": "30000000-0000-4000-8000-000000000004",
          "note": "Fictional example: inventory reserved.",
          "created_at": "2026-10-25T05:00:00.000Z"
        },
        {
          "id": "d43aca86-16bf-42f1-b4c5-3e507345ff54",
          "order_id": "f3f689f7-3776-44e8-9b28-943c9386f0b1",
          "event": "payment_submitted",
          "actor_id": "30000000-0000-4000-8000-000000000004",
          "note": "Fictional bank reference; no transfer occurred.",
          "created_at": "2026-10-25T05:10:00.000Z"
        },
        {
          "id": "c1db0c81-9d28-41ec-a779-6cbd2610a56b",
          "order_id": "f3f689f7-3776-44e8-9b28-943c9386f0b1",
          "event": "payment_verified",
          "actor_id": "seed-worker",
          "note": "Fictional deposit verification.",
          "created_at": "2026-10-25T05:20:00.000Z"
        }
      ],
      "sample_data": true
    },
    {
      "id": "6f539cbc-1e0a-4598-8ea1-3b0ca137ffa3",
      "order_number": 10005,
      "customer_id": "30000000-0000-4000-8000-000000000005",
      "status": "shipped",
      "payment_status": "verified",
      "address": {
        "name": "Demo Motorist 05",
        "phone": "0100000000",
        "line1": "Demo address — not for delivery",
        "city": "Petaling Jaya",
        "postcode": "47300",
        "state": "Selangor"
      },
      "subtotal_cents": 7700,
      "discount_cents": 0,
      "shipping_cents": 1500,
      "total_cents": 9200,
      "payment_instructions": {
        "bank_name": "DEMO — DO NOT TRANSFER",
        "bank_account_name": "FICTIONAL EXAMPLE ONLY",
        "bank_account_number": "0000000000"
      },
      "payment_reference": "SAMPLE-NO-TRANSFER-5",
      "paid_verified_by": "seed-worker",
      "payment_note": null,
      "carrier": "Demo carrier",
      "tracking_number": "DEMO-NOT-A-PARCEL-5",
      "received_at": null,
      "cancel_reason": null,
      "idempotency_key": "dc2f1d9b-eae6-4cfe-95d5-06a062569d9e",
      "created_at": "2026-10-24T06:00:00.000Z",
      "updated_at": "2026-10-25T06:00:00.000Z",
      "expires_at": "2026-10-25T06:00:00.000Z",
      "items": [
        {
          "id": "0f465431-d263-4bb2-8791-79d5eaae13fa",
          "order_id": "6f539cbc-1e0a-4598-8ea1-3b0ca137ffa3",
          "product_id": "proton-cvt-transmission-fluid-1l",
          "name": "Proton CVT Transmission Fluid 1L",
          "sku": "GL-0005",
          "category": "Transmission Fluid",
          "quantity": 1,
          "price_cents": 5500,
          "line_total_cents": 5500
        },
        {
          "id": "73d64a37-50ef-46cd-b337-212ececc0732",
          "order_id": "6f539cbc-1e0a-4598-8ea1-3b0ca137ffa3",
          "product_id": "bendix-dot-4-brake-and-clutch-fluid-1l",
          "name": "Bendix DOT 4 Brake and Clutch Fluid 1L",
          "sku": "GL-0003",
          "category": "Brake Fluid",
          "quantity": 1,
          "price_cents": 2200,
          "line_total_cents": 2200
        }
      ],
      "events": [
        {
          "id": "6a9877c0-dd98-4438-9e8f-6fbc461821dc",
          "order_id": "6f539cbc-1e0a-4598-8ea1-3b0ca137ffa3",
          "event": "order_created",
          "actor_id": "30000000-0000-4000-8000-000000000005",
          "note": "Fictional example: inventory reserved.",
          "created_at": "2026-10-24T06:00:00.000Z"
        },
        {
          "id": "a0829da3-7a4c-4137-95a4-0f814ea5e57d",
          "order_id": "6f539cbc-1e0a-4598-8ea1-3b0ca137ffa3",
          "event": "payment_submitted",
          "actor_id": "30000000-0000-4000-8000-000000000005",
          "note": "Fictional bank reference; no transfer occurred.",
          "created_at": "2026-10-24T06:10:00.000Z"
        },
        {
          "id": "07c3ef48-cba3-47d2-bbaf-63948ca0e932",
          "order_id": "6f539cbc-1e0a-4598-8ea1-3b0ca137ffa3",
          "event": "payment_verified",
          "actor_id": "seed-worker",
          "note": "Fictional deposit verification.",
          "created_at": "2026-10-24T06:20:00.000Z"
        },
        {
          "id": "fc0ed911-dc7c-4a9d-bcf7-dd4c2ee9e281",
          "order_id": "6f539cbc-1e0a-4598-8ea1-3b0ca137ffa3",
          "event": "shipped",
          "actor_id": "seed-worker",
          "note": "Fictional carrier and tracking number.",
          "created_at": "2026-10-25T06:00:00.000Z"
        }
      ],
      "sample_data": true
    },
    {
      "id": "e3153f45-a852-4264-84b8-a1d8c2d17ea6",
      "order_number": 10006,
      "customer_id": "30000000-0000-4000-8000-000000000006",
      "status": "delivered",
      "payment_status": "verified",
      "address": {
        "name": "Demo Workshop 06",
        "phone": "0100000000",
        "line1": "Demo address — not for delivery",
        "city": "Petaling Jaya",
        "postcode": "47300",
        "state": "Selangor"
      },
      "subtotal_cents": 65996,
      "discount_cents": 0,
      "shipping_cents": 0,
      "total_cents": 65996,
      "payment_instructions": {
        "bank_name": "DEMO — DO NOT TRANSFER",
        "bank_account_name": "FICTIONAL EXAMPLE ONLY",
        "bank_account_number": "0000000000"
      },
      "payment_reference": "SAMPLE-NO-TRANSFER-6",
      "paid_verified_by": "seed-worker",
      "payment_note": null,
      "carrier": "Demo carrier",
      "tracking_number": "DEMO-NOT-A-PARCEL-6",
      "received_at": "2026-10-25T10:00:00.000Z",
      "cancel_reason": null,
      "idempotency_key": "55a585b7-16af-4347-9e9d-860016c6d869",
      "created_at": "2026-10-23T10:00:00.000Z",
      "updated_at": "2026-10-25T10:00:00.000Z",
      "expires_at": "2026-10-24T10:00:00.000Z",
      "items": [
        {
          "id": "769468ca-136b-41e1-881c-a691fc4998ee",
          "order_id": "e3153f45-a852-4264-84b8-a1d8c2d17ea6",
          "product_id": "x-traseal-carburetor-and-choke-cleaner-400ml",
          "name": "X'traseal Carburetor and Choke Cleaner 400ml",
          "sku": "GL-0006",
          "category": "Cleaners & Additives",
          "quantity": 4,
          "price_cents": 999,
          "line_total_cents": 3996
        },
        {
          "id": "864b0cc2-703e-4da0-8d9a-97f58ec6b3bb",
          "order_id": "e3153f45-a852-4264-84b8-a1d8c2d17ea6",
          "product_id": "proton-atf-hts-4at-fully-synthetic-fluid-3l",
          "name": "Proton ATF HTS 4AT Fully Synthetic Fluid 3L",
          "sku": "GL-0041",
          "category": "Transmission Fluid",
          "quantity": 4,
          "price_cents": 11500,
          "line_total_cents": 46000
        },
        {
          "id": "ca76bccc-a8c9-4fc7-9580-786b6818c8cc",
          "order_id": "e3153f45-a852-4264-84b8-a1d8c2d17ea6",
          "product_id": "aftermarket-engine-oil-filters-10-pack",
          "name": "Aftermarket Engine Oil Filters — 10 Pack",
          "sku": "GL-0019",
          "category": "Filters",
          "quantity": 4,
          "price_cents": 4000,
          "line_total_cents": 16000
        }
      ],
      "events": [
        {
          "id": "ccbc74a0-905e-4aa4-aa52-459cd159940f",
          "order_id": "e3153f45-a852-4264-84b8-a1d8c2d17ea6",
          "event": "order_created",
          "actor_id": "30000000-0000-4000-8000-000000000006",
          "note": "Fictional example: inventory reserved.",
          "created_at": "2026-10-23T10:00:00.000Z"
        },
        {
          "id": "a50b0ffd-e76e-4c72-a606-48cdeb53d865",
          "order_id": "e3153f45-a852-4264-84b8-a1d8c2d17ea6",
          "event": "payment_submitted",
          "actor_id": "30000000-0000-4000-8000-000000000006",
          "note": "Fictional bank reference; no transfer occurred.",
          "created_at": "2026-10-23T10:10:00.000Z"
        },
        {
          "id": "dadad650-6a65-4f00-a210-80935916f85e",
          "order_id": "e3153f45-a852-4264-84b8-a1d8c2d17ea6",
          "event": "payment_verified",
          "actor_id": "seed-worker",
          "note": "Fictional deposit verification.",
          "created_at": "2026-10-23T10:20:00.000Z"
        },
        {
          "id": "7e3ea4cf-3280-42a1-ac13-872b03c4e5d8",
          "order_id": "e3153f45-a852-4264-84b8-a1d8c2d17ea6",
          "event": "shipped",
          "actor_id": "seed-worker",
          "note": "Fictional carrier and tracking number.",
          "created_at": "2026-10-24T10:00:00.000Z"
        },
        {
          "id": "a06da497-cfb8-4b36-84f5-af831a66ec5b",
          "order_id": "e3153f45-a852-4264-84b8-a1d8c2d17ea6",
          "event": "receipt_confirmed",
          "actor_id": "30000000-0000-4000-8000-000000000006",
          "note": "Fictional buyer confirmed receipt.",
          "created_at": "2026-10-25T10:00:00.000Z"
        }
      ],
      "sample_data": true
    },
    {
      "id": "d1f64c66-fb7f-4c1e-867a-369321c3ae57",
      "order_number": 10007,
      "customer_id": "30000000-0000-4000-8000-000000000007",
      "status": "cancelled",
      "payment_status": "awaiting",
      "address": {
        "name": "Demo Parts Shop 07",
        "phone": "0100000000",
        "line1": "Demo address — not for delivery",
        "city": "Petaling Jaya",
        "postcode": "47300",
        "state": "Selangor"
      },
      "subtotal_cents": 57600,
      "discount_cents": 0,
      "shipping_cents": 0,
      "total_cents": 57600,
      "payment_instructions": {
        "bank_name": "DEMO — DO NOT TRANSFER",
        "bank_account_name": "FICTIONAL EXAMPLE ONLY",
        "bank_account_number": "0000000000"
      },
      "payment_reference": null,
      "paid_verified_by": null,
      "payment_note": null,
      "carrier": null,
      "tracking_number": null,
      "received_at": null,
      "cancel_reason": "Example customer changed their mind.",
      "idempotency_key": "d1e8b3f2-79bf-4c49-81cb-edcb89f5603c",
      "created_at": "2026-10-22T12:00:00.000Z",
      "updated_at": "2026-10-22T12:30:00.000Z",
      "expires_at": "2026-10-23T12:00:00.000Z",
      "items": [
        {
          "id": "cc635c59-ffde-4f9c-b832-4a5e7212c275",
          "order_id": "d1f64c66-fb7f-4c1e-867a-369321c3ae57",
          "product_id": "10w-30-engine-oil-perodua-oil-filter-bundle",
          "name": "10W-30 Engine Oil + Perodua Oil Filter Bundle",
          "sku": "GL-0030",
          "category": "Engine Oil",
          "quantity": 12,
          "price_cents": 4800,
          "line_total_cents": 57600
        }
      ],
      "events": [
        {
          "id": "636ce268-cd03-4006-bb89-1fdbf1ea44c4",
          "order_id": "d1f64c66-fb7f-4c1e-867a-369321c3ae57",
          "event": "order_created",
          "actor_id": "30000000-0000-4000-8000-000000000007",
          "note": "Fictional example: inventory reserved.",
          "created_at": "2026-10-22T12:00:00.000Z"
        },
        {
          "id": "08816d6a-8a31-45bf-b244-f019e7f692d0",
          "order_id": "d1f64c66-fb7f-4c1e-867a-369321c3ae57",
          "event": "cancelled",
          "actor_id": "30000000-0000-4000-8000-000000000007",
          "note": "Fictional unpaid cancellation; reserved inventory restored.",
          "created_at": "2026-10-22T12:30:00.000Z"
        }
      ],
      "sample_data": true
    },
    {
      "id": "6e25d28e-1844-48de-b341-8fb237db1cdf",
      "order_number": 10008,
      "customer_id": "30000000-0000-4000-8000-000000000008",
      "status": "cancelled",
      "payment_status": "refunded",
      "address": {
        "name": "Demo Distributor 08",
        "phone": "0100000000",
        "line1": "Demo address — not for delivery",
        "city": "Petaling Jaya",
        "postcode": "47300",
        "state": "Selangor"
      },
      "subtotal_cents": 89300,
      "discount_cents": 0,
      "shipping_cents": 0,
      "total_cents": 89300,
      "payment_instructions": {
        "bank_name": "DEMO — DO NOT TRANSFER",
        "bank_account_name": "FICTIONAL EXAMPLE ONLY",
        "bank_account_number": "0000000000"
      },
      "payment_reference": "SAMPLE-NO-TRANSFER-8",
      "paid_verified_by": "seed-worker",
      "payment_note": null,
      "carrier": "Demo carrier",
      "tracking_number": "DEMO-NOT-A-PARCEL-8",
      "received_at": "2026-10-23T13:00:00.000Z",
      "cancel_reason": null,
      "idempotency_key": "92da07b4-23b5-4ae3-a7e9-767d428bcbd2",
      "created_at": "2026-10-21T13:00:00.000Z",
      "updated_at": "2026-10-24T13:00:00.000Z",
      "expires_at": "2026-10-22T13:00:00.000Z",
      "items": [
        {
          "id": "cf57e4cc-b578-4604-972b-811a4bf3cb2f",
          "order_id": "6e25d28e-1844-48de-b341-8fb237db1cdf",
          "product_id": "bendix-dot-4-brake-and-clutch-fluid-1l",
          "name": "Bendix DOT 4 Brake and Clutch Fluid 1L",
          "sku": "GL-0003",
          "category": "Brake Fluid",
          "quantity": 19,
          "price_cents": 2200,
          "line_total_cents": 41800
        },
        {
          "id": "5c191860-dd9b-43f7-8021-0b3ab536c506",
          "order_id": "6e25d28e-1844-48de-b341-8fb237db1cdf",
          "product_id": "perodua-radiator-coolant-1l",
          "name": "Perodua Radiator Coolant 1L",
          "sku": "GL-0024",
          "category": "Coolant",
          "quantity": 19,
          "price_cents": 2500,
          "line_total_cents": 47500
        }
      ],
      "events": [
        {
          "id": "744b01f6-6a30-4508-a850-defeda069d2f",
          "order_id": "6e25d28e-1844-48de-b341-8fb237db1cdf",
          "event": "order_created",
          "actor_id": "30000000-0000-4000-8000-000000000008",
          "note": "Fictional example: inventory reserved.",
          "created_at": "2026-10-21T13:00:00.000Z"
        },
        {
          "id": "fc387188-110a-4d8c-92ec-ef9b1cdf0e8f",
          "order_id": "6e25d28e-1844-48de-b341-8fb237db1cdf",
          "event": "payment_submitted",
          "actor_id": "30000000-0000-4000-8000-000000000008",
          "note": "Fictional bank reference; no transfer occurred.",
          "created_at": "2026-10-21T13:10:00.000Z"
        },
        {
          "id": "8b7c9676-d515-499c-8127-e2ed83bb0200",
          "order_id": "6e25d28e-1844-48de-b341-8fb237db1cdf",
          "event": "payment_verified",
          "actor_id": "seed-worker",
          "note": "Fictional deposit verification.",
          "created_at": "2026-10-21T13:20:00.000Z"
        },
        {
          "id": "4782e0b5-79d4-47cf-a5b3-2b025d7c8088",
          "order_id": "6e25d28e-1844-48de-b341-8fb237db1cdf",
          "event": "shipped",
          "actor_id": "seed-worker",
          "note": "Fictional carrier and tracking number.",
          "created_at": "2026-10-22T13:00:00.000Z"
        },
        {
          "id": "0e0ea5bb-d4eb-4069-9ffa-39718a6afc83",
          "order_id": "6e25d28e-1844-48de-b341-8fb237db1cdf",
          "event": "receipt_confirmed",
          "actor_id": "30000000-0000-4000-8000-000000000008",
          "note": "Fictional buyer confirmed receipt.",
          "created_at": "2026-10-23T13:00:00.000Z"
        },
        {
          "id": "8e10fdf0-5b5f-42c3-865c-0cce68ceb858",
          "order_id": "6e25d28e-1844-48de-b341-8fb237db1cdf",
          "event": "refund_paid",
          "actor_id": "seed-admin",
          "note": "Fictional full refund; returned units restored.",
          "created_at": "2026-10-24T13:00:00.000Z"
        }
      ],
      "sample_data": true
    },
    {
      "id": "422030dc-7dfb-4f38-9fc5-1233b4e5dc4c",
      "order_number": 10009,
      "customer_id": "30000000-0000-4000-8000-000000000009",
      "status": "delivered",
      "payment_status": "verified",
      "address": {
        "name": "Demo Motorist 09",
        "phone": "0100000000",
        "line1": "Demo address — not for delivery",
        "city": "Petaling Jaya",
        "postcode": "47300",
        "state": "Selangor"
      },
      "subtotal_cents": 14200,
      "discount_cents": 0,
      "shipping_cents": 1500,
      "total_cents": 15700,
      "payment_instructions": {
        "bank_name": "DEMO — DO NOT TRANSFER",
        "bank_account_name": "FICTIONAL EXAMPLE ONLY",
        "bank_account_number": "0000000000"
      },
      "payment_reference": "SAMPLE-NO-TRANSFER-9",
      "paid_verified_by": "seed-worker",
      "payment_note": null,
      "carrier": "Demo carrier",
      "tracking_number": "DEMO-NOT-A-PARCEL-9",
      "received_at": "2026-10-22T12:00:00.000Z",
      "cancel_reason": null,
      "idempotency_key": "e732f170-9bcf-4012-a0de-057a61ee01cf",
      "created_at": "2026-10-20T12:00:00.000Z",
      "updated_at": "2026-10-22T12:00:00.000Z",
      "expires_at": "2026-10-21T12:00:00.000Z",
      "items": [
        {
          "id": "79ed0c4a-af07-4129-a512-2471cc389a6e",
          "order_id": "422030dc-7dfb-4f38-9fc5-1233b4e5dc4c",
          "product_id": "manual-gear-oil-80w-90-4l",
          "name": "Manual Gear Oil 80W-90 4L",
          "sku": "GL-0015",
          "category": "Transmission Fluid",
          "quantity": 1,
          "price_cents": 5000,
          "line_total_cents": 5000
        },
        {
          "id": "08b3b85c-0037-437e-a573-2ca0b3930485",
          "order_id": "422030dc-7dfb-4f38-9fc5-1233b4e5dc4c",
          "product_id": "cabin-filter-for-perodua-myvi-alza-axia-bezza",
          "name": "Cabin Filter for Perodua Myvi / Alza / Axia / Bezza",
          "sku": "GL-0037",
          "category": "Filters",
          "quantity": 1,
          "price_cents": 1500,
          "line_total_cents": 1500
        },
        {
          "id": "11dd88cf-38a9-4e14-8514-804296b72c0d",
          "order_id": "422030dc-7dfb-4f38-9fc5-1233b4e5dc4c",
          "product_id": "trw-gdb7986-front-brake-pads",
          "name": "TRW GDB7986 Front Brake Pads",
          "sku": "GL-0045",
          "category": "Brake Pads",
          "quantity": 1,
          "price_cents": 7700,
          "line_total_cents": 7700
        }
      ],
      "events": [
        {
          "id": "4afde437-6052-4de1-838f-dbbc06060604",
          "order_id": "422030dc-7dfb-4f38-9fc5-1233b4e5dc4c",
          "event": "order_created",
          "actor_id": "30000000-0000-4000-8000-000000000009",
          "note": "Fictional example: inventory reserved.",
          "created_at": "2026-10-20T12:00:00.000Z"
        },
        {
          "id": "1746a090-e3c2-4d31-b383-c8c122d65a8f",
          "order_id": "422030dc-7dfb-4f38-9fc5-1233b4e5dc4c",
          "event": "payment_submitted",
          "actor_id": "30000000-0000-4000-8000-000000000009",
          "note": "Fictional bank reference; no transfer occurred.",
          "created_at": "2026-10-20T12:10:00.000Z"
        },
        {
          "id": "aa7d00a9-a535-4bd1-9b01-9c8148a0b201",
          "order_id": "422030dc-7dfb-4f38-9fc5-1233b4e5dc4c",
          "event": "payment_verified",
          "actor_id": "seed-worker",
          "note": "Fictional deposit verification.",
          "created_at": "2026-10-20T12:20:00.000Z"
        },
        {
          "id": "d96df505-d722-4532-90b4-45154af4812e",
          "order_id": "422030dc-7dfb-4f38-9fc5-1233b4e5dc4c",
          "event": "shipped",
          "actor_id": "seed-worker",
          "note": "Fictional carrier and tracking number.",
          "created_at": "2026-10-21T12:00:00.000Z"
        },
        {
          "id": "44f28f7f-9a02-407a-851f-056dbfccc5ab",
          "order_id": "422030dc-7dfb-4f38-9fc5-1233b4e5dc4c",
          "event": "receipt_confirmed",
          "actor_id": "30000000-0000-4000-8000-000000000009",
          "note": "Fictional buyer confirmed receipt.",
          "created_at": "2026-10-22T12:00:00.000Z"
        }
      ],
      "sample_data": true
    },
    {
      "id": "b7d4afb9-21fd-48a9-a8c0-eacd153e7fbb",
      "order_number": 10015,
      "customer_id": "30000000-0000-4000-8000-000000000003",
      "status": "delivered",
      "payment_status": "verified",
      "address": {
        "name": "Demo Parts Shop 03",
        "phone": "0100000000",
        "line1": "Demo address — not for delivery",
        "city": "Petaling Jaya",
        "postcode": "47300",
        "state": "Selangor"
      },
      "subtotal_cents": 78600,
      "discount_cents": 0,
      "shipping_cents": 0,
      "total_cents": 78600,
      "payment_instructions": {
        "bank_name": "DEMO — DO NOT TRANSFER",
        "bank_account_name": "FICTIONAL EXAMPLE ONLY",
        "bank_account_number": "0000000000"
      },
      "payment_reference": "SAMPLE-NO-TRANSFER-15",
      "paid_verified_by": "seed-worker",
      "payment_note": null,
      "carrier": "Demo carrier",
      "tracking_number": "DEMO-NOT-A-PARCEL-15",
      "received_at": "2026-10-22T03:00:00.000Z",
      "cancel_reason": null,
      "idempotency_key": "fa9b1698-66da-444e-8e22-5c9974aa58ff",
      "created_at": "2026-10-20T03:00:00.000Z",
      "updated_at": "2026-10-22T03:00:00.000Z",
      "expires_at": "2026-10-21T03:00:00.000Z",
      "items": [
        {
          "id": "ee61700a-b6c3-484d-8a2e-0129fc837d76",
          "order_id": "b7d4afb9-21fd-48a9-a8c0-eacd153e7fbb",
          "product_id": "front-brake-pads-for-proton-gen-2-persona-neo",
          "name": "Front Brake Pads for Proton Gen 2 / Persona / Neo",
          "sku": "GL-0042",
          "category": "Brake Pads",
          "quantity": 6,
          "price_cents": 3800,
          "line_total_cents": 22800
        },
        {
          "id": "f64878a5-a239-43da-b62e-c4386ad9b315",
          "order_id": "b7d4afb9-21fd-48a9-a8c0-eacd153e7fbb",
          "product_id": "bardahl-15w-40-engine-oil-4l",
          "name": "Bardahl 15W-40 Engine Oil 4L",
          "sku": "GL-0028",
          "category": "Engine Oil",
          "quantity": 6,
          "price_cents": 6500,
          "line_total_cents": 39000
        },
        {
          "id": "c58a55de-89e6-4cb9-af96-707b425b0198",
          "order_id": "b7d4afb9-21fd-48a9-a8c0-eacd153e7fbb",
          "product_id": "petrol-filter-for-proton-iriz-saga-vvt-persona-vvt",
          "name": "Petrol Filter for Proton Iriz / Saga VVT / Persona VVT",
          "sku": "GL-0017",
          "category": "Filters",
          "quantity": 6,
          "price_cents": 2800,
          "line_total_cents": 16800
        }
      ],
      "events": [
        {
          "id": "2917ad16-333a-4110-9033-b5216f1cd4d7",
          "order_id": "b7d4afb9-21fd-48a9-a8c0-eacd153e7fbb",
          "event": "order_created",
          "actor_id": "30000000-0000-4000-8000-000000000003",
          "note": "Fictional example: inventory reserved.",
          "created_at": "2026-10-20T03:00:00.000Z"
        },
        {
          "id": "f6df8a1f-d7b4-42c8-8e69-b5f654e9d176",
          "order_id": "b7d4afb9-21fd-48a9-a8c0-eacd153e7fbb",
          "event": "payment_submitted",
          "actor_id": "30000000-0000-4000-8000-000000000003",
          "note": "Fictional bank reference; no transfer occurred.",
          "created_at": "2026-10-20T03:10:00.000Z"
        },
        {
          "id": "603bee39-597b-448e-b250-ed30e600dd4e",
          "order_id": "b7d4afb9-21fd-48a9-a8c0-eacd153e7fbb",
          "event": "payment_verified",
          "actor_id": "seed-worker",
          "note": "Fictional deposit verification.",
          "created_at": "2026-10-20T03:20:00.000Z"
        },
        {
          "id": "efd0055f-7741-408e-a0f9-ff80c9473ca6",
          "order_id": "b7d4afb9-21fd-48a9-a8c0-eacd153e7fbb",
          "event": "shipped",
          "actor_id": "seed-worker",
          "note": "Fictional carrier and tracking number.",
          "created_at": "2026-10-21T03:00:00.000Z"
        },
        {
          "id": "554cbb1c-4764-4475-9096-ea48812b0387",
          "order_id": "b7d4afb9-21fd-48a9-a8c0-eacd153e7fbb",
          "event": "receipt_confirmed",
          "actor_id": "30000000-0000-4000-8000-000000000003",
          "note": "Fictional buyer confirmed receipt.",
          "created_at": "2026-10-22T03:00:00.000Z"
        }
      ],
      "sample_data": true
    },
    {
      "id": "1291de7f-ce68-4f87-962d-c5e747d8367f",
      "order_number": 10010,
      "customer_id": "30000000-0000-4000-8000-000000000010",
      "status": "delivered",
      "payment_status": "verified",
      "address": {
        "name": "Demo Workshop 10",
        "phone": "0100000000",
        "line1": "Demo address — not for delivery",
        "city": "Petaling Jaya",
        "postcode": "47300",
        "state": "Selangor"
      },
      "subtotal_cents": 3996,
      "discount_cents": 0,
      "shipping_cents": 1500,
      "total_cents": 5496,
      "payment_instructions": {
        "bank_name": "DEMO — DO NOT TRANSFER",
        "bank_account_name": "FICTIONAL EXAMPLE ONLY",
        "bank_account_number": "0000000000"
      },
      "payment_reference": "SAMPLE-NO-TRANSFER-10",
      "paid_verified_by": "seed-worker",
      "payment_note": null,
      "carrier": "Demo carrier",
      "tracking_number": "DEMO-NOT-A-PARCEL-10",
      "received_at": "2026-10-21T13:00:00.000Z",
      "cancel_reason": null,
      "idempotency_key": "a1afd8af-fd53-43fd-895a-f1d86955be8a",
      "created_at": "2026-10-19T13:00:00.000Z",
      "updated_at": "2026-10-21T13:00:00.000Z",
      "expires_at": "2026-10-20T13:00:00.000Z",
      "items": [
        {
          "id": "46aac386-dd5d-4b2c-bf2b-babe7837406d",
          "order_id": "1291de7f-ce68-4f87-962d-c5e747d8367f",
          "product_id": "x-traseal-carburetor-and-choke-cleaner-400ml",
          "name": "X'traseal Carburetor and Choke Cleaner 400ml",
          "sku": "GL-0006",
          "category": "Cleaners & Additives",
          "quantity": 4,
          "price_cents": 999,
          "line_total_cents": 3996
        }
      ],
      "events": [
        {
          "id": "6ff498a9-2649-42e6-a62b-6817b51b03ae",
          "order_id": "1291de7f-ce68-4f87-962d-c5e747d8367f",
          "event": "order_created",
          "actor_id": "30000000-0000-4000-8000-000000000010",
          "note": "Fictional example: inventory reserved.",
          "created_at": "2026-10-19T13:00:00.000Z"
        },
        {
          "id": "bae3a564-a74c-4240-86b4-5cab6a8cfa0c",
          "order_id": "1291de7f-ce68-4f87-962d-c5e747d8367f",
          "event": "payment_submitted",
          "actor_id": "30000000-0000-4000-8000-000000000010",
          "note": "Fictional bank reference; no transfer occurred.",
          "created_at": "2026-10-19T13:10:00.000Z"
        },
        {
          "id": "18c40cd7-ce06-411d-b0c0-5e133f3ca40d",
          "order_id": "1291de7f-ce68-4f87-962d-c5e747d8367f",
          "event": "payment_verified",
          "actor_id": "seed-worker",
          "note": "Fictional deposit verification.",
          "created_at": "2026-10-19T13:20:00.000Z"
        },
        {
          "id": "7fbb53ba-6822-459e-8a57-d091dc3290f0",
          "order_id": "1291de7f-ce68-4f87-962d-c5e747d8367f",
          "event": "shipped",
          "actor_id": "seed-worker",
          "note": "Fictional carrier and tracking number.",
          "created_at": "2026-10-20T13:00:00.000Z"
        },
        {
          "id": "44783b23-74f5-4d72-8008-a1694047c174",
          "order_id": "1291de7f-ce68-4f87-962d-c5e747d8367f",
          "event": "receipt_confirmed",
          "actor_id": "30000000-0000-4000-8000-000000000010",
          "note": "Fictional buyer confirmed receipt.",
          "created_at": "2026-10-21T13:00:00.000Z"
        }
      ],
      "sample_data": true
    },
    {
      "id": "0e0b5c99-0992-4d8a-acee-350528cd2790",
      "order_number": 10016,
      "customer_id": "30000000-0000-4000-8000-000000000004",
      "status": "delivered",
      "payment_status": "verified",
      "address": {
        "name": "Demo Distributor 04",
        "phone": "0100000000",
        "line1": "Demo address — not for delivery",
        "city": "Petaling Jaya",
        "postcode": "47300",
        "state": "Selangor"
      },
      "subtotal_cents": 117000,
      "discount_cents": 0,
      "shipping_cents": 0,
      "total_cents": 117000,
      "payment_instructions": {
        "bank_name": "DEMO — DO NOT TRANSFER",
        "bank_account_name": "FICTIONAL EXAMPLE ONLY",
        "bank_account_number": "0000000000"
      },
      "payment_reference": "SAMPLE-NO-TRANSFER-16",
      "paid_verified_by": "seed-worker",
      "payment_note": null,
      "carrier": "Demo carrier",
      "tracking_number": "DEMO-NOT-A-PARCEL-16",
      "received_at": "2026-10-21T05:00:00.000Z",
      "cancel_reason": null,
      "idempotency_key": "ac44e2be-7120-4d3c-98e5-612fc01c2209",
      "created_at": "2026-10-19T05:00:00.000Z",
      "updated_at": "2026-10-21T05:00:00.000Z",
      "expires_at": "2026-10-20T05:00:00.000Z",
      "items": [
        {
          "id": "605a575f-d2b1-4b7d-9ea0-b913dbcecb21",
          "order_id": "0e0b5c99-0992-4d8a-acee-350528cd2790",
          "product_id": "bardahl-15w-40-engine-oil-4l",
          "name": "Bardahl 15W-40 Engine Oil 4L",
          "sku": "GL-0028",
          "category": "Engine Oil",
          "quantity": 18,
          "price_cents": 6500,
          "line_total_cents": 117000
        }
      ],
      "events": [
        {
          "id": "b0f16358-7368-4609-a609-57a625c7409d",
          "order_id": "0e0b5c99-0992-4d8a-acee-350528cd2790",
          "event": "order_created",
          "actor_id": "30000000-0000-4000-8000-000000000004",
          "note": "Fictional example: inventory reserved.",
          "created_at": "2026-10-19T05:00:00.000Z"
        },
        {
          "id": "03e41cec-5694-482c-8fd5-986d1f6a0f50",
          "order_id": "0e0b5c99-0992-4d8a-acee-350528cd2790",
          "event": "payment_submitted",
          "actor_id": "30000000-0000-4000-8000-000000000004",
          "note": "Fictional bank reference; no transfer occurred.",
          "created_at": "2026-10-19T05:10:00.000Z"
        },
        {
          "id": "fd02cce0-95e2-405f-a84c-df3d4d701de8",
          "order_id": "0e0b5c99-0992-4d8a-acee-350528cd2790",
          "event": "payment_verified",
          "actor_id": "seed-worker",
          "note": "Fictional deposit verification.",
          "created_at": "2026-10-19T05:20:00.000Z"
        },
        {
          "id": "93e47d62-54ef-4277-889e-7e13c571523f",
          "order_id": "0e0b5c99-0992-4d8a-acee-350528cd2790",
          "event": "shipped",
          "actor_id": "seed-worker",
          "note": "Fictional carrier and tracking number.",
          "created_at": "2026-10-20T05:00:00.000Z"
        },
        {
          "id": "ea239dc9-83a6-4cb8-8a4f-dcf53af0ebf2",
          "order_id": "0e0b5c99-0992-4d8a-acee-350528cd2790",
          "event": "receipt_confirmed",
          "actor_id": "30000000-0000-4000-8000-000000000004",
          "note": "Fictional buyer confirmed receipt.",
          "created_at": "2026-10-21T05:00:00.000Z"
        }
      ],
      "sample_data": true
    },
    {
      "id": "52190ce5-3c3b-48b2-b21c-412b1ea8dd55",
      "order_number": 10011,
      "customer_id": "30000000-0000-4000-8000-000000000011",
      "status": "delivered",
      "payment_status": "verified",
      "address": {
        "name": "Demo Parts Shop 11",
        "phone": "0100000000",
        "line1": "Demo address — not for delivery",
        "city": "Petaling Jaya",
        "postcode": "47300",
        "state": "Selangor"
      },
      "subtotal_cents": 21600,
      "discount_cents": 0,
      "shipping_cents": 1500,
      "total_cents": 23100,
      "payment_instructions": {
        "bank_name": "DEMO — DO NOT TRANSFER",
        "bank_account_name": "FICTIONAL EXAMPLE ONLY",
        "bank_account_number": "0000000000"
      },
      "payment_reference": "SAMPLE-NO-TRANSFER-11",
      "paid_verified_by": "seed-worker",
      "payment_note": null,
      "carrier": "Demo carrier",
      "tracking_number": "DEMO-NOT-A-PARCEL-11",
      "received_at": "2026-10-20T12:00:00.000Z",
      "cancel_reason": null,
      "idempotency_key": "54bb1b7d-8f31-479a-96f7-1c0451f15e0b",
      "created_at": "2026-10-18T12:00:00.000Z",
      "updated_at": "2026-10-20T12:00:00.000Z",
      "expires_at": "2026-10-19T12:00:00.000Z",
      "items": [
        {
          "id": "543998f6-9409-4a22-b01e-125f65b87d02",
          "order_id": "52190ce5-3c3b-48b2-b21c-412b1ea8dd55",
          "product_id": "top-1-green-radiator-coolant-500ml",
          "name": "Top 1 Green Radiator Coolant 500ml",
          "sku": "GL-0013",
          "category": "Coolant",
          "quantity": 9,
          "price_cents": 1000,
          "line_total_cents": 9000
        },
        {
          "id": "3cb5eef8-abcf-4432-b559-a49863f2f27c",
          "order_id": "52190ce5-3c3b-48b2-b21c-412b1ea8dd55",
          "product_id": "power-up-power-steering-fluid-1l",
          "name": "Power Up Power Steering Fluid 1L",
          "sku": "GL-0026",
          "category": "Steering Fluid",
          "quantity": 9,
          "price_cents": 1400,
          "line_total_cents": 12600
        }
      ],
      "events": [
        {
          "id": "741e308b-9a11-4626-b8c6-f1d5765f5160",
          "order_id": "52190ce5-3c3b-48b2-b21c-412b1ea8dd55",
          "event": "order_created",
          "actor_id": "30000000-0000-4000-8000-000000000011",
          "note": "Fictional example: inventory reserved.",
          "created_at": "2026-10-18T12:00:00.000Z"
        },
        {
          "id": "441a8676-0ec8-41ed-b699-aeba7601b901",
          "order_id": "52190ce5-3c3b-48b2-b21c-412b1ea8dd55",
          "event": "payment_submitted",
          "actor_id": "30000000-0000-4000-8000-000000000011",
          "note": "Fictional bank reference; no transfer occurred.",
          "created_at": "2026-10-18T12:10:00.000Z"
        },
        {
          "id": "2ad8722f-553f-426d-8482-4f5dc367f721",
          "order_id": "52190ce5-3c3b-48b2-b21c-412b1ea8dd55",
          "event": "payment_verified",
          "actor_id": "seed-worker",
          "note": "Fictional deposit verification.",
          "created_at": "2026-10-18T12:20:00.000Z"
        },
        {
          "id": "5ba82dcb-909b-44e8-95cf-a9974b47e1d6",
          "order_id": "52190ce5-3c3b-48b2-b21c-412b1ea8dd55",
          "event": "shipped",
          "actor_id": "seed-worker",
          "note": "Fictional carrier and tracking number.",
          "created_at": "2026-10-19T12:00:00.000Z"
        },
        {
          "id": "0757b989-0cf4-4552-81f3-2b6df748a56a",
          "order_id": "52190ce5-3c3b-48b2-b21c-412b1ea8dd55",
          "event": "receipt_confirmed",
          "actor_id": "30000000-0000-4000-8000-000000000011",
          "note": "Fictional buyer confirmed receipt.",
          "created_at": "2026-10-20T12:00:00.000Z"
        }
      ],
      "sample_data": true
    },
    {
      "id": "3ed9084c-0b17-4c7a-b0e3-715b1a0feb12",
      "order_number": 10017,
      "customer_id": "30000000-0000-4000-8000-000000000005",
      "status": "delivered",
      "payment_status": "verified",
      "address": {
        "name": "Demo Motorist 05",
        "phone": "0100000000",
        "line1": "Demo address — not for delivery",
        "city": "Petaling Jaya",
        "postcode": "47300",
        "state": "Selangor"
      },
      "subtotal_cents": 6800,
      "discount_cents": 0,
      "shipping_cents": 1500,
      "total_cents": 8300,
      "payment_instructions": {
        "bank_name": "DEMO — DO NOT TRANSFER",
        "bank_account_name": "FICTIONAL EXAMPLE ONLY",
        "bank_account_number": "0000000000"
      },
      "payment_reference": "SAMPLE-NO-TRANSFER-17",
      "paid_verified_by": "seed-worker",
      "payment_note": null,
      "carrier": "Demo carrier",
      "tracking_number": "DEMO-NOT-A-PARCEL-17",
      "received_at": "2026-10-20T06:00:00.000Z",
      "cancel_reason": null,
      "idempotency_key": "481726b7-987f-4e66-847d-5c9d76467fa7",
      "created_at": "2026-10-18T06:00:00.000Z",
      "updated_at": "2026-10-20T06:00:00.000Z",
      "expires_at": "2026-10-19T06:00:00.000Z",
      "items": [
        {
          "id": "dfd9eec3-cd47-48b6-9cc5-a6d2e508b0ef",
          "order_id": "3ed9084c-0b17-4c7a-b0e3-715b1a0feb12",
          "product_id": "petrol-filter-for-proton-iriz-saga-vvt-persona-vvt",
          "name": "Petrol Filter for Proton Iriz / Saga VVT / Persona VVT",
          "sku": "GL-0017",
          "category": "Filters",
          "quantity": 1,
          "price_cents": 2800,
          "line_total_cents": 2800
        },
        {
          "id": "952b518b-df59-498e-9c3c-79b30d0616e7",
          "order_id": "3ed9084c-0b17-4c7a-b0e3-715b1a0feb12",
          "product_id": "aftermarket-engine-oil-filters-10-pack",
          "name": "Aftermarket Engine Oil Filters — 10 Pack",
          "sku": "GL-0019",
          "category": "Filters",
          "quantity": 1,
          "price_cents": 4000,
          "line_total_cents": 4000
        }
      ],
      "events": [
        {
          "id": "3bc9ea95-8f1b-4d8f-a8bb-14fab97614cc",
          "order_id": "3ed9084c-0b17-4c7a-b0e3-715b1a0feb12",
          "event": "order_created",
          "actor_id": "30000000-0000-4000-8000-000000000005",
          "note": "Fictional example: inventory reserved.",
          "created_at": "2026-10-18T06:00:00.000Z"
        },
        {
          "id": "72691dc3-cce0-4483-9b3a-5fadcf02bb86",
          "order_id": "3ed9084c-0b17-4c7a-b0e3-715b1a0feb12",
          "event": "payment_submitted",
          "actor_id": "30000000-0000-4000-8000-000000000005",
          "note": "Fictional bank reference; no transfer occurred.",
          "created_at": "2026-10-18T06:10:00.000Z"
        },
        {
          "id": "ef708436-9700-4e42-af2a-cee15b6382a7",
          "order_id": "3ed9084c-0b17-4c7a-b0e3-715b1a0feb12",
          "event": "payment_verified",
          "actor_id": "seed-worker",
          "note": "Fictional deposit verification.",
          "created_at": "2026-10-18T06:20:00.000Z"
        },
        {
          "id": "884e6884-688c-4efe-a5f8-9b6c4b376086",
          "order_id": "3ed9084c-0b17-4c7a-b0e3-715b1a0feb12",
          "event": "shipped",
          "actor_id": "seed-worker",
          "note": "Fictional carrier and tracking number.",
          "created_at": "2026-10-19T06:00:00.000Z"
        },
        {
          "id": "e9381475-871f-42a6-ac70-d7f12692e64a",
          "order_id": "3ed9084c-0b17-4c7a-b0e3-715b1a0feb12",
          "event": "receipt_confirmed",
          "actor_id": "30000000-0000-4000-8000-000000000005",
          "note": "Fictional buyer confirmed receipt.",
          "created_at": "2026-10-20T06:00:00.000Z"
        }
      ],
      "sample_data": true
    },
    {
      "id": "3213edfa-71f9-4487-b35e-cf2c8b72b508",
      "order_number": 10012,
      "customer_id": "30000000-0000-4000-8000-000000000012",
      "status": "delivered",
      "payment_status": "verified",
      "address": {
        "name": "Demo Distributor 12",
        "phone": "0100000000",
        "line1": "Demo address — not for delivery",
        "city": "Petaling Jaya",
        "postcode": "47300",
        "state": "Selangor"
      },
      "subtotal_cents": 273000,
      "discount_cents": 0,
      "shipping_cents": 0,
      "total_cents": 273000,
      "payment_instructions": {
        "bank_name": "DEMO — DO NOT TRANSFER",
        "bank_account_name": "FICTIONAL EXAMPLE ONLY",
        "bank_account_number": "0000000000"
      },
      "payment_reference": "SAMPLE-NO-TRANSFER-12",
      "paid_verified_by": "seed-worker",
      "payment_note": null,
      "carrier": "Demo carrier",
      "tracking_number": "DEMO-NOT-A-PARCEL-12",
      "received_at": "2026-10-19T13:00:00.000Z",
      "cancel_reason": null,
      "idempotency_key": "24eccb87-52e2-45ee-b76d-03b00c3aff98",
      "created_at": "2026-10-17T13:00:00.000Z",
      "updated_at": "2026-10-19T13:00:00.000Z",
      "expires_at": "2026-10-18T13:00:00.000Z",
      "items": [
        {
          "id": "ef6eb611-9af1-46b5-bf25-483ca3ce0fb2",
          "order_id": "3213edfa-71f9-4487-b35e-cf2c8b72b508",
          "product_id": "cabin-filter-for-proton-x50",
          "name": "Cabin Filter for Proton X50",
          "sku": "GL-0009",
          "category": "Filters",
          "quantity": 14,
          "price_cents": 2500,
          "line_total_cents": 35000
        },
        {
          "id": "8ee3d4ce-8b14-49b6-a336-511fbcf220e4",
          "order_id": "3213edfa-71f9-4487-b35e-cf2c8b72b508",
          "product_id": "trw-gdb8977-front-brake-pads",
          "name": "TRW GDB8977 Front Brake Pads",
          "sku": "GL-0047",
          "category": "Brake Pads",
          "quantity": 14,
          "price_cents": 7500,
          "line_total_cents": 105000
        },
        {
          "id": "b8715158-f3ed-497f-9765-a302a55815c2",
          "order_id": "3213edfa-71f9-4487-b35e-cf2c8b72b508",
          "product_id": "castrol-gtx-ultraclean-15w-40-engine-oil-4l",
          "name": "Castrol GTX Ultraclean 15W-40 Engine Oil 4L",
          "sku": "GL-0004",
          "category": "Engine Oil",
          "quantity": 14,
          "price_cents": 9500,
          "line_total_cents": 133000
        }
      ],
      "events": [
        {
          "id": "9fdbc592-e5f7-4f4c-bda9-c76611b4c50d",
          "order_id": "3213edfa-71f9-4487-b35e-cf2c8b72b508",
          "event": "order_created",
          "actor_id": "30000000-0000-4000-8000-000000000012",
          "note": "Fictional example: inventory reserved.",
          "created_at": "2026-10-17T13:00:00.000Z"
        },
        {
          "id": "84a4ba51-3d19-4d2c-b314-6dd9a651b6d3",
          "order_id": "3213edfa-71f9-4487-b35e-cf2c8b72b508",
          "event": "payment_submitted",
          "actor_id": "30000000-0000-4000-8000-000000000012",
          "note": "Fictional bank reference; no transfer occurred.",
          "created_at": "2026-10-17T13:10:00.000Z"
        },
        {
          "id": "e2789afa-9de8-45b5-b0e4-a40224162587",
          "order_id": "3213edfa-71f9-4487-b35e-cf2c8b72b508",
          "event": "payment_verified",
          "actor_id": "seed-worker",
          "note": "Fictional deposit verification.",
          "created_at": "2026-10-17T13:20:00.000Z"
        },
        {
          "id": "5ae55dbd-3fb6-44d4-952b-c9de16727828",
          "order_id": "3213edfa-71f9-4487-b35e-cf2c8b72b508",
          "event": "shipped",
          "actor_id": "seed-worker",
          "note": "Fictional carrier and tracking number.",
          "created_at": "2026-10-18T13:00:00.000Z"
        },
        {
          "id": "a3382844-19d6-409d-9790-75482cf827a9",
          "order_id": "3213edfa-71f9-4487-b35e-cf2c8b72b508",
          "event": "receipt_confirmed",
          "actor_id": "30000000-0000-4000-8000-000000000012",
          "note": "Fictional buyer confirmed receipt.",
          "created_at": "2026-10-19T13:00:00.000Z"
        }
      ],
      "sample_data": true
    },
    {
      "id": "98b1d760-8479-42c0-a53b-29499f216be6",
      "order_number": 10018,
      "customer_id": "30000000-0000-4000-8000-000000000006",
      "status": "cancelled",
      "payment_status": "refunded",
      "address": {
        "name": "Demo Workshop 06",
        "phone": "0100000000",
        "line1": "Demo address — not for delivery",
        "city": "Petaling Jaya",
        "postcode": "47300",
        "state": "Selangor"
      },
      "subtotal_cents": 40400,
      "discount_cents": 0,
      "shipping_cents": 0,
      "total_cents": 40400,
      "payment_instructions": {
        "bank_name": "DEMO — DO NOT TRANSFER",
        "bank_account_name": "FICTIONAL EXAMPLE ONLY",
        "bank_account_number": "0000000000"
      },
      "payment_reference": "SAMPLE-NO-TRANSFER-18",
      "paid_verified_by": "seed-worker",
      "payment_note": null,
      "carrier": "Demo carrier",
      "tracking_number": "DEMO-NOT-A-PARCEL-18",
      "received_at": "2026-10-19T10:00:00.000Z",
      "cancel_reason": null,
      "idempotency_key": "56d0264a-91c1-4f5e-8975-bf9729a19d4b",
      "created_at": "2026-10-17T10:00:00.000Z",
      "updated_at": "2026-10-20T10:00:00.000Z",
      "expires_at": "2026-10-18T10:00:00.000Z",
      "items": [
        {
          "id": "2d8d783b-5d6f-4134-b20f-94bd6e85abf0",
          "order_id": "98b1d760-8479-42c0-a53b-29499f216be6",
          "product_id": "10w-30-engine-oil-perodua-oil-filter-bundle",
          "name": "10W-30 Engine Oil + Perodua Oil Filter Bundle",
          "sku": "GL-0030",
          "category": "Engine Oil",
          "quantity": 4,
          "price_cents": 4800,
          "line_total_cents": 19200
        },
        {
          "id": "48146adb-73d7-43fa-a9b4-ece488d663ec",
          "order_id": "98b1d760-8479-42c0-a53b-29499f216be6",
          "product_id": "aftermarket-engine-oil-filters-10-pack",
          "name": "Aftermarket Engine Oil Filters — 10 Pack",
          "sku": "GL-0019",
          "category": "Filters",
          "quantity": 4,
          "price_cents": 4000,
          "line_total_cents": 16000
        },
        {
          "id": "0f4ad4eb-0242-4afc-8818-bdc21405964f",
          "order_id": "98b1d760-8479-42c0-a53b-29499f216be6",
          "product_id": "dexron-iii-atf-d3-transmission-fluid-1l",
          "name": "Dexron III ATF D3 Transmission Fluid 1L",
          "sku": "GL-0035",
          "category": "Transmission Fluid",
          "quantity": 4,
          "price_cents": 1300,
          "line_total_cents": 5200
        }
      ],
      "events": [
        {
          "id": "cdc236bc-5d79-44fa-80cc-d66605e962a1",
          "order_id": "98b1d760-8479-42c0-a53b-29499f216be6",
          "event": "order_created",
          "actor_id": "30000000-0000-4000-8000-000000000006",
          "note": "Fictional example: inventory reserved.",
          "created_at": "2026-10-17T10:00:00.000Z"
        },
        {
          "id": "0a5e1a97-2a1e-43e9-84f0-68ccc5506e77",
          "order_id": "98b1d760-8479-42c0-a53b-29499f216be6",
          "event": "payment_submitted",
          "actor_id": "30000000-0000-4000-8000-000000000006",
          "note": "Fictional bank reference; no transfer occurred.",
          "created_at": "2026-10-17T10:10:00.000Z"
        },
        {
          "id": "2e1d9916-98ba-4a30-8882-d43f24575f2b",
          "order_id": "98b1d760-8479-42c0-a53b-29499f216be6",
          "event": "payment_verified",
          "actor_id": "seed-worker",
          "note": "Fictional deposit verification.",
          "created_at": "2026-10-17T10:20:00.000Z"
        },
        {
          "id": "1dd3eb96-7d02-40cf-83c6-9b8e503af6a6",
          "order_id": "98b1d760-8479-42c0-a53b-29499f216be6",
          "event": "shipped",
          "actor_id": "seed-worker",
          "note": "Fictional carrier and tracking number.",
          "created_at": "2026-10-18T10:00:00.000Z"
        },
        {
          "id": "d8277a01-24d9-4afa-ad1a-1c2f8df74f99",
          "order_id": "98b1d760-8479-42c0-a53b-29499f216be6",
          "event": "receipt_confirmed",
          "actor_id": "30000000-0000-4000-8000-000000000006",
          "note": "Fictional buyer confirmed receipt.",
          "created_at": "2026-10-19T10:00:00.000Z"
        },
        {
          "id": "0640a21c-7262-4762-a93b-d9c2a4e2c09f",
          "order_id": "98b1d760-8479-42c0-a53b-29499f216be6",
          "event": "refund_paid",
          "actor_id": "seed-admin",
          "note": "Fictional full refund; returned units restored.",
          "created_at": "2026-10-20T10:00:00.000Z"
        }
      ],
      "sample_data": true
    },
    {
      "id": "f8a9ee30-4bc3-4cb3-a6d0-e2864613fcd0",
      "order_number": 10019,
      "customer_id": "30000000-0000-4000-8000-000000000007",
      "status": "delivered",
      "payment_status": "verified",
      "address": {
        "name": "Demo Parts Shop 07",
        "phone": "0100000000",
        "line1": "Demo address — not for delivery",
        "city": "Petaling Jaya",
        "postcode": "47300",
        "state": "Selangor"
      },
      "subtotal_cents": 52000,
      "discount_cents": 0,
      "shipping_cents": 0,
      "total_cents": 52000,
      "payment_instructions": {
        "bank_name": "DEMO — DO NOT TRANSFER",
        "bank_account_name": "FICTIONAL EXAMPLE ONLY",
        "bank_account_number": "0000000000"
      },
      "payment_reference": "SAMPLE-NO-TRANSFER-19",
      "paid_verified_by": "seed-worker",
      "payment_note": null,
      "carrier": "Demo carrier",
      "tracking_number": "DEMO-NOT-A-PARCEL-19",
      "received_at": "2026-10-18T12:00:00.000Z",
      "cancel_reason": null,
      "idempotency_key": "0126a821-7f1b-46d1-a4d5-c2b500e8fbaa",
      "created_at": "2026-10-16T12:00:00.000Z",
      "updated_at": "2026-10-18T12:00:00.000Z",
      "expires_at": "2026-10-17T12:00:00.000Z",
      "items": [
        {
          "id": "2875eecd-1a28-4882-a02e-21ef99a892eb",
          "order_id": "f8a9ee30-4bc3-4cb3-a6d0-e2864613fcd0",
          "product_id": "trw-gdb1198-front-brake-pads",
          "name": "TRW GDB1198 Front Brake Pads",
          "sku": "GL-0046",
          "category": "Brake Pads",
          "quantity": 10,
          "price_cents": 5200,
          "line_total_cents": 52000
        }
      ],
      "events": [
        {
          "id": "d3a8b97e-a627-42f8-b5e4-f9f5fa6a218d",
          "order_id": "f8a9ee30-4bc3-4cb3-a6d0-e2864613fcd0",
          "event": "order_created",
          "actor_id": "30000000-0000-4000-8000-000000000007",
          "note": "Fictional example: inventory reserved.",
          "created_at": "2026-10-16T12:00:00.000Z"
        },
        {
          "id": "79258bb4-bb2a-4ba9-9e6e-b43b06a1e300",
          "order_id": "f8a9ee30-4bc3-4cb3-a6d0-e2864613fcd0",
          "event": "payment_submitted",
          "actor_id": "30000000-0000-4000-8000-000000000007",
          "note": "Fictional bank reference; no transfer occurred.",
          "created_at": "2026-10-16T12:10:00.000Z"
        },
        {
          "id": "c5988235-3a40-4dde-a6bf-ff2387f91722",
          "order_id": "f8a9ee30-4bc3-4cb3-a6d0-e2864613fcd0",
          "event": "payment_verified",
          "actor_id": "seed-worker",
          "note": "Fictional deposit verification.",
          "created_at": "2026-10-16T12:20:00.000Z"
        },
        {
          "id": "9e0c2ac0-5170-4918-b529-542c82e891ec",
          "order_id": "f8a9ee30-4bc3-4cb3-a6d0-e2864613fcd0",
          "event": "shipped",
          "actor_id": "seed-worker",
          "note": "Fictional carrier and tracking number.",
          "created_at": "2026-10-17T12:00:00.000Z"
        },
        {
          "id": "4a94af9e-6fca-4895-88bd-9cf3d7c11739",
          "order_id": "f8a9ee30-4bc3-4cb3-a6d0-e2864613fcd0",
          "event": "receipt_confirmed",
          "actor_id": "30000000-0000-4000-8000-000000000007",
          "note": "Fictional buyer confirmed receipt.",
          "created_at": "2026-10-18T12:00:00.000Z"
        }
      ],
      "sample_data": true
    },
    {
      "id": "3b2e2bed-8f6e-43d8-80bf-29b3898ecc7e",
      "order_number": 10013,
      "customer_id": "30000000-0000-4000-8000-000000000001",
      "status": "delivered",
      "payment_status": "verified",
      "address": {
        "name": "Demo Motorist 01",
        "phone": "0100000000",
        "line1": "Demo address — not for delivery",
        "city": "Petaling Jaya",
        "postcode": "47300",
        "state": "Selangor"
      },
      "subtotal_cents": 6000,
      "discount_cents": 0,
      "shipping_cents": 1500,
      "total_cents": 7500,
      "payment_instructions": {
        "bank_name": "DEMO — DO NOT TRANSFER",
        "bank_account_name": "FICTIONAL EXAMPLE ONLY",
        "bank_account_number": "0000000000"
      },
      "payment_reference": "SAMPLE-NO-TRANSFER-13",
      "paid_verified_by": "seed-worker",
      "payment_note": null,
      "carrier": "Demo carrier",
      "tracking_number": "DEMO-NOT-A-PARCEL-13",
      "received_at": "2026-10-18T01:00:00.000Z",
      "cancel_reason": null,
      "idempotency_key": "16ea1e27-c4c1-48b2-8537-fa48bdfdaa91",
      "created_at": "2026-10-16T01:00:00.000Z",
      "updated_at": "2026-10-18T01:00:00.000Z",
      "expires_at": "2026-10-17T01:00:00.000Z",
      "items": [
        {
          "id": "53209124-15e7-4534-8cf2-e5e6cfd3fa6b",
          "order_id": "3b2e2bed-8f6e-43d8-80bf-29b3898ecc7e",
          "product_id": "bosch-super-4-wr78x-spark-plugs-4-pack",
          "name": "Bosch Super 4 WR78X Spark Plugs — 4 Pack",
          "sku": "GL-0039",
          "category": "Spark Plugs",
          "quantity": 1,
          "price_cents": 6000,
          "line_total_cents": 6000
        }
      ],
      "events": [
        {
          "id": "a03f856e-2ece-4914-800c-f54a0d29dfed",
          "order_id": "3b2e2bed-8f6e-43d8-80bf-29b3898ecc7e",
          "event": "order_created",
          "actor_id": "30000000-0000-4000-8000-000000000001",
          "note": "Fictional example: inventory reserved.",
          "created_at": "2026-10-16T01:00:00.000Z"
        },
        {
          "id": "694bc430-629e-43d9-aeaf-7c487755884c",
          "order_id": "3b2e2bed-8f6e-43d8-80bf-29b3898ecc7e",
          "event": "payment_submitted",
          "actor_id": "30000000-0000-4000-8000-000000000001",
          "note": "Fictional bank reference; no transfer occurred.",
          "created_at": "2026-10-16T01:10:00.000Z"
        },
        {
          "id": "bdd8d0c9-f97e-44ae-b6d6-2e56e70bb5e9",
          "order_id": "3b2e2bed-8f6e-43d8-80bf-29b3898ecc7e",
          "event": "payment_verified",
          "actor_id": "seed-worker",
          "note": "Fictional deposit verification.",
          "created_at": "2026-10-16T01:20:00.000Z"
        },
        {
          "id": "b5fd7df8-4ed4-493e-969b-b9b5684fe16d",
          "order_id": "3b2e2bed-8f6e-43d8-80bf-29b3898ecc7e",
          "event": "shipped",
          "actor_id": "seed-worker",
          "note": "Fictional carrier and tracking number.",
          "created_at": "2026-10-17T01:00:00.000Z"
        },
        {
          "id": "4b3049b8-039c-437f-a192-0d4a36d37c7c",
          "order_id": "3b2e2bed-8f6e-43d8-80bf-29b3898ecc7e",
          "event": "receipt_confirmed",
          "actor_id": "30000000-0000-4000-8000-000000000001",
          "note": "Fictional buyer confirmed receipt.",
          "created_at": "2026-10-18T01:00:00.000Z"
        }
      ],
      "sample_data": true
    },
    {
      "id": "b5942df3-1c8e-4dd7-9a67-3d7106ac83c7",
      "order_number": 10020,
      "customer_id": "30000000-0000-4000-8000-000000000008",
      "status": "delivered",
      "payment_status": "verified",
      "address": {
        "name": "Demo Distributor 08",
        "phone": "0100000000",
        "line1": "Demo address — not for delivery",
        "city": "Petaling Jaya",
        "postcode": "47300",
        "state": "Selangor"
      },
      "subtotal_cents": 243100,
      "discount_cents": 0,
      "shipping_cents": 0,
      "total_cents": 243100,
      "payment_instructions": {
        "bank_name": "DEMO — DO NOT TRANSFER",
        "bank_account_name": "FICTIONAL EXAMPLE ONLY",
        "bank_account_number": "0000000000"
      },
      "payment_reference": "SAMPLE-NO-TRANSFER-20",
      "paid_verified_by": "seed-worker",
      "payment_note": null,
      "carrier": "Demo carrier",
      "tracking_number": "DEMO-NOT-A-PARCEL-20",
      "received_at": "2026-10-17T13:00:00.000Z",
      "cancel_reason": null,
      "idempotency_key": "1f3d5430-4ff0-440b-97ef-4012e4983dda",
      "created_at": "2026-10-15T13:00:00.000Z",
      "updated_at": "2026-10-17T13:00:00.000Z",
      "expires_at": "2026-10-16T13:00:00.000Z",
      "items": [
        {
          "id": "0887d5d2-7ef2-4151-a027-bb4754f294dc",
          "order_id": "b5942df3-1c8e-4dd7-9a67-3d7106ac83c7",
          "product_id": "perodua-fully-synthetic-0w-20-oil-3-5l-filter",
          "name": "Perodua Fully Synthetic 0W-20 Oil 3.5L + Filter",
          "sku": "GL-0020",
          "category": "Engine Oil",
          "quantity": 13,
          "price_cents": 16500,
          "line_total_cents": 214500
        },
        {
          "id": "ea56feab-d84d-4bb6-a6b5-044f314f43cf",
          "order_id": "b5942df3-1c8e-4dd7-9a67-3d7106ac83c7",
          "product_id": "bendix-dot-4-brake-and-clutch-fluid-1l",
          "name": "Bendix DOT 4 Brake and Clutch Fluid 1L",
          "sku": "GL-0003",
          "category": "Brake Fluid",
          "quantity": 13,
          "price_cents": 2200,
          "line_total_cents": 28600
        }
      ],
      "events": [
        {
          "id": "ef5f9df3-5c3f-4794-911a-4a70298e4694",
          "order_id": "b5942df3-1c8e-4dd7-9a67-3d7106ac83c7",
          "event": "order_created",
          "actor_id": "30000000-0000-4000-8000-000000000008",
          "note": "Fictional example: inventory reserved.",
          "created_at": "2026-10-15T13:00:00.000Z"
        },
        {
          "id": "b91467bb-c100-408f-8e33-5c429c1cd823",
          "order_id": "b5942df3-1c8e-4dd7-9a67-3d7106ac83c7",
          "event": "payment_submitted",
          "actor_id": "30000000-0000-4000-8000-000000000008",
          "note": "Fictional bank reference; no transfer occurred.",
          "created_at": "2026-10-15T13:10:00.000Z"
        },
        {
          "id": "4a71bef1-f1c9-43ad-aa48-8380eac05a42",
          "order_id": "b5942df3-1c8e-4dd7-9a67-3d7106ac83c7",
          "event": "payment_verified",
          "actor_id": "seed-worker",
          "note": "Fictional deposit verification.",
          "created_at": "2026-10-15T13:20:00.000Z"
        },
        {
          "id": "5833c73a-b6d5-4f07-a4fb-89544666e08c",
          "order_id": "b5942df3-1c8e-4dd7-9a67-3d7106ac83c7",
          "event": "shipped",
          "actor_id": "seed-worker",
          "note": "Fictional carrier and tracking number.",
          "created_at": "2026-10-16T13:00:00.000Z"
        },
        {
          "id": "28a7cb32-c695-4d0d-a068-39e809b64ace",
          "order_id": "b5942df3-1c8e-4dd7-9a67-3d7106ac83c7",
          "event": "receipt_confirmed",
          "actor_id": "30000000-0000-4000-8000-000000000008",
          "note": "Fictional buyer confirmed receipt.",
          "created_at": "2026-10-17T13:00:00.000Z"
        }
      ],
      "sample_data": true
    },
    {
      "id": "441664bc-c8d2-4f48-8df3-78504a1ef436",
      "order_number": 10014,
      "customer_id": "30000000-0000-4000-8000-000000000002",
      "status": "delivered",
      "payment_status": "verified",
      "address": {
        "name": "Demo Workshop 02",
        "phone": "0100000000",
        "line1": "Demo address — not for delivery",
        "city": "Petaling Jaya",
        "postcode": "47300",
        "state": "Selangor"
      },
      "subtotal_cents": 12800,
      "discount_cents": 0,
      "shipping_cents": 1500,
      "total_cents": 14300,
      "payment_instructions": {
        "bank_name": "DEMO — DO NOT TRANSFER",
        "bank_account_name": "FICTIONAL EXAMPLE ONLY",
        "bank_account_number": "0000000000"
      },
      "payment_reference": "SAMPLE-NO-TRANSFER-14",
      "paid_verified_by": "seed-worker",
      "payment_note": null,
      "carrier": "Demo carrier",
      "tracking_number": "DEMO-NOT-A-PARCEL-14",
      "received_at": "2026-10-17T02:00:00.000Z",
      "cancel_reason": null,
      "idempotency_key": "6a3fdf77-d3c1-421f-b323-a7f9a27c2cc0",
      "created_at": "2026-10-15T02:00:00.000Z",
      "updated_at": "2026-10-17T02:00:00.000Z",
      "expires_at": "2026-10-16T02:00:00.000Z",
      "items": [
        {
          "id": "897b8af7-2848-480e-9293-d4c8ece4469e",
          "order_id": "441664bc-c8d2-4f48-8df3-78504a1ef436",
          "product_id": "power-up-power-steering-fluid-1l",
          "name": "Power Up Power Steering Fluid 1L",
          "sku": "GL-0026",
          "category": "Steering Fluid",
          "quantity": 4,
          "price_cents": 1400,
          "line_total_cents": 5600
        },
        {
          "id": "efe9cf08-2512-4482-800e-db5c23190055",
          "order_id": "441664bc-c8d2-4f48-8df3-78504a1ef436",
          "product_id": "engine-air-filter-for-proton-x70",
          "name": "Engine Air Filter for Proton X70",
          "sku": "GL-0012",
          "category": "Filters",
          "quantity": 4,
          "price_cents": 1800,
          "line_total_cents": 7200
        }
      ],
      "events": [
        {
          "id": "ca2034aa-63e1-4524-a09c-d688919742e6",
          "order_id": "441664bc-c8d2-4f48-8df3-78504a1ef436",
          "event": "order_created",
          "actor_id": "30000000-0000-4000-8000-000000000002",
          "note": "Fictional example: inventory reserved.",
          "created_at": "2026-10-15T02:00:00.000Z"
        },
        {
          "id": "32f22778-326b-407d-a06b-a18e494ef31a",
          "order_id": "441664bc-c8d2-4f48-8df3-78504a1ef436",
          "event": "payment_submitted",
          "actor_id": "30000000-0000-4000-8000-000000000002",
          "note": "Fictional bank reference; no transfer occurred.",
          "created_at": "2026-10-15T02:10:00.000Z"
        },
        {
          "id": "71e1747d-f117-49aa-bff6-af9250cedaa0",
          "order_id": "441664bc-c8d2-4f48-8df3-78504a1ef436",
          "event": "payment_verified",
          "actor_id": "seed-worker",
          "note": "Fictional deposit verification.",
          "created_at": "2026-10-15T02:20:00.000Z"
        },
        {
          "id": "ce2ab5e9-7caa-4139-a26f-2d9c422cc42c",
          "order_id": "441664bc-c8d2-4f48-8df3-78504a1ef436",
          "event": "shipped",
          "actor_id": "seed-worker",
          "note": "Fictional carrier and tracking number.",
          "created_at": "2026-10-16T02:00:00.000Z"
        },
        {
          "id": "7033494f-ca7a-4d1c-b37b-18a074796278",
          "order_id": "441664bc-c8d2-4f48-8df3-78504a1ef436",
          "event": "receipt_confirmed",
          "actor_id": "30000000-0000-4000-8000-000000000002",
          "note": "Fictional buyer confirmed receipt.",
          "created_at": "2026-10-17T02:00:00.000Z"
        }
      ],
      "sample_data": true
    },
    {
      "id": "52fb53cb-fc86-4d01-9c4a-ea2739800b14",
      "order_number": 10021,
      "customer_id": "30000000-0000-4000-8000-000000000009",
      "status": "delivered",
      "payment_status": "verified",
      "address": {
        "name": "Demo Motorist 09",
        "phone": "0100000000",
        "line1": "Demo address — not for delivery",
        "city": "Petaling Jaya",
        "postcode": "47300",
        "state": "Selangor"
      },
      "subtotal_cents": 13500,
      "discount_cents": 0,
      "shipping_cents": 1500,
      "total_cents": 15000,
      "payment_instructions": {
        "bank_name": "DEMO — DO NOT TRANSFER",
        "bank_account_name": "FICTIONAL EXAMPLE ONLY",
        "bank_account_number": "0000000000"
      },
      "payment_reference": "SAMPLE-NO-TRANSFER-21",
      "paid_verified_by": "seed-worker",
      "payment_note": null,
      "carrier": "Demo carrier",
      "tracking_number": "DEMO-NOT-A-PARCEL-21",
      "received_at": "2026-10-16T12:00:00.000Z",
      "cancel_reason": null,
      "idempotency_key": "7eb63ab7-1db6-4594-b94f-9b7ecb227839",
      "created_at": "2026-10-14T12:00:00.000Z",
      "updated_at": "2026-10-16T12:00:00.000Z",
      "expires_at": "2026-10-15T12:00:00.000Z",
      "items": [
        {
          "id": "5889e399-807e-4071-9f1e-47875f729b2f",
          "order_id": "52fb53cb-fc86-4d01-9c4a-ea2739800b14",
          "product_id": "ngk-lkar7c-9-spark-plugs-4-pack",
          "name": "NGK LKAR7C-9 Spark Plugs — 4 Pack",
          "sku": "GL-0021",
          "category": "Spark Plugs",
          "quantity": 1,
          "price_cents": 6000,
          "line_total_cents": 6000
        },
        {
          "id": "6232411e-38b1-4b3e-b2ad-2abd32119f26",
          "order_id": "52fb53cb-fc86-4d01-9c4a-ea2739800b14",
          "product_id": "proton-cvt-transmission-fluid-1l",
          "name": "Proton CVT Transmission Fluid 1L",
          "sku": "GL-0005",
          "category": "Transmission Fluid",
          "quantity": 1,
          "price_cents": 5500,
          "line_total_cents": 5500
        },
        {
          "id": "bf03804e-6977-479c-a40d-636951019d03",
          "order_id": "52fb53cb-fc86-4d01-9c4a-ea2739800b14",
          "product_id": "cabin-filter-for-proton-x70",
          "name": "Cabin Filter for Proton X70",
          "sku": "GL-0010",
          "category": "Filters",
          "quantity": 1,
          "price_cents": 2000,
          "line_total_cents": 2000
        }
      ],
      "events": [
        {
          "id": "63eb391e-103b-4c8f-86d7-31d846a94a55",
          "order_id": "52fb53cb-fc86-4d01-9c4a-ea2739800b14",
          "event": "order_created",
          "actor_id": "30000000-0000-4000-8000-000000000009",
          "note": "Fictional example: inventory reserved.",
          "created_at": "2026-10-14T12:00:00.000Z"
        },
        {
          "id": "a38565f7-4741-4ef9-bf32-b612f96ff99c",
          "order_id": "52fb53cb-fc86-4d01-9c4a-ea2739800b14",
          "event": "payment_submitted",
          "actor_id": "30000000-0000-4000-8000-000000000009",
          "note": "Fictional bank reference; no transfer occurred.",
          "created_at": "2026-10-14T12:10:00.000Z"
        },
        {
          "id": "a00b0dd2-0e5c-424f-b783-8a7718800114",
          "order_id": "52fb53cb-fc86-4d01-9c4a-ea2739800b14",
          "event": "payment_verified",
          "actor_id": "seed-worker",
          "note": "Fictional deposit verification.",
          "created_at": "2026-10-14T12:20:00.000Z"
        },
        {
          "id": "e16e3d92-0709-4d82-914f-b54e5df10f5f",
          "order_id": "52fb53cb-fc86-4d01-9c4a-ea2739800b14",
          "event": "shipped",
          "actor_id": "seed-worker",
          "note": "Fictional carrier and tracking number.",
          "created_at": "2026-10-15T12:00:00.000Z"
        },
        {
          "id": "94f3c91d-4894-4e55-b803-3410a00097d7",
          "order_id": "52fb53cb-fc86-4d01-9c4a-ea2739800b14",
          "event": "receipt_confirmed",
          "actor_id": "30000000-0000-4000-8000-000000000009",
          "note": "Fictional buyer confirmed receipt.",
          "created_at": "2026-10-16T12:00:00.000Z"
        }
      ],
      "sample_data": true
    },
    {
      "id": "8424ad93-a3a6-4458-a46a-7aa1778ad160",
      "order_number": 10022,
      "customer_id": "30000000-0000-4000-8000-000000000010",
      "status": "delivered",
      "payment_status": "verified",
      "address": {
        "name": "Demo Workshop 10",
        "phone": "0100000000",
        "line1": "Demo address — not for delivery",
        "city": "Petaling Jaya",
        "postcode": "47300",
        "state": "Selangor"
      },
      "subtotal_cents": 40000,
      "discount_cents": 0,
      "shipping_cents": 0,
      "total_cents": 40000,
      "payment_instructions": {
        "bank_name": "DEMO — DO NOT TRANSFER",
        "bank_account_name": "FICTIONAL EXAMPLE ONLY",
        "bank_account_number": "0000000000"
      },
      "payment_reference": "SAMPLE-NO-TRANSFER-22",
      "paid_verified_by": "seed-worker",
      "payment_note": null,
      "carrier": "Demo carrier",
      "tracking_number": "DEMO-NOT-A-PARCEL-22",
      "received_at": "2026-10-15T13:00:00.000Z",
      "cancel_reason": null,
      "idempotency_key": "9b2bfd0b-01f6-4038-9deb-7853ba336e58",
      "created_at": "2026-10-13T13:00:00.000Z",
      "updated_at": "2026-10-15T13:00:00.000Z",
      "expires_at": "2026-10-14T13:00:00.000Z",
      "items": [
        {
          "id": "8ab3a3a8-9f65-4a2f-a99b-93f313620984",
          "order_id": "8424ad93-a3a6-4458-a46a-7aa1778ad160",
          "product_id": "toyota-5w-30-engine-oil-4l",
          "name": "Toyota 5W-30 Engine Oil 4L",
          "sku": "GL-0036",
          "category": "Engine Oil",
          "quantity": 4,
          "price_cents": 10000,
          "line_total_cents": 40000
        }
      ],
      "events": [
        {
          "id": "d648aa21-402f-41c6-ab9d-acc8be05cd41",
          "order_id": "8424ad93-a3a6-4458-a46a-7aa1778ad160",
          "event": "order_created",
          "actor_id": "30000000-0000-4000-8000-000000000010",
          "note": "Fictional example: inventory reserved.",
          "created_at": "2026-10-13T13:00:00.000Z"
        },
        {
          "id": "bfbbec07-ca2c-4b70-8e0e-325670e8bed3",
          "order_id": "8424ad93-a3a6-4458-a46a-7aa1778ad160",
          "event": "payment_submitted",
          "actor_id": "30000000-0000-4000-8000-000000000010",
          "note": "Fictional bank reference; no transfer occurred.",
          "created_at": "2026-10-13T13:10:00.000Z"
        },
        {
          "id": "b30e2d91-3248-46bf-b073-5065e8745b4d",
          "order_id": "8424ad93-a3a6-4458-a46a-7aa1778ad160",
          "event": "payment_verified",
          "actor_id": "seed-worker",
          "note": "Fictional deposit verification.",
          "created_at": "2026-10-13T13:20:00.000Z"
        },
        {
          "id": "64d8badb-b718-4923-9b42-dbff2ddf5095",
          "order_id": "8424ad93-a3a6-4458-a46a-7aa1778ad160",
          "event": "shipped",
          "actor_id": "seed-worker",
          "note": "Fictional carrier and tracking number.",
          "created_at": "2026-10-14T13:00:00.000Z"
        },
        {
          "id": "14777e93-1154-450e-822a-9a65f6f20209",
          "order_id": "8424ad93-a3a6-4458-a46a-7aa1778ad160",
          "event": "receipt_confirmed",
          "actor_id": "30000000-0000-4000-8000-000000000010",
          "note": "Fictional buyer confirmed receipt.",
          "created_at": "2026-10-15T13:00:00.000Z"
        }
      ],
      "sample_data": true
    },
    {
      "id": "1cc9fe90-8c13-4a50-92fd-ae1f0afb07cb",
      "order_number": 10023,
      "customer_id": "30000000-0000-4000-8000-000000000011",
      "status": "delivered",
      "payment_status": "verified",
      "address": {
        "name": "Demo Parts Shop 11",
        "phone": "0100000000",
        "line1": "Demo address — not for delivery",
        "city": "Petaling Jaya",
        "postcode": "47300",
        "state": "Selangor"
      },
      "subtotal_cents": 32900,
      "discount_cents": 0,
      "shipping_cents": 0,
      "total_cents": 32900,
      "payment_instructions": {
        "bank_name": "DEMO — DO NOT TRANSFER",
        "bank_account_name": "FICTIONAL EXAMPLE ONLY",
        "bank_account_number": "0000000000"
      },
      "payment_reference": "SAMPLE-NO-TRANSFER-23",
      "paid_verified_by": "seed-worker",
      "payment_note": null,
      "carrier": "Demo carrier",
      "tracking_number": "DEMO-NOT-A-PARCEL-23",
      "received_at": "2026-10-14T12:00:00.000Z",
      "cancel_reason": null,
      "idempotency_key": "39e8f401-1121-49d5-9cbe-21a90af9b281",
      "created_at": "2026-10-12T12:00:00.000Z",
      "updated_at": "2026-10-14T12:00:00.000Z",
      "expires_at": "2026-10-13T12:00:00.000Z",
      "items": [
        {
          "id": "1b4a533f-054e-4d04-bb5f-3fd8ae003fb2",
          "order_id": "1cc9fe90-8c13-4a50-92fd-ae1f0afb07cb",
          "product_id": "bendix-dot-4-brake-and-clutch-fluid-1l",
          "name": "Bendix DOT 4 Brake and Clutch Fluid 1L",
          "sku": "GL-0003",
          "category": "Brake Fluid",
          "quantity": 7,
          "price_cents": 2200,
          "line_total_cents": 15400
        },
        {
          "id": "2589652c-4704-4415-9cf1-9e4ebe3ad360",
          "order_id": "1cc9fe90-8c13-4a50-92fd-ae1f0afb07cb",
          "product_id": "perodua-radiator-coolant-1l",
          "name": "Perodua Radiator Coolant 1L",
          "sku": "GL-0024",
          "category": "Coolant",
          "quantity": 7,
          "price_cents": 2500,
          "line_total_cents": 17500
        }
      ],
      "events": [
        {
          "id": "50e0ca6d-dc27-4bf6-88a4-9d946692ba94",
          "order_id": "1cc9fe90-8c13-4a50-92fd-ae1f0afb07cb",
          "event": "order_created",
          "actor_id": "30000000-0000-4000-8000-000000000011",
          "note": "Fictional example: inventory reserved.",
          "created_at": "2026-10-12T12:00:00.000Z"
        },
        {
          "id": "be61d3f9-ead0-4ca5-b263-53bf19406221",
          "order_id": "1cc9fe90-8c13-4a50-92fd-ae1f0afb07cb",
          "event": "payment_submitted",
          "actor_id": "30000000-0000-4000-8000-000000000011",
          "note": "Fictional bank reference; no transfer occurred.",
          "created_at": "2026-10-12T12:10:00.000Z"
        },
        {
          "id": "a373e9ac-229c-43a0-9f41-a4d0c3484ea8",
          "order_id": "1cc9fe90-8c13-4a50-92fd-ae1f0afb07cb",
          "event": "payment_verified",
          "actor_id": "seed-worker",
          "note": "Fictional deposit verification.",
          "created_at": "2026-10-12T12:20:00.000Z"
        },
        {
          "id": "79d416dd-aa34-4265-a8c3-c00c0f913a8b",
          "order_id": "1cc9fe90-8c13-4a50-92fd-ae1f0afb07cb",
          "event": "shipped",
          "actor_id": "seed-worker",
          "note": "Fictional carrier and tracking number.",
          "created_at": "2026-10-13T12:00:00.000Z"
        },
        {
          "id": "e827c765-2e65-4ae9-a0f1-d9cce6039f4e",
          "order_id": "1cc9fe90-8c13-4a50-92fd-ae1f0afb07cb",
          "event": "receipt_confirmed",
          "actor_id": "30000000-0000-4000-8000-000000000011",
          "note": "Fictional buyer confirmed receipt.",
          "created_at": "2026-10-14T12:00:00.000Z"
        }
      ],
      "sample_data": true
    },
    {
      "id": "e89eeb3d-685a-454c-86fd-5c758d09a4d1",
      "order_number": 10024,
      "customer_id": "30000000-0000-4000-8000-000000000012",
      "status": "delivered",
      "payment_status": "verified",
      "address": {
        "name": "Demo Distributor 12",
        "phone": "0100000000",
        "line1": "Demo address — not for delivery",
        "city": "Petaling Jaya",
        "postcode": "47300",
        "state": "Selangor"
      },
      "subtotal_cents": 144500,
      "discount_cents": 0,
      "shipping_cents": 0,
      "total_cents": 144500,
      "payment_instructions": {
        "bank_name": "DEMO — DO NOT TRANSFER",
        "bank_account_name": "FICTIONAL EXAMPLE ONLY",
        "bank_account_number": "0000000000"
      },
      "payment_reference": "SAMPLE-NO-TRANSFER-24",
      "paid_verified_by": "seed-worker",
      "payment_note": null,
      "carrier": "Demo carrier",
      "tracking_number": "DEMO-NOT-A-PARCEL-24",
      "received_at": "2026-10-13T13:00:00.000Z",
      "cancel_reason": null,
      "idempotency_key": "b52790a2-f0ca-4643-8d8b-026c95185fd2",
      "created_at": "2026-10-11T13:00:00.000Z",
      "updated_at": "2026-10-13T13:00:00.000Z",
      "expires_at": "2026-10-12T13:00:00.000Z",
      "items": [
        {
          "id": "4f55d327-286e-4a7d-9058-f2e805a5e77a",
          "order_id": "e89eeb3d-685a-454c-86fd-5c758d09a4d1",
          "product_id": "manual-gear-oil-ep-140-1l",
          "name": "Manual Gear Oil EP 140 1L",
          "sku": "GL-0016",
          "category": "Transmission Fluid",
          "quantity": 17,
          "price_cents": 1500,
          "line_total_cents": 25500
        },
        {
          "id": "366fbca5-4f40-4aa1-8462-4b3186140af7",
          "order_id": "e89eeb3d-685a-454c-86fd-5c758d09a4d1",
          "product_id": "engine-air-filter-for-proton-x70",
          "name": "Engine Air Filter for Proton X70",
          "sku": "GL-0012",
          "category": "Filters",
          "quantity": 17,
          "price_cents": 1800,
          "line_total_cents": 30600
        },
        {
          "id": "e5e556f6-039a-455b-bbd6-07304eb85022",
          "order_id": "e89eeb3d-685a-454c-86fd-5c758d09a4d1",
          "product_id": "trw-gdb1198-front-brake-pads",
          "name": "TRW GDB1198 Front Brake Pads",
          "sku": "GL-0046",
          "category": "Brake Pads",
          "quantity": 17,
          "price_cents": 5200,
          "line_total_cents": 88400
        }
      ],
      "events": [
        {
          "id": "f5e828ba-95c4-414d-925c-5f425aeeeef9",
          "order_id": "e89eeb3d-685a-454c-86fd-5c758d09a4d1",
          "event": "order_created",
          "actor_id": "30000000-0000-4000-8000-000000000012",
          "note": "Fictional example: inventory reserved.",
          "created_at": "2026-10-11T13:00:00.000Z"
        },
        {
          "id": "95fc9212-20f6-45fd-889d-56fe8f16b8df",
          "order_id": "e89eeb3d-685a-454c-86fd-5c758d09a4d1",
          "event": "payment_submitted",
          "actor_id": "30000000-0000-4000-8000-000000000012",
          "note": "Fictional bank reference; no transfer occurred.",
          "created_at": "2026-10-11T13:10:00.000Z"
        },
        {
          "id": "dc51520f-3f61-4c79-ae13-4876c5c4aec7",
          "order_id": "e89eeb3d-685a-454c-86fd-5c758d09a4d1",
          "event": "payment_verified",
          "actor_id": "seed-worker",
          "note": "Fictional deposit verification.",
          "created_at": "2026-10-11T13:20:00.000Z"
        },
        {
          "id": "0e273983-395c-48ae-b138-db31444146b2",
          "order_id": "e89eeb3d-685a-454c-86fd-5c758d09a4d1",
          "event": "shipped",
          "actor_id": "seed-worker",
          "note": "Fictional carrier and tracking number.",
          "created_at": "2026-10-12T13:00:00.000Z"
        },
        {
          "id": "26735d12-5ec6-4a91-9ffb-12723cc32b8f",
          "order_id": "e89eeb3d-685a-454c-86fd-5c758d09a4d1",
          "event": "receipt_confirmed",
          "actor_id": "30000000-0000-4000-8000-000000000012",
          "note": "Fictional buyer confirmed receipt.",
          "created_at": "2026-10-13T13:00:00.000Z"
        }
      ],
      "sample_data": true
    },
    {
      "id": "320135dc-7c4a-46bd-8960-ac2110ad8fb2",
      "order_number": 10025,
      "customer_id": "30000000-0000-4000-8000-000000000001",
      "status": "delivered",
      "payment_status": "verified",
      "address": {
        "name": "Demo Motorist 01",
        "phone": "0100000000",
        "line1": "Demo address — not for delivery",
        "city": "Petaling Jaya",
        "postcode": "47300",
        "state": "Selangor"
      },
      "subtotal_cents": 999,
      "discount_cents": 0,
      "shipping_cents": 1500,
      "total_cents": 2499,
      "payment_instructions": {
        "bank_name": "DEMO — DO NOT TRANSFER",
        "bank_account_name": "FICTIONAL EXAMPLE ONLY",
        "bank_account_number": "0000000000"
      },
      "payment_reference": "SAMPLE-NO-TRANSFER-25",
      "paid_verified_by": "seed-worker",
      "payment_note": null,
      "carrier": "Demo carrier",
      "tracking_number": "DEMO-NOT-A-PARCEL-25",
      "received_at": "2026-10-12T01:00:00.000Z",
      "cancel_reason": null,
      "idempotency_key": "2d9299ea-0365-4413-89b1-a40b267a149f",
      "created_at": "2026-10-10T01:00:00.000Z",
      "updated_at": "2026-10-12T01:00:00.000Z",
      "expires_at": "2026-10-11T01:00:00.000Z",
      "items": [
        {
          "id": "46165d9a-5e6d-4fb2-9b42-ffc6d1663d39",
          "order_id": "320135dc-7c4a-46bd-8960-ac2110ad8fb2",
          "product_id": "x-traseal-carburetor-and-choke-cleaner-400ml",
          "name": "X'traseal Carburetor and Choke Cleaner 400ml",
          "sku": "GL-0006",
          "category": "Cleaners & Additives",
          "quantity": 1,
          "price_cents": 999,
          "line_total_cents": 999
        }
      ],
      "events": [
        {
          "id": "e83b98dc-0841-44a9-a022-6e8639f06a01",
          "order_id": "320135dc-7c4a-46bd-8960-ac2110ad8fb2",
          "event": "order_created",
          "actor_id": "30000000-0000-4000-8000-000000000001",
          "note": "Fictional example: inventory reserved.",
          "created_at": "2026-10-10T01:00:00.000Z"
        },
        {
          "id": "68dbc272-3f4c-4570-bfa8-ac793c5e4414",
          "order_id": "320135dc-7c4a-46bd-8960-ac2110ad8fb2",
          "event": "payment_submitted",
          "actor_id": "30000000-0000-4000-8000-000000000001",
          "note": "Fictional bank reference; no transfer occurred.",
          "created_at": "2026-10-10T01:10:00.000Z"
        },
        {
          "id": "d68d34f4-e79f-431d-8e9d-a6533b828182",
          "order_id": "320135dc-7c4a-46bd-8960-ac2110ad8fb2",
          "event": "payment_verified",
          "actor_id": "seed-worker",
          "note": "Fictional deposit verification.",
          "created_at": "2026-10-10T01:20:00.000Z"
        },
        {
          "id": "9509ca77-59ea-41b1-bbca-bc849c35fa31",
          "order_id": "320135dc-7c4a-46bd-8960-ac2110ad8fb2",
          "event": "shipped",
          "actor_id": "seed-worker",
          "note": "Fictional carrier and tracking number.",
          "created_at": "2026-10-11T01:00:00.000Z"
        },
        {
          "id": "4ffb4284-92e3-44a2-b073-9cd5b2e6a1ad",
          "order_id": "320135dc-7c4a-46bd-8960-ac2110ad8fb2",
          "event": "receipt_confirmed",
          "actor_id": "30000000-0000-4000-8000-000000000001",
          "note": "Fictional buyer confirmed receipt.",
          "created_at": "2026-10-12T01:00:00.000Z"
        }
      ],
      "sample_data": true
    },
    {
      "id": "57b7fc9c-af3e-4c07-b147-751efdb14810",
      "order_number": 10026,
      "customer_id": "30000000-0000-4000-8000-000000000002",
      "status": "delivered",
      "payment_status": "verified",
      "address": {
        "name": "Demo Workshop 02",
        "phone": "0100000000",
        "line1": "Demo address — not for delivery",
        "city": "Petaling Jaya",
        "postcode": "47300",
        "state": "Selangor"
      },
      "subtotal_cents": 9600,
      "discount_cents": 0,
      "shipping_cents": 1500,
      "total_cents": 11100,
      "payment_instructions": {
        "bank_name": "DEMO — DO NOT TRANSFER",
        "bank_account_name": "FICTIONAL EXAMPLE ONLY",
        "bank_account_number": "0000000000"
      },
      "payment_reference": "SAMPLE-NO-TRANSFER-26",
      "paid_verified_by": "seed-worker",
      "payment_note": null,
      "carrier": "Demo carrier",
      "tracking_number": "DEMO-NOT-A-PARCEL-26",
      "received_at": "2026-10-11T02:00:00.000Z",
      "cancel_reason": null,
      "idempotency_key": "ed4656bb-df20-4fd5-94f9-8a0e4005806a",
      "created_at": "2026-10-09T02:00:00.000Z",
      "updated_at": "2026-10-11T02:00:00.000Z",
      "expires_at": "2026-10-10T02:00:00.000Z",
      "items": [
        {
          "id": "c440f889-b334-4b7d-914d-8321465d7b5b",
          "order_id": "57b7fc9c-af3e-4c07-b147-751efdb14810",
          "product_id": "top-1-green-radiator-coolant-500ml",
          "name": "Top 1 Green Radiator Coolant 500ml",
          "sku": "GL-0013",
          "category": "Coolant",
          "quantity": 4,
          "price_cents": 1000,
          "line_total_cents": 4000
        },
        {
          "id": "cb844f5d-5ce2-454c-ac07-695a1aea34c0",
          "order_id": "57b7fc9c-af3e-4c07-b147-751efdb14810",
          "product_id": "power-up-power-steering-fluid-1l",
          "name": "Power Up Power Steering Fluid 1L",
          "sku": "GL-0026",
          "category": "Steering Fluid",
          "quantity": 4,
          "price_cents": 1400,
          "line_total_cents": 5600
        }
      ],
      "events": [
        {
          "id": "d7b56f93-5aec-4f95-8412-53cd4e5c0432",
          "order_id": "57b7fc9c-af3e-4c07-b147-751efdb14810",
          "event": "order_created",
          "actor_id": "30000000-0000-4000-8000-000000000002",
          "note": "Fictional example: inventory reserved.",
          "created_at": "2026-10-09T02:00:00.000Z"
        },
        {
          "id": "73dada21-e950-4385-8a41-2ffedaabed79",
          "order_id": "57b7fc9c-af3e-4c07-b147-751efdb14810",
          "event": "payment_submitted",
          "actor_id": "30000000-0000-4000-8000-000000000002",
          "note": "Fictional bank reference; no transfer occurred.",
          "created_at": "2026-10-09T02:10:00.000Z"
        },
        {
          "id": "946dbd19-62fa-41f0-83af-5510e1c341a2",
          "order_id": "57b7fc9c-af3e-4c07-b147-751efdb14810",
          "event": "payment_verified",
          "actor_id": "seed-worker",
          "note": "Fictional deposit verification.",
          "created_at": "2026-10-09T02:20:00.000Z"
        },
        {
          "id": "7b35ee30-8f13-40dc-b0c6-bd661075c654",
          "order_id": "57b7fc9c-af3e-4c07-b147-751efdb14810",
          "event": "shipped",
          "actor_id": "seed-worker",
          "note": "Fictional carrier and tracking number.",
          "created_at": "2026-10-10T02:00:00.000Z"
        },
        {
          "id": "442f0077-fec8-4370-963b-86be8f33c88b",
          "order_id": "57b7fc9c-af3e-4c07-b147-751efdb14810",
          "event": "receipt_confirmed",
          "actor_id": "30000000-0000-4000-8000-000000000002",
          "note": "Fictional buyer confirmed receipt.",
          "created_at": "2026-10-11T02:00:00.000Z"
        }
      ],
      "sample_data": true
    },
    {
      "id": "ea5cd86c-da22-494b-8ca6-6b546f22357c",
      "order_number": 10027,
      "customer_id": "30000000-0000-4000-8000-000000000003",
      "status": "cancelled",
      "payment_status": "awaiting",
      "address": {
        "name": "Demo Parts Shop 03",
        "phone": "0100000000",
        "line1": "Demo address — not for delivery",
        "city": "Petaling Jaya",
        "postcode": "47300",
        "state": "Selangor"
      },
      "subtotal_cents": 157300,
      "discount_cents": 0,
      "shipping_cents": 0,
      "total_cents": 157300,
      "payment_instructions": {
        "bank_name": "DEMO — DO NOT TRANSFER",
        "bank_account_name": "FICTIONAL EXAMPLE ONLY",
        "bank_account_number": "0000000000"
      },
      "payment_reference": null,
      "paid_verified_by": null,
      "payment_note": null,
      "carrier": null,
      "tracking_number": null,
      "received_at": null,
      "cancel_reason": "Example customer changed their mind.",
      "idempotency_key": "36665754-3322-415c-a1e2-56c27658a5ff",
      "created_at": "2026-10-08T03:00:00.000Z",
      "updated_at": "2026-10-08T03:30:00.000Z",
      "expires_at": "2026-10-09T03:00:00.000Z",
      "items": [
        {
          "id": "043b9664-6ed7-4864-bab7-0bdd9e3cf162",
          "order_id": "ea5cd86c-da22-494b-8ca6-6b546f22357c",
          "product_id": "petrol-filter-for-proton-iriz-saga-vvt-persona-vvt",
          "name": "Petrol Filter for Proton Iriz / Saga VVT / Persona VVT",
          "sku": "GL-0017",
          "category": "Filters",
          "quantity": 11,
          "price_cents": 2800,
          "line_total_cents": 30800
        },
        {
          "id": "bfe6e7d1-c1a8-4382-b83b-98231b59ea24",
          "order_id": "ea5cd86c-da22-494b-8ca6-6b546f22357c",
          "product_id": "trw-gdb3459-front-brake-pads",
          "name": "TRW GDB3459 Front Brake Pads",
          "sku": "GL-0048",
          "category": "Brake Pads",
          "quantity": 11,
          "price_cents": 6700,
          "line_total_cents": 73700
        },
        {
          "id": "258eb380-ebcd-4f51-b430-845ca811c8a7",
          "order_id": "ea5cd86c-da22-494b-8ca6-6b546f22357c",
          "product_id": "10w-30-engine-oil-perodua-oil-filter-bundle",
          "name": "10W-30 Engine Oil + Perodua Oil Filter Bundle",
          "sku": "GL-0030",
          "category": "Engine Oil",
          "quantity": 11,
          "price_cents": 4800,
          "line_total_cents": 52800
        }
      ],
      "events": [
        {
          "id": "be2462c5-c5d5-4ec3-93f2-5a927f52d06f",
          "order_id": "ea5cd86c-da22-494b-8ca6-6b546f22357c",
          "event": "order_created",
          "actor_id": "30000000-0000-4000-8000-000000000003",
          "note": "Fictional example: inventory reserved.",
          "created_at": "2026-10-08T03:00:00.000Z"
        },
        {
          "id": "460df883-439a-4ee9-aed4-ea9a818cb09a",
          "order_id": "ea5cd86c-da22-494b-8ca6-6b546f22357c",
          "event": "cancelled",
          "actor_id": "30000000-0000-4000-8000-000000000003",
          "note": "Fictional unpaid cancellation; reserved inventory restored.",
          "created_at": "2026-10-08T03:30:00.000Z"
        }
      ],
      "sample_data": true
    },
    {
      "id": "350ea3d0-963c-418b-a360-b1275a0c8890",
      "order_number": 10028,
      "customer_id": "30000000-0000-4000-8000-000000000004",
      "status": "delivered",
      "payment_status": "verified",
      "address": {
        "name": "Demo Distributor 04",
        "phone": "0100000000",
        "line1": "Demo address — not for delivery",
        "city": "Petaling Jaya",
        "postcode": "47300",
        "state": "Selangor"
      },
      "subtotal_cents": 96000,
      "discount_cents": 0,
      "shipping_cents": 0,
      "total_cents": 96000,
      "payment_instructions": {
        "bank_name": "DEMO — DO NOT TRANSFER",
        "bank_account_name": "FICTIONAL EXAMPLE ONLY",
        "bank_account_number": "0000000000"
      },
      "payment_reference": "SAMPLE-NO-TRANSFER-28",
      "paid_verified_by": "seed-worker",
      "payment_note": null,
      "carrier": "Demo carrier",
      "tracking_number": "DEMO-NOT-A-PARCEL-28",
      "received_at": "2026-10-09T05:00:00.000Z",
      "cancel_reason": null,
      "idempotency_key": "636a2086-9f59-499f-9a32-55fbd6d860fb",
      "created_at": "2026-10-07T05:00:00.000Z",
      "updated_at": "2026-10-09T05:00:00.000Z",
      "expires_at": "2026-10-08T05:00:00.000Z",
      "items": [
        {
          "id": "30eed0c4-2f6a-425e-9f91-aaeb37c5c08e",
          "order_id": "350ea3d0-963c-418b-a360-b1275a0c8890",
          "product_id": "ngk-lzkar7a-spark-plug",
          "name": "NGK LZKAR7A Spark Plug",
          "sku": "GL-0040",
          "category": "Spark Plugs",
          "quantity": 12,
          "price_cents": 8000,
          "line_total_cents": 96000
        }
      ],
      "events": [
        {
          "id": "56452e95-e883-4ac6-b183-61dd1142e358",
          "order_id": "350ea3d0-963c-418b-a360-b1275a0c8890",
          "event": "order_created",
          "actor_id": "30000000-0000-4000-8000-000000000004",
          "note": "Fictional example: inventory reserved.",
          "created_at": "2026-10-07T05:00:00.000Z"
        },
        {
          "id": "c3695b14-607e-4295-a99e-79dc193f758c",
          "order_id": "350ea3d0-963c-418b-a360-b1275a0c8890",
          "event": "payment_submitted",
          "actor_id": "30000000-0000-4000-8000-000000000004",
          "note": "Fictional bank reference; no transfer occurred.",
          "created_at": "2026-10-07T05:10:00.000Z"
        },
        {
          "id": "2de09901-14e7-463f-ac97-d8d63c5acea4",
          "order_id": "350ea3d0-963c-418b-a360-b1275a0c8890",
          "event": "payment_verified",
          "actor_id": "seed-worker",
          "note": "Fictional deposit verification.",
          "created_at": "2026-10-07T05:20:00.000Z"
        },
        {
          "id": "416c1700-532a-4f14-85af-5b1376fcfa6e",
          "order_id": "350ea3d0-963c-418b-a360-b1275a0c8890",
          "event": "shipped",
          "actor_id": "seed-worker",
          "note": "Fictional carrier and tracking number.",
          "created_at": "2026-10-08T05:00:00.000Z"
        },
        {
          "id": "f682f338-7fe3-409d-87d9-4275b30cf7f6",
          "order_id": "350ea3d0-963c-418b-a360-b1275a0c8890",
          "event": "receipt_confirmed",
          "actor_id": "30000000-0000-4000-8000-000000000004",
          "note": "Fictional buyer confirmed receipt.",
          "created_at": "2026-10-09T05:00:00.000Z"
        }
      ],
      "sample_data": true
    },
    {
      "id": "cbb906e4-21fd-4861-bd61-c5b1f8e95f39",
      "order_number": 10029,
      "customer_id": "30000000-0000-4000-8000-000000000005",
      "status": "delivered",
      "payment_status": "verified",
      "address": {
        "name": "Demo Motorist 05",
        "phone": "0100000000",
        "line1": "Demo address — not for delivery",
        "city": "Petaling Jaya",
        "postcode": "47300",
        "state": "Selangor"
      },
      "subtotal_cents": 2900,
      "discount_cents": 0,
      "shipping_cents": 1500,
      "total_cents": 4400,
      "payment_instructions": {
        "bank_name": "DEMO — DO NOT TRANSFER",
        "bank_account_name": "FICTIONAL EXAMPLE ONLY",
        "bank_account_number": "0000000000"
      },
      "payment_reference": "SAMPLE-NO-TRANSFER-29",
      "paid_verified_by": "seed-worker",
      "payment_note": null,
      "carrier": "Demo carrier",
      "tracking_number": "DEMO-NOT-A-PARCEL-29",
      "received_at": "2026-10-08T06:00:00.000Z",
      "cancel_reason": null,
      "idempotency_key": "8d3e6fe4-aab9-4038-a88f-af73c8968995",
      "created_at": "2026-10-06T06:00:00.000Z",
      "updated_at": "2026-10-08T06:00:00.000Z",
      "expires_at": "2026-10-07T06:00:00.000Z",
      "items": [
        {
          "id": "bc25b445-b7f6-43a7-8e4b-c9dce481dd1b",
          "order_id": "cbb906e4-21fd-4861-bd61-c5b1f8e95f39",
          "product_id": "power-up-power-steering-fluid-1l",
          "name": "Power Up Power Steering Fluid 1L",
          "sku": "GL-0026",
          "category": "Steering Fluid",
          "quantity": 1,
          "price_cents": 1400,
          "line_total_cents": 1400
        },
        {
          "id": "e85aa097-d73b-4505-a925-c97eca5f4b04",
          "order_id": "cbb906e4-21fd-4861-bd61-c5b1f8e95f39",
          "product_id": "cabin-filter-for-perodua-myvi-alza-axia-bezza",
          "name": "Cabin Filter for Perodua Myvi / Alza / Axia / Bezza",
          "sku": "GL-0037",
          "category": "Filters",
          "quantity": 1,
          "price_cents": 1500,
          "line_total_cents": 1500
        }
      ],
      "events": [
        {
          "id": "b4bccc2b-3434-4887-93a2-fc588702aade",
          "order_id": "cbb906e4-21fd-4861-bd61-c5b1f8e95f39",
          "event": "order_created",
          "actor_id": "30000000-0000-4000-8000-000000000005",
          "note": "Fictional example: inventory reserved.",
          "created_at": "2026-10-06T06:00:00.000Z"
        },
        {
          "id": "eaffb668-26e9-4307-b682-cbdb6b7b2ddf",
          "order_id": "cbb906e4-21fd-4861-bd61-c5b1f8e95f39",
          "event": "payment_submitted",
          "actor_id": "30000000-0000-4000-8000-000000000005",
          "note": "Fictional bank reference; no transfer occurred.",
          "created_at": "2026-10-06T06:10:00.000Z"
        },
        {
          "id": "4acddcaf-3f13-46d8-9199-d57c4b65d88b",
          "order_id": "cbb906e4-21fd-4861-bd61-c5b1f8e95f39",
          "event": "payment_verified",
          "actor_id": "seed-worker",
          "note": "Fictional deposit verification.",
          "created_at": "2026-10-06T06:20:00.000Z"
        },
        {
          "id": "a2840fc3-5043-4b51-a264-e9064d7dbfe3",
          "order_id": "cbb906e4-21fd-4861-bd61-c5b1f8e95f39",
          "event": "shipped",
          "actor_id": "seed-worker",
          "note": "Fictional carrier and tracking number.",
          "created_at": "2026-10-07T06:00:00.000Z"
        },
        {
          "id": "c2d54931-5f07-41a6-86a7-30e1ab8baefa",
          "order_id": "cbb906e4-21fd-4861-bd61-c5b1f8e95f39",
          "event": "receipt_confirmed",
          "actor_id": "30000000-0000-4000-8000-000000000005",
          "note": "Fictional buyer confirmed receipt.",
          "created_at": "2026-10-08T06:00:00.000Z"
        }
      ],
      "sample_data": true
    },
    {
      "id": "a0a03351-c591-4d54-8519-334ceded68f1",
      "order_number": 10030,
      "customer_id": "30000000-0000-4000-8000-000000000006",
      "status": "delivered",
      "payment_status": "verified",
      "address": {
        "name": "Demo Workshop 06",
        "phone": "0100000000",
        "line1": "Demo address — not for delivery",
        "city": "Petaling Jaya",
        "postcode": "47300",
        "state": "Selangor"
      },
      "subtotal_cents": 106000,
      "discount_cents": 0,
      "shipping_cents": 0,
      "total_cents": 106000,
      "payment_instructions": {
        "bank_name": "DEMO — DO NOT TRANSFER",
        "bank_account_name": "FICTIONAL EXAMPLE ONLY",
        "bank_account_number": "0000000000"
      },
      "payment_reference": "SAMPLE-NO-TRANSFER-30",
      "paid_verified_by": "seed-worker",
      "payment_note": null,
      "carrier": "Demo carrier",
      "tracking_number": "DEMO-NOT-A-PARCEL-30",
      "received_at": "2026-10-07T10:00:00.000Z",
      "cancel_reason": null,
      "idempotency_key": "a2cf032a-aeb9-49a3-9920-f76d9793bea1",
      "created_at": "2026-10-05T10:00:00.000Z",
      "updated_at": "2026-10-07T10:00:00.000Z",
      "expires_at": "2026-10-06T10:00:00.000Z",
      "items": [
        {
          "id": "3ecad005-a342-4f67-9ae3-421b55464905",
          "order_id": "a0a03351-c591-4d54-8519-334ceded68f1",
          "product_id": "trw-gdb7707-front-brake-pads",
          "name": "TRW GDB7707 Front Brake Pads",
          "sku": "GL-0043",
          "category": "Brake Pads",
          "quantity": 4,
          "price_cents": 5500,
          "line_total_cents": 22000
        },
        {
          "id": "2303d0e6-ce32-407f-b0e7-f8c79300bfeb",
          "order_id": "a0a03351-c591-4d54-8519-334ceded68f1",
          "product_id": "castrol-magnatec-10w-40-engine-oil-4l",
          "name": "Castrol Magnatec 10W-40 Engine Oil 4L",
          "sku": "GL-0032",
          "category": "Engine Oil",
          "quantity": 4,
          "price_cents": 13500,
          "line_total_cents": 54000
        },
        {
          "id": "d110f48e-cac1-4dff-b30d-d288b4e0df29",
          "order_id": "a0a03351-c591-4d54-8519-334ceded68f1",
          "product_id": "castrol-80w-90-manual-gear-oil-4l",
          "name": "Castrol 80W-90 Manual Gear Oil 4L",
          "sku": "GL-0033",
          "category": "Transmission Fluid",
          "quantity": 4,
          "price_cents": 7500,
          "line_total_cents": 30000
        }
      ],
      "events": [
        {
          "id": "cb799fdd-7d3a-46d9-970c-71876f43d45c",
          "order_id": "a0a03351-c591-4d54-8519-334ceded68f1",
          "event": "order_created",
          "actor_id": "30000000-0000-4000-8000-000000000006",
          "note": "Fictional example: inventory reserved.",
          "created_at": "2026-10-05T10:00:00.000Z"
        },
        {
          "id": "296c31d9-32a2-4294-95bb-6f0ae45a23f9",
          "order_id": "a0a03351-c591-4d54-8519-334ceded68f1",
          "event": "payment_submitted",
          "actor_id": "30000000-0000-4000-8000-000000000006",
          "note": "Fictional bank reference; no transfer occurred.",
          "created_at": "2026-10-05T10:10:00.000Z"
        },
        {
          "id": "cb71356c-ffb3-432c-a47e-21a10e39b14d",
          "order_id": "a0a03351-c591-4d54-8519-334ceded68f1",
          "event": "payment_verified",
          "actor_id": "seed-worker",
          "note": "Fictional deposit verification.",
          "created_at": "2026-10-05T10:20:00.000Z"
        },
        {
          "id": "7f78e3bb-e5ec-4eb8-8e97-6a04eead2b3e",
          "order_id": "a0a03351-c591-4d54-8519-334ceded68f1",
          "event": "shipped",
          "actor_id": "seed-worker",
          "note": "Fictional carrier and tracking number.",
          "created_at": "2026-10-06T10:00:00.000Z"
        },
        {
          "id": "88628c5d-438f-428e-820b-a2aebb72dd2b",
          "order_id": "a0a03351-c591-4d54-8519-334ceded68f1",
          "event": "receipt_confirmed",
          "actor_id": "30000000-0000-4000-8000-000000000006",
          "note": "Fictional buyer confirmed receipt.",
          "created_at": "2026-10-07T10:00:00.000Z"
        }
      ],
      "sample_data": true
    },
    {
      "id": "e2483cfc-8580-4e7f-a9d4-593f028c9e15",
      "order_number": 10031,
      "customer_id": "30000000-0000-4000-8000-000000000007",
      "status": "delivered",
      "payment_status": "verified",
      "address": {
        "name": "Demo Parts Shop 07",
        "phone": "0100000000",
        "line1": "Demo address — not for delivery",
        "city": "Petaling Jaya",
        "postcode": "47300",
        "state": "Selangor"
      },
      "subtotal_cents": 108000,
      "discount_cents": 0,
      "shipping_cents": 0,
      "total_cents": 108000,
      "payment_instructions": {
        "bank_name": "DEMO — DO NOT TRANSFER",
        "bank_account_name": "FICTIONAL EXAMPLE ONLY",
        "bank_account_number": "0000000000"
      },
      "payment_reference": "SAMPLE-NO-TRANSFER-31",
      "paid_verified_by": "seed-worker",
      "payment_note": null,
      "carrier": "Demo carrier",
      "tracking_number": "DEMO-NOT-A-PARCEL-31",
      "received_at": "2026-10-06T12:00:00.000Z",
      "cancel_reason": null,
      "idempotency_key": "6976e3ba-8f94-40e7-8758-e4805dfa76fd",
      "created_at": "2026-10-04T12:00:00.000Z",
      "updated_at": "2026-10-06T12:00:00.000Z",
      "expires_at": "2026-10-05T12:00:00.000Z",
      "items": [
        {
          "id": "7f2df49b-17ee-4695-a3bf-8766f52ab778",
          "order_id": "e2483cfc-8580-4e7f-a9d4-593f028c9e15",
          "product_id": "castrol-magnatec-10w-40-engine-oil-4l",
          "name": "Castrol Magnatec 10W-40 Engine Oil 4L",
          "sku": "GL-0032",
          "category": "Engine Oil",
          "quantity": 8,
          "price_cents": 13500,
          "line_total_cents": 108000
        }
      ],
      "events": [
        {
          "id": "c1e20a1a-26ac-463b-bf35-54953659164e",
          "order_id": "e2483cfc-8580-4e7f-a9d4-593f028c9e15",
          "event": "order_created",
          "actor_id": "30000000-0000-4000-8000-000000000007",
          "note": "Fictional example: inventory reserved.",
          "created_at": "2026-10-04T12:00:00.000Z"
        },
        {
          "id": "81d0e90a-74fa-40e9-aeb5-0c197af32e5f",
          "order_id": "e2483cfc-8580-4e7f-a9d4-593f028c9e15",
          "event": "payment_submitted",
          "actor_id": "30000000-0000-4000-8000-000000000007",
          "note": "Fictional bank reference; no transfer occurred.",
          "created_at": "2026-10-04T12:10:00.000Z"
        },
        {
          "id": "6a20ead6-339b-43f4-8489-5ac9651accec",
          "order_id": "e2483cfc-8580-4e7f-a9d4-593f028c9e15",
          "event": "payment_verified",
          "actor_id": "seed-worker",
          "note": "Fictional deposit verification.",
          "created_at": "2026-10-04T12:20:00.000Z"
        },
        {
          "id": "99eb5d33-d2f3-496c-89ef-f7f8016109d3",
          "order_id": "e2483cfc-8580-4e7f-a9d4-593f028c9e15",
          "event": "shipped",
          "actor_id": "seed-worker",
          "note": "Fictional carrier and tracking number.",
          "created_at": "2026-10-05T12:00:00.000Z"
        },
        {
          "id": "26523960-1cc3-40e8-9fb9-2affe467a40d",
          "order_id": "e2483cfc-8580-4e7f-a9d4-593f028c9e15",
          "event": "receipt_confirmed",
          "actor_id": "30000000-0000-4000-8000-000000000007",
          "note": "Fictional buyer confirmed receipt.",
          "created_at": "2026-10-06T12:00:00.000Z"
        }
      ],
      "sample_data": true
    },
    {
      "id": "8c602df6-9fbf-41c8-881c-5f8c9e4c7a5f",
      "order_number": 10032,
      "customer_id": "30000000-0000-4000-8000-000000000008",
      "status": "delivered",
      "payment_status": "verified",
      "address": {
        "name": "Demo Distributor 08",
        "phone": "0100000000",
        "line1": "Demo address — not for delivery",
        "city": "Petaling Jaya",
        "postcode": "47300",
        "state": "Selangor"
      },
      "subtotal_cents": 163200,
      "discount_cents": 0,
      "shipping_cents": 0,
      "total_cents": 163200,
      "payment_instructions": {
        "bank_name": "DEMO — DO NOT TRANSFER",
        "bank_account_name": "FICTIONAL EXAMPLE ONLY",
        "bank_account_number": "0000000000"
      },
      "payment_reference": "SAMPLE-NO-TRANSFER-32",
      "paid_verified_by": "seed-worker",
      "payment_note": null,
      "carrier": "Demo carrier",
      "tracking_number": "DEMO-NOT-A-PARCEL-32",
      "received_at": "2026-10-05T13:00:00.000Z",
      "cancel_reason": null,
      "idempotency_key": "ff429944-b7b5-479b-afa3-4df0c9b246ff",
      "created_at": "2026-10-03T13:00:00.000Z",
      "updated_at": "2026-10-05T13:00:00.000Z",
      "expires_at": "2026-10-04T13:00:00.000Z",
      "items": [
        {
          "id": "c80e634f-682b-4733-a572-2e4f4b9f6f7a",
          "order_id": "8c602df6-9fbf-41c8-881c-5f8c9e4c7a5f",
          "product_id": "cabin-filter-for-proton-x50",
          "name": "Cabin Filter for Proton X50",
          "sku": "GL-0009",
          "category": "Filters",
          "quantity": 16,
          "price_cents": 2500,
          "line_total_cents": 40000
        },
        {
          "id": "70e42c78-e81e-4ff9-aa3a-4fd87fa54a22",
          "order_id": "8c602df6-9fbf-41c8-881c-5f8c9e4c7a5f",
          "product_id": "castrol-gtx-10w-30-engine-oil-4l",
          "name": "Castrol GTX 10W-30 Engine Oil 4L",
          "sku": "GL-0034",
          "category": "Engine Oil",
          "quantity": 16,
          "price_cents": 7700,
          "line_total_cents": 123200
        }
      ],
      "events": [
        {
          "id": "31d776ea-0091-4183-9c15-bb1e3709f933",
          "order_id": "8c602df6-9fbf-41c8-881c-5f8c9e4c7a5f",
          "event": "order_created",
          "actor_id": "30000000-0000-4000-8000-000000000008",
          "note": "Fictional example: inventory reserved.",
          "created_at": "2026-10-03T13:00:00.000Z"
        },
        {
          "id": "037b76cc-cc0d-449c-b9f7-7e8144ea4393",
          "order_id": "8c602df6-9fbf-41c8-881c-5f8c9e4c7a5f",
          "event": "payment_submitted",
          "actor_id": "30000000-0000-4000-8000-000000000008",
          "note": "Fictional bank reference; no transfer occurred.",
          "created_at": "2026-10-03T13:10:00.000Z"
        },
        {
          "id": "3af1e4de-0418-4647-9e49-45195942b697",
          "order_id": "8c602df6-9fbf-41c8-881c-5f8c9e4c7a5f",
          "event": "payment_verified",
          "actor_id": "seed-worker",
          "note": "Fictional deposit verification.",
          "created_at": "2026-10-03T13:20:00.000Z"
        },
        {
          "id": "d85dbca9-cf1f-46dd-957e-a566833e4c65",
          "order_id": "8c602df6-9fbf-41c8-881c-5f8c9e4c7a5f",
          "event": "shipped",
          "actor_id": "seed-worker",
          "note": "Fictional carrier and tracking number.",
          "created_at": "2026-10-04T13:00:00.000Z"
        },
        {
          "id": "e632711f-0e76-41fe-aa5c-695d10c1bbe3",
          "order_id": "8c602df6-9fbf-41c8-881c-5f8c9e4c7a5f",
          "event": "receipt_confirmed",
          "actor_id": "30000000-0000-4000-8000-000000000008",
          "note": "Fictional buyer confirmed receipt.",
          "created_at": "2026-10-05T13:00:00.000Z"
        }
      ],
      "sample_data": true
    },
    {
      "id": "7f588494-8f3b-4759-9b76-fb8e0c6e583a",
      "order_number": 10033,
      "customer_id": "30000000-0000-4000-8000-000000000009",
      "status": "delivered",
      "payment_status": "verified",
      "address": {
        "name": "Demo Motorist 09",
        "phone": "0100000000",
        "line1": "Demo address — not for delivery",
        "city": "Petaling Jaya",
        "postcode": "47300",
        "state": "Selangor"
      },
      "subtotal_cents": 29200,
      "discount_cents": 0,
      "shipping_cents": 0,
      "total_cents": 29200,
      "payment_instructions": {
        "bank_name": "DEMO — DO NOT TRANSFER",
        "bank_account_name": "FICTIONAL EXAMPLE ONLY",
        "bank_account_number": "0000000000"
      },
      "payment_reference": "SAMPLE-NO-TRANSFER-33",
      "paid_verified_by": "seed-worker",
      "payment_note": null,
      "carrier": "Demo carrier",
      "tracking_number": "DEMO-NOT-A-PARCEL-33",
      "received_at": "2026-10-04T12:00:00.000Z",
      "cancel_reason": null,
      "idempotency_key": "697d656c-295d-442a-8e11-06d22d0ddc1d",
      "created_at": "2026-10-02T12:00:00.000Z",
      "updated_at": "2026-10-04T12:00:00.000Z",
      "expires_at": "2026-10-03T12:00:00.000Z",
      "items": [
        {
          "id": "9916bdd0-6df7-48ed-ab21-119beca67e31",
          "order_id": "7f588494-8f3b-4759-9b76-fb8e0c6e583a",
          "product_id": "toyota-5w-30-engine-oil-4l",
          "name": "Toyota 5W-30 Engine Oil 4L",
          "sku": "GL-0036",
          "category": "Engine Oil",
          "quantity": 1,
          "price_cents": 10000,
          "line_total_cents": 10000
        },
        {
          "id": "9f2055cd-4d24-4059-bfaa-596c54158cef",
          "order_id": "7f588494-8f3b-4759-9b76-fb8e0c6e583a",
          "product_id": "castrol-gtx-10w-30-engine-oil-4l",
          "name": "Castrol GTX 10W-30 Engine Oil 4L",
          "sku": "GL-0034",
          "category": "Engine Oil",
          "quantity": 1,
          "price_cents": 7700,
          "line_total_cents": 7700
        },
        {
          "id": "3fab18d8-3b4a-484d-b041-67f6b1bd31ee",
          "order_id": "7f588494-8f3b-4759-9b76-fb8e0c6e583a",
          "product_id": "proton-atf-hts-4at-fully-synthetic-fluid-3l",
          "name": "Proton ATF HTS 4AT Fully Synthetic Fluid 3L",
          "sku": "GL-0041",
          "category": "Transmission Fluid",
          "quantity": 1,
          "price_cents": 11500,
          "line_total_cents": 11500
        }
      ],
      "events": [
        {
          "id": "d12add8c-aad0-4a28-9d2e-4ce8a3280318",
          "order_id": "7f588494-8f3b-4759-9b76-fb8e0c6e583a",
          "event": "order_created",
          "actor_id": "30000000-0000-4000-8000-000000000009",
          "note": "Fictional example: inventory reserved.",
          "created_at": "2026-10-02T12:00:00.000Z"
        },
        {
          "id": "7ddfbed4-5c0e-408f-88b4-49599833bda1",
          "order_id": "7f588494-8f3b-4759-9b76-fb8e0c6e583a",
          "event": "payment_submitted",
          "actor_id": "30000000-0000-4000-8000-000000000009",
          "note": "Fictional bank reference; no transfer occurred.",
          "created_at": "2026-10-02T12:10:00.000Z"
        },
        {
          "id": "392d3fd3-a5f3-4f92-a2fd-5903c5feb10b",
          "order_id": "7f588494-8f3b-4759-9b76-fb8e0c6e583a",
          "event": "payment_verified",
          "actor_id": "seed-worker",
          "note": "Fictional deposit verification.",
          "created_at": "2026-10-02T12:20:00.000Z"
        },
        {
          "id": "b492877e-e253-4931-9de8-fc56d80b6e87",
          "order_id": "7f588494-8f3b-4759-9b76-fb8e0c6e583a",
          "event": "shipped",
          "actor_id": "seed-worker",
          "note": "Fictional carrier and tracking number.",
          "created_at": "2026-10-03T12:00:00.000Z"
        },
        {
          "id": "9b189be4-b8e8-47e8-9137-26e32c1c2fde",
          "order_id": "7f588494-8f3b-4759-9b76-fb8e0c6e583a",
          "event": "receipt_confirmed",
          "actor_id": "30000000-0000-4000-8000-000000000009",
          "note": "Fictional buyer confirmed receipt.",
          "created_at": "2026-10-04T12:00:00.000Z"
        }
      ],
      "sample_data": true
    },
    {
      "id": "0921b3fa-282d-471d-8434-44cd94bf210d",
      "order_number": 10034,
      "customer_id": "30000000-0000-4000-8000-000000000010",
      "status": "delivered",
      "payment_status": "verified",
      "address": {
        "name": "Demo Workshop 10",
        "phone": "0100000000",
        "line1": "Demo address — not for delivery",
        "city": "Petaling Jaya",
        "postcode": "47300",
        "state": "Selangor"
      },
      "subtotal_cents": 30000,
      "discount_cents": 0,
      "shipping_cents": 0,
      "total_cents": 30000,
      "payment_instructions": {
        "bank_name": "DEMO — DO NOT TRANSFER",
        "bank_account_name": "FICTIONAL EXAMPLE ONLY",
        "bank_account_number": "0000000000"
      },
      "payment_reference": "SAMPLE-NO-TRANSFER-34",
      "paid_verified_by": "seed-worker",
      "payment_note": null,
      "carrier": "Demo carrier",
      "tracking_number": "DEMO-NOT-A-PARCEL-34",
      "received_at": "2026-10-03T13:00:00.000Z",
      "cancel_reason": null,
      "idempotency_key": "c82d7922-c378-49e1-ad61-cb52b93e6c78",
      "created_at": "2026-10-01T13:00:00.000Z",
      "updated_at": "2026-10-03T13:00:00.000Z",
      "expires_at": "2026-10-02T13:00:00.000Z",
      "items": [
        {
          "id": "2a11c1a7-1ac6-4b6e-baea-8a42f6bb2b9f",
          "order_id": "0921b3fa-282d-471d-8434-44cd94bf210d",
          "product_id": "trw-gdb8977-front-brake-pads",
          "name": "TRW GDB8977 Front Brake Pads",
          "sku": "GL-0047",
          "category": "Brake Pads",
          "quantity": 4,
          "price_cents": 7500,
          "line_total_cents": 30000
        }
      ],
      "events": [
        {
          "id": "7e5a525d-2b4c-4254-b68d-b003cc8eb4fc",
          "order_id": "0921b3fa-282d-471d-8434-44cd94bf210d",
          "event": "order_created",
          "actor_id": "30000000-0000-4000-8000-000000000010",
          "note": "Fictional example: inventory reserved.",
          "created_at": "2026-10-01T13:00:00.000Z"
        },
        {
          "id": "4c84d24c-518d-47ce-b6b0-4387d96cec0a",
          "order_id": "0921b3fa-282d-471d-8434-44cd94bf210d",
          "event": "payment_submitted",
          "actor_id": "30000000-0000-4000-8000-000000000010",
          "note": "Fictional bank reference; no transfer occurred.",
          "created_at": "2026-10-01T13:10:00.000Z"
        },
        {
          "id": "6067aab4-0cbb-4083-87c8-3e08d89b6680",
          "order_id": "0921b3fa-282d-471d-8434-44cd94bf210d",
          "event": "payment_verified",
          "actor_id": "seed-worker",
          "note": "Fictional deposit verification.",
          "created_at": "2026-10-01T13:20:00.000Z"
        },
        {
          "id": "7d7a4b8c-2625-4afa-89e5-7ffcc20fb6d4",
          "order_id": "0921b3fa-282d-471d-8434-44cd94bf210d",
          "event": "shipped",
          "actor_id": "seed-worker",
          "note": "Fictional carrier and tracking number.",
          "created_at": "2026-10-02T13:00:00.000Z"
        },
        {
          "id": "2cbc5510-9328-4880-9520-f0c475616c6e",
          "order_id": "0921b3fa-282d-471d-8434-44cd94bf210d",
          "event": "receipt_confirmed",
          "actor_id": "30000000-0000-4000-8000-000000000010",
          "note": "Fictional buyer confirmed receipt.",
          "created_at": "2026-10-03T13:00:00.000Z"
        }
      ],
      "sample_data": true
    },
    {
      "id": "4a752e25-7b6b-49ba-8f04-62cba0829be1",
      "order_number": 10035,
      "customer_id": "30000000-0000-4000-8000-000000000011",
      "status": "cancelled",
      "payment_status": "refunded",
      "address": {
        "name": "Demo Parts Shop 11",
        "phone": "0100000000",
        "line1": "Demo address — not for delivery",
        "city": "Petaling Jaya",
        "postcode": "47300",
        "state": "Selangor"
      },
      "subtotal_cents": 42000,
      "discount_cents": 0,
      "shipping_cents": 0,
      "total_cents": 42000,
      "payment_instructions": {
        "bank_name": "DEMO — DO NOT TRANSFER",
        "bank_account_name": "FICTIONAL EXAMPLE ONLY",
        "bank_account_number": "0000000000"
      },
      "payment_reference": "SAMPLE-NO-TRANSFER-35",
      "paid_verified_by": "seed-worker",
      "payment_note": null,
      "carrier": "Demo carrier",
      "tracking_number": "DEMO-NOT-A-PARCEL-35",
      "received_at": "2026-10-02T12:00:00.000Z",
      "cancel_reason": null,
      "idempotency_key": "9befeba4-e9b5-4155-afd9-30805d0310ed",
      "created_at": "2026-09-30T12:00:00.000Z",
      "updated_at": "2026-10-03T12:00:00.000Z",
      "expires_at": "2026-10-01T12:00:00.000Z",
      "items": [
        {
          "id": "a531f5a3-d419-41cc-9556-f81aabb27a6d",
          "order_id": "4a752e25-7b6b-49ba-8f04-62cba0829be1",
          "product_id": "dexron-iii-atf-d3-transmission-fluid-1l",
          "name": "Dexron III ATF D3 Transmission Fluid 1L",
          "sku": "GL-0035",
          "category": "Transmission Fluid",
          "quantity": 12,
          "price_cents": 1300,
          "line_total_cents": 15600
        },
        {
          "id": "0fc4844b-42a9-473d-bd3c-f69af8c00a43",
          "order_id": "4a752e25-7b6b-49ba-8f04-62cba0829be1",
          "product_id": "bendix-dot-4-brake-and-clutch-fluid-1l",
          "name": "Bendix DOT 4 Brake and Clutch Fluid 1L",
          "sku": "GL-0003",
          "category": "Brake Fluid",
          "quantity": 12,
          "price_cents": 2200,
          "line_total_cents": 26400
        }
      ],
      "events": [
        {
          "id": "e1285c71-66bf-4156-9ddd-e57afbdf06b2",
          "order_id": "4a752e25-7b6b-49ba-8f04-62cba0829be1",
          "event": "order_created",
          "actor_id": "30000000-0000-4000-8000-000000000011",
          "note": "Fictional example: inventory reserved.",
          "created_at": "2026-09-30T12:00:00.000Z"
        },
        {
          "id": "174e64cb-60eb-48fc-932a-2d21b5f45135",
          "order_id": "4a752e25-7b6b-49ba-8f04-62cba0829be1",
          "event": "payment_submitted",
          "actor_id": "30000000-0000-4000-8000-000000000011",
          "note": "Fictional bank reference; no transfer occurred.",
          "created_at": "2026-09-30T12:10:00.000Z"
        },
        {
          "id": "0f7a227a-d0a7-45d0-8afe-83c0ed95840f",
          "order_id": "4a752e25-7b6b-49ba-8f04-62cba0829be1",
          "event": "payment_verified",
          "actor_id": "seed-worker",
          "note": "Fictional deposit verification.",
          "created_at": "2026-09-30T12:20:00.000Z"
        },
        {
          "id": "6e0fefd9-0a7f-4586-8814-37dcce2f07de",
          "order_id": "4a752e25-7b6b-49ba-8f04-62cba0829be1",
          "event": "shipped",
          "actor_id": "seed-worker",
          "note": "Fictional carrier and tracking number.",
          "created_at": "2026-10-01T12:00:00.000Z"
        },
        {
          "id": "eca0f7ee-76f1-47ee-9d68-925772ab5147",
          "order_id": "4a752e25-7b6b-49ba-8f04-62cba0829be1",
          "event": "receipt_confirmed",
          "actor_id": "30000000-0000-4000-8000-000000000011",
          "note": "Fictional buyer confirmed receipt.",
          "created_at": "2026-10-02T12:00:00.000Z"
        },
        {
          "id": "ab42f6ca-c979-4345-8af7-668545330176",
          "order_id": "4a752e25-7b6b-49ba-8f04-62cba0829be1",
          "event": "refund_paid",
          "actor_id": "seed-admin",
          "note": "Fictional full refund; returned units restored.",
          "created_at": "2026-10-03T12:00:00.000Z"
        }
      ],
      "sample_data": true
    },
    {
      "id": "83b24def-4301-4c45-8d84-29ba5eeb3040",
      "order_number": 10036,
      "customer_id": "30000000-0000-4000-8000-000000000012",
      "status": "delivered",
      "payment_status": "verified",
      "address": {
        "name": "Demo Distributor 12",
        "phone": "0100000000",
        "line1": "Demo address — not for delivery",
        "city": "Petaling Jaya",
        "postcode": "47300",
        "state": "Selangor"
      },
      "subtotal_cents": 380000,
      "discount_cents": 0,
      "shipping_cents": 0,
      "total_cents": 380000,
      "payment_instructions": {
        "bank_name": "DEMO — DO NOT TRANSFER",
        "bank_account_name": "FICTIONAL EXAMPLE ONLY",
        "bank_account_number": "0000000000"
      },
      "payment_reference": "SAMPLE-NO-TRANSFER-36",
      "paid_verified_by": "seed-worker",
      "payment_note": null,
      "carrier": "Demo carrier",
      "tracking_number": "DEMO-NOT-A-PARCEL-36",
      "received_at": "2026-10-01T13:00:00.000Z",
      "cancel_reason": null,
      "idempotency_key": "7d51c7d3-5cb6-43eb-b6e9-cc94705b5069",
      "created_at": "2026-09-29T13:00:00.000Z",
      "updated_at": "2026-10-01T13:00:00.000Z",
      "expires_at": "2026-09-30T13:00:00.000Z",
      "items": [
        {
          "id": "8beabdb6-b813-47e1-a2c1-4eea62289abe",
          "order_id": "83b24def-4301-4c45-8d84-29ba5eeb3040",
          "product_id": "toyota-5w-30-engine-oil-4l",
          "name": "Toyota 5W-30 Engine Oil 4L",
          "sku": "GL-0036",
          "category": "Engine Oil",
          "quantity": 20,
          "price_cents": 10000,
          "line_total_cents": 200000
        },
        {
          "id": "88ee5688-b8ef-40a0-b759-9362fb472702",
          "order_id": "83b24def-4301-4c45-8d84-29ba5eeb3040",
          "product_id": "manual-gear-oil-80w-90-4l",
          "name": "Manual Gear Oil 80W-90 4L",
          "sku": "GL-0015",
          "category": "Transmission Fluid",
          "quantity": 20,
          "price_cents": 5000,
          "line_total_cents": 100000
        },
        {
          "id": "db9109e1-aa7e-4dda-82fb-61cceef5b114",
          "order_id": "83b24def-4301-4c45-8d84-29ba5eeb3040",
          "product_id": "aftermarket-engine-oil-filters-10-pack",
          "name": "Aftermarket Engine Oil Filters — 10 Pack",
          "sku": "GL-0019",
          "category": "Filters",
          "quantity": 20,
          "price_cents": 4000,
          "line_total_cents": 80000
        }
      ],
      "events": [
        {
          "id": "bdfeee32-198a-4a2c-b51d-af32e84fb6fc",
          "order_id": "83b24def-4301-4c45-8d84-29ba5eeb3040",
          "event": "order_created",
          "actor_id": "30000000-0000-4000-8000-000000000012",
          "note": "Fictional example: inventory reserved.",
          "created_at": "2026-09-29T13:00:00.000Z"
        },
        {
          "id": "f985a5ce-fa3e-41ac-b3d6-944caa332ba2",
          "order_id": "83b24def-4301-4c45-8d84-29ba5eeb3040",
          "event": "payment_submitted",
          "actor_id": "30000000-0000-4000-8000-000000000012",
          "note": "Fictional bank reference; no transfer occurred.",
          "created_at": "2026-09-29T13:10:00.000Z"
        },
        {
          "id": "b90d9d6c-9351-49a9-a34e-ecba01d5f2ea",
          "order_id": "83b24def-4301-4c45-8d84-29ba5eeb3040",
          "event": "payment_verified",
          "actor_id": "seed-worker",
          "note": "Fictional deposit verification.",
          "created_at": "2026-09-29T13:20:00.000Z"
        },
        {
          "id": "1e866211-7055-4a20-b4f0-3d1b38f79099",
          "order_id": "83b24def-4301-4c45-8d84-29ba5eeb3040",
          "event": "shipped",
          "actor_id": "seed-worker",
          "note": "Fictional carrier and tracking number.",
          "created_at": "2026-09-30T13:00:00.000Z"
        },
        {
          "id": "e7058ec8-a71e-4d51-ad71-8f25740f1c48",
          "order_id": "83b24def-4301-4c45-8d84-29ba5eeb3040",
          "event": "receipt_confirmed",
          "actor_id": "30000000-0000-4000-8000-000000000012",
          "note": "Fictional buyer confirmed receipt.",
          "created_at": "2026-10-01T13:00:00.000Z"
        }
      ],
      "sample_data": true
    },
    {
      "id": "9da168e5-de9b-4759-b1ec-9665cf25ac8a",
      "order_number": 10037,
      "customer_id": "30000000-0000-4000-8000-000000000001",
      "status": "delivered",
      "payment_status": "verified",
      "address": {
        "name": "Demo Motorist 01",
        "phone": "0100000000",
        "line1": "Demo address — not for delivery",
        "city": "Petaling Jaya",
        "postcode": "47300",
        "state": "Selangor"
      },
      "subtotal_cents": 16500,
      "discount_cents": 0,
      "shipping_cents": 1500,
      "total_cents": 18000,
      "payment_instructions": {
        "bank_name": "DEMO — DO NOT TRANSFER",
        "bank_account_name": "FICTIONAL EXAMPLE ONLY",
        "bank_account_number": "0000000000"
      },
      "payment_reference": "SAMPLE-NO-TRANSFER-37",
      "paid_verified_by": "seed-worker",
      "payment_note": null,
      "carrier": "Demo carrier",
      "tracking_number": "DEMO-NOT-A-PARCEL-37",
      "received_at": "2026-09-30T01:00:00.000Z",
      "cancel_reason": null,
      "idempotency_key": "725ac4b4-b89a-4aed-8667-cec3742126fa",
      "created_at": "2026-09-28T01:00:00.000Z",
      "updated_at": "2026-09-30T01:00:00.000Z",
      "expires_at": "2026-09-29T01:00:00.000Z",
      "items": [
        {
          "id": "290793ab-e6ff-4d8c-97cd-46441b526378",
          "order_id": "9da168e5-de9b-4759-b1ec-9665cf25ac8a",
          "product_id": "perodua-fully-synthetic-0w-20-oil-3-5l-filter",
          "name": "Perodua Fully Synthetic 0W-20 Oil 3.5L + Filter",
          "sku": "GL-0020",
          "category": "Engine Oil",
          "quantity": 1,
          "price_cents": 16500,
          "line_total_cents": 16500
        }
      ],
      "events": [
        {
          "id": "32ec42d4-5bf7-4e79-bce7-d777aea2e753",
          "order_id": "9da168e5-de9b-4759-b1ec-9665cf25ac8a",
          "event": "order_created",
          "actor_id": "30000000-0000-4000-8000-000000000001",
          "note": "Fictional example: inventory reserved.",
          "created_at": "2026-09-28T01:00:00.000Z"
        },
        {
          "id": "9b11827c-3c54-4822-869f-64504c09749a",
          "order_id": "9da168e5-de9b-4759-b1ec-9665cf25ac8a",
          "event": "payment_submitted",
          "actor_id": "30000000-0000-4000-8000-000000000001",
          "note": "Fictional bank reference; no transfer occurred.",
          "created_at": "2026-09-28T01:10:00.000Z"
        },
        {
          "id": "01010a80-703c-4a95-8bf3-eea32fd24caf",
          "order_id": "9da168e5-de9b-4759-b1ec-9665cf25ac8a",
          "event": "payment_verified",
          "actor_id": "seed-worker",
          "note": "Fictional deposit verification.",
          "created_at": "2026-09-28T01:20:00.000Z"
        },
        {
          "id": "434496a6-4eb4-4d27-a6ab-b1cef4ecc6f2",
          "order_id": "9da168e5-de9b-4759-b1ec-9665cf25ac8a",
          "event": "shipped",
          "actor_id": "seed-worker",
          "note": "Fictional carrier and tracking number.",
          "created_at": "2026-09-29T01:00:00.000Z"
        },
        {
          "id": "4269c56d-53f0-4ef2-ae60-5bcb59140c36",
          "order_id": "9da168e5-de9b-4759-b1ec-9665cf25ac8a",
          "event": "receipt_confirmed",
          "actor_id": "30000000-0000-4000-8000-000000000001",
          "note": "Fictional buyer confirmed receipt.",
          "created_at": "2026-09-30T01:00:00.000Z"
        }
      ],
      "sample_data": true
    },
    {
      "id": "e731e604-9a6f-4980-8ee5-cbf3c0a1cbe1",
      "order_number": 10038,
      "customer_id": "30000000-0000-4000-8000-000000000002",
      "status": "delivered",
      "payment_status": "verified",
      "address": {
        "name": "Demo Workshop 02",
        "phone": "0100000000",
        "line1": "Demo address — not for delivery",
        "city": "Petaling Jaya",
        "postcode": "47300",
        "state": "Selangor"
      },
      "subtotal_cents": 18800,
      "discount_cents": 0,
      "shipping_cents": 1500,
      "total_cents": 20300,
      "payment_instructions": {
        "bank_name": "DEMO — DO NOT TRANSFER",
        "bank_account_name": "FICTIONAL EXAMPLE ONLY",
        "bank_account_number": "0000000000"
      },
      "payment_reference": "SAMPLE-NO-TRANSFER-38",
      "paid_verified_by": "seed-worker",
      "payment_note": null,
      "carrier": "Demo carrier",
      "tracking_number": "DEMO-NOT-A-PARCEL-38",
      "received_at": "2026-09-29T02:00:00.000Z",
      "cancel_reason": null,
      "idempotency_key": "6e991974-991e-4414-a3cf-0ba51d3bfa88",
      "created_at": "2026-09-27T02:00:00.000Z",
      "updated_at": "2026-09-29T02:00:00.000Z",
      "expires_at": "2026-09-28T02:00:00.000Z",
      "items": [
        {
          "id": "d62fe655-3f87-483b-bcd1-cec7c457def0",
          "order_id": "e731e604-9a6f-4980-8ee5-cbf3c0a1cbe1",
          "product_id": "bendix-dot-4-brake-and-clutch-fluid-1l",
          "name": "Bendix DOT 4 Brake and Clutch Fluid 1L",
          "sku": "GL-0003",
          "category": "Brake Fluid",
          "quantity": 4,
          "price_cents": 2200,
          "line_total_cents": 8800
        },
        {
          "id": "d8ea92aa-9147-4a2b-8c1c-91dbe41b4f4d",
          "order_id": "e731e604-9a6f-4980-8ee5-cbf3c0a1cbe1",
          "product_id": "perodua-radiator-coolant-1l",
          "name": "Perodua Radiator Coolant 1L",
          "sku": "GL-0024",
          "category": "Coolant",
          "quantity": 4,
          "price_cents": 2500,
          "line_total_cents": 10000
        }
      ],
      "events": [
        {
          "id": "579377f9-b933-4519-8dc4-693601e95f8a",
          "order_id": "e731e604-9a6f-4980-8ee5-cbf3c0a1cbe1",
          "event": "order_created",
          "actor_id": "30000000-0000-4000-8000-000000000002",
          "note": "Fictional example: inventory reserved.",
          "created_at": "2026-09-27T02:00:00.000Z"
        },
        {
          "id": "b6dd232c-3f1b-4864-af6f-6f98d3dbf2a5",
          "order_id": "e731e604-9a6f-4980-8ee5-cbf3c0a1cbe1",
          "event": "payment_submitted",
          "actor_id": "30000000-0000-4000-8000-000000000002",
          "note": "Fictional bank reference; no transfer occurred.",
          "created_at": "2026-09-27T02:10:00.000Z"
        },
        {
          "id": "6f7efa88-cc91-4e2b-8bcd-60c586cecb43",
          "order_id": "e731e604-9a6f-4980-8ee5-cbf3c0a1cbe1",
          "event": "payment_verified",
          "actor_id": "seed-worker",
          "note": "Fictional deposit verification.",
          "created_at": "2026-09-27T02:20:00.000Z"
        },
        {
          "id": "c3aa7728-47a4-4a0a-88f3-eedb0cb456cf",
          "order_id": "e731e604-9a6f-4980-8ee5-cbf3c0a1cbe1",
          "event": "shipped",
          "actor_id": "seed-worker",
          "note": "Fictional carrier and tracking number.",
          "created_at": "2026-09-28T02:00:00.000Z"
        },
        {
          "id": "cde2ffd0-34c2-4f39-87da-81695c1ae4a6",
          "order_id": "e731e604-9a6f-4980-8ee5-cbf3c0a1cbe1",
          "event": "receipt_confirmed",
          "actor_id": "30000000-0000-4000-8000-000000000002",
          "note": "Fictional buyer confirmed receipt.",
          "created_at": "2026-09-29T02:00:00.000Z"
        }
      ],
      "sample_data": true
    },
    {
      "id": "8a7cb795-76a0-48e8-b8ce-a62e97dfda46",
      "order_number": 10039,
      "customer_id": "30000000-0000-4000-8000-000000000003",
      "status": "delivered",
      "payment_status": "verified",
      "address": {
        "name": "Demo Parts Shop 03",
        "phone": "0100000000",
        "line1": "Demo address — not for delivery",
        "city": "Petaling Jaya",
        "postcode": "47300",
        "state": "Selangor"
      },
      "subtotal_cents": 148500,
      "discount_cents": 0,
      "shipping_cents": 0,
      "total_cents": 148500,
      "payment_instructions": {
        "bank_name": "DEMO — DO NOT TRANSFER",
        "bank_account_name": "FICTIONAL EXAMPLE ONLY",
        "bank_account_number": "0000000000"
      },
      "payment_reference": "SAMPLE-NO-TRANSFER-39",
      "paid_verified_by": "seed-worker",
      "payment_note": null,
      "carrier": "Demo carrier",
      "tracking_number": "DEMO-NOT-A-PARCEL-39",
      "received_at": "2026-09-28T03:00:00.000Z",
      "cancel_reason": null,
      "idempotency_key": "2cb1f833-d630-4c16-bedc-c0e20211e63f",
      "created_at": "2026-09-26T03:00:00.000Z",
      "updated_at": "2026-09-28T03:00:00.000Z",
      "expires_at": "2026-09-27T03:00:00.000Z",
      "items": [
        {
          "id": "e3d0dd44-f931-4ee2-a4a2-d9831394fb57",
          "order_id": "8a7cb795-76a0-48e8-b8ce-a62e97dfda46",
          "product_id": "castrol-140-manual-gear-oil-4l",
          "name": "Castrol 140 Manual Gear Oil 4L",
          "sku": "GL-0023",
          "category": "Transmission Fluid",
          "quantity": 9,
          "price_cents": 7500,
          "line_total_cents": 67500
        },
        {
          "id": "0f61d7a8-1b4a-4e2e-86da-cb9b1cef8035",
          "order_id": "8a7cb795-76a0-48e8-b8ce-a62e97dfda46",
          "product_id": "cabin-filter-for-perodua-myvi-alza-axia-bezza",
          "name": "Cabin Filter for Perodua Myvi / Alza / Axia / Bezza",
          "sku": "GL-0037",
          "category": "Filters",
          "quantity": 9,
          "price_cents": 1500,
          "line_total_cents": 13500
        },
        {
          "id": "ae682af2-fb32-4418-9b3d-49df5001d908",
          "order_id": "8a7cb795-76a0-48e8-b8ce-a62e97dfda46",
          "product_id": "trw-gdb8977-front-brake-pads",
          "name": "TRW GDB8977 Front Brake Pads",
          "sku": "GL-0047",
          "category": "Brake Pads",
          "quantity": 9,
          "price_cents": 7500,
          "line_total_cents": 67500
        }
      ],
      "events": [
        {
          "id": "4446b6e7-ca37-4261-abca-a539d0f2f080",
          "order_id": "8a7cb795-76a0-48e8-b8ce-a62e97dfda46",
          "event": "order_created",
          "actor_id": "30000000-0000-4000-8000-000000000003",
          "note": "Fictional example: inventory reserved.",
          "created_at": "2026-09-26T03:00:00.000Z"
        },
        {
          "id": "08de17a0-f91b-4cac-82dd-79acf721cccd",
          "order_id": "8a7cb795-76a0-48e8-b8ce-a62e97dfda46",
          "event": "payment_submitted",
          "actor_id": "30000000-0000-4000-8000-000000000003",
          "note": "Fictional bank reference; no transfer occurred.",
          "created_at": "2026-09-26T03:10:00.000Z"
        },
        {
          "id": "3c01abd9-786d-4ad6-ae39-d7c88df1c4cd",
          "order_id": "8a7cb795-76a0-48e8-b8ce-a62e97dfda46",
          "event": "payment_verified",
          "actor_id": "seed-worker",
          "note": "Fictional deposit verification.",
          "created_at": "2026-09-26T03:20:00.000Z"
        },
        {
          "id": "e1468e97-8e73-4168-91b7-7f451fc60a53",
          "order_id": "8a7cb795-76a0-48e8-b8ce-a62e97dfda46",
          "event": "shipped",
          "actor_id": "seed-worker",
          "note": "Fictional carrier and tracking number.",
          "created_at": "2026-09-27T03:00:00.000Z"
        },
        {
          "id": "1af4d162-37f4-4d5e-a479-93d384ca7576",
          "order_id": "8a7cb795-76a0-48e8-b8ce-a62e97dfda46",
          "event": "receipt_confirmed",
          "actor_id": "30000000-0000-4000-8000-000000000003",
          "note": "Fictional buyer confirmed receipt.",
          "created_at": "2026-09-28T03:00:00.000Z"
        }
      ],
      "sample_data": true
    },
    {
      "id": "e5417cab-91d4-449b-a25c-93b62275d8f9",
      "order_number": 10040,
      "customer_id": "30000000-0000-4000-8000-000000000004",
      "status": "cancelled",
      "payment_status": "awaiting",
      "address": {
        "name": "Demo Distributor 04",
        "phone": "0100000000",
        "line1": "Demo address — not for delivery",
        "city": "Petaling Jaya",
        "postcode": "47300",
        "state": "Selangor"
      },
      "subtotal_cents": 14985,
      "discount_cents": 0,
      "shipping_cents": 1500,
      "total_cents": 16485,
      "payment_instructions": {
        "bank_name": "DEMO — DO NOT TRANSFER",
        "bank_account_name": "FICTIONAL EXAMPLE ONLY",
        "bank_account_number": "0000000000"
      },
      "payment_reference": null,
      "paid_verified_by": null,
      "payment_note": null,
      "carrier": null,
      "tracking_number": null,
      "received_at": null,
      "cancel_reason": "Example customer changed their mind.",
      "idempotency_key": "7fd3f1e0-30af-4680-8bfb-2cef6fa6b877",
      "created_at": "2026-09-25T05:00:00.000Z",
      "updated_at": "2026-09-25T05:30:00.000Z",
      "expires_at": "2026-09-26T05:00:00.000Z",
      "items": [
        {
          "id": "c2fe1127-f107-4635-b1ce-ea9d5154203b",
          "order_id": "e5417cab-91d4-449b-a25c-93b62275d8f9",
          "product_id": "x-traseal-carburetor-and-choke-cleaner-400ml",
          "name": "X'traseal Carburetor and Choke Cleaner 400ml",
          "sku": "GL-0006",
          "category": "Cleaners & Additives",
          "quantity": 15,
          "price_cents": 999,
          "line_total_cents": 14985
        }
      ],
      "events": [
        {
          "id": "0d6e6402-19de-49e4-a85e-abb576f6b68a",
          "order_id": "e5417cab-91d4-449b-a25c-93b62275d8f9",
          "event": "order_created",
          "actor_id": "30000000-0000-4000-8000-000000000004",
          "note": "Fictional example: inventory reserved.",
          "created_at": "2026-09-25T05:00:00.000Z"
        },
        {
          "id": "789b82ef-3887-457f-8602-6357258f41ce",
          "order_id": "e5417cab-91d4-449b-a25c-93b62275d8f9",
          "event": "cancelled",
          "actor_id": "30000000-0000-4000-8000-000000000004",
          "note": "Fictional unpaid cancellation; reserved inventory restored.",
          "created_at": "2026-09-25T05:30:00.000Z"
        }
      ],
      "sample_data": true
    },
    {
      "id": "4c1b2f20-a7ba-4144-b5c1-941345c2cc79",
      "order_number": 10041,
      "customer_id": "30000000-0000-4000-8000-000000000005",
      "status": "delivered",
      "payment_status": "verified",
      "address": {
        "name": "Demo Motorist 05",
        "phone": "0100000000",
        "line1": "Demo address — not for delivery",
        "city": "Petaling Jaya",
        "postcode": "47300",
        "state": "Selangor"
      },
      "subtotal_cents": 2400,
      "discount_cents": 0,
      "shipping_cents": 1500,
      "total_cents": 3900,
      "payment_instructions": {
        "bank_name": "DEMO — DO NOT TRANSFER",
        "bank_account_name": "FICTIONAL EXAMPLE ONLY",
        "bank_account_number": "0000000000"
      },
      "payment_reference": "SAMPLE-NO-TRANSFER-41",
      "paid_verified_by": "seed-worker",
      "payment_note": null,
      "carrier": "Demo carrier",
      "tracking_number": "DEMO-NOT-A-PARCEL-41",
      "received_at": "2026-09-26T06:00:00.000Z",
      "cancel_reason": null,
      "idempotency_key": "67594772-134b-40d8-9403-2a666255eaf2",
      "created_at": "2026-09-24T06:00:00.000Z",
      "updated_at": "2026-09-26T06:00:00.000Z",
      "expires_at": "2026-09-25T06:00:00.000Z",
      "items": [
        {
          "id": "38a9dfa6-d9c1-44f7-b178-3e48d3b61653",
          "order_id": "4c1b2f20-a7ba-4144-b5c1-941345c2cc79",
          "product_id": "top-1-green-radiator-coolant-500ml",
          "name": "Top 1 Green Radiator Coolant 500ml",
          "sku": "GL-0013",
          "category": "Coolant",
          "quantity": 1,
          "price_cents": 1000,
          "line_total_cents": 1000
        },
        {
          "id": "32ea601c-02b9-405c-b917-67c29b321300",
          "order_id": "4c1b2f20-a7ba-4144-b5c1-941345c2cc79",
          "product_id": "power-up-power-steering-fluid-1l",
          "name": "Power Up Power Steering Fluid 1L",
          "sku": "GL-0026",
          "category": "Steering Fluid",
          "quantity": 1,
          "price_cents": 1400,
          "line_total_cents": 1400
        }
      ],
      "events": [
        {
          "id": "2567a642-ead9-423b-9a83-ec407b34d2e9",
          "order_id": "4c1b2f20-a7ba-4144-b5c1-941345c2cc79",
          "event": "order_created",
          "actor_id": "30000000-0000-4000-8000-000000000005",
          "note": "Fictional example: inventory reserved.",
          "created_at": "2026-09-24T06:00:00.000Z"
        },
        {
          "id": "a0c0b91b-6c41-4dee-b3ec-740ec2e83cd1",
          "order_id": "4c1b2f20-a7ba-4144-b5c1-941345c2cc79",
          "event": "payment_submitted",
          "actor_id": "30000000-0000-4000-8000-000000000005",
          "note": "Fictional bank reference; no transfer occurred.",
          "created_at": "2026-09-24T06:10:00.000Z"
        },
        {
          "id": "254d51bc-8e32-4856-94f6-8aad4936670f",
          "order_id": "4c1b2f20-a7ba-4144-b5c1-941345c2cc79",
          "event": "payment_verified",
          "actor_id": "seed-worker",
          "note": "Fictional deposit verification.",
          "created_at": "2026-09-24T06:20:00.000Z"
        },
        {
          "id": "f84c2d3a-5fb6-4190-bb72-29dfb5623257",
          "order_id": "4c1b2f20-a7ba-4144-b5c1-941345c2cc79",
          "event": "shipped",
          "actor_id": "seed-worker",
          "note": "Fictional carrier and tracking number.",
          "created_at": "2026-09-25T06:00:00.000Z"
        },
        {
          "id": "a560eddf-a395-4e4e-8b4c-f505493666f5",
          "order_id": "4c1b2f20-a7ba-4144-b5c1-941345c2cc79",
          "event": "receipt_confirmed",
          "actor_id": "30000000-0000-4000-8000-000000000005",
          "note": "Fictional buyer confirmed receipt.",
          "created_at": "2026-09-26T06:00:00.000Z"
        }
      ],
      "sample_data": true
    },
    {
      "id": "a3b59873-f017-4067-abf1-3ef0202b6f37",
      "order_number": 10042,
      "customer_id": "30000000-0000-4000-8000-000000000006",
      "status": "delivered",
      "payment_status": "verified",
      "address": {
        "name": "Demo Workshop 06",
        "phone": "0100000000",
        "line1": "Demo address — not for delivery",
        "city": "Petaling Jaya",
        "postcode": "47300",
        "state": "Selangor"
      },
      "subtotal_cents": 65200,
      "discount_cents": 0,
      "shipping_cents": 0,
      "total_cents": 65200,
      "payment_instructions": {
        "bank_name": "DEMO — DO NOT TRANSFER",
        "bank_account_name": "FICTIONAL EXAMPLE ONLY",
        "bank_account_number": "0000000000"
      },
      "payment_reference": "SAMPLE-NO-TRANSFER-42",
      "paid_verified_by": "seed-worker",
      "payment_note": null,
      "carrier": "Demo carrier",
      "tracking_number": "DEMO-NOT-A-PARCEL-42",
      "received_at": "2026-09-25T10:00:00.000Z",
      "cancel_reason": null,
      "idempotency_key": "a802a11e-7ca6-4097-be5d-73a6b5b4a9d4",
      "created_at": "2026-09-23T10:00:00.000Z",
      "updated_at": "2026-09-25T10:00:00.000Z",
      "expires_at": "2026-09-24T10:00:00.000Z",
      "items": [
        {
          "id": "074ce445-6282-474c-b9ad-5d81798b1244",
          "order_id": "a3b59873-f017-4067-abf1-3ef0202b6f37",
          "product_id": "cabin-filter-for-proton-x50",
          "name": "Cabin Filter for Proton X50",
          "sku": "GL-0009",
          "category": "Filters",
          "quantity": 4,
          "price_cents": 2500,
          "line_total_cents": 10000
        },
        {
          "id": "5448eae3-a29b-4726-856c-6c79e833ba09",
          "order_id": "a3b59873-f017-4067-abf1-3ef0202b6f37",
          "product_id": "front-brake-pads-for-proton-gen-2-persona-neo",
          "name": "Front Brake Pads for Proton Gen 2 / Persona / Neo",
          "sku": "GL-0042",
          "category": "Brake Pads",
          "quantity": 4,
          "price_cents": 3800,
          "line_total_cents": 15200
        },
        {
          "id": "8c05b0c5-9d09-4291-97b6-409e2d8c47b0",
          "order_id": "a3b59873-f017-4067-abf1-3ef0202b6f37",
          "product_id": "toyota-5w-30-engine-oil-4l",
          "name": "Toyota 5W-30 Engine Oil 4L",
          "sku": "GL-0036",
          "category": "Engine Oil",
          "quantity": 4,
          "price_cents": 10000,
          "line_total_cents": 40000
        }
      ],
      "events": [
        {
          "id": "c00d0667-82eb-4f1a-b6b3-fbfd3ab2cc7e",
          "order_id": "a3b59873-f017-4067-abf1-3ef0202b6f37",
          "event": "order_created",
          "actor_id": "30000000-0000-4000-8000-000000000006",
          "note": "Fictional example: inventory reserved.",
          "created_at": "2026-09-23T10:00:00.000Z"
        },
        {
          "id": "c7af74c6-8814-44a1-83cf-ec534662f074",
          "order_id": "a3b59873-f017-4067-abf1-3ef0202b6f37",
          "event": "payment_submitted",
          "actor_id": "30000000-0000-4000-8000-000000000006",
          "note": "Fictional bank reference; no transfer occurred.",
          "created_at": "2026-09-23T10:10:00.000Z"
        },
        {
          "id": "3eddb618-6bb4-4aab-8208-ed1983c59f6e",
          "order_id": "a3b59873-f017-4067-abf1-3ef0202b6f37",
          "event": "payment_verified",
          "actor_id": "seed-worker",
          "note": "Fictional deposit verification.",
          "created_at": "2026-09-23T10:20:00.000Z"
        },
        {
          "id": "f1e1c146-c4d8-4178-9a10-ca440d3f96f1",
          "order_id": "a3b59873-f017-4067-abf1-3ef0202b6f37",
          "event": "shipped",
          "actor_id": "seed-worker",
          "note": "Fictional carrier and tracking number.",
          "created_at": "2026-09-24T10:00:00.000Z"
        },
        {
          "id": "ca371e93-c7d0-43da-8aba-f729654f037a",
          "order_id": "a3b59873-f017-4067-abf1-3ef0202b6f37",
          "event": "receipt_confirmed",
          "actor_id": "30000000-0000-4000-8000-000000000006",
          "note": "Fictional buyer confirmed receipt.",
          "created_at": "2026-09-25T10:00:00.000Z"
        }
      ],
      "sample_data": true
    },
    {
      "id": "2cddf347-82f8-4d5b-8c0a-e61e96bb492f",
      "order_number": 10043,
      "customer_id": "30000000-0000-4000-8000-000000000007",
      "status": "delivered",
      "payment_status": "verified",
      "address": {
        "name": "Demo Parts Shop 07",
        "phone": "0100000000",
        "line1": "Demo address — not for delivery",
        "city": "Petaling Jaya",
        "postcode": "47300",
        "state": "Selangor"
      },
      "subtotal_cents": 33000,
      "discount_cents": 0,
      "shipping_cents": 0,
      "total_cents": 33000,
      "payment_instructions": {
        "bank_name": "DEMO — DO NOT TRANSFER",
        "bank_account_name": "FICTIONAL EXAMPLE ONLY",
        "bank_account_number": "0000000000"
      },
      "payment_reference": "SAMPLE-NO-TRANSFER-43",
      "paid_verified_by": "seed-worker",
      "payment_note": null,
      "carrier": "Demo carrier",
      "tracking_number": "DEMO-NOT-A-PARCEL-43",
      "received_at": "2026-09-24T12:00:00.000Z",
      "cancel_reason": null,
      "idempotency_key": "d714bdd1-5d56-4ec9-9560-f3f791f652ec",
      "created_at": "2026-09-22T12:00:00.000Z",
      "updated_at": "2026-09-24T12:00:00.000Z",
      "expires_at": "2026-09-23T12:00:00.000Z",
      "items": [
        {
          "id": "f8a0230e-47bf-44ec-9cd8-54a9965d3392",
          "order_id": "2cddf347-82f8-4d5b-8c0a-e61e96bb492f",
          "product_id": "denso-k20tnr-s-spark-plugs-4-pack",
          "name": "Denso K20TNR-S Spark Plugs — 4 Pack",
          "sku": "GL-0018",
          "category": "Spark Plugs",
          "quantity": 6,
          "price_cents": 5500,
          "line_total_cents": 33000
        }
      ],
      "events": [
        {
          "id": "e32f3154-7145-4c84-9b0b-48a03e4702bb",
          "order_id": "2cddf347-82f8-4d5b-8c0a-e61e96bb492f",
          "event": "order_created",
          "actor_id": "30000000-0000-4000-8000-000000000007",
          "note": "Fictional example: inventory reserved.",
          "created_at": "2026-09-22T12:00:00.000Z"
        },
        {
          "id": "082ec19c-dee0-4687-83b7-8cecae2357a3",
          "order_id": "2cddf347-82f8-4d5b-8c0a-e61e96bb492f",
          "event": "payment_submitted",
          "actor_id": "30000000-0000-4000-8000-000000000007",
          "note": "Fictional bank reference; no transfer occurred.",
          "created_at": "2026-09-22T12:10:00.000Z"
        },
        {
          "id": "e9b8b7b1-e823-4281-a162-113dd7246d0f",
          "order_id": "2cddf347-82f8-4d5b-8c0a-e61e96bb492f",
          "event": "payment_verified",
          "actor_id": "seed-worker",
          "note": "Fictional deposit verification.",
          "created_at": "2026-09-22T12:20:00.000Z"
        },
        {
          "id": "2e828958-9d9f-4e6b-bae2-51dc6d485b53",
          "order_id": "2cddf347-82f8-4d5b-8c0a-e61e96bb492f",
          "event": "shipped",
          "actor_id": "seed-worker",
          "note": "Fictional carrier and tracking number.",
          "created_at": "2026-09-23T12:00:00.000Z"
        },
        {
          "id": "d1de1a84-e2c0-4069-b048-6ef895228f1e",
          "order_id": "2cddf347-82f8-4d5b-8c0a-e61e96bb492f",
          "event": "receipt_confirmed",
          "actor_id": "30000000-0000-4000-8000-000000000007",
          "note": "Fictional buyer confirmed receipt.",
          "created_at": "2026-09-24T12:00:00.000Z"
        }
      ],
      "sample_data": true
    },
    {
      "id": "b52cbf96-e66f-4e37-a214-5586fdcf4788",
      "order_number": 10044,
      "customer_id": "30000000-0000-4000-8000-000000000008",
      "status": "delivered",
      "payment_status": "verified",
      "address": {
        "name": "Demo Distributor 08",
        "phone": "0100000000",
        "line1": "Demo address — not for delivery",
        "city": "Petaling Jaya",
        "postcode": "47300",
        "state": "Selangor"
      },
      "subtotal_cents": 60800,
      "discount_cents": 0,
      "shipping_cents": 0,
      "total_cents": 60800,
      "payment_instructions": {
        "bank_name": "DEMO — DO NOT TRANSFER",
        "bank_account_name": "FICTIONAL EXAMPLE ONLY",
        "bank_account_number": "0000000000"
      },
      "payment_reference": "SAMPLE-NO-TRANSFER-44",
      "paid_verified_by": "seed-worker",
      "payment_note": null,
      "carrier": "Demo carrier",
      "tracking_number": "DEMO-NOT-A-PARCEL-44",
      "received_at": "2026-09-23T13:00:00.000Z",
      "cancel_reason": null,
      "idempotency_key": "8d367e99-8481-434c-ad9e-04be155377bb",
      "created_at": "2026-09-21T13:00:00.000Z",
      "updated_at": "2026-09-23T13:00:00.000Z",
      "expires_at": "2026-09-22T13:00:00.000Z",
      "items": [
        {
          "id": "5be1e0b8-c038-4841-a60a-ba5879c85bc5",
          "order_id": "b52cbf96-e66f-4e37-a214-5586fdcf4788",
          "product_id": "power-up-power-steering-fluid-1l",
          "name": "Power Up Power Steering Fluid 1L",
          "sku": "GL-0026",
          "category": "Steering Fluid",
          "quantity": 19,
          "price_cents": 1400,
          "line_total_cents": 26600
        },
        {
          "id": "f4abea90-029c-44d7-9391-49f9fdeef600",
          "order_id": "b52cbf96-e66f-4e37-a214-5586fdcf4788",
          "product_id": "engine-air-filter-for-proton-x70",
          "name": "Engine Air Filter for Proton X70",
          "sku": "GL-0012",
          "category": "Filters",
          "quantity": 19,
          "price_cents": 1800,
          "line_total_cents": 34200
        }
      ],
      "events": [
        {
          "id": "f0629b4a-4da2-4aa7-9530-7a23c21f63db",
          "order_id": "b52cbf96-e66f-4e37-a214-5586fdcf4788",
          "event": "order_created",
          "actor_id": "30000000-0000-4000-8000-000000000008",
          "note": "Fictional example: inventory reserved.",
          "created_at": "2026-09-21T13:00:00.000Z"
        },
        {
          "id": "0a13c707-99a9-4723-a7f4-37c7463e3a1c",
          "order_id": "b52cbf96-e66f-4e37-a214-5586fdcf4788",
          "event": "payment_submitted",
          "actor_id": "30000000-0000-4000-8000-000000000008",
          "note": "Fictional bank reference; no transfer occurred.",
          "created_at": "2026-09-21T13:10:00.000Z"
        },
        {
          "id": "c15afb0a-e597-48ec-b0ab-04861df60599",
          "order_id": "b52cbf96-e66f-4e37-a214-5586fdcf4788",
          "event": "payment_verified",
          "actor_id": "seed-worker",
          "note": "Fictional deposit verification.",
          "created_at": "2026-09-21T13:20:00.000Z"
        },
        {
          "id": "57e31f55-798b-4fdc-a2f0-6fa26f981b8e",
          "order_id": "b52cbf96-e66f-4e37-a214-5586fdcf4788",
          "event": "shipped",
          "actor_id": "seed-worker",
          "note": "Fictional carrier and tracking number.",
          "created_at": "2026-09-22T13:00:00.000Z"
        },
        {
          "id": "de9accbc-ce0a-4dde-a3d8-b922e638b12a",
          "order_id": "b52cbf96-e66f-4e37-a214-5586fdcf4788",
          "event": "receipt_confirmed",
          "actor_id": "30000000-0000-4000-8000-000000000008",
          "note": "Fictional buyer confirmed receipt.",
          "created_at": "2026-09-23T13:00:00.000Z"
        }
      ],
      "sample_data": true
    },
    {
      "id": "0334e4d3-e4f1-4480-b367-bcf3e3ed11d3",
      "order_number": 10045,
      "customer_id": "30000000-0000-4000-8000-000000000009",
      "status": "delivered",
      "payment_status": "verified",
      "address": {
        "name": "Demo Motorist 09",
        "phone": "0100000000",
        "line1": "Demo address — not for delivery",
        "city": "Petaling Jaya",
        "postcode": "47300",
        "state": "Selangor"
      },
      "subtotal_cents": 20700,
      "discount_cents": 0,
      "shipping_cents": 1500,
      "total_cents": 22200,
      "payment_instructions": {
        "bank_name": "DEMO — DO NOT TRANSFER",
        "bank_account_name": "FICTIONAL EXAMPLE ONLY",
        "bank_account_number": "0000000000"
      },
      "payment_reference": "SAMPLE-NO-TRANSFER-45",
      "paid_verified_by": "seed-worker",
      "payment_note": null,
      "carrier": "Demo carrier",
      "tracking_number": "DEMO-NOT-A-PARCEL-45",
      "received_at": "2026-09-22T12:00:00.000Z",
      "cancel_reason": null,
      "idempotency_key": "0d5fa9b5-59ab-4166-a3f7-0a59d7c59d5b",
      "created_at": "2026-09-20T12:00:00.000Z",
      "updated_at": "2026-09-22T12:00:00.000Z",
      "expires_at": "2026-09-21T12:00:00.000Z",
      "items": [
        {
          "id": "df3f2baf-605d-4ba4-9371-f156f84f2370",
          "order_id": "0334e4d3-e4f1-4480-b367-bcf3e3ed11d3",
          "product_id": "trw-gdb7742-front-brake-pads",
          "name": "TRW GDB7742 Front Brake Pads",
          "sku": "GL-0044",
          "category": "Brake Pads",
          "quantity": 1,
          "price_cents": 6700,
          "line_total_cents": 6700
        },
        {
          "id": "4ceb04b4-bf2a-4535-9c16-82d10e20a35f",
          "order_id": "0334e4d3-e4f1-4480-b367-bcf3e3ed11d3",
          "product_id": "sae-40-engine-oil-1l",
          "name": "SAE 40 Engine Oil 1L",
          "sku": "GL-0002",
          "category": "Engine Oil",
          "quantity": 1,
          "price_cents": 1000,
          "line_total_cents": 1000
        },
        {
          "id": "310d7340-695d-4a32-bc1c-4c7b40238f12",
          "order_id": "0334e4d3-e4f1-4480-b367-bcf3e3ed11d3",
          "product_id": "toyota-fully-synthetic-0w-20-engine-oil-4l",
          "name": "Toyota Fully Synthetic 0W-20 Engine Oil 4L",
          "sku": "GL-0001",
          "category": "Engine Oil",
          "quantity": 1,
          "price_cents": 13000,
          "line_total_cents": 13000
        }
      ],
      "events": [
        {
          "id": "0cf1c474-9d78-46a1-be56-3213c681fbce",
          "order_id": "0334e4d3-e4f1-4480-b367-bcf3e3ed11d3",
          "event": "order_created",
          "actor_id": "30000000-0000-4000-8000-000000000009",
          "note": "Fictional example: inventory reserved.",
          "created_at": "2026-09-20T12:00:00.000Z"
        },
        {
          "id": "0b044fc9-49d0-472b-86c1-c0efe738f01d",
          "order_id": "0334e4d3-e4f1-4480-b367-bcf3e3ed11d3",
          "event": "payment_submitted",
          "actor_id": "30000000-0000-4000-8000-000000000009",
          "note": "Fictional bank reference; no transfer occurred.",
          "created_at": "2026-09-20T12:10:00.000Z"
        },
        {
          "id": "afa81834-ecc6-43cd-9f04-da7cff43407d",
          "order_id": "0334e4d3-e4f1-4480-b367-bcf3e3ed11d3",
          "event": "payment_verified",
          "actor_id": "seed-worker",
          "note": "Fictional deposit verification.",
          "created_at": "2026-09-20T12:20:00.000Z"
        },
        {
          "id": "9f973062-07bb-4681-822c-287b99a40664",
          "order_id": "0334e4d3-e4f1-4480-b367-bcf3e3ed11d3",
          "event": "shipped",
          "actor_id": "seed-worker",
          "note": "Fictional carrier and tracking number.",
          "created_at": "2026-09-21T12:00:00.000Z"
        },
        {
          "id": "903cd955-86d3-4601-b5f2-bebee9bb696d",
          "order_id": "0334e4d3-e4f1-4480-b367-bcf3e3ed11d3",
          "event": "receipt_confirmed",
          "actor_id": "30000000-0000-4000-8000-000000000009",
          "note": "Fictional buyer confirmed receipt.",
          "created_at": "2026-09-22T12:00:00.000Z"
        }
      ],
      "sample_data": true
    },
    {
      "id": "fdfbdca8-095c-4917-a859-c9f3c44aa894",
      "order_number": 10046,
      "customer_id": "30000000-0000-4000-8000-000000000010",
      "status": "delivered",
      "payment_status": "verified",
      "address": {
        "name": "Demo Workshop 10",
        "phone": "0100000000",
        "line1": "Demo address — not for delivery",
        "city": "Petaling Jaya",
        "postcode": "47300",
        "state": "Selangor"
      },
      "subtotal_cents": 4000,
      "discount_cents": 0,
      "shipping_cents": 1500,
      "total_cents": 5500,
      "payment_instructions": {
        "bank_name": "DEMO — DO NOT TRANSFER",
        "bank_account_name": "FICTIONAL EXAMPLE ONLY",
        "bank_account_number": "0000000000"
      },
      "payment_reference": "SAMPLE-NO-TRANSFER-46",
      "paid_verified_by": "seed-worker",
      "payment_note": null,
      "carrier": "Demo carrier",
      "tracking_number": "DEMO-NOT-A-PARCEL-46",
      "received_at": "2026-09-21T13:00:00.000Z",
      "cancel_reason": null,
      "idempotency_key": "2a28bf27-ab6c-402b-be76-61ecce33ae91",
      "created_at": "2026-09-19T13:00:00.000Z",
      "updated_at": "2026-09-21T13:00:00.000Z",
      "expires_at": "2026-09-20T13:00:00.000Z",
      "items": [
        {
          "id": "e8e6dd52-2f0e-49d1-a2c4-f805cc6b1c1b",
          "order_id": "fdfbdca8-095c-4917-a859-c9f3c44aa894",
          "product_id": "sae-40-engine-oil-1l",
          "name": "SAE 40 Engine Oil 1L",
          "sku": "GL-0002",
          "category": "Engine Oil",
          "quantity": 4,
          "price_cents": 1000,
          "line_total_cents": 4000
        }
      ],
      "events": [
        {
          "id": "92eee31f-fb23-4d81-ab2b-1b8011581fc0",
          "order_id": "fdfbdca8-095c-4917-a859-c9f3c44aa894",
          "event": "order_created",
          "actor_id": "30000000-0000-4000-8000-000000000010",
          "note": "Fictional example: inventory reserved.",
          "created_at": "2026-09-19T13:00:00.000Z"
        },
        {
          "id": "d9bd6544-9230-46f1-9781-8b34e0f0a29a",
          "order_id": "fdfbdca8-095c-4917-a859-c9f3c44aa894",
          "event": "payment_submitted",
          "actor_id": "30000000-0000-4000-8000-000000000010",
          "note": "Fictional bank reference; no transfer occurred.",
          "created_at": "2026-09-19T13:10:00.000Z"
        },
        {
          "id": "c08db6b7-0997-4ff7-84a9-ec6282294db2",
          "order_id": "fdfbdca8-095c-4917-a859-c9f3c44aa894",
          "event": "payment_verified",
          "actor_id": "seed-worker",
          "note": "Fictional deposit verification.",
          "created_at": "2026-09-19T13:20:00.000Z"
        },
        {
          "id": "3891e21e-43d1-4080-ba25-5ed2a12e6c36",
          "order_id": "fdfbdca8-095c-4917-a859-c9f3c44aa894",
          "event": "shipped",
          "actor_id": "seed-worker",
          "note": "Fictional carrier and tracking number.",
          "created_at": "2026-09-20T13:00:00.000Z"
        },
        {
          "id": "edbba44f-6a39-4afb-bd34-6a48246fec7c",
          "order_id": "fdfbdca8-095c-4917-a859-c9f3c44aa894",
          "event": "receipt_confirmed",
          "actor_id": "30000000-0000-4000-8000-000000000010",
          "note": "Fictional buyer confirmed receipt.",
          "created_at": "2026-09-21T13:00:00.000Z"
        }
      ],
      "sample_data": true
    },
    {
      "id": "69a5780f-efb6-4276-8be3-b06dbb04dfb9",
      "order_number": 10047,
      "customer_id": "30000000-0000-4000-8000-000000000011",
      "status": "delivered",
      "payment_status": "verified",
      "address": {
        "name": "Demo Parts Shop 11",
        "phone": "0100000000",
        "line1": "Demo address — not for delivery",
        "city": "Petaling Jaya",
        "postcode": "47300",
        "state": "Selangor"
      },
      "subtotal_cents": 158000,
      "discount_cents": 0,
      "shipping_cents": 0,
      "total_cents": 158000,
      "payment_instructions": {
        "bank_name": "DEMO — DO NOT TRANSFER",
        "bank_account_name": "FICTIONAL EXAMPLE ONLY",
        "bank_account_number": "0000000000"
      },
      "payment_reference": "SAMPLE-NO-TRANSFER-47",
      "paid_verified_by": "seed-worker",
      "payment_note": null,
      "carrier": "Demo carrier",
      "tracking_number": "DEMO-NOT-A-PARCEL-47",
      "received_at": "2026-09-20T12:00:00.000Z",
      "cancel_reason": null,
      "idempotency_key": "d6bf9b4e-bbbd-4ac3-9e12-256b316222b9",
      "created_at": "2026-09-18T12:00:00.000Z",
      "updated_at": "2026-09-20T12:00:00.000Z",
      "expires_at": "2026-09-19T12:00:00.000Z",
      "items": [
        {
          "id": "2f6e7158-f977-4f10-aa26-b2504df59179",
          "order_id": "69a5780f-efb6-4276-8be3-b06dbb04dfb9",
          "product_id": "petrol-filter-for-proton-iriz-saga-vvt-persona-vvt",
          "name": "Petrol Filter for Proton Iriz / Saga VVT / Persona VVT",
          "sku": "GL-0017",
          "category": "Filters",
          "quantity": 10,
          "price_cents": 2800,
          "line_total_cents": 28000
        },
        {
          "id": "62bffb8f-ec47-49a5-9473-c9b1d02a60a7",
          "order_id": "69a5780f-efb6-4276-8be3-b06dbb04dfb9",
          "product_id": "toyota-fully-synthetic-0w-20-engine-oil-4l",
          "name": "Toyota Fully Synthetic 0W-20 Engine Oil 4L",
          "sku": "GL-0001",
          "category": "Engine Oil",
          "quantity": 10,
          "price_cents": 13000,
          "line_total_cents": 130000
        }
      ],
      "events": [
        {
          "id": "e273aad8-6605-4933-85c7-d4c3f01a45be",
          "order_id": "69a5780f-efb6-4276-8be3-b06dbb04dfb9",
          "event": "order_created",
          "actor_id": "30000000-0000-4000-8000-000000000011",
          "note": "Fictional example: inventory reserved.",
          "created_at": "2026-09-18T12:00:00.000Z"
        },
        {
          "id": "b2e62d3d-68b3-4695-b50a-812026d1a94d",
          "order_id": "69a5780f-efb6-4276-8be3-b06dbb04dfb9",
          "event": "payment_submitted",
          "actor_id": "30000000-0000-4000-8000-000000000011",
          "note": "Fictional bank reference; no transfer occurred.",
          "created_at": "2026-09-18T12:10:00.000Z"
        },
        {
          "id": "71fe3947-8c6d-437d-abd8-6d093974e3e2",
          "order_id": "69a5780f-efb6-4276-8be3-b06dbb04dfb9",
          "event": "payment_verified",
          "actor_id": "seed-worker",
          "note": "Fictional deposit verification.",
          "created_at": "2026-09-18T12:20:00.000Z"
        },
        {
          "id": "94547c67-e6cb-421c-8800-2b16ced950c4",
          "order_id": "69a5780f-efb6-4276-8be3-b06dbb04dfb9",
          "event": "shipped",
          "actor_id": "seed-worker",
          "note": "Fictional carrier and tracking number.",
          "created_at": "2026-09-19T12:00:00.000Z"
        },
        {
          "id": "65b59b16-9311-4f76-8464-c87eea5fab36",
          "order_id": "69a5780f-efb6-4276-8be3-b06dbb04dfb9",
          "event": "receipt_confirmed",
          "actor_id": "30000000-0000-4000-8000-000000000011",
          "note": "Fictional buyer confirmed receipt.",
          "created_at": "2026-09-20T12:00:00.000Z"
        }
      ],
      "sample_data": true
    },
    {
      "id": "91b70aff-14fa-48aa-91ea-8c9f8ea42df5",
      "order_number": 10048,
      "customer_id": "30000000-0000-4000-8000-000000000012",
      "status": "delivered",
      "payment_status": "verified",
      "address": {
        "name": "Demo Distributor 12",
        "phone": "0100000000",
        "line1": "Demo address — not for delivery",
        "city": "Petaling Jaya",
        "postcode": "47300",
        "state": "Selangor"
      },
      "subtotal_cents": 322000,
      "discount_cents": 0,
      "shipping_cents": 0,
      "total_cents": 322000,
      "payment_instructions": {
        "bank_name": "DEMO — DO NOT TRANSFER",
        "bank_account_name": "FICTIONAL EXAMPLE ONLY",
        "bank_account_number": "0000000000"
      },
      "payment_reference": "SAMPLE-NO-TRANSFER-48",
      "paid_verified_by": "seed-worker",
      "payment_note": null,
      "carrier": "Demo carrier",
      "tracking_number": "DEMO-NOT-A-PARCEL-48",
      "received_at": "2026-09-19T13:00:00.000Z",
      "cancel_reason": null,
      "idempotency_key": "4f0213ed-6f79-41dd-b62d-49c60b8bae83",
      "created_at": "2026-09-17T13:00:00.000Z",
      "updated_at": "2026-09-19T13:00:00.000Z",
      "expires_at": "2026-09-18T13:00:00.000Z",
      "items": [
        {
          "id": "c68d29ec-f87d-49f8-a4f5-5a2e98d89bdf",
          "order_id": "91b70aff-14fa-48aa-91ea-8c9f8ea42df5",
          "product_id": "perodua-fully-synthetic-0w-20-oil-3-5l-filter",
          "name": "Perodua Fully Synthetic 0W-20 Oil 3.5L + Filter",
          "sku": "GL-0020",
          "category": "Engine Oil",
          "quantity": 14,
          "price_cents": 16500,
          "line_total_cents": 231000
        },
        {
          "id": "a0e8d5ae-7ea4-487b-84de-1faceeb11ea0",
          "order_id": "91b70aff-14fa-48aa-91ea-8c9f8ea42df5",
          "product_id": "sae-40-engine-oil-1l",
          "name": "SAE 40 Engine Oil 1L",
          "sku": "GL-0002",
          "category": "Engine Oil",
          "quantity": 14,
          "price_cents": 1000,
          "line_total_cents": 14000
        },
        {
          "id": "bd0268bc-e10d-4e67-a661-31e174769693",
          "order_id": "91b70aff-14fa-48aa-91ea-8c9f8ea42df5",
          "product_id": "proton-cvt-transmission-fluid-1l",
          "name": "Proton CVT Transmission Fluid 1L",
          "sku": "GL-0005",
          "category": "Transmission Fluid",
          "quantity": 14,
          "price_cents": 5500,
          "line_total_cents": 77000
        }
      ],
      "events": [
        {
          "id": "a6019e7c-6c70-4f2b-9567-32e62044aff3",
          "order_id": "91b70aff-14fa-48aa-91ea-8c9f8ea42df5",
          "event": "order_created",
          "actor_id": "30000000-0000-4000-8000-000000000012",
          "note": "Fictional example: inventory reserved.",
          "created_at": "2026-09-17T13:00:00.000Z"
        },
        {
          "id": "e0323d14-a944-4120-ba69-6ba03bb99956",
          "order_id": "91b70aff-14fa-48aa-91ea-8c9f8ea42df5",
          "event": "payment_submitted",
          "actor_id": "30000000-0000-4000-8000-000000000012",
          "note": "Fictional bank reference; no transfer occurred.",
          "created_at": "2026-09-17T13:10:00.000Z"
        },
        {
          "id": "be1a0f2a-505a-4625-92a5-25d62c434e0c",
          "order_id": "91b70aff-14fa-48aa-91ea-8c9f8ea42df5",
          "event": "payment_verified",
          "actor_id": "seed-worker",
          "note": "Fictional deposit verification.",
          "created_at": "2026-09-17T13:20:00.000Z"
        },
        {
          "id": "713f3ba7-e6c0-42e8-9be0-3fb3e0481487",
          "order_id": "91b70aff-14fa-48aa-91ea-8c9f8ea42df5",
          "event": "shipped",
          "actor_id": "seed-worker",
          "note": "Fictional carrier and tracking number.",
          "created_at": "2026-09-18T13:00:00.000Z"
        },
        {
          "id": "6362365c-658d-4b3f-8c2e-98f4aabb9420",
          "order_id": "91b70aff-14fa-48aa-91ea-8c9f8ea42df5",
          "event": "receipt_confirmed",
          "actor_id": "30000000-0000-4000-8000-000000000012",
          "note": "Fictional buyer confirmed receipt.",
          "created_at": "2026-09-19T13:00:00.000Z"
        }
      ],
      "sample_data": true
    },
    {
      "id": "924a68f5-73da-42e4-8c81-7f85c3026013",
      "order_number": 10049,
      "customer_id": "30000000-0000-4000-8000-000000000001",
      "status": "delivered",
      "payment_status": "verified",
      "address": {
        "name": "Demo Motorist 01",
        "phone": "0100000000",
        "line1": "Demo address — not for delivery",
        "city": "Petaling Jaya",
        "postcode": "47300",
        "state": "Selangor"
      },
      "subtotal_cents": 6700,
      "discount_cents": 0,
      "shipping_cents": 1500,
      "total_cents": 8200,
      "payment_instructions": {
        "bank_name": "DEMO — DO NOT TRANSFER",
        "bank_account_name": "FICTIONAL EXAMPLE ONLY",
        "bank_account_number": "0000000000"
      },
      "payment_reference": "SAMPLE-NO-TRANSFER-49",
      "paid_verified_by": "seed-worker",
      "payment_note": null,
      "carrier": "Demo carrier",
      "tracking_number": "DEMO-NOT-A-PARCEL-49",
      "received_at": "2026-09-18T01:00:00.000Z",
      "cancel_reason": null,
      "idempotency_key": "cc5c8b0d-43cf-4dce-9e18-7ae0eef763d2",
      "created_at": "2026-09-16T01:00:00.000Z",
      "updated_at": "2026-09-18T01:00:00.000Z",
      "expires_at": "2026-09-17T01:00:00.000Z",
      "items": [
        {
          "id": "d88048ef-0e03-4887-82a9-c73fe78ecb38",
          "order_id": "924a68f5-73da-42e4-8c81-7f85c3026013",
          "product_id": "trw-gdb3459-front-brake-pads",
          "name": "TRW GDB3459 Front Brake Pads",
          "sku": "GL-0048",
          "category": "Brake Pads",
          "quantity": 1,
          "price_cents": 6700,
          "line_total_cents": 6700
        }
      ],
      "events": [
        {
          "id": "4e4a9078-210a-41c6-8ece-072ac4061bcb",
          "order_id": "924a68f5-73da-42e4-8c81-7f85c3026013",
          "event": "order_created",
          "actor_id": "30000000-0000-4000-8000-000000000001",
          "note": "Fictional example: inventory reserved.",
          "created_at": "2026-09-16T01:00:00.000Z"
        },
        {
          "id": "8190c6ab-57be-4836-a2b0-a6ddea46892b",
          "order_id": "924a68f5-73da-42e4-8c81-7f85c3026013",
          "event": "payment_submitted",
          "actor_id": "30000000-0000-4000-8000-000000000001",
          "note": "Fictional bank reference; no transfer occurred.",
          "created_at": "2026-09-16T01:10:00.000Z"
        },
        {
          "id": "6710c20a-1e39-4588-afbe-9b62cffa6592",
          "order_id": "924a68f5-73da-42e4-8c81-7f85c3026013",
          "event": "payment_verified",
          "actor_id": "seed-worker",
          "note": "Fictional deposit verification.",
          "created_at": "2026-09-16T01:20:00.000Z"
        },
        {
          "id": "9179205d-800a-4c25-a979-88da1c4217b1",
          "order_id": "924a68f5-73da-42e4-8c81-7f85c3026013",
          "event": "shipped",
          "actor_id": "seed-worker",
          "note": "Fictional carrier and tracking number.",
          "created_at": "2026-09-17T01:00:00.000Z"
        },
        {
          "id": "81569294-90bc-4ca9-a88a-3e413e036185",
          "order_id": "924a68f5-73da-42e4-8c81-7f85c3026013",
          "event": "receipt_confirmed",
          "actor_id": "30000000-0000-4000-8000-000000000001",
          "note": "Fictional buyer confirmed receipt.",
          "created_at": "2026-09-18T01:00:00.000Z"
        }
      ],
      "sample_data": true
    },
    {
      "id": "1cf203d3-58d9-4a66-9a83-0040c66e3e10",
      "order_number": 10050,
      "customer_id": "30000000-0000-4000-8000-000000000002",
      "status": "delivered",
      "payment_status": "verified",
      "address": {
        "name": "Demo Workshop 02",
        "phone": "0100000000",
        "line1": "Demo address — not for delivery",
        "city": "Petaling Jaya",
        "postcode": "47300",
        "state": "Selangor"
      },
      "subtotal_cents": 12800,
      "discount_cents": 0,
      "shipping_cents": 1500,
      "total_cents": 14300,
      "payment_instructions": {
        "bank_name": "DEMO — DO NOT TRANSFER",
        "bank_account_name": "FICTIONAL EXAMPLE ONLY",
        "bank_account_number": "0000000000"
      },
      "payment_reference": "SAMPLE-NO-TRANSFER-50",
      "paid_verified_by": "seed-worker",
      "payment_note": null,
      "carrier": "Demo carrier",
      "tracking_number": "DEMO-NOT-A-PARCEL-50",
      "received_at": "2026-09-17T02:00:00.000Z",
      "cancel_reason": null,
      "idempotency_key": "ec7b1322-f1bd-4b39-83ec-c26db7732457",
      "created_at": "2026-09-15T02:00:00.000Z",
      "updated_at": "2026-09-17T02:00:00.000Z",
      "expires_at": "2026-09-16T02:00:00.000Z",
      "items": [
        {
          "id": "337ad532-ed5c-4146-94b2-d917f76f2a5b",
          "order_id": "1cf203d3-58d9-4a66-9a83-0040c66e3e10",
          "product_id": "sae-40-engine-oil-1l",
          "name": "SAE 40 Engine Oil 1L",
          "sku": "GL-0002",
          "category": "Engine Oil",
          "quantity": 4,
          "price_cents": 1000,
          "line_total_cents": 4000
        },
        {
          "id": "5cdf4943-5b34-4923-907d-38746730a7ca",
          "order_id": "1cf203d3-58d9-4a66-9a83-0040c66e3e10",
          "product_id": "bendix-dot-4-brake-and-clutch-fluid-1l",
          "name": "Bendix DOT 4 Brake and Clutch Fluid 1L",
          "sku": "GL-0003",
          "category": "Brake Fluid",
          "quantity": 4,
          "price_cents": 2200,
          "line_total_cents": 8800
        }
      ],
      "events": [
        {
          "id": "f909516b-055c-4cd9-a988-3c4d39e3c106",
          "order_id": "1cf203d3-58d9-4a66-9a83-0040c66e3e10",
          "event": "order_created",
          "actor_id": "30000000-0000-4000-8000-000000000002",
          "note": "Fictional example: inventory reserved.",
          "created_at": "2026-09-15T02:00:00.000Z"
        },
        {
          "id": "a721b0b9-cf2c-4486-87e1-0f83c6204f14",
          "order_id": "1cf203d3-58d9-4a66-9a83-0040c66e3e10",
          "event": "payment_submitted",
          "actor_id": "30000000-0000-4000-8000-000000000002",
          "note": "Fictional bank reference; no transfer occurred.",
          "created_at": "2026-09-15T02:10:00.000Z"
        },
        {
          "id": "7df31cfd-b268-40d0-a303-fd7c9f230d79",
          "order_id": "1cf203d3-58d9-4a66-9a83-0040c66e3e10",
          "event": "payment_verified",
          "actor_id": "seed-worker",
          "note": "Fictional deposit verification.",
          "created_at": "2026-09-15T02:20:00.000Z"
        },
        {
          "id": "a1a47cd2-d27b-49fe-aa4f-54ee00ea36e2",
          "order_id": "1cf203d3-58d9-4a66-9a83-0040c66e3e10",
          "event": "shipped",
          "actor_id": "seed-worker",
          "note": "Fictional carrier and tracking number.",
          "created_at": "2026-09-16T02:00:00.000Z"
        },
        {
          "id": "3b22db19-73f6-4870-89c5-005712dff43f",
          "order_id": "1cf203d3-58d9-4a66-9a83-0040c66e3e10",
          "event": "receipt_confirmed",
          "actor_id": "30000000-0000-4000-8000-000000000002",
          "note": "Fictional buyer confirmed receipt.",
          "created_at": "2026-09-17T02:00:00.000Z"
        }
      ],
      "sample_data": true
    },
    {
      "id": "ae1963f7-3cf5-4c93-9509-d2481c8965ce",
      "order_number": 10051,
      "customer_id": "30000000-0000-4000-8000-000000000003",
      "status": "delivered",
      "payment_status": "verified",
      "address": {
        "name": "Demo Parts Shop 03",
        "phone": "0100000000",
        "line1": "Demo address — not for delivery",
        "city": "Petaling Jaya",
        "postcode": "47300",
        "state": "Selangor"
      },
      "subtotal_cents": 39900,
      "discount_cents": 0,
      "shipping_cents": 0,
      "total_cents": 39900,
      "payment_instructions": {
        "bank_name": "DEMO — DO NOT TRANSFER",
        "bank_account_name": "FICTIONAL EXAMPLE ONLY",
        "bank_account_number": "0000000000"
      },
      "payment_reference": "SAMPLE-NO-TRANSFER-51",
      "paid_verified_by": "seed-worker",
      "payment_note": null,
      "carrier": "Demo carrier",
      "tracking_number": "DEMO-NOT-A-PARCEL-51",
      "received_at": "2026-09-16T03:00:00.000Z",
      "cancel_reason": null,
      "idempotency_key": "ffca239b-13d9-4405-bc96-f04233d73b0c",
      "created_at": "2026-09-14T03:00:00.000Z",
      "updated_at": "2026-09-16T03:00:00.000Z",
      "expires_at": "2026-09-15T03:00:00.000Z",
      "items": [
        {
          "id": "0d1a3a95-e2b5-4216-ad0a-2611f1099ff1",
          "order_id": "ae1963f7-3cf5-4c93-9509-d2481c8965ce",
          "product_id": "bendix-dot-4-brake-and-clutch-fluid-1l",
          "name": "Bendix DOT 4 Brake and Clutch Fluid 1L",
          "sku": "GL-0003",
          "category": "Brake Fluid",
          "quantity": 7,
          "price_cents": 2200,
          "line_total_cents": 15400
        },
        {
          "id": "45fb7660-0e28-4a32-a10c-c60c204944f9",
          "order_id": "ae1963f7-3cf5-4c93-9509-d2481c8965ce",
          "product_id": "manual-gear-oil-ep-140-1l",
          "name": "Manual Gear Oil EP 140 1L",
          "sku": "GL-0016",
          "category": "Transmission Fluid",
          "quantity": 7,
          "price_cents": 1500,
          "line_total_cents": 10500
        },
        {
          "id": "6256d066-3f5d-43b5-b110-ba5c05729a38",
          "order_id": "ae1963f7-3cf5-4c93-9509-d2481c8965ce",
          "product_id": "cabin-filter-for-proton-x70",
          "name": "Cabin Filter for Proton X70",
          "sku": "GL-0010",
          "category": "Filters",
          "quantity": 7,
          "price_cents": 2000,
          "line_total_cents": 14000
        }
      ],
      "events": [
        {
          "id": "a921d35f-4539-492d-98db-8390e0bc12ce",
          "order_id": "ae1963f7-3cf5-4c93-9509-d2481c8965ce",
          "event": "order_created",
          "actor_id": "30000000-0000-4000-8000-000000000003",
          "note": "Fictional example: inventory reserved.",
          "created_at": "2026-09-14T03:00:00.000Z"
        },
        {
          "id": "abd80dab-4b2f-4f3b-8b75-bf2b85fa5841",
          "order_id": "ae1963f7-3cf5-4c93-9509-d2481c8965ce",
          "event": "payment_submitted",
          "actor_id": "30000000-0000-4000-8000-000000000003",
          "note": "Fictional bank reference; no transfer occurred.",
          "created_at": "2026-09-14T03:10:00.000Z"
        },
        {
          "id": "1b4c4dfb-ae7e-4efb-9f81-7f9fb2fb9fd3",
          "order_id": "ae1963f7-3cf5-4c93-9509-d2481c8965ce",
          "event": "payment_verified",
          "actor_id": "seed-worker",
          "note": "Fictional deposit verification.",
          "created_at": "2026-09-14T03:20:00.000Z"
        },
        {
          "id": "83084769-f5a0-486b-9be9-fb5fb398f94c",
          "order_id": "ae1963f7-3cf5-4c93-9509-d2481c8965ce",
          "event": "shipped",
          "actor_id": "seed-worker",
          "note": "Fictional carrier and tracking number.",
          "created_at": "2026-09-15T03:00:00.000Z"
        },
        {
          "id": "abb5e98b-53fb-4504-9910-a742c76f29ad",
          "order_id": "ae1963f7-3cf5-4c93-9509-d2481c8965ce",
          "event": "receipt_confirmed",
          "actor_id": "30000000-0000-4000-8000-000000000003",
          "note": "Fictional buyer confirmed receipt.",
          "created_at": "2026-09-16T03:00:00.000Z"
        }
      ],
      "sample_data": true
    },
    {
      "id": "5118c922-5af1-4013-a516-ae7155018ace",
      "order_number": 10052,
      "customer_id": "30000000-0000-4000-8000-000000000004",
      "status": "cancelled",
      "payment_status": "refunded",
      "address": {
        "name": "Demo Distributor 04",
        "phone": "0100000000",
        "line1": "Demo address — not for delivery",
        "city": "Petaling Jaya",
        "postcode": "47300",
        "state": "Selangor"
      },
      "subtotal_cents": 90000,
      "discount_cents": 0,
      "shipping_cents": 0,
      "total_cents": 90000,
      "payment_instructions": {
        "bank_name": "DEMO — DO NOT TRANSFER",
        "bank_account_name": "FICTIONAL EXAMPLE ONLY",
        "bank_account_number": "0000000000"
      },
      "payment_reference": "SAMPLE-NO-TRANSFER-52",
      "paid_verified_by": "seed-worker",
      "payment_note": null,
      "carrier": "Demo carrier",
      "tracking_number": "DEMO-NOT-A-PARCEL-52",
      "received_at": "2026-09-15T05:00:00.000Z",
      "cancel_reason": null,
      "idempotency_key": "1142b7ca-1299-4ecb-b3b7-e7fbd225e4df",
      "created_at": "2026-09-13T05:00:00.000Z",
      "updated_at": "2026-09-16T05:00:00.000Z",
      "expires_at": "2026-09-14T05:00:00.000Z",
      "items": [
        {
          "id": "29e4e44a-eaed-4411-8a41-3f3bf5c82d09",
          "order_id": "5118c922-5af1-4013-a516-ae7155018ace",
          "product_id": "castrol-gtx-10w-30-engine-oil-3l",
          "name": "Castrol GTX 10W-30 Engine Oil 3L",
          "sku": "GL-0031",
          "category": "Engine Oil",
          "quantity": 18,
          "price_cents": 5000,
          "line_total_cents": 90000
        }
      ],
      "events": [
        {
          "id": "c5d49f1d-1da0-4b53-8007-28fd82796aaf",
          "order_id": "5118c922-5af1-4013-a516-ae7155018ace",
          "event": "order_created",
          "actor_id": "30000000-0000-4000-8000-000000000004",
          "note": "Fictional example: inventory reserved.",
          "created_at": "2026-09-13T05:00:00.000Z"
        },
        {
          "id": "4224c2c4-5444-4007-b421-b5728c77cbde",
          "order_id": "5118c922-5af1-4013-a516-ae7155018ace",
          "event": "payment_submitted",
          "actor_id": "30000000-0000-4000-8000-000000000004",
          "note": "Fictional bank reference; no transfer occurred.",
          "created_at": "2026-09-13T05:10:00.000Z"
        },
        {
          "id": "cbdff153-d6ea-418d-91f8-fb66ce5fd621",
          "order_id": "5118c922-5af1-4013-a516-ae7155018ace",
          "event": "payment_verified",
          "actor_id": "seed-worker",
          "note": "Fictional deposit verification.",
          "created_at": "2026-09-13T05:20:00.000Z"
        },
        {
          "id": "5570ad53-9f63-479f-88d5-410591351f66",
          "order_id": "5118c922-5af1-4013-a516-ae7155018ace",
          "event": "shipped",
          "actor_id": "seed-worker",
          "note": "Fictional carrier and tracking number.",
          "created_at": "2026-09-14T05:00:00.000Z"
        },
        {
          "id": "1fdb9fd2-d6a9-4497-9693-2382659326f0",
          "order_id": "5118c922-5af1-4013-a516-ae7155018ace",
          "event": "receipt_confirmed",
          "actor_id": "30000000-0000-4000-8000-000000000004",
          "note": "Fictional buyer confirmed receipt.",
          "created_at": "2026-09-15T05:00:00.000Z"
        },
        {
          "id": "ec2fb71a-9673-40b9-8876-6f5f2e93fef5",
          "order_id": "5118c922-5af1-4013-a516-ae7155018ace",
          "event": "refund_paid",
          "actor_id": "seed-admin",
          "note": "Fictional full refund; returned units restored.",
          "created_at": "2026-09-16T05:00:00.000Z"
        }
      ],
      "sample_data": true
    },
    {
      "id": "c350ff32-0c81-4426-b9c1-e32f73a8a93d",
      "order_number": 10053,
      "customer_id": "30000000-0000-4000-8000-000000000005",
      "status": "cancelled",
      "payment_status": "awaiting",
      "address": {
        "name": "Demo Motorist 05",
        "phone": "0100000000",
        "line1": "Demo address — not for delivery",
        "city": "Petaling Jaya",
        "postcode": "47300",
        "state": "Selangor"
      },
      "subtotal_cents": 4700,
      "discount_cents": 0,
      "shipping_cents": 1500,
      "total_cents": 6200,
      "payment_instructions": {
        "bank_name": "DEMO — DO NOT TRANSFER",
        "bank_account_name": "FICTIONAL EXAMPLE ONLY",
        "bank_account_number": "0000000000"
      },
      "payment_reference": null,
      "paid_verified_by": null,
      "payment_note": null,
      "carrier": null,
      "tracking_number": null,
      "received_at": null,
      "cancel_reason": "Example customer changed their mind.",
      "idempotency_key": "78e555d2-61cf-489b-b939-26da409c7428",
      "created_at": "2026-09-12T06:00:00.000Z",
      "updated_at": "2026-09-12T06:30:00.000Z",
      "expires_at": "2026-09-13T06:00:00.000Z",
      "items": [
        {
          "id": "a6c4b243-1456-455f-9638-09a3838d7024",
          "order_id": "c350ff32-0c81-4426-b9c1-e32f73a8a93d",
          "product_id": "bendix-dot-4-brake-and-clutch-fluid-1l",
          "name": "Bendix DOT 4 Brake and Clutch Fluid 1L",
          "sku": "GL-0003",
          "category": "Brake Fluid",
          "quantity": 1,
          "price_cents": 2200,
          "line_total_cents": 2200
        },
        {
          "id": "ceba3df6-588d-4966-82dd-7e1344cefce1",
          "order_id": "c350ff32-0c81-4426-b9c1-e32f73a8a93d",
          "product_id": "perodua-radiator-coolant-1l",
          "name": "Perodua Radiator Coolant 1L",
          "sku": "GL-0024",
          "category": "Coolant",
          "quantity": 1,
          "price_cents": 2500,
          "line_total_cents": 2500
        }
      ],
      "events": [
        {
          "id": "aff6f37b-27a0-4b75-8e50-33efbd198266",
          "order_id": "c350ff32-0c81-4426-b9c1-e32f73a8a93d",
          "event": "order_created",
          "actor_id": "30000000-0000-4000-8000-000000000005",
          "note": "Fictional example: inventory reserved.",
          "created_at": "2026-09-12T06:00:00.000Z"
        },
        {
          "id": "fabe689c-4cf0-4ca7-ab10-5bf44c0c5a3f",
          "order_id": "c350ff32-0c81-4426-b9c1-e32f73a8a93d",
          "event": "cancelled",
          "actor_id": "30000000-0000-4000-8000-000000000005",
          "note": "Fictional unpaid cancellation; reserved inventory restored.",
          "created_at": "2026-09-12T06:30:00.000Z"
        }
      ],
      "sample_data": true
    },
    {
      "id": "562a8186-8922-41da-87d0-3f9761e08b2b",
      "order_number": 10054,
      "customer_id": "30000000-0000-4000-8000-000000000006",
      "status": "delivered",
      "payment_status": "verified",
      "address": {
        "name": "Demo Workshop 06",
        "phone": "0100000000",
        "line1": "Demo address — not for delivery",
        "city": "Petaling Jaya",
        "postcode": "47300",
        "state": "Selangor"
      },
      "subtotal_cents": 64000,
      "discount_cents": 0,
      "shipping_cents": 0,
      "total_cents": 64000,
      "payment_instructions": {
        "bank_name": "DEMO — DO NOT TRANSFER",
        "bank_account_name": "FICTIONAL EXAMPLE ONLY",
        "bank_account_number": "0000000000"
      },
      "payment_reference": "SAMPLE-NO-TRANSFER-54",
      "paid_verified_by": "seed-worker",
      "payment_note": null,
      "carrier": "Demo carrier",
      "tracking_number": "DEMO-NOT-A-PARCEL-54",
      "received_at": "2026-09-13T10:00:00.000Z",
      "cancel_reason": null,
      "idempotency_key": "a5b70a68-048d-496f-80d8-bfaa57bff2b6",
      "created_at": "2026-09-11T10:00:00.000Z",
      "updated_at": "2026-09-13T10:00:00.000Z",
      "expires_at": "2026-09-12T10:00:00.000Z",
      "items": [
        {
          "id": "0a23b546-ce63-4a54-931e-e3a676a8df4f",
          "order_id": "562a8186-8922-41da-87d0-3f9761e08b2b",
          "product_id": "castrol-80w-90-manual-gear-oil-4l",
          "name": "Castrol 80W-90 Manual Gear Oil 4L",
          "sku": "GL-0033",
          "category": "Transmission Fluid",
          "quantity": 4,
          "price_cents": 7500,
          "line_total_cents": 30000
        },
        {
          "id": "ace53dbb-f33e-4a71-afc4-23287247cb77",
          "order_id": "562a8186-8922-41da-87d0-3f9761e08b2b",
          "product_id": "engine-air-filter-for-proton-x70",
          "name": "Engine Air Filter for Proton X70",
          "sku": "GL-0012",
          "category": "Filters",
          "quantity": 4,
          "price_cents": 1800,
          "line_total_cents": 7200
        },
        {
          "id": "86a8cbf6-e8f0-479f-8c4d-bb595eef1702",
          "order_id": "562a8186-8922-41da-87d0-3f9761e08b2b",
          "product_id": "trw-gdb3459-front-brake-pads",
          "name": "TRW GDB3459 Front Brake Pads",
          "sku": "GL-0048",
          "category": "Brake Pads",
          "quantity": 4,
          "price_cents": 6700,
          "line_total_cents": 26800
        }
      ],
      "events": [
        {
          "id": "f7871cdf-c5ef-41af-a3bb-6697cac29dde",
          "order_id": "562a8186-8922-41da-87d0-3f9761e08b2b",
          "event": "order_created",
          "actor_id": "30000000-0000-4000-8000-000000000006",
          "note": "Fictional example: inventory reserved.",
          "created_at": "2026-09-11T10:00:00.000Z"
        },
        {
          "id": "dca1fcca-4d8a-4815-abb3-4a72502e903e",
          "order_id": "562a8186-8922-41da-87d0-3f9761e08b2b",
          "event": "payment_submitted",
          "actor_id": "30000000-0000-4000-8000-000000000006",
          "note": "Fictional bank reference; no transfer occurred.",
          "created_at": "2026-09-11T10:10:00.000Z"
        },
        {
          "id": "b499cfe6-293a-489a-92ef-ad09a664fe60",
          "order_id": "562a8186-8922-41da-87d0-3f9761e08b2b",
          "event": "payment_verified",
          "actor_id": "seed-worker",
          "note": "Fictional deposit verification.",
          "created_at": "2026-09-11T10:20:00.000Z"
        },
        {
          "id": "fa713164-27cd-479c-93a9-3ad5b500729b",
          "order_id": "562a8186-8922-41da-87d0-3f9761e08b2b",
          "event": "shipped",
          "actor_id": "seed-worker",
          "note": "Fictional carrier and tracking number.",
          "created_at": "2026-09-12T10:00:00.000Z"
        },
        {
          "id": "b21b979c-8ff1-4950-90c0-f035436714d3",
          "order_id": "562a8186-8922-41da-87d0-3f9761e08b2b",
          "event": "receipt_confirmed",
          "actor_id": "30000000-0000-4000-8000-000000000006",
          "note": "Fictional buyer confirmed receipt.",
          "created_at": "2026-09-13T10:00:00.000Z"
        }
      ],
      "sample_data": true
    },
    {
      "id": "3c0f4f95-046d-41e8-8141-ac1f9dde8d95",
      "order_number": 10055,
      "customer_id": "30000000-0000-4000-8000-000000000007",
      "status": "delivered",
      "payment_status": "verified",
      "address": {
        "name": "Demo Parts Shop 07",
        "phone": "0100000000",
        "line1": "Demo address — not for delivery",
        "city": "Petaling Jaya",
        "postcode": "47300",
        "state": "Selangor"
      },
      "subtotal_cents": 10989,
      "discount_cents": 0,
      "shipping_cents": 1500,
      "total_cents": 12489,
      "payment_instructions": {
        "bank_name": "DEMO — DO NOT TRANSFER",
        "bank_account_name": "FICTIONAL EXAMPLE ONLY",
        "bank_account_number": "0000000000"
      },
      "payment_reference": "SAMPLE-NO-TRANSFER-55",
      "paid_verified_by": "seed-worker",
      "payment_note": null,
      "carrier": "Demo carrier",
      "tracking_number": "DEMO-NOT-A-PARCEL-55",
      "received_at": "2026-09-12T12:00:00.000Z",
      "cancel_reason": null,
      "idempotency_key": "1f0d3880-feaa-4fc9-aa99-ccc684ca1465",
      "created_at": "2026-09-10T12:00:00.000Z",
      "updated_at": "2026-09-12T12:00:00.000Z",
      "expires_at": "2026-09-11T12:00:00.000Z",
      "items": [
        {
          "id": "c58a0d39-cb4a-488a-a55f-e21b5852343d",
          "order_id": "3c0f4f95-046d-41e8-8141-ac1f9dde8d95",
          "product_id": "x-traseal-carburetor-and-choke-cleaner-400ml",
          "name": "X'traseal Carburetor and Choke Cleaner 400ml",
          "sku": "GL-0006",
          "category": "Cleaners & Additives",
          "quantity": 11,
          "price_cents": 999,
          "line_total_cents": 10989
        }
      ],
      "events": [
        {
          "id": "d1d0d7c3-174d-4a7f-9556-f7996c28f998",
          "order_id": "3c0f4f95-046d-41e8-8141-ac1f9dde8d95",
          "event": "order_created",
          "actor_id": "30000000-0000-4000-8000-000000000007",
          "note": "Fictional example: inventory reserved.",
          "created_at": "2026-09-10T12:00:00.000Z"
        },
        {
          "id": "f808e1c0-2fed-4399-83fa-7942f43aaf45",
          "order_id": "3c0f4f95-046d-41e8-8141-ac1f9dde8d95",
          "event": "payment_submitted",
          "actor_id": "30000000-0000-4000-8000-000000000007",
          "note": "Fictional bank reference; no transfer occurred.",
          "created_at": "2026-09-10T12:10:00.000Z"
        },
        {
          "id": "f5d600de-95d0-43c1-bd98-781d92d9af11",
          "order_id": "3c0f4f95-046d-41e8-8141-ac1f9dde8d95",
          "event": "payment_verified",
          "actor_id": "seed-worker",
          "note": "Fictional deposit verification.",
          "created_at": "2026-09-10T12:20:00.000Z"
        },
        {
          "id": "825e45df-dfab-4efa-8836-d71516fdaebe",
          "order_id": "3c0f4f95-046d-41e8-8141-ac1f9dde8d95",
          "event": "shipped",
          "actor_id": "seed-worker",
          "note": "Fictional carrier and tracking number.",
          "created_at": "2026-09-11T12:00:00.000Z"
        },
        {
          "id": "c962f48c-5d50-4417-b8ef-cc194202a498",
          "order_id": "3c0f4f95-046d-41e8-8141-ac1f9dde8d95",
          "event": "receipt_confirmed",
          "actor_id": "30000000-0000-4000-8000-000000000007",
          "note": "Fictional buyer confirmed receipt.",
          "created_at": "2026-09-12T12:00:00.000Z"
        }
      ],
      "sample_data": true
    },
    {
      "id": "745580b6-fb6e-4a8e-994d-a19e217c1a67",
      "order_number": 10056,
      "customer_id": "30000000-0000-4000-8000-000000000008",
      "status": "delivered",
      "payment_status": "verified",
      "address": {
        "name": "Demo Distributor 08",
        "phone": "0100000000",
        "line1": "Demo address — not for delivery",
        "city": "Petaling Jaya",
        "postcode": "47300",
        "state": "Selangor"
      },
      "subtotal_cents": 31200,
      "discount_cents": 0,
      "shipping_cents": 0,
      "total_cents": 31200,
      "payment_instructions": {
        "bank_name": "DEMO — DO NOT TRANSFER",
        "bank_account_name": "FICTIONAL EXAMPLE ONLY",
        "bank_account_number": "0000000000"
      },
      "payment_reference": "SAMPLE-NO-TRANSFER-56",
      "paid_verified_by": "seed-worker",
      "payment_note": null,
      "carrier": "Demo carrier",
      "tracking_number": "DEMO-NOT-A-PARCEL-56",
      "received_at": "2026-09-11T13:00:00.000Z",
      "cancel_reason": null,
      "idempotency_key": "74fdc4e5-fec0-4c0a-9ae7-7daeefa1e6de",
      "created_at": "2026-09-09T13:00:00.000Z",
      "updated_at": "2026-09-11T13:00:00.000Z",
      "expires_at": "2026-09-10T13:00:00.000Z",
      "items": [
        {
          "id": "5892f7ef-460f-4a14-97b1-5ec1782e589e",
          "order_id": "745580b6-fb6e-4a8e-994d-a19e217c1a67",
          "product_id": "top-1-green-radiator-coolant-500ml",
          "name": "Top 1 Green Radiator Coolant 500ml",
          "sku": "GL-0013",
          "category": "Coolant",
          "quantity": 13,
          "price_cents": 1000,
          "line_total_cents": 13000
        },
        {
          "id": "cef643c6-c7bb-4d5a-a425-07105df8b65e",
          "order_id": "745580b6-fb6e-4a8e-994d-a19e217c1a67",
          "product_id": "power-up-power-steering-fluid-1l",
          "name": "Power Up Power Steering Fluid 1L",
          "sku": "GL-0026",
          "category": "Steering Fluid",
          "quantity": 13,
          "price_cents": 1400,
          "line_total_cents": 18200
        }
      ],
      "events": [
        {
          "id": "a229a01b-06f9-434f-a55f-93c6ff4e2d5d",
          "order_id": "745580b6-fb6e-4a8e-994d-a19e217c1a67",
          "event": "order_created",
          "actor_id": "30000000-0000-4000-8000-000000000008",
          "note": "Fictional example: inventory reserved.",
          "created_at": "2026-09-09T13:00:00.000Z"
        },
        {
          "id": "ae0463e7-e541-45ab-a894-30009efabf49",
          "order_id": "745580b6-fb6e-4a8e-994d-a19e217c1a67",
          "event": "payment_submitted",
          "actor_id": "30000000-0000-4000-8000-000000000008",
          "note": "Fictional bank reference; no transfer occurred.",
          "created_at": "2026-09-09T13:10:00.000Z"
        },
        {
          "id": "c4353aec-58e0-4c50-a4d4-2a4423c5926b",
          "order_id": "745580b6-fb6e-4a8e-994d-a19e217c1a67",
          "event": "payment_verified",
          "actor_id": "seed-worker",
          "note": "Fictional deposit verification.",
          "created_at": "2026-09-09T13:20:00.000Z"
        },
        {
          "id": "08dfea76-2fcb-4273-a15e-e83f2c35a993",
          "order_id": "745580b6-fb6e-4a8e-994d-a19e217c1a67",
          "event": "shipped",
          "actor_id": "seed-worker",
          "note": "Fictional carrier and tracking number.",
          "created_at": "2026-09-10T13:00:00.000Z"
        },
        {
          "id": "fc6302f1-9cb0-4348-a666-b32332ca5044",
          "order_id": "745580b6-fb6e-4a8e-994d-a19e217c1a67",
          "event": "receipt_confirmed",
          "actor_id": "30000000-0000-4000-8000-000000000008",
          "note": "Fictional buyer confirmed receipt.",
          "created_at": "2026-09-11T13:00:00.000Z"
        }
      ],
      "sample_data": true
    },
    {
      "id": "ccd1676f-2f46-4ed1-ac60-22db168fc302",
      "order_number": 10057,
      "customer_id": "30000000-0000-4000-8000-000000000009",
      "status": "delivered",
      "payment_status": "verified",
      "address": {
        "name": "Demo Motorist 09",
        "phone": "0100000000",
        "line1": "Demo address — not for delivery",
        "city": "Petaling Jaya",
        "postcode": "47300",
        "state": "Selangor"
      },
      "subtotal_cents": 24800,
      "discount_cents": 0,
      "shipping_cents": 1500,
      "total_cents": 26300,
      "payment_instructions": {
        "bank_name": "DEMO — DO NOT TRANSFER",
        "bank_account_name": "FICTIONAL EXAMPLE ONLY",
        "bank_account_number": "0000000000"
      },
      "payment_reference": "SAMPLE-NO-TRANSFER-57",
      "paid_verified_by": "seed-worker",
      "payment_note": null,
      "carrier": "Demo carrier",
      "tracking_number": "DEMO-NOT-A-PARCEL-57",
      "received_at": "2026-09-10T12:00:00.000Z",
      "cancel_reason": null,
      "idempotency_key": "a9c18f57-e039-44b4-85c9-4036b564d1a9",
      "created_at": "2026-09-08T12:00:00.000Z",
      "updated_at": "2026-09-10T12:00:00.000Z",
      "expires_at": "2026-09-09T12:00:00.000Z",
      "items": [
        {
          "id": "499e6f1f-f787-422b-9b3b-62e4e5ece7cb",
          "order_id": "ccd1676f-2f46-4ed1-ac60-22db168fc302",
          "product_id": "petrol-filter-for-proton-iriz-saga-vvt-persona-vvt",
          "name": "Petrol Filter for Proton Iriz / Saga VVT / Persona VVT",
          "sku": "GL-0017",
          "category": "Filters",
          "quantity": 1,
          "price_cents": 2800,
          "line_total_cents": 2800
        },
        {
          "id": "b1b72b32-d022-4cc3-839b-5607167d88c2",
          "order_id": "ccd1676f-2f46-4ed1-ac60-22db168fc302",
          "product_id": "trw-gdb7707-front-brake-pads",
          "name": "TRW GDB7707 Front Brake Pads",
          "sku": "GL-0043",
          "category": "Brake Pads",
          "quantity": 1,
          "price_cents": 5500,
          "line_total_cents": 5500
        },
        {
          "id": "220cc3ae-7546-44c2-965f-a7e4b06f461d",
          "order_id": "ccd1676f-2f46-4ed1-ac60-22db168fc302",
          "product_id": "perodua-fully-synthetic-0w-20-oil-3-5l-filter",
          "name": "Perodua Fully Synthetic 0W-20 Oil 3.5L + Filter",
          "sku": "GL-0020",
          "category": "Engine Oil",
          "quantity": 1,
          "price_cents": 16500,
          "line_total_cents": 16500
        }
      ],
      "events": [
        {
          "id": "e7f1ef07-1e7a-4bea-8401-3b9ada54e45b",
          "order_id": "ccd1676f-2f46-4ed1-ac60-22db168fc302",
          "event": "order_created",
          "actor_id": "30000000-0000-4000-8000-000000000009",
          "note": "Fictional example: inventory reserved.",
          "created_at": "2026-09-08T12:00:00.000Z"
        },
        {
          "id": "92a38e38-5d24-46e4-9bbb-0e917ff8c9d4",
          "order_id": "ccd1676f-2f46-4ed1-ac60-22db168fc302",
          "event": "payment_submitted",
          "actor_id": "30000000-0000-4000-8000-000000000009",
          "note": "Fictional bank reference; no transfer occurred.",
          "created_at": "2026-09-08T12:10:00.000Z"
        },
        {
          "id": "a6f3bc94-da37-4c4d-9526-cd04b975ee13",
          "order_id": "ccd1676f-2f46-4ed1-ac60-22db168fc302",
          "event": "payment_verified",
          "actor_id": "seed-worker",
          "note": "Fictional deposit verification.",
          "created_at": "2026-09-08T12:20:00.000Z"
        },
        {
          "id": "5b36a3a7-06e2-47c9-be6e-e1c2d87615e1",
          "order_id": "ccd1676f-2f46-4ed1-ac60-22db168fc302",
          "event": "shipped",
          "actor_id": "seed-worker",
          "note": "Fictional carrier and tracking number.",
          "created_at": "2026-09-09T12:00:00.000Z"
        },
        {
          "id": "6e840c48-c781-435e-9e02-09e1e06d246b",
          "order_id": "ccd1676f-2f46-4ed1-ac60-22db168fc302",
          "event": "receipt_confirmed",
          "actor_id": "30000000-0000-4000-8000-000000000009",
          "note": "Fictional buyer confirmed receipt.",
          "created_at": "2026-09-10T12:00:00.000Z"
        }
      ],
      "sample_data": true
    },
    {
      "id": "d3011c8c-6e6e-40ee-8ffa-32507f6b6106",
      "order_number": 10058,
      "customer_id": "30000000-0000-4000-8000-000000000010",
      "status": "delivered",
      "payment_status": "verified",
      "address": {
        "name": "Demo Workshop 10",
        "phone": "0100000000",
        "line1": "Demo address — not for delivery",
        "city": "Petaling Jaya",
        "postcode": "47300",
        "state": "Selangor"
      },
      "subtotal_cents": 24000,
      "discount_cents": 0,
      "shipping_cents": 1500,
      "total_cents": 25500,
      "payment_instructions": {
        "bank_name": "DEMO — DO NOT TRANSFER",
        "bank_account_name": "FICTIONAL EXAMPLE ONLY",
        "bank_account_number": "0000000000"
      },
      "payment_reference": "SAMPLE-NO-TRANSFER-58",
      "paid_verified_by": "seed-worker",
      "payment_note": null,
      "carrier": "Demo carrier",
      "tracking_number": "DEMO-NOT-A-PARCEL-58",
      "received_at": "2026-09-09T13:00:00.000Z",
      "cancel_reason": null,
      "idempotency_key": "2ab64b7d-f849-4dba-ade0-463e181ea02c",
      "created_at": "2026-09-07T13:00:00.000Z",
      "updated_at": "2026-09-09T13:00:00.000Z",
      "expires_at": "2026-09-08T13:00:00.000Z",
      "items": [
        {
          "id": "d1c2bcf8-d798-4904-b3e0-b91979d15959",
          "order_id": "d3011c8c-6e6e-40ee-8ffa-32507f6b6106",
          "product_id": "ngk-lkar7c-9-spark-plugs-4-pack",
          "name": "NGK LKAR7C-9 Spark Plugs — 4 Pack",
          "sku": "GL-0021",
          "category": "Spark Plugs",
          "quantity": 4,
          "price_cents": 6000,
          "line_total_cents": 24000
        }
      ],
      "events": [
        {
          "id": "c58212c9-b80a-4afc-bd8c-152dd8f187c5",
          "order_id": "d3011c8c-6e6e-40ee-8ffa-32507f6b6106",
          "event": "order_created",
          "actor_id": "30000000-0000-4000-8000-000000000010",
          "note": "Fictional example: inventory reserved.",
          "created_at": "2026-09-07T13:00:00.000Z"
        },
        {
          "id": "31de244b-4178-4b34-a75e-3805107bb5a4",
          "order_id": "d3011c8c-6e6e-40ee-8ffa-32507f6b6106",
          "event": "payment_submitted",
          "actor_id": "30000000-0000-4000-8000-000000000010",
          "note": "Fictional bank reference; no transfer occurred.",
          "created_at": "2026-09-07T13:10:00.000Z"
        },
        {
          "id": "c173078a-13ae-4083-9fb2-4c056bd55eeb",
          "order_id": "d3011c8c-6e6e-40ee-8ffa-32507f6b6106",
          "event": "payment_verified",
          "actor_id": "seed-worker",
          "note": "Fictional deposit verification.",
          "created_at": "2026-09-07T13:20:00.000Z"
        },
        {
          "id": "29b8745c-3119-455a-8c08-7a35b806552c",
          "order_id": "d3011c8c-6e6e-40ee-8ffa-32507f6b6106",
          "event": "shipped",
          "actor_id": "seed-worker",
          "note": "Fictional carrier and tracking number.",
          "created_at": "2026-09-08T13:00:00.000Z"
        },
        {
          "id": "54aca229-9feb-4526-a7bb-fa18477fa1f3",
          "order_id": "d3011c8c-6e6e-40ee-8ffa-32507f6b6106",
          "event": "receipt_confirmed",
          "actor_id": "30000000-0000-4000-8000-000000000010",
          "note": "Fictional buyer confirmed receipt.",
          "created_at": "2026-09-09T13:00:00.000Z"
        }
      ],
      "sample_data": true
    },
    {
      "id": "026575c2-40c2-4a56-9aeb-a95e6b1f3412",
      "order_number": 10059,
      "customer_id": "30000000-0000-4000-8000-000000000011",
      "status": "delivered",
      "payment_status": "verified",
      "address": {
        "name": "Demo Parts Shop 11",
        "phone": "0100000000",
        "line1": "Demo address — not for delivery",
        "city": "Petaling Jaya",
        "postcode": "47300",
        "state": "Selangor"
      },
      "subtotal_cents": 23200,
      "discount_cents": 0,
      "shipping_cents": 1500,
      "total_cents": 24700,
      "payment_instructions": {
        "bank_name": "DEMO — DO NOT TRANSFER",
        "bank_account_name": "FICTIONAL EXAMPLE ONLY",
        "bank_account_number": "0000000000"
      },
      "payment_reference": "SAMPLE-NO-TRANSFER-59",
      "paid_verified_by": "seed-worker",
      "payment_note": null,
      "carrier": "Demo carrier",
      "tracking_number": "DEMO-NOT-A-PARCEL-59",
      "received_at": "2026-09-08T12:00:00.000Z",
      "cancel_reason": null,
      "idempotency_key": "1bd80b7f-4f87-4a27-ae45-695495283cf8",
      "created_at": "2026-09-06T12:00:00.000Z",
      "updated_at": "2026-09-08T12:00:00.000Z",
      "expires_at": "2026-09-07T12:00:00.000Z",
      "items": [
        {
          "id": "15b479ac-9204-42ce-a7ff-d84599553622",
          "order_id": "026575c2-40c2-4a56-9aeb-a95e6b1f3412",
          "product_id": "power-up-power-steering-fluid-1l",
          "name": "Power Up Power Steering Fluid 1L",
          "sku": "GL-0026",
          "category": "Steering Fluid",
          "quantity": 8,
          "price_cents": 1400,
          "line_total_cents": 11200
        },
        {
          "id": "49a40206-445e-4133-b072-933b39131304",
          "order_id": "026575c2-40c2-4a56-9aeb-a95e6b1f3412",
          "product_id": "cabin-filter-for-perodua-myvi-alza-axia-bezza",
          "name": "Cabin Filter for Perodua Myvi / Alza / Axia / Bezza",
          "sku": "GL-0037",
          "category": "Filters",
          "quantity": 8,
          "price_cents": 1500,
          "line_total_cents": 12000
        }
      ],
      "events": [
        {
          "id": "d3941852-43f9-49b7-b0db-60b6e786cd35",
          "order_id": "026575c2-40c2-4a56-9aeb-a95e6b1f3412",
          "event": "order_created",
          "actor_id": "30000000-0000-4000-8000-000000000011",
          "note": "Fictional example: inventory reserved.",
          "created_at": "2026-09-06T12:00:00.000Z"
        },
        {
          "id": "50d83962-ffa7-4d74-ab63-132827f7abbe",
          "order_id": "026575c2-40c2-4a56-9aeb-a95e6b1f3412",
          "event": "payment_submitted",
          "actor_id": "30000000-0000-4000-8000-000000000011",
          "note": "Fictional bank reference; no transfer occurred.",
          "created_at": "2026-09-06T12:10:00.000Z"
        },
        {
          "id": "9293a770-93c8-4318-ad95-0c27368012ee",
          "order_id": "026575c2-40c2-4a56-9aeb-a95e6b1f3412",
          "event": "payment_verified",
          "actor_id": "seed-worker",
          "note": "Fictional deposit verification.",
          "created_at": "2026-09-06T12:20:00.000Z"
        },
        {
          "id": "dbecf369-86a7-4c63-ae54-110e2d052cf6",
          "order_id": "026575c2-40c2-4a56-9aeb-a95e6b1f3412",
          "event": "shipped",
          "actor_id": "seed-worker",
          "note": "Fictional carrier and tracking number.",
          "created_at": "2026-09-07T12:00:00.000Z"
        },
        {
          "id": "300ab6bf-eb7f-4603-aad6-3311c328c704",
          "order_id": "026575c2-40c2-4a56-9aeb-a95e6b1f3412",
          "event": "receipt_confirmed",
          "actor_id": "30000000-0000-4000-8000-000000000011",
          "note": "Fictional buyer confirmed receipt.",
          "created_at": "2026-09-08T12:00:00.000Z"
        }
      ],
      "sample_data": true
    },
    {
      "id": "d2d61a19-9078-4014-a5f8-c0055ac1f458",
      "order_number": 10060,
      "customer_id": "30000000-0000-4000-8000-000000000012",
      "status": "delivered",
      "payment_status": "verified",
      "address": {
        "name": "Demo Distributor 12",
        "phone": "0100000000",
        "line1": "Demo address — not for delivery",
        "city": "Petaling Jaya",
        "postcode": "47300",
        "state": "Selangor"
      },
      "subtotal_cents": 244800,
      "discount_cents": 0,
      "shipping_cents": 0,
      "total_cents": 244800,
      "payment_instructions": {
        "bank_name": "DEMO — DO NOT TRANSFER",
        "bank_account_name": "FICTIONAL EXAMPLE ONLY",
        "bank_account_number": "0000000000"
      },
      "payment_reference": "SAMPLE-NO-TRANSFER-60",
      "paid_verified_by": "seed-worker",
      "payment_note": null,
      "carrier": "Demo carrier",
      "tracking_number": "DEMO-NOT-A-PARCEL-60",
      "received_at": "2026-09-07T13:00:00.000Z",
      "cancel_reason": null,
      "idempotency_key": "e2d480bf-e2fd-4598-8d86-66365c1ae419",
      "created_at": "2026-09-05T13:00:00.000Z",
      "updated_at": "2026-09-07T13:00:00.000Z",
      "expires_at": "2026-09-06T13:00:00.000Z",
      "items": [
        {
          "id": "cd98ba54-84d7-4415-8a0d-494802f59eef",
          "order_id": "d2d61a19-9078-4014-a5f8-c0055ac1f458",
          "product_id": "trw-gdb7986-front-brake-pads",
          "name": "TRW GDB7986 Front Brake Pads",
          "sku": "GL-0045",
          "category": "Brake Pads",
          "quantity": 17,
          "price_cents": 7700,
          "line_total_cents": 130900
        },
        {
          "id": "15734524-b8bf-4aa9-820e-be5e8808fa2b",
          "order_id": "d2d61a19-9078-4014-a5f8-c0055ac1f458",
          "product_id": "bardahl-10w-30-engine-oil-3-quarts",
          "name": "Bardahl 10W-30 Engine Oil 3 Quarts",
          "sku": "GL-0029",
          "category": "Engine Oil",
          "quantity": 17,
          "price_cents": 5200,
          "line_total_cents": 88400
        },
        {
          "id": "35333439-0c2b-4d5b-8dcd-361b692125aa",
          "order_id": "d2d61a19-9078-4014-a5f8-c0055ac1f458",
          "product_id": "manual-gear-oil-ep-140-1l",
          "name": "Manual Gear Oil EP 140 1L",
          "sku": "GL-0016",
          "category": "Transmission Fluid",
          "quantity": 17,
          "price_cents": 1500,
          "line_total_cents": 25500
        }
      ],
      "events": [
        {
          "id": "eb9ea64e-acc1-4432-8e76-accbb7623a14",
          "order_id": "d2d61a19-9078-4014-a5f8-c0055ac1f458",
          "event": "order_created",
          "actor_id": "30000000-0000-4000-8000-000000000012",
          "note": "Fictional example: inventory reserved.",
          "created_at": "2026-09-05T13:00:00.000Z"
        },
        {
          "id": "517a428a-a444-4c15-ac07-874378aa085c",
          "order_id": "d2d61a19-9078-4014-a5f8-c0055ac1f458",
          "event": "payment_submitted",
          "actor_id": "30000000-0000-4000-8000-000000000012",
          "note": "Fictional bank reference; no transfer occurred.",
          "created_at": "2026-09-05T13:10:00.000Z"
        },
        {
          "id": "0a8ce55d-944e-4482-923f-eb6bbb3c3b5c",
          "order_id": "d2d61a19-9078-4014-a5f8-c0055ac1f458",
          "event": "payment_verified",
          "actor_id": "seed-worker",
          "note": "Fictional deposit verification.",
          "created_at": "2026-09-05T13:20:00.000Z"
        },
        {
          "id": "dcf13c66-6523-45e3-9874-5baa231225f2",
          "order_id": "d2d61a19-9078-4014-a5f8-c0055ac1f458",
          "event": "shipped",
          "actor_id": "seed-worker",
          "note": "Fictional carrier and tracking number.",
          "created_at": "2026-09-06T13:00:00.000Z"
        },
        {
          "id": "369dd035-0e31-4c3d-a9e9-b7aa3beb1ecc",
          "order_id": "d2d61a19-9078-4014-a5f8-c0055ac1f458",
          "event": "receipt_confirmed",
          "actor_id": "30000000-0000-4000-8000-000000000012",
          "note": "Fictional buyer confirmed receipt.",
          "created_at": "2026-09-07T13:00:00.000Z"
        }
      ],
      "sample_data": true
    },
    {
      "id": "b86702d2-9f3a-46ba-8ce4-4dc8dab0d7e3",
      "order_number": 10061,
      "customer_id": "30000000-0000-4000-8000-000000000001",
      "status": "delivered",
      "payment_status": "verified",
      "address": {
        "name": "Demo Motorist 01",
        "phone": "0100000000",
        "line1": "Demo address — not for delivery",
        "city": "Petaling Jaya",
        "postcode": "47300",
        "state": "Selangor"
      },
      "subtotal_cents": 5200,
      "discount_cents": 0,
      "shipping_cents": 1500,
      "total_cents": 6700,
      "payment_instructions": {
        "bank_name": "DEMO — DO NOT TRANSFER",
        "bank_account_name": "FICTIONAL EXAMPLE ONLY",
        "bank_account_number": "0000000000"
      },
      "payment_reference": "SAMPLE-NO-TRANSFER-61",
      "paid_verified_by": "seed-worker",
      "payment_note": null,
      "carrier": "Demo carrier",
      "tracking_number": "DEMO-NOT-A-PARCEL-61",
      "received_at": "2026-09-06T01:00:00.000Z",
      "cancel_reason": null,
      "idempotency_key": "0dc0376a-2d39-4169-86ef-be833197d502",
      "created_at": "2026-09-04T01:00:00.000Z",
      "updated_at": "2026-09-06T01:00:00.000Z",
      "expires_at": "2026-09-05T01:00:00.000Z",
      "items": [
        {
          "id": "0839705e-c883-4736-b06d-d0e3f7d6f66a",
          "order_id": "b86702d2-9f3a-46ba-8ce4-4dc8dab0d7e3",
          "product_id": "bardahl-10w-30-engine-oil-3-quarts",
          "name": "Bardahl 10W-30 Engine Oil 3 Quarts",
          "sku": "GL-0029",
          "category": "Engine Oil",
          "quantity": 1,
          "price_cents": 5200,
          "line_total_cents": 5200
        }
      ],
      "events": [
        {
          "id": "4caa66c3-ddd9-4e3c-a113-7f65ccba3847",
          "order_id": "b86702d2-9f3a-46ba-8ce4-4dc8dab0d7e3",
          "event": "order_created",
          "actor_id": "30000000-0000-4000-8000-000000000001",
          "note": "Fictional example: inventory reserved.",
          "created_at": "2026-09-04T01:00:00.000Z"
        },
        {
          "id": "75e0fafb-995a-48c2-8496-e6279d176c7d",
          "order_id": "b86702d2-9f3a-46ba-8ce4-4dc8dab0d7e3",
          "event": "payment_submitted",
          "actor_id": "30000000-0000-4000-8000-000000000001",
          "note": "Fictional bank reference; no transfer occurred.",
          "created_at": "2026-09-04T01:10:00.000Z"
        },
        {
          "id": "60bcc966-e9d2-4ab3-9cc8-c2e4ea40a042",
          "order_id": "b86702d2-9f3a-46ba-8ce4-4dc8dab0d7e3",
          "event": "payment_verified",
          "actor_id": "seed-worker",
          "note": "Fictional deposit verification.",
          "created_at": "2026-09-04T01:20:00.000Z"
        },
        {
          "id": "59b06e96-611f-40e6-886f-4ffe66b87070",
          "order_id": "b86702d2-9f3a-46ba-8ce4-4dc8dab0d7e3",
          "event": "shipped",
          "actor_id": "seed-worker",
          "note": "Fictional carrier and tracking number.",
          "created_at": "2026-09-05T01:00:00.000Z"
        },
        {
          "id": "7996d68c-46d2-4aab-adbd-fb94f03ea7f0",
          "order_id": "b86702d2-9f3a-46ba-8ce4-4dc8dab0d7e3",
          "event": "receipt_confirmed",
          "actor_id": "30000000-0000-4000-8000-000000000001",
          "note": "Fictional buyer confirmed receipt.",
          "created_at": "2026-09-06T01:00:00.000Z"
        }
      ],
      "sample_data": true
    },
    {
      "id": "9f83a097-a7c4-4ec1-a544-1b385935c1c6",
      "order_number": 10062,
      "customer_id": "30000000-0000-4000-8000-000000000002",
      "status": "delivered",
      "payment_status": "verified",
      "address": {
        "name": "Demo Workshop 02",
        "phone": "0100000000",
        "line1": "Demo address — not for delivery",
        "city": "Petaling Jaya",
        "postcode": "47300",
        "state": "Selangor"
      },
      "subtotal_cents": 21200,
      "discount_cents": 0,
      "shipping_cents": 1500,
      "total_cents": 22700,
      "payment_instructions": {
        "bank_name": "DEMO — DO NOT TRANSFER",
        "bank_account_name": "FICTIONAL EXAMPLE ONLY",
        "bank_account_number": "0000000000"
      },
      "payment_reference": "SAMPLE-NO-TRANSFER-62",
      "paid_verified_by": "seed-worker",
      "payment_note": null,
      "carrier": "Demo carrier",
      "tracking_number": "DEMO-NOT-A-PARCEL-62",
      "received_at": "2026-09-05T02:00:00.000Z",
      "cancel_reason": null,
      "idempotency_key": "d23e6a90-ab1f-4642-ae19-43712cfb15dc",
      "created_at": "2026-09-03T02:00:00.000Z",
      "updated_at": "2026-09-05T02:00:00.000Z",
      "expires_at": "2026-09-04T02:00:00.000Z",
      "items": [
        {
          "id": "d0c0286a-cc31-4fc0-87cd-ab1ded454558",
          "order_id": "9f83a097-a7c4-4ec1-a544-1b385935c1c6",
          "product_id": "cabin-filter-for-proton-x50",
          "name": "Cabin Filter for Proton X50",
          "sku": "GL-0009",
          "category": "Filters",
          "quantity": 4,
          "price_cents": 2500,
          "line_total_cents": 10000
        },
        {
          "id": "96061975-e192-4eed-b751-22183f18f6ef",
          "order_id": "9f83a097-a7c4-4ec1-a544-1b385935c1c6",
          "product_id": "petrol-filter-for-proton-iriz-saga-vvt-persona-vvt",
          "name": "Petrol Filter for Proton Iriz / Saga VVT / Persona VVT",
          "sku": "GL-0017",
          "category": "Filters",
          "quantity": 4,
          "price_cents": 2800,
          "line_total_cents": 11200
        }
      ],
      "events": [
        {
          "id": "023e1b33-6f61-4ef0-a94d-bcd66075b814",
          "order_id": "9f83a097-a7c4-4ec1-a544-1b385935c1c6",
          "event": "order_created",
          "actor_id": "30000000-0000-4000-8000-000000000002",
          "note": "Fictional example: inventory reserved.",
          "created_at": "2026-09-03T02:00:00.000Z"
        },
        {
          "id": "ea0d2222-c950-4492-87b4-73d316de2ca3",
          "order_id": "9f83a097-a7c4-4ec1-a544-1b385935c1c6",
          "event": "payment_submitted",
          "actor_id": "30000000-0000-4000-8000-000000000002",
          "note": "Fictional bank reference; no transfer occurred.",
          "created_at": "2026-09-03T02:10:00.000Z"
        },
        {
          "id": "47635b00-88b3-4a22-b4ce-4680158009f3",
          "order_id": "9f83a097-a7c4-4ec1-a544-1b385935c1c6",
          "event": "payment_verified",
          "actor_id": "seed-worker",
          "note": "Fictional deposit verification.",
          "created_at": "2026-09-03T02:20:00.000Z"
        },
        {
          "id": "d8a9b011-249a-45da-94ba-5b0da07d596f",
          "order_id": "9f83a097-a7c4-4ec1-a544-1b385935c1c6",
          "event": "shipped",
          "actor_id": "seed-worker",
          "note": "Fictional carrier and tracking number.",
          "created_at": "2026-09-04T02:00:00.000Z"
        },
        {
          "id": "e049486b-e43b-4e36-9276-ba4a3c60c20d",
          "order_id": "9f83a097-a7c4-4ec1-a544-1b385935c1c6",
          "event": "receipt_confirmed",
          "actor_id": "30000000-0000-4000-8000-000000000002",
          "note": "Fictional buyer confirmed receipt.",
          "created_at": "2026-09-05T02:00:00.000Z"
        }
      ],
      "sample_data": true
    },
    {
      "id": "a730ea21-4c1b-411a-ae7e-f6a871861127",
      "order_number": 10063,
      "customer_id": "30000000-0000-4000-8000-000000000003",
      "status": "delivered",
      "payment_status": "verified",
      "address": {
        "name": "Demo Parts Shop 03",
        "phone": "0100000000",
        "line1": "Demo address — not for delivery",
        "city": "Petaling Jaya",
        "postcode": "47300",
        "state": "Selangor"
      },
      "subtotal_cents": 153600,
      "discount_cents": 0,
      "shipping_cents": 0,
      "total_cents": 153600,
      "payment_instructions": {
        "bank_name": "DEMO — DO NOT TRANSFER",
        "bank_account_name": "FICTIONAL EXAMPLE ONLY",
        "bank_account_number": "0000000000"
      },
      "payment_reference": "SAMPLE-NO-TRANSFER-63",
      "paid_verified_by": "seed-worker",
      "payment_note": null,
      "carrier": "Demo carrier",
      "tracking_number": "DEMO-NOT-A-PARCEL-63",
      "received_at": "2026-09-04T03:00:00.000Z",
      "cancel_reason": null,
      "idempotency_key": "4a89b0ff-785a-4277-b9af-ac682e53cd45",
      "created_at": "2026-09-02T03:00:00.000Z",
      "updated_at": "2026-09-04T03:00:00.000Z",
      "expires_at": "2026-09-03T03:00:00.000Z",
      "items": [
        {
          "id": "487d7e75-e9c5-4094-8f7e-c6c798c675c0",
          "order_id": "a730ea21-4c1b-411a-ae7e-f6a871861127",
          "product_id": "castrol-gtx-10w-30-engine-oil-3l",
          "name": "Castrol GTX 10W-30 Engine Oil 3L",
          "sku": "GL-0031",
          "category": "Engine Oil",
          "quantity": 12,
          "price_cents": 5000,
          "line_total_cents": 60000
        },
        {
          "id": "16b3676e-7be8-434a-a3b4-2c4da1a75e99",
          "order_id": "a730ea21-4c1b-411a-ae7e-f6a871861127",
          "product_id": "petrol-filter-for-proton-iriz-saga-vvt-persona-vvt",
          "name": "Petrol Filter for Proton Iriz / Saga VVT / Persona VVT",
          "sku": "GL-0017",
          "category": "Filters",
          "quantity": 12,
          "price_cents": 2800,
          "line_total_cents": 33600
        },
        {
          "id": "86fca8d7-5f06-40a4-8bb9-603ec783cf25",
          "order_id": "a730ea21-4c1b-411a-ae7e-f6a871861127",
          "product_id": "manual-gear-oil-80w-90-4l",
          "name": "Manual Gear Oil 80W-90 4L",
          "sku": "GL-0015",
          "category": "Transmission Fluid",
          "quantity": 12,
          "price_cents": 5000,
          "line_total_cents": 60000
        }
      ],
      "events": [
        {
          "id": "344422f0-6a2d-4064-9d57-474c5cefbe3d",
          "order_id": "a730ea21-4c1b-411a-ae7e-f6a871861127",
          "event": "order_created",
          "actor_id": "30000000-0000-4000-8000-000000000003",
          "note": "Fictional example: inventory reserved.",
          "created_at": "2026-09-02T03:00:00.000Z"
        },
        {
          "id": "19ea69fc-f49a-48ce-b24e-6ff6e8b9a6cb",
          "order_id": "a730ea21-4c1b-411a-ae7e-f6a871861127",
          "event": "payment_submitted",
          "actor_id": "30000000-0000-4000-8000-000000000003",
          "note": "Fictional bank reference; no transfer occurred.",
          "created_at": "2026-09-02T03:10:00.000Z"
        },
        {
          "id": "1a1812b6-92e4-4e79-8286-44228f431de3",
          "order_id": "a730ea21-4c1b-411a-ae7e-f6a871861127",
          "event": "payment_verified",
          "actor_id": "seed-worker",
          "note": "Fictional deposit verification.",
          "created_at": "2026-09-02T03:20:00.000Z"
        },
        {
          "id": "b2bd8cb5-9c9c-483f-9e31-d37a1919434e",
          "order_id": "a730ea21-4c1b-411a-ae7e-f6a871861127",
          "event": "shipped",
          "actor_id": "seed-worker",
          "note": "Fictional carrier and tracking number.",
          "created_at": "2026-09-03T03:00:00.000Z"
        },
        {
          "id": "09d1032d-03f2-47cb-892e-7db09170644a",
          "order_id": "a730ea21-4c1b-411a-ae7e-f6a871861127",
          "event": "receipt_confirmed",
          "actor_id": "30000000-0000-4000-8000-000000000003",
          "note": "Fictional buyer confirmed receipt.",
          "created_at": "2026-09-04T03:00:00.000Z"
        }
      ],
      "sample_data": true
    },
    {
      "id": "35e85220-18d7-453f-a05f-b099b799399a",
      "order_number": 10064,
      "customer_id": "30000000-0000-4000-8000-000000000004",
      "status": "delivered",
      "payment_status": "verified",
      "address": {
        "name": "Demo Distributor 04",
        "phone": "0100000000",
        "line1": "Demo address — not for delivery",
        "city": "Petaling Jaya",
        "postcode": "47300",
        "state": "Selangor"
      },
      "subtotal_cents": 45600,
      "discount_cents": 0,
      "shipping_cents": 0,
      "total_cents": 45600,
      "payment_instructions": {
        "bank_name": "DEMO — DO NOT TRANSFER",
        "bank_account_name": "FICTIONAL EXAMPLE ONLY",
        "bank_account_number": "0000000000"
      },
      "payment_reference": "SAMPLE-NO-TRANSFER-64",
      "paid_verified_by": "seed-worker",
      "payment_note": null,
      "carrier": "Demo carrier",
      "tracking_number": "DEMO-NOT-A-PARCEL-64",
      "received_at": "2026-09-03T05:00:00.000Z",
      "cancel_reason": null,
      "idempotency_key": "efdf0f52-9d33-4cc4-acba-e50c93e4ee21",
      "created_at": "2026-09-01T05:00:00.000Z",
      "updated_at": "2026-09-03T05:00:00.000Z",
      "expires_at": "2026-09-02T05:00:00.000Z",
      "items": [
        {
          "id": "bcf50858-e7e8-4059-8846-be314c8cf9c5",
          "order_id": "35e85220-18d7-453f-a05f-b099b799399a",
          "product_id": "front-brake-pads-for-proton-gen-2-persona-neo",
          "name": "Front Brake Pads for Proton Gen 2 / Persona / Neo",
          "sku": "GL-0042",
          "category": "Brake Pads",
          "quantity": 12,
          "price_cents": 3800,
          "line_total_cents": 45600
        }
      ],
      "events": [
        {
          "id": "b7550abb-788a-4db5-b07d-66aaa0fd3469",
          "order_id": "35e85220-18d7-453f-a05f-b099b799399a",
          "event": "order_created",
          "actor_id": "30000000-0000-4000-8000-000000000004",
          "note": "Fictional example: inventory reserved.",
          "created_at": "2026-09-01T05:00:00.000Z"
        },
        {
          "id": "4aceb1c3-f71c-4ef5-9a3b-399a814b8999",
          "order_id": "35e85220-18d7-453f-a05f-b099b799399a",
          "event": "payment_submitted",
          "actor_id": "30000000-0000-4000-8000-000000000004",
          "note": "Fictional bank reference; no transfer occurred.",
          "created_at": "2026-09-01T05:10:00.000Z"
        },
        {
          "id": "798a5182-5785-4383-9c68-8486f9d7320b",
          "order_id": "35e85220-18d7-453f-a05f-b099b799399a",
          "event": "payment_verified",
          "actor_id": "seed-worker",
          "note": "Fictional deposit verification.",
          "created_at": "2026-09-01T05:20:00.000Z"
        },
        {
          "id": "f63fa649-c37d-4f0d-8b8d-797680ddc0df",
          "order_id": "35e85220-18d7-453f-a05f-b099b799399a",
          "event": "shipped",
          "actor_id": "seed-worker",
          "note": "Fictional carrier and tracking number.",
          "created_at": "2026-09-02T05:00:00.000Z"
        },
        {
          "id": "5b340945-3b6d-4c3e-a593-9cc871abade9",
          "order_id": "35e85220-18d7-453f-a05f-b099b799399a",
          "event": "receipt_confirmed",
          "actor_id": "30000000-0000-4000-8000-000000000004",
          "note": "Fictional buyer confirmed receipt.",
          "created_at": "2026-09-03T05:00:00.000Z"
        }
      ],
      "sample_data": true
    },
    {
      "id": "34ec037f-2253-4a6e-86df-b492ed6e45dd",
      "order_number": 10065,
      "customer_id": "30000000-0000-4000-8000-000000000005",
      "status": "delivered",
      "payment_status": "verified",
      "address": {
        "name": "Demo Motorist 05",
        "phone": "0100000000",
        "line1": "Demo address — not for delivery",
        "city": "Petaling Jaya",
        "postcode": "47300",
        "state": "Selangor"
      },
      "subtotal_cents": 5000,
      "discount_cents": 0,
      "shipping_cents": 1500,
      "total_cents": 6500,
      "payment_instructions": {
        "bank_name": "DEMO — DO NOT TRANSFER",
        "bank_account_name": "FICTIONAL EXAMPLE ONLY",
        "bank_account_number": "0000000000"
      },
      "payment_reference": "SAMPLE-NO-TRANSFER-65",
      "paid_verified_by": "seed-worker",
      "payment_note": null,
      "carrier": "Demo carrier",
      "tracking_number": "DEMO-NOT-A-PARCEL-65",
      "received_at": "2026-09-02T06:00:00.000Z",
      "cancel_reason": null,
      "idempotency_key": "1e566b3a-d1a6-460f-9417-3a9845e40d7d",
      "created_at": "2026-08-31T06:00:00.000Z",
      "updated_at": "2026-09-02T06:00:00.000Z",
      "expires_at": "2026-09-01T06:00:00.000Z",
      "items": [
        {
          "id": "82af77d6-e87c-438b-950b-0e05d72efe15",
          "order_id": "34ec037f-2253-4a6e-86df-b492ed6e45dd",
          "product_id": "petrol-filter-for-proton-iriz-saga-vvt-persona-vvt",
          "name": "Petrol Filter for Proton Iriz / Saga VVT / Persona VVT",
          "sku": "GL-0017",
          "category": "Filters",
          "quantity": 1,
          "price_cents": 2800,
          "line_total_cents": 2800
        },
        {
          "id": "fb710076-3273-491e-8ad2-b1411fca48db",
          "order_id": "34ec037f-2253-4a6e-86df-b492ed6e45dd",
          "product_id": "bendix-dot-4-brake-and-clutch-fluid-1l",
          "name": "Bendix DOT 4 Brake and Clutch Fluid 1L",
          "sku": "GL-0003",
          "category": "Brake Fluid",
          "quantity": 1,
          "price_cents": 2200,
          "line_total_cents": 2200
        }
      ],
      "events": [
        {
          "id": "4c96b809-dfea-4770-9e2d-8a767bd0714c",
          "order_id": "34ec037f-2253-4a6e-86df-b492ed6e45dd",
          "event": "order_created",
          "actor_id": "30000000-0000-4000-8000-000000000005",
          "note": "Fictional example: inventory reserved.",
          "created_at": "2026-08-31T06:00:00.000Z"
        },
        {
          "id": "63aa26ad-7a2f-4d31-a0e6-47649fb31706",
          "order_id": "34ec037f-2253-4a6e-86df-b492ed6e45dd",
          "event": "payment_submitted",
          "actor_id": "30000000-0000-4000-8000-000000000005",
          "note": "Fictional bank reference; no transfer occurred.",
          "created_at": "2026-08-31T06:10:00.000Z"
        },
        {
          "id": "21554bd2-c91a-4ae6-931f-42adf050eed3",
          "order_id": "34ec037f-2253-4a6e-86df-b492ed6e45dd",
          "event": "payment_verified",
          "actor_id": "seed-worker",
          "note": "Fictional deposit verification.",
          "created_at": "2026-08-31T06:20:00.000Z"
        },
        {
          "id": "85c700e2-ce71-4ad7-96a2-02bb9f94f331",
          "order_id": "34ec037f-2253-4a6e-86df-b492ed6e45dd",
          "event": "shipped",
          "actor_id": "seed-worker",
          "note": "Fictional carrier and tracking number.",
          "created_at": "2026-09-01T06:00:00.000Z"
        },
        {
          "id": "0775036d-aff7-46ff-a193-5f188708fc10",
          "order_id": "34ec037f-2253-4a6e-86df-b492ed6e45dd",
          "event": "receipt_confirmed",
          "actor_id": "30000000-0000-4000-8000-000000000005",
          "note": "Fictional buyer confirmed receipt.",
          "created_at": "2026-09-02T06:00:00.000Z"
        }
      ],
      "sample_data": true
    },
    {
      "id": "6094dea7-ae00-4d0f-9740-9facc1b970e2",
      "order_number": 10066,
      "customer_id": "30000000-0000-4000-8000-000000000006",
      "status": "cancelled",
      "payment_status": "awaiting",
      "address": {
        "name": "Demo Workshop 06",
        "phone": "0100000000",
        "line1": "Demo address — not for delivery",
        "city": "Petaling Jaya",
        "postcode": "47300",
        "state": "Selangor"
      },
      "subtotal_cents": 68000,
      "discount_cents": 0,
      "shipping_cents": 0,
      "total_cents": 68000,
      "payment_instructions": {
        "bank_name": "DEMO — DO NOT TRANSFER",
        "bank_account_name": "FICTIONAL EXAMPLE ONLY",
        "bank_account_number": "0000000000"
      },
      "payment_reference": null,
      "paid_verified_by": null,
      "payment_note": null,
      "carrier": null,
      "tracking_number": null,
      "received_at": null,
      "cancel_reason": "Example customer changed their mind.",
      "idempotency_key": "baf748d4-c35e-4c46-8797-dd37741eccf9",
      "created_at": "2026-08-30T10:00:00.000Z",
      "updated_at": "2026-08-30T10:30:00.000Z",
      "expires_at": "2026-08-31T10:00:00.000Z",
      "items": [
        {
          "id": "92e81e0c-613e-422d-b9d2-a854e7a56134",
          "order_id": "6094dea7-ae00-4d0f-9740-9facc1b970e2",
          "product_id": "denso-k20tnr-s-spark-plugs-4-pack",
          "name": "Denso K20TNR-S Spark Plugs — 4 Pack",
          "sku": "GL-0018",
          "category": "Spark Plugs",
          "quantity": 4,
          "price_cents": 5500,
          "line_total_cents": 22000
        },
        {
          "id": "f49864c0-cd34-4f0e-a0df-3c1530f48ff5",
          "order_id": "6094dea7-ae00-4d0f-9740-9facc1b970e2",
          "product_id": "castrol-140-manual-gear-oil-4l",
          "name": "Castrol 140 Manual Gear Oil 4L",
          "sku": "GL-0023",
          "category": "Transmission Fluid",
          "quantity": 4,
          "price_cents": 7500,
          "line_total_cents": 30000
        },
        {
          "id": "e8212910-2921-4a8a-88b1-ad69c1a99f75",
          "order_id": "6094dea7-ae00-4d0f-9740-9facc1b970e2",
          "product_id": "aftermarket-engine-oil-filters-10-pack",
          "name": "Aftermarket Engine Oil Filters — 10 Pack",
          "sku": "GL-0019",
          "category": "Filters",
          "quantity": 4,
          "price_cents": 4000,
          "line_total_cents": 16000
        }
      ],
      "events": [
        {
          "id": "d55a5edb-a312-475e-b7f4-989a1461e270",
          "order_id": "6094dea7-ae00-4d0f-9740-9facc1b970e2",
          "event": "order_created",
          "actor_id": "30000000-0000-4000-8000-000000000006",
          "note": "Fictional example: inventory reserved.",
          "created_at": "2026-08-30T10:00:00.000Z"
        },
        {
          "id": "9ce5d3fa-82be-4240-ada8-faef5012ac2c",
          "order_id": "6094dea7-ae00-4d0f-9740-9facc1b970e2",
          "event": "cancelled",
          "actor_id": "30000000-0000-4000-8000-000000000006",
          "note": "Fictional unpaid cancellation; reserved inventory restored.",
          "created_at": "2026-08-30T10:30:00.000Z"
        }
      ],
      "sample_data": true
    },
    {
      "id": "0183bed5-088c-42e1-8ee5-e78a8a07de32",
      "order_number": 10067,
      "customer_id": "30000000-0000-4000-8000-000000000007",
      "status": "delivered",
      "payment_status": "verified",
      "address": {
        "name": "Demo Parts Shop 07",
        "phone": "0100000000",
        "line1": "Demo address — not for delivery",
        "city": "Petaling Jaya",
        "postcode": "47300",
        "state": "Selangor"
      },
      "subtotal_cents": 117000,
      "discount_cents": 0,
      "shipping_cents": 0,
      "total_cents": 117000,
      "payment_instructions": {
        "bank_name": "DEMO — DO NOT TRANSFER",
        "bank_account_name": "FICTIONAL EXAMPLE ONLY",
        "bank_account_number": "0000000000"
      },
      "payment_reference": "SAMPLE-NO-TRANSFER-67",
      "paid_verified_by": "seed-worker",
      "payment_note": null,
      "carrier": "Demo carrier",
      "tracking_number": "DEMO-NOT-A-PARCEL-67",
      "received_at": "2026-08-31T12:00:00.000Z",
      "cancel_reason": null,
      "idempotency_key": "e1b8bd95-4fdf-442b-ac8a-4c4b462ab40d",
      "created_at": "2026-08-29T12:00:00.000Z",
      "updated_at": "2026-08-31T12:00:00.000Z",
      "expires_at": "2026-08-30T12:00:00.000Z",
      "items": [
        {
          "id": "fb4082bf-6e81-4db0-9fc7-c622c2149e43",
          "order_id": "0183bed5-088c-42e1-8ee5-e78a8a07de32",
          "product_id": "toyota-fully-synthetic-0w-20-engine-oil-4l",
          "name": "Toyota Fully Synthetic 0W-20 Engine Oil 4L",
          "sku": "GL-0001",
          "category": "Engine Oil",
          "quantity": 9,
          "price_cents": 13000,
          "line_total_cents": 117000
        }
      ],
      "events": [
        {
          "id": "109dea52-adf8-4f01-a65c-30c0bc8f420a",
          "order_id": "0183bed5-088c-42e1-8ee5-e78a8a07de32",
          "event": "order_created",
          "actor_id": "30000000-0000-4000-8000-000000000007",
          "note": "Fictional example: inventory reserved.",
          "created_at": "2026-08-29T12:00:00.000Z"
        },
        {
          "id": "8e1f9ee9-5a06-4804-bec6-41fcf29ea869",
          "order_id": "0183bed5-088c-42e1-8ee5-e78a8a07de32",
          "event": "payment_submitted",
          "actor_id": "30000000-0000-4000-8000-000000000007",
          "note": "Fictional bank reference; no transfer occurred.",
          "created_at": "2026-08-29T12:10:00.000Z"
        },
        {
          "id": "6d785628-d4b9-45f6-a8f1-5f5ffe6a17d7",
          "order_id": "0183bed5-088c-42e1-8ee5-e78a8a07de32",
          "event": "payment_verified",
          "actor_id": "seed-worker",
          "note": "Fictional deposit verification.",
          "created_at": "2026-08-29T12:20:00.000Z"
        },
        {
          "id": "e7430f5c-2c15-41e0-ad41-7a9b510731a1",
          "order_id": "0183bed5-088c-42e1-8ee5-e78a8a07de32",
          "event": "shipped",
          "actor_id": "seed-worker",
          "note": "Fictional carrier and tracking number.",
          "created_at": "2026-08-30T12:00:00.000Z"
        },
        {
          "id": "dd80735b-9a58-4ad6-8149-eb24a513b189",
          "order_id": "0183bed5-088c-42e1-8ee5-e78a8a07de32",
          "event": "receipt_confirmed",
          "actor_id": "30000000-0000-4000-8000-000000000007",
          "note": "Fictional buyer confirmed receipt.",
          "created_at": "2026-08-31T12:00:00.000Z"
        }
      ],
      "sample_data": true
    },
    {
      "id": "df43d4ff-bd2b-46fe-aa93-8569acaeffca",
      "order_number": 10068,
      "customer_id": "30000000-0000-4000-8000-000000000008",
      "status": "delivered",
      "payment_status": "verified",
      "address": {
        "name": "Demo Distributor 08",
        "phone": "0100000000",
        "line1": "Demo address — not for delivery",
        "city": "Petaling Jaya",
        "postcode": "47300",
        "state": "Selangor"
      },
      "subtotal_cents": 75200,
      "discount_cents": 0,
      "shipping_cents": 0,
      "total_cents": 75200,
      "payment_instructions": {
        "bank_name": "DEMO — DO NOT TRANSFER",
        "bank_account_name": "FICTIONAL EXAMPLE ONLY",
        "bank_account_number": "0000000000"
      },
      "payment_reference": "SAMPLE-NO-TRANSFER-68",
      "paid_verified_by": "seed-worker",
      "payment_note": null,
      "carrier": "Demo carrier",
      "tracking_number": "DEMO-NOT-A-PARCEL-68",
      "received_at": "2026-08-30T13:00:00.000Z",
      "cancel_reason": null,
      "idempotency_key": "a7acabd7-6ca5-42e3-85dc-cb5a026911c5",
      "created_at": "2026-08-28T13:00:00.000Z",
      "updated_at": "2026-08-30T13:00:00.000Z",
      "expires_at": "2026-08-29T13:00:00.000Z",
      "items": [
        {
          "id": "692b00b3-5d0f-4cbc-a2ab-d27c5e6c4203",
          "order_id": "df43d4ff-bd2b-46fe-aa93-8569acaeffca",
          "product_id": "bendix-dot-4-brake-and-clutch-fluid-1l",
          "name": "Bendix DOT 4 Brake and Clutch Fluid 1L",
          "sku": "GL-0003",
          "category": "Brake Fluid",
          "quantity": 16,
          "price_cents": 2200,
          "line_total_cents": 35200
        },
        {
          "id": "f080aab4-0933-4d85-9a21-37eee82001a8",
          "order_id": "df43d4ff-bd2b-46fe-aa93-8569acaeffca",
          "product_id": "perodua-radiator-coolant-1l",
          "name": "Perodua Radiator Coolant 1L",
          "sku": "GL-0024",
          "category": "Coolant",
          "quantity": 16,
          "price_cents": 2500,
          "line_total_cents": 40000
        }
      ],
      "events": [
        {
          "id": "3a657258-697a-4325-9ead-5069809a10e7",
          "order_id": "df43d4ff-bd2b-46fe-aa93-8569acaeffca",
          "event": "order_created",
          "actor_id": "30000000-0000-4000-8000-000000000008",
          "note": "Fictional example: inventory reserved.",
          "created_at": "2026-08-28T13:00:00.000Z"
        },
        {
          "id": "2b380853-9519-4b0d-bb7d-fbafd5daad08",
          "order_id": "df43d4ff-bd2b-46fe-aa93-8569acaeffca",
          "event": "payment_submitted",
          "actor_id": "30000000-0000-4000-8000-000000000008",
          "note": "Fictional bank reference; no transfer occurred.",
          "created_at": "2026-08-28T13:10:00.000Z"
        },
        {
          "id": "abf1e25e-85d3-4271-9e5e-e46d94e38440",
          "order_id": "df43d4ff-bd2b-46fe-aa93-8569acaeffca",
          "event": "payment_verified",
          "actor_id": "seed-worker",
          "note": "Fictional deposit verification.",
          "created_at": "2026-08-28T13:20:00.000Z"
        },
        {
          "id": "5b108633-61c1-4e66-bbfa-e9c059ba7fbb",
          "order_id": "df43d4ff-bd2b-46fe-aa93-8569acaeffca",
          "event": "shipped",
          "actor_id": "seed-worker",
          "note": "Fictional carrier and tracking number.",
          "created_at": "2026-08-29T13:00:00.000Z"
        },
        {
          "id": "bec63c91-d14f-4227-b265-c230a842d5aa",
          "order_id": "df43d4ff-bd2b-46fe-aa93-8569acaeffca",
          "event": "receipt_confirmed",
          "actor_id": "30000000-0000-4000-8000-000000000008",
          "note": "Fictional buyer confirmed receipt.",
          "created_at": "2026-08-30T13:00:00.000Z"
        }
      ],
      "sample_data": true
    },
    {
      "id": "c12d5bc2-9b0b-45f7-9ef7-124b09a467be",
      "order_number": 10069,
      "customer_id": "30000000-0000-4000-8000-000000000009",
      "status": "cancelled",
      "payment_status": "refunded",
      "address": {
        "name": "Demo Motorist 09",
        "phone": "0100000000",
        "line1": "Demo address — not for delivery",
        "city": "Petaling Jaya",
        "postcode": "47300",
        "state": "Selangor"
      },
      "subtotal_cents": 6600,
      "discount_cents": 0,
      "shipping_cents": 1500,
      "total_cents": 8100,
      "payment_instructions": {
        "bank_name": "DEMO — DO NOT TRANSFER",
        "bank_account_name": "FICTIONAL EXAMPLE ONLY",
        "bank_account_number": "0000000000"
      },
      "payment_reference": "SAMPLE-NO-TRANSFER-69",
      "paid_verified_by": "seed-worker",
      "payment_note": null,
      "carrier": "Demo carrier",
      "tracking_number": "DEMO-NOT-A-PARCEL-69",
      "received_at": "2026-08-29T12:00:00.000Z",
      "cancel_reason": null,
      "idempotency_key": "0cf1eff8-01de-4b34-bf8c-0bb1f6fe3cce",
      "created_at": "2026-08-27T12:00:00.000Z",
      "updated_at": "2026-08-30T12:00:00.000Z",
      "expires_at": "2026-08-28T12:00:00.000Z",
      "items": [
        {
          "id": "4df3e7e1-4d5f-40fa-a5cb-4a645a2f0e1e",
          "order_id": "c12d5bc2-9b0b-45f7-9ef7-124b09a467be",
          "product_id": "dexron-iii-atf-d3-transmission-fluid-1l",
          "name": "Dexron III ATF D3 Transmission Fluid 1L",
          "sku": "GL-0035",
          "category": "Transmission Fluid",
          "quantity": 1,
          "price_cents": 1300,
          "line_total_cents": 1300
        },
        {
          "id": "4e9cff85-407c-48f6-89e6-0ddb92b874fa",
          "order_id": "c12d5bc2-9b0b-45f7-9ef7-124b09a467be",
          "product_id": "cabin-filter-for-perodua-myvi-alza-axia-bezza",
          "name": "Cabin Filter for Perodua Myvi / Alza / Axia / Bezza",
          "sku": "GL-0037",
          "category": "Filters",
          "quantity": 1,
          "price_cents": 1500,
          "line_total_cents": 1500
        },
        {
          "id": "a98366fb-a351-4dcb-a069-222e3bedc2d4",
          "order_id": "c12d5bc2-9b0b-45f7-9ef7-124b09a467be",
          "product_id": "front-brake-pads-for-proton-gen-2-persona-neo",
          "name": "Front Brake Pads for Proton Gen 2 / Persona / Neo",
          "sku": "GL-0042",
          "category": "Brake Pads",
          "quantity": 1,
          "price_cents": 3800,
          "line_total_cents": 3800
        }
      ],
      "events": [
        {
          "id": "57cc014e-6d8c-4842-b31a-c573bd44f258",
          "order_id": "c12d5bc2-9b0b-45f7-9ef7-124b09a467be",
          "event": "order_created",
          "actor_id": "30000000-0000-4000-8000-000000000009",
          "note": "Fictional example: inventory reserved.",
          "created_at": "2026-08-27T12:00:00.000Z"
        },
        {
          "id": "e5004592-ee4d-48d6-8349-424995823016",
          "order_id": "c12d5bc2-9b0b-45f7-9ef7-124b09a467be",
          "event": "payment_submitted",
          "actor_id": "30000000-0000-4000-8000-000000000009",
          "note": "Fictional bank reference; no transfer occurred.",
          "created_at": "2026-08-27T12:10:00.000Z"
        },
        {
          "id": "1e8d8626-a6ed-4a33-ac3e-a50b83a32e36",
          "order_id": "c12d5bc2-9b0b-45f7-9ef7-124b09a467be",
          "event": "payment_verified",
          "actor_id": "seed-worker",
          "note": "Fictional deposit verification.",
          "created_at": "2026-08-27T12:20:00.000Z"
        },
        {
          "id": "8101d8f0-2a4a-42a0-82db-a773406aeb99",
          "order_id": "c12d5bc2-9b0b-45f7-9ef7-124b09a467be",
          "event": "shipped",
          "actor_id": "seed-worker",
          "note": "Fictional carrier and tracking number.",
          "created_at": "2026-08-28T12:00:00.000Z"
        },
        {
          "id": "76aa20e9-1aec-4d3d-9a09-4fa1f7f5b69c",
          "order_id": "c12d5bc2-9b0b-45f7-9ef7-124b09a467be",
          "event": "receipt_confirmed",
          "actor_id": "30000000-0000-4000-8000-000000000009",
          "note": "Fictional buyer confirmed receipt.",
          "created_at": "2026-08-29T12:00:00.000Z"
        },
        {
          "id": "66e4a4da-4923-40b4-8022-38ef24b15355",
          "order_id": "c12d5bc2-9b0b-45f7-9ef7-124b09a467be",
          "event": "refund_paid",
          "actor_id": "seed-admin",
          "note": "Fictional full refund; returned units restored.",
          "created_at": "2026-08-30T12:00:00.000Z"
        }
      ],
      "sample_data": true
    },
    {
      "id": "b97631df-1749-49d5-8fc7-fc2dde9e8116",
      "order_number": 10070,
      "customer_id": "30000000-0000-4000-8000-000000000010",
      "status": "delivered",
      "payment_status": "verified",
      "address": {
        "name": "Demo Workshop 10",
        "phone": "0100000000",
        "line1": "Demo address — not for delivery",
        "city": "Petaling Jaya",
        "postcode": "47300",
        "state": "Selangor"
      },
      "subtotal_cents": 3996,
      "discount_cents": 0,
      "shipping_cents": 1500,
      "total_cents": 5496,
      "payment_instructions": {
        "bank_name": "DEMO — DO NOT TRANSFER",
        "bank_account_name": "FICTIONAL EXAMPLE ONLY",
        "bank_account_number": "0000000000"
      },
      "payment_reference": "SAMPLE-NO-TRANSFER-70",
      "paid_verified_by": "seed-worker",
      "payment_note": null,
      "carrier": "Demo carrier",
      "tracking_number": "DEMO-NOT-A-PARCEL-70",
      "received_at": "2026-08-28T13:00:00.000Z",
      "cancel_reason": null,
      "idempotency_key": "c7e23b5f-0527-4158-b0e1-fd6fd867b0a9",
      "created_at": "2026-08-26T13:00:00.000Z",
      "updated_at": "2026-08-28T13:00:00.000Z",
      "expires_at": "2026-08-27T13:00:00.000Z",
      "items": [
        {
          "id": "da9bbd67-9158-4ab5-8980-acd64e0fa005",
          "order_id": "b97631df-1749-49d5-8fc7-fc2dde9e8116",
          "product_id": "x-traseal-carburetor-and-choke-cleaner-400ml",
          "name": "X'traseal Carburetor and Choke Cleaner 400ml",
          "sku": "GL-0006",
          "category": "Cleaners & Additives",
          "quantity": 4,
          "price_cents": 999,
          "line_total_cents": 3996
        }
      ],
      "events": [
        {
          "id": "3d1083b9-3b91-4c03-8f7f-f3f61c645bc8",
          "order_id": "b97631df-1749-49d5-8fc7-fc2dde9e8116",
          "event": "order_created",
          "actor_id": "30000000-0000-4000-8000-000000000010",
          "note": "Fictional example: inventory reserved.",
          "created_at": "2026-08-26T13:00:00.000Z"
        },
        {
          "id": "ab1544ca-a5ba-4ff0-9b40-b3818f7ea04b",
          "order_id": "b97631df-1749-49d5-8fc7-fc2dde9e8116",
          "event": "payment_submitted",
          "actor_id": "30000000-0000-4000-8000-000000000010",
          "note": "Fictional bank reference; no transfer occurred.",
          "created_at": "2026-08-26T13:10:00.000Z"
        },
        {
          "id": "10a6b6f6-09ef-483c-9f27-4a078b004957",
          "order_id": "b97631df-1749-49d5-8fc7-fc2dde9e8116",
          "event": "payment_verified",
          "actor_id": "seed-worker",
          "note": "Fictional deposit verification.",
          "created_at": "2026-08-26T13:20:00.000Z"
        },
        {
          "id": "b883aa16-a146-4b68-aec5-585985e9fe64",
          "order_id": "b97631df-1749-49d5-8fc7-fc2dde9e8116",
          "event": "shipped",
          "actor_id": "seed-worker",
          "note": "Fictional carrier and tracking number.",
          "created_at": "2026-08-27T13:00:00.000Z"
        },
        {
          "id": "92c38bd8-bac3-4651-bb43-9ae7f6a43152",
          "order_id": "b97631df-1749-49d5-8fc7-fc2dde9e8116",
          "event": "receipt_confirmed",
          "actor_id": "30000000-0000-4000-8000-000000000010",
          "note": "Fictional buyer confirmed receipt.",
          "created_at": "2026-08-28T13:00:00.000Z"
        }
      ],
      "sample_data": true
    },
    {
      "id": "1ced20a7-65b2-4f9a-ba56-0afe320b0e0e",
      "order_number": 10071,
      "customer_id": "30000000-0000-4000-8000-000000000011",
      "status": "delivered",
      "payment_status": "verified",
      "address": {
        "name": "Demo Parts Shop 11",
        "phone": "0100000000",
        "line1": "Demo address — not for delivery",
        "city": "Petaling Jaya",
        "postcode": "47300",
        "state": "Selangor"
      },
      "subtotal_cents": 14400,
      "discount_cents": 0,
      "shipping_cents": 1500,
      "total_cents": 15900,
      "payment_instructions": {
        "bank_name": "DEMO — DO NOT TRANSFER",
        "bank_account_name": "FICTIONAL EXAMPLE ONLY",
        "bank_account_number": "0000000000"
      },
      "payment_reference": "SAMPLE-NO-TRANSFER-71",
      "paid_verified_by": "seed-worker",
      "payment_note": null,
      "carrier": "Demo carrier",
      "tracking_number": "DEMO-NOT-A-PARCEL-71",
      "received_at": "2026-08-27T12:00:00.000Z",
      "cancel_reason": null,
      "idempotency_key": "7328254e-c1d8-43e5-8cb8-3377a5974fbe",
      "created_at": "2026-08-25T12:00:00.000Z",
      "updated_at": "2026-08-27T12:00:00.000Z",
      "expires_at": "2026-08-26T12:00:00.000Z",
      "items": [
        {
          "id": "35c9e1dd-c297-416b-a027-7ebee841ead6",
          "order_id": "1ced20a7-65b2-4f9a-ba56-0afe320b0e0e",
          "product_id": "top-1-green-radiator-coolant-500ml",
          "name": "Top 1 Green Radiator Coolant 500ml",
          "sku": "GL-0013",
          "category": "Coolant",
          "quantity": 6,
          "price_cents": 1000,
          "line_total_cents": 6000
        },
        {
          "id": "8885d1ca-c10f-4971-b16a-0583c9bf1261",
          "order_id": "1ced20a7-65b2-4f9a-ba56-0afe320b0e0e",
          "product_id": "power-up-power-steering-fluid-1l",
          "name": "Power Up Power Steering Fluid 1L",
          "sku": "GL-0026",
          "category": "Steering Fluid",
          "quantity": 6,
          "price_cents": 1400,
          "line_total_cents": 8400
        }
      ],
      "events": [
        {
          "id": "373d3b7a-6f11-4b72-a999-94cbbde613c1",
          "order_id": "1ced20a7-65b2-4f9a-ba56-0afe320b0e0e",
          "event": "order_created",
          "actor_id": "30000000-0000-4000-8000-000000000011",
          "note": "Fictional example: inventory reserved.",
          "created_at": "2026-08-25T12:00:00.000Z"
        },
        {
          "id": "e40570d2-8bf2-4223-8812-db6cce578b25",
          "order_id": "1ced20a7-65b2-4f9a-ba56-0afe320b0e0e",
          "event": "payment_submitted",
          "actor_id": "30000000-0000-4000-8000-000000000011",
          "note": "Fictional bank reference; no transfer occurred.",
          "created_at": "2026-08-25T12:10:00.000Z"
        },
        {
          "id": "645f7874-ea22-44ed-893a-957060325e84",
          "order_id": "1ced20a7-65b2-4f9a-ba56-0afe320b0e0e",
          "event": "payment_verified",
          "actor_id": "seed-worker",
          "note": "Fictional deposit verification.",
          "created_at": "2026-08-25T12:20:00.000Z"
        },
        {
          "id": "edfc98e5-2682-40b1-86b5-cf8914079e99",
          "order_id": "1ced20a7-65b2-4f9a-ba56-0afe320b0e0e",
          "event": "shipped",
          "actor_id": "seed-worker",
          "note": "Fictional carrier and tracking number.",
          "created_at": "2026-08-26T12:00:00.000Z"
        },
        {
          "id": "c7b030dc-c5e6-4ec7-8830-d7dc049dbb26",
          "order_id": "1ced20a7-65b2-4f9a-ba56-0afe320b0e0e",
          "event": "receipt_confirmed",
          "actor_id": "30000000-0000-4000-8000-000000000011",
          "note": "Fictional buyer confirmed receipt.",
          "created_at": "2026-08-27T12:00:00.000Z"
        }
      ],
      "sample_data": true
    },
    {
      "id": "aeb4f03f-8bbc-4e59-a863-4656a9be4b2b",
      "order_number": 10072,
      "customer_id": "30000000-0000-4000-8000-000000000012",
      "status": "delivered",
      "payment_status": "verified",
      "address": {
        "name": "Demo Distributor 12",
        "phone": "0100000000",
        "line1": "Demo address — not for delivery",
        "city": "Petaling Jaya",
        "postcode": "47300",
        "state": "Selangor"
      },
      "subtotal_cents": 284000,
      "discount_cents": 0,
      "shipping_cents": 0,
      "total_cents": 284000,
      "payment_instructions": {
        "bank_name": "DEMO — DO NOT TRANSFER",
        "bank_account_name": "FICTIONAL EXAMPLE ONLY",
        "bank_account_number": "0000000000"
      },
      "payment_reference": "SAMPLE-NO-TRANSFER-72",
      "paid_verified_by": "seed-worker",
      "payment_note": null,
      "carrier": "Demo carrier",
      "tracking_number": "DEMO-NOT-A-PARCEL-72",
      "received_at": "2026-08-26T13:00:00.000Z",
      "cancel_reason": null,
      "idempotency_key": "f047df31-1de2-46e7-86a5-fe8542ed6555",
      "created_at": "2026-08-24T13:00:00.000Z",
      "updated_at": "2026-08-26T13:00:00.000Z",
      "expires_at": "2026-08-25T13:00:00.000Z",
      "items": [
        {
          "id": "1a7af571-57ce-4240-bbb9-d639821120c0",
          "order_id": "aeb4f03f-8bbc-4e59-a863-4656a9be4b2b",
          "product_id": "cabin-filter-for-proton-x50",
          "name": "Cabin Filter for Proton X50",
          "sku": "GL-0009",
          "category": "Filters",
          "quantity": 20,
          "price_cents": 2500,
          "line_total_cents": 50000
        },
        {
          "id": "b0ab5884-b85b-434a-982a-9074fdecf4a7",
          "order_id": "aeb4f03f-8bbc-4e59-a863-4656a9be4b2b",
          "product_id": "trw-gdb7742-front-brake-pads",
          "name": "TRW GDB7742 Front Brake Pads",
          "sku": "GL-0044",
          "category": "Brake Pads",
          "quantity": 20,
          "price_cents": 6700,
          "line_total_cents": 134000
        },
        {
          "id": "0702e33c-ac5f-4e57-9e75-0b564a6b74c4",
          "order_id": "aeb4f03f-8bbc-4e59-a863-4656a9be4b2b",
          "product_id": "castrol-gtx-10w-30-engine-oil-3l",
          "name": "Castrol GTX 10W-30 Engine Oil 3L",
          "sku": "GL-0031",
          "category": "Engine Oil",
          "quantity": 20,
          "price_cents": 5000,
          "line_total_cents": 100000
        }
      ],
      "events": [
        {
          "id": "0455731b-f434-4054-9137-4c5093513158",
          "order_id": "aeb4f03f-8bbc-4e59-a863-4656a9be4b2b",
          "event": "order_created",
          "actor_id": "30000000-0000-4000-8000-000000000012",
          "note": "Fictional example: inventory reserved.",
          "created_at": "2026-08-24T13:00:00.000Z"
        },
        {
          "id": "c6d2b781-24f8-4918-bf2c-7b5d4a5cb206",
          "order_id": "aeb4f03f-8bbc-4e59-a863-4656a9be4b2b",
          "event": "payment_submitted",
          "actor_id": "30000000-0000-4000-8000-000000000012",
          "note": "Fictional bank reference; no transfer occurred.",
          "created_at": "2026-08-24T13:10:00.000Z"
        },
        {
          "id": "5ea03a43-82d9-4744-b31b-aee83ae0a05f",
          "order_id": "aeb4f03f-8bbc-4e59-a863-4656a9be4b2b",
          "event": "payment_verified",
          "actor_id": "seed-worker",
          "note": "Fictional deposit verification.",
          "created_at": "2026-08-24T13:20:00.000Z"
        },
        {
          "id": "4c79e672-c420-40ec-84ac-15f6c11e05d5",
          "order_id": "aeb4f03f-8bbc-4e59-a863-4656a9be4b2b",
          "event": "shipped",
          "actor_id": "seed-worker",
          "note": "Fictional carrier and tracking number.",
          "created_at": "2026-08-25T13:00:00.000Z"
        },
        {
          "id": "aa549ba5-13d6-4e2e-b1b0-7e8a3bf286ff",
          "order_id": "aeb4f03f-8bbc-4e59-a863-4656a9be4b2b",
          "event": "receipt_confirmed",
          "actor_id": "30000000-0000-4000-8000-000000000012",
          "note": "Fictional buyer confirmed receipt.",
          "created_at": "2026-08-26T13:00:00.000Z"
        }
      ],
      "sample_data": true
    },
    {
      "id": "2c881c27-ac84-4144-bd92-a589ea7fc304",
      "order_number": 10073,
      "customer_id": "30000000-0000-4000-8000-000000000001",
      "status": "delivered",
      "payment_status": "verified",
      "address": {
        "name": "Demo Motorist 01",
        "phone": "0100000000",
        "line1": "Demo address — not for delivery",
        "city": "Petaling Jaya",
        "postcode": "47300",
        "state": "Selangor"
      },
      "subtotal_cents": 2500,
      "discount_cents": 0,
      "shipping_cents": 1500,
      "total_cents": 4000,
      "payment_instructions": {
        "bank_name": "DEMO — DO NOT TRANSFER",
        "bank_account_name": "FICTIONAL EXAMPLE ONLY",
        "bank_account_number": "0000000000"
      },
      "payment_reference": "SAMPLE-NO-TRANSFER-73",
      "paid_verified_by": "seed-worker",
      "payment_note": null,
      "carrier": "Demo carrier",
      "tracking_number": "DEMO-NOT-A-PARCEL-73",
      "received_at": "2026-08-25T01:00:00.000Z",
      "cancel_reason": null,
      "idempotency_key": "5766d5b9-6965-4670-add2-ee3b0e59dcf2",
      "created_at": "2026-08-23T01:00:00.000Z",
      "updated_at": "2026-08-25T01:00:00.000Z",
      "expires_at": "2026-08-24T01:00:00.000Z",
      "items": [
        {
          "id": "b5c98548-358b-4381-a9eb-08b2e1c27b0b",
          "order_id": "2c881c27-ac84-4144-bd92-a589ea7fc304",
          "product_id": "ngk-lkr6c-spark-plug",
          "name": "NGK LKR6C Spark Plug",
          "sku": "GL-0025",
          "category": "Spark Plugs",
          "quantity": 1,
          "price_cents": 2500,
          "line_total_cents": 2500
        }
      ],
      "events": [
        {
          "id": "41c15454-8f0b-4488-99dc-1fd33c55fc7d",
          "order_id": "2c881c27-ac84-4144-bd92-a589ea7fc304",
          "event": "order_created",
          "actor_id": "30000000-0000-4000-8000-000000000001",
          "note": "Fictional example: inventory reserved.",
          "created_at": "2026-08-23T01:00:00.000Z"
        },
        {
          "id": "866ae878-7b9e-4eca-a32e-dfbe0eb94831",
          "order_id": "2c881c27-ac84-4144-bd92-a589ea7fc304",
          "event": "payment_submitted",
          "actor_id": "30000000-0000-4000-8000-000000000001",
          "note": "Fictional bank reference; no transfer occurred.",
          "created_at": "2026-08-23T01:10:00.000Z"
        },
        {
          "id": "1be642ba-4431-468b-a9bb-1cebc0d47dbc",
          "order_id": "2c881c27-ac84-4144-bd92-a589ea7fc304",
          "event": "payment_verified",
          "actor_id": "seed-worker",
          "note": "Fictional deposit verification.",
          "created_at": "2026-08-23T01:20:00.000Z"
        },
        {
          "id": "857856d8-08b2-4b52-b100-60608b342533",
          "order_id": "2c881c27-ac84-4144-bd92-a589ea7fc304",
          "event": "shipped",
          "actor_id": "seed-worker",
          "note": "Fictional carrier and tracking number.",
          "created_at": "2026-08-24T01:00:00.000Z"
        },
        {
          "id": "0074c881-e3b8-4486-a8ae-81e0cf656626",
          "order_id": "2c881c27-ac84-4144-bd92-a589ea7fc304",
          "event": "receipt_confirmed",
          "actor_id": "30000000-0000-4000-8000-000000000001",
          "note": "Fictional buyer confirmed receipt.",
          "created_at": "2026-08-25T01:00:00.000Z"
        }
      ],
      "sample_data": true
    },
    {
      "id": "38aa5f81-d407-4784-9974-2fea74a8eee4",
      "order_number": 10074,
      "customer_id": "30000000-0000-4000-8000-000000000002",
      "status": "delivered",
      "payment_status": "verified",
      "address": {
        "name": "Demo Workshop 02",
        "phone": "0100000000",
        "line1": "Demo address — not for delivery",
        "city": "Petaling Jaya",
        "postcode": "47300",
        "state": "Selangor"
      },
      "subtotal_cents": 12800,
      "discount_cents": 0,
      "shipping_cents": 1500,
      "total_cents": 14300,
      "payment_instructions": {
        "bank_name": "DEMO — DO NOT TRANSFER",
        "bank_account_name": "FICTIONAL EXAMPLE ONLY",
        "bank_account_number": "0000000000"
      },
      "payment_reference": "SAMPLE-NO-TRANSFER-74",
      "paid_verified_by": "seed-worker",
      "payment_note": null,
      "carrier": "Demo carrier",
      "tracking_number": "DEMO-NOT-A-PARCEL-74",
      "received_at": "2026-08-24T02:00:00.000Z",
      "cancel_reason": null,
      "idempotency_key": "6c7c1214-b7d1-4abf-a611-083b35f8e750",
      "created_at": "2026-08-22T02:00:00.000Z",
      "updated_at": "2026-08-24T02:00:00.000Z",
      "expires_at": "2026-08-23T02:00:00.000Z",
      "items": [
        {
          "id": "2671948f-b13a-48e7-b6a1-bf6feca38af5",
          "order_id": "38aa5f81-d407-4784-9974-2fea74a8eee4",
          "product_id": "power-up-power-steering-fluid-1l",
          "name": "Power Up Power Steering Fluid 1L",
          "sku": "GL-0026",
          "category": "Steering Fluid",
          "quantity": 4,
          "price_cents": 1400,
          "line_total_cents": 5600
        },
        {
          "id": "e946dc33-5122-46cc-89b0-16cad5d4ee2d",
          "order_id": "38aa5f81-d407-4784-9974-2fea74a8eee4",
          "product_id": "engine-air-filter-for-proton-x70",
          "name": "Engine Air Filter for Proton X70",
          "sku": "GL-0012",
          "category": "Filters",
          "quantity": 4,
          "price_cents": 1800,
          "line_total_cents": 7200
        }
      ],
      "events": [
        {
          "id": "6889b420-6722-424e-9523-292090ecba2d",
          "order_id": "38aa5f81-d407-4784-9974-2fea74a8eee4",
          "event": "order_created",
          "actor_id": "30000000-0000-4000-8000-000000000002",
          "note": "Fictional example: inventory reserved.",
          "created_at": "2026-08-22T02:00:00.000Z"
        },
        {
          "id": "892612f9-1ea1-486e-9529-acf213df327c",
          "order_id": "38aa5f81-d407-4784-9974-2fea74a8eee4",
          "event": "payment_submitted",
          "actor_id": "30000000-0000-4000-8000-000000000002",
          "note": "Fictional bank reference; no transfer occurred.",
          "created_at": "2026-08-22T02:10:00.000Z"
        },
        {
          "id": "1747c942-b887-43a9-bb01-92387d47d8f7",
          "order_id": "38aa5f81-d407-4784-9974-2fea74a8eee4",
          "event": "payment_verified",
          "actor_id": "seed-worker",
          "note": "Fictional deposit verification.",
          "created_at": "2026-08-22T02:20:00.000Z"
        },
        {
          "id": "9c753219-4ab0-4a34-b3e3-4d5259e3f560",
          "order_id": "38aa5f81-d407-4784-9974-2fea74a8eee4",
          "event": "shipped",
          "actor_id": "seed-worker",
          "note": "Fictional carrier and tracking number.",
          "created_at": "2026-08-23T02:00:00.000Z"
        },
        {
          "id": "42514aa0-501a-4619-a4d9-20467c52d50c",
          "order_id": "38aa5f81-d407-4784-9974-2fea74a8eee4",
          "event": "receipt_confirmed",
          "actor_id": "30000000-0000-4000-8000-000000000002",
          "note": "Fictional buyer confirmed receipt.",
          "created_at": "2026-08-24T02:00:00.000Z"
        }
      ],
      "sample_data": true
    },
    {
      "id": "2501b10f-4dc5-43a1-8fd1-8d23015ef09a",
      "order_number": 10075,
      "customer_id": "30000000-0000-4000-8000-000000000003",
      "status": "delivered",
      "payment_status": "verified",
      "address": {
        "name": "Demo Parts Shop 03",
        "phone": "0100000000",
        "line1": "Demo address — not for delivery",
        "city": "Petaling Jaya",
        "postcode": "47300",
        "state": "Selangor"
      },
      "subtotal_cents": 179000,
      "discount_cents": 0,
      "shipping_cents": 0,
      "total_cents": 179000,
      "payment_instructions": {
        "bank_name": "DEMO — DO NOT TRANSFER",
        "bank_account_name": "FICTIONAL EXAMPLE ONLY",
        "bank_account_number": "0000000000"
      },
      "payment_reference": "SAMPLE-NO-TRANSFER-75",
      "paid_verified_by": "seed-worker",
      "payment_note": null,
      "carrier": "Demo carrier",
      "tracking_number": "DEMO-NOT-A-PARCEL-75",
      "received_at": "2026-08-23T03:00:00.000Z",
      "cancel_reason": null,
      "idempotency_key": "c9a393d5-c752-4c8f-99f6-e8e877fd712d",
      "created_at": "2026-08-21T03:00:00.000Z",
      "updated_at": "2026-08-23T03:00:00.000Z",
      "expires_at": "2026-08-22T03:00:00.000Z",
      "items": [
        {
          "id": "b4012d7c-2eb0-4581-81e8-17419209428a",
          "order_id": "2501b10f-4dc5-43a1-8fd1-8d23015ef09a",
          "product_id": "trw-gdb1198-front-brake-pads",
          "name": "TRW GDB1198 Front Brake Pads",
          "sku": "GL-0046",
          "category": "Brake Pads",
          "quantity": 10,
          "price_cents": 5200,
          "line_total_cents": 52000
        },
        {
          "id": "ac03828a-2281-42ed-a776-9e6bc048eaab",
          "order_id": "2501b10f-4dc5-43a1-8fd1-8d23015ef09a",
          "product_id": "castrol-gtx-10w-30-engine-oil-4l",
          "name": "Castrol GTX 10W-30 Engine Oil 4L",
          "sku": "GL-0034",
          "category": "Engine Oil",
          "quantity": 10,
          "price_cents": 7700,
          "line_total_cents": 77000
        },
        {
          "id": "87083872-c0d8-4c62-97db-56e3ebb74424",
          "order_id": "2501b10f-4dc5-43a1-8fd1-8d23015ef09a",
          "product_id": "castrol-gtx-10w-30-engine-oil-3l",
          "name": "Castrol GTX 10W-30 Engine Oil 3L",
          "sku": "GL-0031",
          "category": "Engine Oil",
          "quantity": 10,
          "price_cents": 5000,
          "line_total_cents": 50000
        }
      ],
      "events": [
        {
          "id": "c1713071-e18c-4ef9-9fe3-f85f661b03f5",
          "order_id": "2501b10f-4dc5-43a1-8fd1-8d23015ef09a",
          "event": "order_created",
          "actor_id": "30000000-0000-4000-8000-000000000003",
          "note": "Fictional example: inventory reserved.",
          "created_at": "2026-08-21T03:00:00.000Z"
        },
        {
          "id": "d7b7c3a9-977d-4717-97a1-9909a38efb48",
          "order_id": "2501b10f-4dc5-43a1-8fd1-8d23015ef09a",
          "event": "payment_submitted",
          "actor_id": "30000000-0000-4000-8000-000000000003",
          "note": "Fictional bank reference; no transfer occurred.",
          "created_at": "2026-08-21T03:10:00.000Z"
        },
        {
          "id": "9271e6c7-6267-45ff-872e-ffff18c9310a",
          "order_id": "2501b10f-4dc5-43a1-8fd1-8d23015ef09a",
          "event": "payment_verified",
          "actor_id": "seed-worker",
          "note": "Fictional deposit verification.",
          "created_at": "2026-08-21T03:20:00.000Z"
        },
        {
          "id": "ab05e910-89a1-413a-bb49-7e87a8f85bf2",
          "order_id": "2501b10f-4dc5-43a1-8fd1-8d23015ef09a",
          "event": "shipped",
          "actor_id": "seed-worker",
          "note": "Fictional carrier and tracking number.",
          "created_at": "2026-08-22T03:00:00.000Z"
        },
        {
          "id": "d5beec54-71ac-4fc0-a6f7-fcd04062fc98",
          "order_id": "2501b10f-4dc5-43a1-8fd1-8d23015ef09a",
          "event": "receipt_confirmed",
          "actor_id": "30000000-0000-4000-8000-000000000003",
          "note": "Fictional buyer confirmed receipt.",
          "created_at": "2026-08-23T03:00:00.000Z"
        }
      ],
      "sample_data": true
    },
    {
      "id": "f2832918-2ef0-4c04-b94f-1d5ffdc609cc",
      "order_number": 10076,
      "customer_id": "30000000-0000-4000-8000-000000000004",
      "status": "delivered",
      "payment_status": "verified",
      "address": {
        "name": "Demo Distributor 04",
        "phone": "0100000000",
        "line1": "Demo address — not for delivery",
        "city": "Petaling Jaya",
        "postcode": "47300",
        "state": "Selangor"
      },
      "subtotal_cents": 115500,
      "discount_cents": 0,
      "shipping_cents": 0,
      "total_cents": 115500,
      "payment_instructions": {
        "bank_name": "DEMO — DO NOT TRANSFER",
        "bank_account_name": "FICTIONAL EXAMPLE ONLY",
        "bank_account_number": "0000000000"
      },
      "payment_reference": "SAMPLE-NO-TRANSFER-76",
      "paid_verified_by": "seed-worker",
      "payment_note": null,
      "carrier": "Demo carrier",
      "tracking_number": "DEMO-NOT-A-PARCEL-76",
      "received_at": "2026-08-22T05:00:00.000Z",
      "cancel_reason": null,
      "idempotency_key": "524299d0-5d7c-4282-b7e0-d4cda4ca5909",
      "created_at": "2026-08-20T05:00:00.000Z",
      "updated_at": "2026-08-22T05:00:00.000Z",
      "expires_at": "2026-08-21T05:00:00.000Z",
      "items": [
        {
          "id": "abbb3d8d-56af-4cdd-ac49-b83450e52b59",
          "order_id": "f2832918-2ef0-4c04-b94f-1d5ffdc609cc",
          "product_id": "castrol-gtx-10w-30-engine-oil-4l",
          "name": "Castrol GTX 10W-30 Engine Oil 4L",
          "sku": "GL-0034",
          "category": "Engine Oil",
          "quantity": 15,
          "price_cents": 7700,
          "line_total_cents": 115500
        }
      ],
      "events": [
        {
          "id": "8c812cab-4346-477d-8677-3ce915e12da6",
          "order_id": "f2832918-2ef0-4c04-b94f-1d5ffdc609cc",
          "event": "order_created",
          "actor_id": "30000000-0000-4000-8000-000000000004",
          "note": "Fictional example: inventory reserved.",
          "created_at": "2026-08-20T05:00:00.000Z"
        },
        {
          "id": "b4b9212a-5d8b-4816-b2f3-18fc8a021fe9",
          "order_id": "f2832918-2ef0-4c04-b94f-1d5ffdc609cc",
          "event": "payment_submitted",
          "actor_id": "30000000-0000-4000-8000-000000000004",
          "note": "Fictional bank reference; no transfer occurred.",
          "created_at": "2026-08-20T05:10:00.000Z"
        },
        {
          "id": "98f0ac5b-d33d-498b-a9b0-fb8dd97d3ae2",
          "order_id": "f2832918-2ef0-4c04-b94f-1d5ffdc609cc",
          "event": "payment_verified",
          "actor_id": "seed-worker",
          "note": "Fictional deposit verification.",
          "created_at": "2026-08-20T05:20:00.000Z"
        },
        {
          "id": "49f8b128-53c9-43c0-9eb5-f96675b9babd",
          "order_id": "f2832918-2ef0-4c04-b94f-1d5ffdc609cc",
          "event": "shipped",
          "actor_id": "seed-worker",
          "note": "Fictional carrier and tracking number.",
          "created_at": "2026-08-21T05:00:00.000Z"
        },
        {
          "id": "b36c99f3-6ae8-4cdc-8c71-816116666873",
          "order_id": "f2832918-2ef0-4c04-b94f-1d5ffdc609cc",
          "event": "receipt_confirmed",
          "actor_id": "30000000-0000-4000-8000-000000000004",
          "note": "Fictional buyer confirmed receipt.",
          "created_at": "2026-08-22T05:00:00.000Z"
        }
      ],
      "sample_data": true
    },
    {
      "id": "9e32059e-17b5-4595-b652-e7cb83f95ffc",
      "order_number": 10077,
      "customer_id": "30000000-0000-4000-8000-000000000005",
      "status": "delivered",
      "payment_status": "verified",
      "address": {
        "name": "Demo Motorist 05",
        "phone": "0100000000",
        "line1": "Demo address — not for delivery",
        "city": "Petaling Jaya",
        "postcode": "47300",
        "state": "Selangor"
      },
      "subtotal_cents": 16300,
      "discount_cents": 0,
      "shipping_cents": 1500,
      "total_cents": 17800,
      "payment_instructions": {
        "bank_name": "DEMO — DO NOT TRANSFER",
        "bank_account_name": "FICTIONAL EXAMPLE ONLY",
        "bank_account_number": "0000000000"
      },
      "payment_reference": "SAMPLE-NO-TRANSFER-77",
      "paid_verified_by": "seed-worker",
      "payment_note": null,
      "carrier": "Demo carrier",
      "tracking_number": "DEMO-NOT-A-PARCEL-77",
      "received_at": "2026-08-21T06:00:00.000Z",
      "cancel_reason": null,
      "idempotency_key": "e3746747-a718-4f57-bafc-d65671a156ab",
      "created_at": "2026-08-19T06:00:00.000Z",
      "updated_at": "2026-08-21T06:00:00.000Z",
      "expires_at": "2026-08-20T06:00:00.000Z",
      "items": [
        {
          "id": "d1418401-903d-44e8-bbcb-e1c7df03e643",
          "order_id": "9e32059e-17b5-4595-b652-e7cb83f95ffc",
          "product_id": "petrol-filter-for-proton-iriz-saga-vvt-persona-vvt",
          "name": "Petrol Filter for Proton Iriz / Saga VVT / Persona VVT",
          "sku": "GL-0017",
          "category": "Filters",
          "quantity": 1,
          "price_cents": 2800,
          "line_total_cents": 2800
        },
        {
          "id": "6f433f4b-7b5a-43aa-81a0-7329b53a1710",
          "order_id": "9e32059e-17b5-4595-b652-e7cb83f95ffc",
          "product_id": "castrol-magnatec-10w-40-engine-oil-4l",
          "name": "Castrol Magnatec 10W-40 Engine Oil 4L",
          "sku": "GL-0032",
          "category": "Engine Oil",
          "quantity": 1,
          "price_cents": 13500,
          "line_total_cents": 13500
        }
      ],
      "events": [
        {
          "id": "96236e17-69b0-4e27-bbb6-b2e31e751bad",
          "order_id": "9e32059e-17b5-4595-b652-e7cb83f95ffc",
          "event": "order_created",
          "actor_id": "30000000-0000-4000-8000-000000000005",
          "note": "Fictional example: inventory reserved.",
          "created_at": "2026-08-19T06:00:00.000Z"
        },
        {
          "id": "4bacf70a-3d6d-4cff-915d-b510b1b19361",
          "order_id": "9e32059e-17b5-4595-b652-e7cb83f95ffc",
          "event": "payment_submitted",
          "actor_id": "30000000-0000-4000-8000-000000000005",
          "note": "Fictional bank reference; no transfer occurred.",
          "created_at": "2026-08-19T06:10:00.000Z"
        },
        {
          "id": "abffe0ed-f7e8-4209-a3f9-167cbda8bcb3",
          "order_id": "9e32059e-17b5-4595-b652-e7cb83f95ffc",
          "event": "payment_verified",
          "actor_id": "seed-worker",
          "note": "Fictional deposit verification.",
          "created_at": "2026-08-19T06:20:00.000Z"
        },
        {
          "id": "74acf35a-b596-4dff-8245-379d5a8e0d74",
          "order_id": "9e32059e-17b5-4595-b652-e7cb83f95ffc",
          "event": "shipped",
          "actor_id": "seed-worker",
          "note": "Fictional carrier and tracking number.",
          "created_at": "2026-08-20T06:00:00.000Z"
        },
        {
          "id": "2d7a0aef-e67d-4916-b0c8-4fcd013f0c12",
          "order_id": "9e32059e-17b5-4595-b652-e7cb83f95ffc",
          "event": "receipt_confirmed",
          "actor_id": "30000000-0000-4000-8000-000000000005",
          "note": "Fictional buyer confirmed receipt.",
          "created_at": "2026-08-21T06:00:00.000Z"
        }
      ],
      "sample_data": true
    },
    {
      "id": "b689b1fa-5ffc-47a2-a111-b0f4bc4c9ca8",
      "order_number": 10078,
      "customer_id": "30000000-0000-4000-8000-000000000006",
      "status": "delivered",
      "payment_status": "verified",
      "address": {
        "name": "Demo Workshop 06",
        "phone": "0100000000",
        "line1": "Demo address — not for delivery",
        "city": "Petaling Jaya",
        "postcode": "47300",
        "state": "Selangor"
      },
      "subtotal_cents": 102000,
      "discount_cents": 0,
      "shipping_cents": 0,
      "total_cents": 102000,
      "payment_instructions": {
        "bank_name": "DEMO — DO NOT TRANSFER",
        "bank_account_name": "FICTIONAL EXAMPLE ONLY",
        "bank_account_number": "0000000000"
      },
      "payment_reference": "SAMPLE-NO-TRANSFER-78",
      "paid_verified_by": "seed-worker",
      "payment_note": null,
      "carrier": "Demo carrier",
      "tracking_number": "DEMO-NOT-A-PARCEL-78",
      "received_at": "2026-08-20T10:00:00.000Z",
      "cancel_reason": null,
      "idempotency_key": "5762d9a5-885f-4b70-82d6-0775ad1b2260",
      "created_at": "2026-08-18T10:00:00.000Z",
      "updated_at": "2026-08-20T10:00:00.000Z",
      "expires_at": "2026-08-19T10:00:00.000Z",
      "items": [
        {
          "id": "015a666b-bc85-490f-b39b-b589faec2bc9",
          "order_id": "b689b1fa-5ffc-47a2-a111-b0f4bc4c9ca8",
          "product_id": "toyota-fully-synthetic-0w-20-engine-oil-4l",
          "name": "Toyota Fully Synthetic 0W-20 Engine Oil 4L",
          "sku": "GL-0001",
          "category": "Engine Oil",
          "quantity": 4,
          "price_cents": 13000,
          "line_total_cents": 52000
        },
        {
          "id": "f2aedc47-3ccd-41a2-9e9d-b1fb1cc4947e",
          "order_id": "b689b1fa-5ffc-47a2-a111-b0f4bc4c9ca8",
          "product_id": "castrol-80w-90-manual-gear-oil-4l",
          "name": "Castrol 80W-90 Manual Gear Oil 4L",
          "sku": "GL-0033",
          "category": "Transmission Fluid",
          "quantity": 4,
          "price_cents": 7500,
          "line_total_cents": 30000
        },
        {
          "id": "198fd979-8926-4a6c-a07e-3cedfb892a5c",
          "order_id": "b689b1fa-5ffc-47a2-a111-b0f4bc4c9ca8",
          "product_id": "manual-gear-oil-80w-90-4l",
          "name": "Manual Gear Oil 80W-90 4L",
          "sku": "GL-0015",
          "category": "Transmission Fluid",
          "quantity": 4,
          "price_cents": 5000,
          "line_total_cents": 20000
        }
      ],
      "events": [
        {
          "id": "a55e39b5-0220-496e-b59e-0d28f1ba7abd",
          "order_id": "b689b1fa-5ffc-47a2-a111-b0f4bc4c9ca8",
          "event": "order_created",
          "actor_id": "30000000-0000-4000-8000-000000000006",
          "note": "Fictional example: inventory reserved.",
          "created_at": "2026-08-18T10:00:00.000Z"
        },
        {
          "id": "e4a9370c-62a1-4501-9b57-565ae2e2bf98",
          "order_id": "b689b1fa-5ffc-47a2-a111-b0f4bc4c9ca8",
          "event": "payment_submitted",
          "actor_id": "30000000-0000-4000-8000-000000000006",
          "note": "Fictional bank reference; no transfer occurred.",
          "created_at": "2026-08-18T10:10:00.000Z"
        },
        {
          "id": "f24b9105-6d5f-485b-9e6e-3cd0f3279965",
          "order_id": "b689b1fa-5ffc-47a2-a111-b0f4bc4c9ca8",
          "event": "payment_verified",
          "actor_id": "seed-worker",
          "note": "Fictional deposit verification.",
          "created_at": "2026-08-18T10:20:00.000Z"
        },
        {
          "id": "368e3c24-c970-42cc-b089-5af14bc60cdb",
          "order_id": "b689b1fa-5ffc-47a2-a111-b0f4bc4c9ca8",
          "event": "shipped",
          "actor_id": "seed-worker",
          "note": "Fictional carrier and tracking number.",
          "created_at": "2026-08-19T10:00:00.000Z"
        },
        {
          "id": "174bceb2-4680-4113-aed0-be77fb85952a",
          "order_id": "b689b1fa-5ffc-47a2-a111-b0f4bc4c9ca8",
          "event": "receipt_confirmed",
          "actor_id": "30000000-0000-4000-8000-000000000006",
          "note": "Fictional buyer confirmed receipt.",
          "created_at": "2026-08-20T10:00:00.000Z"
        }
      ],
      "sample_data": true
    },
    {
      "id": "ac06bc5c-34ed-4102-aff5-eeef7d8eb254",
      "order_number": 10079,
      "customer_id": "30000000-0000-4000-8000-000000000007",
      "status": "cancelled",
      "payment_status": "awaiting",
      "address": {
        "name": "Demo Parts Shop 07",
        "phone": "0100000000",
        "line1": "Demo address — not for delivery",
        "city": "Petaling Jaya",
        "postcode": "47300",
        "state": "Selangor"
      },
      "subtotal_cents": 38500,
      "discount_cents": 0,
      "shipping_cents": 0,
      "total_cents": 38500,
      "payment_instructions": {
        "bank_name": "DEMO — DO NOT TRANSFER",
        "bank_account_name": "FICTIONAL EXAMPLE ONLY",
        "bank_account_number": "0000000000"
      },
      "payment_reference": null,
      "paid_verified_by": null,
      "payment_note": null,
      "carrier": null,
      "tracking_number": null,
      "received_at": null,
      "cancel_reason": "Example customer changed their mind.",
      "idempotency_key": "6f5dafe1-bf23-4bf6-9091-235fde2a12af",
      "created_at": "2026-08-17T12:00:00.000Z",
      "updated_at": "2026-08-17T12:30:00.000Z",
      "expires_at": "2026-08-18T12:00:00.000Z",
      "items": [
        {
          "id": "cca7b39b-044c-438d-b842-83c49817ed9c",
          "order_id": "ac06bc5c-34ed-4102-aff5-eeef7d8eb254",
          "product_id": "trw-gdb7707-front-brake-pads",
          "name": "TRW GDB7707 Front Brake Pads",
          "sku": "GL-0043",
          "category": "Brake Pads",
          "quantity": 7,
          "price_cents": 5500,
          "line_total_cents": 38500
        }
      ],
      "events": [
        {
          "id": "dc6f80fe-7a64-43c5-b6df-3f682d319e08",
          "order_id": "ac06bc5c-34ed-4102-aff5-eeef7d8eb254",
          "event": "order_created",
          "actor_id": "30000000-0000-4000-8000-000000000007",
          "note": "Fictional example: inventory reserved.",
          "created_at": "2026-08-17T12:00:00.000Z"
        },
        {
          "id": "8158e11f-df96-45ec-a21b-eaf506d530fe",
          "order_id": "ac06bc5c-34ed-4102-aff5-eeef7d8eb254",
          "event": "cancelled",
          "actor_id": "30000000-0000-4000-8000-000000000007",
          "note": "Fictional unpaid cancellation; reserved inventory restored.",
          "created_at": "2026-08-17T12:30:00.000Z"
        }
      ],
      "sample_data": true
    },
    {
      "id": "56c2a15a-8b64-4644-b811-40034aa69507",
      "order_number": 10080,
      "customer_id": "30000000-0000-4000-8000-000000000008",
      "status": "delivered",
      "payment_status": "verified",
      "address": {
        "name": "Demo Distributor 08",
        "phone": "0100000000",
        "line1": "Demo address — not for delivery",
        "city": "Petaling Jaya",
        "postcode": "47300",
        "state": "Selangor"
      },
      "subtotal_cents": 298300,
      "discount_cents": 0,
      "shipping_cents": 0,
      "total_cents": 298300,
      "payment_instructions": {
        "bank_name": "DEMO — DO NOT TRANSFER",
        "bank_account_name": "FICTIONAL EXAMPLE ONLY",
        "bank_account_number": "0000000000"
      },
      "payment_reference": "SAMPLE-NO-TRANSFER-80",
      "paid_verified_by": "seed-worker",
      "payment_note": null,
      "carrier": "Demo carrier",
      "tracking_number": "DEMO-NOT-A-PARCEL-80",
      "received_at": "2026-08-18T13:00:00.000Z",
      "cancel_reason": null,
      "idempotency_key": "528cbbf3-123f-4241-af3a-e0983c270c41",
      "created_at": "2026-08-16T13:00:00.000Z",
      "updated_at": "2026-08-18T13:00:00.000Z",
      "expires_at": "2026-08-17T13:00:00.000Z",
      "items": [
        {
          "id": "946041d9-4399-490a-b38d-b8092cd25add",
          "order_id": "56c2a15a-8b64-4644-b811-40034aa69507",
          "product_id": "castrol-magnatec-10w-40-engine-oil-4l",
          "name": "Castrol Magnatec 10W-40 Engine Oil 4L",
          "sku": "GL-0032",
          "category": "Engine Oil",
          "quantity": 19,
          "price_cents": 13500,
          "line_total_cents": 256500
        },
        {
          "id": "b8ae3cef-d9e4-449c-8972-0a35788ff7a0",
          "order_id": "56c2a15a-8b64-4644-b811-40034aa69507",
          "product_id": "bendix-dot-4-brake-and-clutch-fluid-1l",
          "name": "Bendix DOT 4 Brake and Clutch Fluid 1L",
          "sku": "GL-0003",
          "category": "Brake Fluid",
          "quantity": 19,
          "price_cents": 2200,
          "line_total_cents": 41800
        }
      ],
      "events": [
        {
          "id": "77c45631-80f0-4866-ae6a-fb039446d1ce",
          "order_id": "56c2a15a-8b64-4644-b811-40034aa69507",
          "event": "order_created",
          "actor_id": "30000000-0000-4000-8000-000000000008",
          "note": "Fictional example: inventory reserved.",
          "created_at": "2026-08-16T13:00:00.000Z"
        },
        {
          "id": "e21e7680-8302-4cb9-ae56-219f6b32981b",
          "order_id": "56c2a15a-8b64-4644-b811-40034aa69507",
          "event": "payment_submitted",
          "actor_id": "30000000-0000-4000-8000-000000000008",
          "note": "Fictional bank reference; no transfer occurred.",
          "created_at": "2026-08-16T13:10:00.000Z"
        },
        {
          "id": "f984e0fb-2b7d-475d-891f-674e56e7f666",
          "order_id": "56c2a15a-8b64-4644-b811-40034aa69507",
          "event": "payment_verified",
          "actor_id": "seed-worker",
          "note": "Fictional deposit verification.",
          "created_at": "2026-08-16T13:20:00.000Z"
        },
        {
          "id": "ab5c9113-60dd-4355-8351-e86dc2c3746c",
          "order_id": "56c2a15a-8b64-4644-b811-40034aa69507",
          "event": "shipped",
          "actor_id": "seed-worker",
          "note": "Fictional carrier and tracking number.",
          "created_at": "2026-08-17T13:00:00.000Z"
        },
        {
          "id": "c29c7a3d-22ce-4503-9299-c69330edbc5a",
          "order_id": "56c2a15a-8b64-4644-b811-40034aa69507",
          "event": "receipt_confirmed",
          "actor_id": "30000000-0000-4000-8000-000000000008",
          "note": "Fictional buyer confirmed receipt.",
          "created_at": "2026-08-18T13:00:00.000Z"
        }
      ],
      "sample_data": true
    },
    {
      "id": "5a978105-cced-412d-b16b-c7cf0ccc04d8",
      "order_number": 10081,
      "customer_id": "30000000-0000-4000-8000-000000000009",
      "status": "delivered",
      "payment_status": "verified",
      "address": {
        "name": "Demo Motorist 09",
        "phone": "0100000000",
        "line1": "Demo address — not for delivery",
        "city": "Petaling Jaya",
        "postcode": "47300",
        "state": "Selangor"
      },
      "subtotal_cents": 17000,
      "discount_cents": 0,
      "shipping_cents": 1500,
      "total_cents": 18500,
      "payment_instructions": {
        "bank_name": "DEMO — DO NOT TRANSFER",
        "bank_account_name": "FICTIONAL EXAMPLE ONLY",
        "bank_account_number": "0000000000"
      },
      "payment_reference": "SAMPLE-NO-TRANSFER-81",
      "paid_verified_by": "seed-worker",
      "payment_note": null,
      "carrier": "Demo carrier",
      "tracking_number": "DEMO-NOT-A-PARCEL-81",
      "received_at": "2026-08-17T12:00:00.000Z",
      "cancel_reason": null,
      "idempotency_key": "419afeb3-a95c-4266-b94f-037313552019",
      "created_at": "2026-08-15T12:00:00.000Z",
      "updated_at": "2026-08-17T12:00:00.000Z",
      "expires_at": "2026-08-16T12:00:00.000Z",
      "items": [
        {
          "id": "7d385fda-cf30-4202-b2bd-9a4c3da214b5",
          "order_id": "5a978105-cced-412d-b16b-c7cf0ccc04d8",
          "product_id": "castrol-80w-90-manual-gear-oil-4l",
          "name": "Castrol 80W-90 Manual Gear Oil 4L",
          "sku": "GL-0033",
          "category": "Transmission Fluid",
          "quantity": 1,
          "price_cents": 7500,
          "line_total_cents": 7500
        },
        {
          "id": "db372a2d-12da-425d-966d-7071ebb25e4e",
          "order_id": "5a978105-cced-412d-b16b-c7cf0ccc04d8",
          "product_id": "castrol-140-manual-gear-oil-4l",
          "name": "Castrol 140 Manual Gear Oil 4L",
          "sku": "GL-0023",
          "category": "Transmission Fluid",
          "quantity": 1,
          "price_cents": 7500,
          "line_total_cents": 7500
        },
        {
          "id": "c3c0c7f9-d5e9-4af6-9c2f-5778db0322b5",
          "order_id": "5a978105-cced-412d-b16b-c7cf0ccc04d8",
          "product_id": "cabin-filter-for-proton-x70",
          "name": "Cabin Filter for Proton X70",
          "sku": "GL-0010",
          "category": "Filters",
          "quantity": 1,
          "price_cents": 2000,
          "line_total_cents": 2000
        }
      ],
      "events": [
        {
          "id": "202acd8b-a3ba-4c5b-8eea-094cffd7c670",
          "order_id": "5a978105-cced-412d-b16b-c7cf0ccc04d8",
          "event": "order_created",
          "actor_id": "30000000-0000-4000-8000-000000000009",
          "note": "Fictional example: inventory reserved.",
          "created_at": "2026-08-15T12:00:00.000Z"
        },
        {
          "id": "6a30defb-0745-4821-bc2c-b92bdad743b2",
          "order_id": "5a978105-cced-412d-b16b-c7cf0ccc04d8",
          "event": "payment_submitted",
          "actor_id": "30000000-0000-4000-8000-000000000009",
          "note": "Fictional bank reference; no transfer occurred.",
          "created_at": "2026-08-15T12:10:00.000Z"
        },
        {
          "id": "221e8515-ea5a-45d6-9162-75dd24d79a03",
          "order_id": "5a978105-cced-412d-b16b-c7cf0ccc04d8",
          "event": "payment_verified",
          "actor_id": "seed-worker",
          "note": "Fictional deposit verification.",
          "created_at": "2026-08-15T12:20:00.000Z"
        },
        {
          "id": "d533d53b-9195-44f4-b929-e0fb5d0e1d46",
          "order_id": "5a978105-cced-412d-b16b-c7cf0ccc04d8",
          "event": "shipped",
          "actor_id": "seed-worker",
          "note": "Fictional carrier and tracking number.",
          "created_at": "2026-08-16T12:00:00.000Z"
        },
        {
          "id": "2a88b0a9-d0d8-4cec-bcc9-693748002b58",
          "order_id": "5a978105-cced-412d-b16b-c7cf0ccc04d8",
          "event": "receipt_confirmed",
          "actor_id": "30000000-0000-4000-8000-000000000009",
          "note": "Fictional buyer confirmed receipt.",
          "created_at": "2026-08-17T12:00:00.000Z"
        }
      ],
      "sample_data": true
    },
    {
      "id": "f0d054f2-45c0-455f-abfa-70ccccd8089e",
      "order_number": 10082,
      "customer_id": "30000000-0000-4000-8000-000000000010",
      "status": "delivered",
      "payment_status": "verified",
      "address": {
        "name": "Demo Workshop 10",
        "phone": "0100000000",
        "line1": "Demo address — not for delivery",
        "city": "Petaling Jaya",
        "postcode": "47300",
        "state": "Selangor"
      },
      "subtotal_cents": 26000,
      "discount_cents": 0,
      "shipping_cents": 0,
      "total_cents": 26000,
      "payment_instructions": {
        "bank_name": "DEMO — DO NOT TRANSFER",
        "bank_account_name": "FICTIONAL EXAMPLE ONLY",
        "bank_account_number": "0000000000"
      },
      "payment_reference": "SAMPLE-NO-TRANSFER-82",
      "paid_verified_by": "seed-worker",
      "payment_note": null,
      "carrier": "Demo carrier",
      "tracking_number": "DEMO-NOT-A-PARCEL-82",
      "received_at": "2026-08-16T13:00:00.000Z",
      "cancel_reason": null,
      "idempotency_key": "ff7120a5-b9af-495d-89e8-b2b4eceef3f5",
      "created_at": "2026-08-14T13:00:00.000Z",
      "updated_at": "2026-08-16T13:00:00.000Z",
      "expires_at": "2026-08-15T13:00:00.000Z",
      "items": [
        {
          "id": "f241cf49-8c24-4b6a-9e62-594f345d40b7",
          "order_id": "f0d054f2-45c0-455f-abfa-70ccccd8089e",
          "product_id": "bardahl-15w-40-engine-oil-4l",
          "name": "Bardahl 15W-40 Engine Oil 4L",
          "sku": "GL-0028",
          "category": "Engine Oil",
          "quantity": 4,
          "price_cents": 6500,
          "line_total_cents": 26000
        }
      ],
      "events": [
        {
          "id": "083f016d-a836-4e69-9d52-e2c3b194e4bd",
          "order_id": "f0d054f2-45c0-455f-abfa-70ccccd8089e",
          "event": "order_created",
          "actor_id": "30000000-0000-4000-8000-000000000010",
          "note": "Fictional example: inventory reserved.",
          "created_at": "2026-08-14T13:00:00.000Z"
        },
        {
          "id": "dcb14f6b-e9ea-44c7-aab5-b782a680b9d4",
          "order_id": "f0d054f2-45c0-455f-abfa-70ccccd8089e",
          "event": "payment_submitted",
          "actor_id": "30000000-0000-4000-8000-000000000010",
          "note": "Fictional bank reference; no transfer occurred.",
          "created_at": "2026-08-14T13:10:00.000Z"
        },
        {
          "id": "69541501-770a-457f-acd8-10730e23fc52",
          "order_id": "f0d054f2-45c0-455f-abfa-70ccccd8089e",
          "event": "payment_verified",
          "actor_id": "seed-worker",
          "note": "Fictional deposit verification.",
          "created_at": "2026-08-14T13:20:00.000Z"
        },
        {
          "id": "5831eddd-816d-464a-8b84-68d22a43ce49",
          "order_id": "f0d054f2-45c0-455f-abfa-70ccccd8089e",
          "event": "shipped",
          "actor_id": "seed-worker",
          "note": "Fictional carrier and tracking number.",
          "created_at": "2026-08-15T13:00:00.000Z"
        },
        {
          "id": "8983684b-a54f-4189-a126-e218bfd3f028",
          "order_id": "f0d054f2-45c0-455f-abfa-70ccccd8089e",
          "event": "receipt_confirmed",
          "actor_id": "30000000-0000-4000-8000-000000000010",
          "note": "Fictional buyer confirmed receipt.",
          "created_at": "2026-08-16T13:00:00.000Z"
        }
      ],
      "sample_data": true
    },
    {
      "id": "66cf4ec2-b61d-4c09-8a9b-4c82b73488f7",
      "order_number": 10083,
      "customer_id": "30000000-0000-4000-8000-000000000011",
      "status": "delivered",
      "payment_status": "verified",
      "address": {
        "name": "Demo Parts Shop 11",
        "phone": "0100000000",
        "line1": "Demo address — not for delivery",
        "city": "Petaling Jaya",
        "postcode": "47300",
        "state": "Selangor"
      },
      "subtotal_cents": 51700,
      "discount_cents": 0,
      "shipping_cents": 0,
      "total_cents": 51700,
      "payment_instructions": {
        "bank_name": "DEMO — DO NOT TRANSFER",
        "bank_account_name": "FICTIONAL EXAMPLE ONLY",
        "bank_account_number": "0000000000"
      },
      "payment_reference": "SAMPLE-NO-TRANSFER-83",
      "paid_verified_by": "seed-worker",
      "payment_note": null,
      "carrier": "Demo carrier",
      "tracking_number": "DEMO-NOT-A-PARCEL-83",
      "received_at": "2026-08-15T12:00:00.000Z",
      "cancel_reason": null,
      "idempotency_key": "f7d8dec5-2b54-4cda-ba4f-e089bc6c0b27",
      "created_at": "2026-08-13T12:00:00.000Z",
      "updated_at": "2026-08-15T12:00:00.000Z",
      "expires_at": "2026-08-14T12:00:00.000Z",
      "items": [
        {
          "id": "51e84dbc-02f4-4ec3-8817-942239644f3b",
          "order_id": "66cf4ec2-b61d-4c09-8a9b-4c82b73488f7",
          "product_id": "bendix-dot-4-brake-and-clutch-fluid-1l",
          "name": "Bendix DOT 4 Brake and Clutch Fluid 1L",
          "sku": "GL-0003",
          "category": "Brake Fluid",
          "quantity": 11,
          "price_cents": 2200,
          "line_total_cents": 24200
        },
        {
          "id": "18af28e4-c442-4ad0-990c-7f6110ef0255",
          "order_id": "66cf4ec2-b61d-4c09-8a9b-4c82b73488f7",
          "product_id": "perodua-radiator-coolant-1l",
          "name": "Perodua Radiator Coolant 1L",
          "sku": "GL-0024",
          "category": "Coolant",
          "quantity": 11,
          "price_cents": 2500,
          "line_total_cents": 27500
        }
      ],
      "events": [
        {
          "id": "af9ec248-907c-4258-8b7e-4efc4fe09c57",
          "order_id": "66cf4ec2-b61d-4c09-8a9b-4c82b73488f7",
          "event": "order_created",
          "actor_id": "30000000-0000-4000-8000-000000000011",
          "note": "Fictional example: inventory reserved.",
          "created_at": "2026-08-13T12:00:00.000Z"
        },
        {
          "id": "619946df-140f-49e2-acad-8139897691b0",
          "order_id": "66cf4ec2-b61d-4c09-8a9b-4c82b73488f7",
          "event": "payment_submitted",
          "actor_id": "30000000-0000-4000-8000-000000000011",
          "note": "Fictional bank reference; no transfer occurred.",
          "created_at": "2026-08-13T12:10:00.000Z"
        },
        {
          "id": "1434f29c-7c6f-45f7-8222-a937e0c37aa6",
          "order_id": "66cf4ec2-b61d-4c09-8a9b-4c82b73488f7",
          "event": "payment_verified",
          "actor_id": "seed-worker",
          "note": "Fictional deposit verification.",
          "created_at": "2026-08-13T12:20:00.000Z"
        },
        {
          "id": "87b235f7-f23e-4a70-8d1d-2dbe70d4cdf6",
          "order_id": "66cf4ec2-b61d-4c09-8a9b-4c82b73488f7",
          "event": "shipped",
          "actor_id": "seed-worker",
          "note": "Fictional carrier and tracking number.",
          "created_at": "2026-08-14T12:00:00.000Z"
        },
        {
          "id": "6f59825c-f648-4403-bac5-68f58862375d",
          "order_id": "66cf4ec2-b61d-4c09-8a9b-4c82b73488f7",
          "event": "receipt_confirmed",
          "actor_id": "30000000-0000-4000-8000-000000000011",
          "note": "Fictional buyer confirmed receipt.",
          "created_at": "2026-08-15T12:00:00.000Z"
        }
      ],
      "sample_data": true
    },
    {
      "id": "c86b86dd-e301-4d3b-9a9e-1a1e678667c0",
      "order_number": 10084,
      "customer_id": "30000000-0000-4000-8000-000000000012",
      "status": "delivered",
      "payment_status": "verified",
      "address": {
        "name": "Demo Distributor 12",
        "phone": "0100000000",
        "line1": "Demo address — not for delivery",
        "city": "Petaling Jaya",
        "postcode": "47300",
        "state": "Selangor"
      },
      "subtotal_cents": 263200,
      "discount_cents": 0,
      "shipping_cents": 0,
      "total_cents": 263200,
      "payment_instructions": {
        "bank_name": "DEMO — DO NOT TRANSFER",
        "bank_account_name": "FICTIONAL EXAMPLE ONLY",
        "bank_account_number": "0000000000"
      },
      "payment_reference": "SAMPLE-NO-TRANSFER-84",
      "paid_verified_by": "seed-worker",
      "payment_note": null,
      "carrier": "Demo carrier",
      "tracking_number": "DEMO-NOT-A-PARCEL-84",
      "received_at": "2026-08-14T13:00:00.000Z",
      "cancel_reason": null,
      "idempotency_key": "40c93f26-6a3a-4ed9-b852-72e9c78eb190",
      "created_at": "2026-08-12T13:00:00.000Z",
      "updated_at": "2026-08-14T13:00:00.000Z",
      "expires_at": "2026-08-13T13:00:00.000Z",
      "items": [
        {
          "id": "68b40a3b-ea44-469e-9819-c231b97bf97a",
          "order_id": "c86b86dd-e301-4d3b-9a9e-1a1e678667c0",
          "product_id": "proton-atf-hts-4at-fully-synthetic-fluid-3l",
          "name": "Proton ATF HTS 4AT Fully Synthetic Fluid 3L",
          "sku": "GL-0041",
          "category": "Transmission Fluid",
          "quantity": 14,
          "price_cents": 11500,
          "line_total_cents": 161000
        },
        {
          "id": "2568dc3c-7bec-409e-bb5f-d10f22ad9ce9",
          "order_id": "c86b86dd-e301-4d3b-9a9e-1a1e678667c0",
          "product_id": "engine-air-filter-for-proton-x70",
          "name": "Engine Air Filter for Proton X70",
          "sku": "GL-0012",
          "category": "Filters",
          "quantity": 14,
          "price_cents": 1800,
          "line_total_cents": 25200
        },
        {
          "id": "26417dec-32fe-4b4e-b320-9018602685d7",
          "order_id": "c86b86dd-e301-4d3b-9a9e-1a1e678667c0",
          "product_id": "trw-gdb7707-front-brake-pads",
          "name": "TRW GDB7707 Front Brake Pads",
          "sku": "GL-0043",
          "category": "Brake Pads",
          "quantity": 14,
          "price_cents": 5500,
          "line_total_cents": 77000
        }
      ],
      "events": [
        {
          "id": "52021fa9-72a5-49af-b28b-cb1ee85b3337",
          "order_id": "c86b86dd-e301-4d3b-9a9e-1a1e678667c0",
          "event": "order_created",
          "actor_id": "30000000-0000-4000-8000-000000000012",
          "note": "Fictional example: inventory reserved.",
          "created_at": "2026-08-12T13:00:00.000Z"
        },
        {
          "id": "218b2c96-e4e2-405d-8673-b10bd687f552",
          "order_id": "c86b86dd-e301-4d3b-9a9e-1a1e678667c0",
          "event": "payment_submitted",
          "actor_id": "30000000-0000-4000-8000-000000000012",
          "note": "Fictional bank reference; no transfer occurred.",
          "created_at": "2026-08-12T13:10:00.000Z"
        },
        {
          "id": "f8b5e505-9079-40aa-b997-dd1f5ba54461",
          "order_id": "c86b86dd-e301-4d3b-9a9e-1a1e678667c0",
          "event": "payment_verified",
          "actor_id": "seed-worker",
          "note": "Fictional deposit verification.",
          "created_at": "2026-08-12T13:20:00.000Z"
        },
        {
          "id": "1c685a99-5fa8-42c4-ac8d-91cbc3995a9f",
          "order_id": "c86b86dd-e301-4d3b-9a9e-1a1e678667c0",
          "event": "shipped",
          "actor_id": "seed-worker",
          "note": "Fictional carrier and tracking number.",
          "created_at": "2026-08-13T13:00:00.000Z"
        },
        {
          "id": "89b75f15-58d2-4fa4-91ed-43115f771eed",
          "order_id": "c86b86dd-e301-4d3b-9a9e-1a1e678667c0",
          "event": "receipt_confirmed",
          "actor_id": "30000000-0000-4000-8000-000000000012",
          "note": "Fictional buyer confirmed receipt.",
          "created_at": "2026-08-14T13:00:00.000Z"
        }
      ],
      "sample_data": true
    }
  ],
  "refunds": [
    {
      "id": "7cfd51c5-7ecd-4f5c-8a9b-bd3477b517bf",
      "order_id": "6e25d28e-1844-48de-b341-8fb237db1cdf",
      "customer_id": "30000000-0000-4000-8000-000000000008",
      "reason": "Fictional example: the buyer ordered the wrong specification.",
      "status": "paid",
      "amount_cents": 89300,
      "staff_note": "Fictional return review only.",
      "transfer_reference": "DEMO-REFUND-NOT-PAID-8",
      "return_received": true,
      "stock_restored": true,
      "created_at": "2026-10-24T01:00:00.000Z",
      "updated_at": "2026-10-24T13:00:00.000Z",
      "sample_data": true
    },
    {
      "id": "f3b12e26-da23-4f83-869d-6b3bfcf3c43e",
      "order_id": "3b2e2bed-8f6e-43d8-80bf-29b3898ecc7e",
      "customer_id": "30000000-0000-4000-8000-000000000001",
      "reason": "Fictional example: the buyer ordered the wrong specification.",
      "status": "requested",
      "amount_cents": 7500,
      "staff_note": null,
      "transfer_reference": null,
      "return_received": false,
      "stock_restored": false,
      "created_at": "2026-10-18T13:00:00.000Z",
      "updated_at": "2026-10-19T01:00:00.000Z",
      "sample_data": true
    },
    {
      "id": "e42b1fb2-2d27-409f-8f40-e8c0bced090d",
      "order_id": "441664bc-c8d2-4f48-8df3-78504a1ef436",
      "customer_id": "30000000-0000-4000-8000-000000000002",
      "reason": "Fictional example: the buyer ordered the wrong specification.",
      "status": "approved",
      "amount_cents": 14300,
      "staff_note": "Fictional return review only.",
      "transfer_reference": null,
      "return_received": true,
      "stock_restored": false,
      "created_at": "2026-10-17T14:00:00.000Z",
      "updated_at": "2026-10-18T02:00:00.000Z",
      "sample_data": true
    },
    {
      "id": "6138bbb4-596c-4b12-9b83-ffe5b6d52088",
      "order_id": "98b1d760-8479-42c0-a53b-29499f216be6",
      "customer_id": "30000000-0000-4000-8000-000000000006",
      "reason": "Fictional example: the buyer ordered the wrong specification.",
      "status": "paid",
      "amount_cents": 40400,
      "staff_note": "Fictional return review only.",
      "transfer_reference": "DEMO-REFUND-NOT-PAID-18",
      "return_received": true,
      "stock_restored": true,
      "created_at": "2026-10-19T22:00:00.000Z",
      "updated_at": "2026-10-20T10:00:00.000Z",
      "sample_data": true
    },
    {
      "id": "4b9ef7d8-7c61-4691-ac55-5eecc49c8e26",
      "order_id": "4a752e25-7b6b-49ba-8f04-62cba0829be1",
      "customer_id": "30000000-0000-4000-8000-000000000011",
      "reason": "Fictional example: the buyer ordered the wrong specification.",
      "status": "paid",
      "amount_cents": 42000,
      "staff_note": "Fictional return review only.",
      "transfer_reference": "DEMO-REFUND-NOT-PAID-35",
      "return_received": true,
      "stock_restored": true,
      "created_at": "2026-10-03T00:00:00.000Z",
      "updated_at": "2026-10-03T12:00:00.000Z",
      "sample_data": true
    },
    {
      "id": "ddd33726-2df2-4142-b973-9d0001fdbc01",
      "order_id": "5118c922-5af1-4013-a516-ae7155018ace",
      "customer_id": "30000000-0000-4000-8000-000000000004",
      "reason": "Fictional example: the buyer ordered the wrong specification.",
      "status": "paid",
      "amount_cents": 90000,
      "staff_note": "Fictional return review only.",
      "transfer_reference": "DEMO-REFUND-NOT-PAID-52",
      "return_received": true,
      "stock_restored": true,
      "created_at": "2026-09-15T17:00:00.000Z",
      "updated_at": "2026-09-16T05:00:00.000Z",
      "sample_data": true
    },
    {
      "id": "98dd7c0f-2450-45cc-8f3e-854542d86ea5",
      "order_id": "c12d5bc2-9b0b-45f7-9ef7-124b09a467be",
      "customer_id": "30000000-0000-4000-8000-000000000009",
      "reason": "Fictional example: the buyer ordered the wrong specification.",
      "status": "paid",
      "amount_cents": 8100,
      "staff_note": "Fictional return review only.",
      "transfer_reference": "DEMO-REFUND-NOT-PAID-69",
      "return_received": true,
      "stock_restored": true,
      "created_at": "2026-08-30T00:00:00.000Z",
      "updated_at": "2026-08-30T12:00:00.000Z",
      "sample_data": true
    }
  ],
  "reviews": [
    {
      "id": "92f2ca59-2990-4774-8227-8ba26bd34184",
      "order_id": "e3153f45-a852-4264-84b8-a1d8c2d17ea6",
      "product_id": "x-traseal-carburetor-and-choke-cleaner-400ml",
      "customer_id": "30000000-0000-4000-8000-000000000006",
      "display_name": "Demo Workshop 06",
      "rating": 3,
      "body": "Fictional verified-purchase feedback: received the selected specification and checked the packaging.",
      "reply": "Example seller reply: thank you for checking the specification.",
      "reply_by": "seed-worker",
      "published": true,
      "created_at": "2026-10-26T10:00:00.000Z",
      "sample_data": true
    },
    {
      "id": "6cd3750f-f7d1-402a-be61-11308016342e",
      "order_id": "1291de7f-ce68-4f87-962d-c5e747d8367f",
      "product_id": "x-traseal-carburetor-and-choke-cleaner-400ml",
      "customer_id": "30000000-0000-4000-8000-000000000010",
      "display_name": "Demo Workshop 10",
      "rating": 4,
      "body": "Fictional verified-purchase feedback: received the selected specification and checked the packaging.",
      "reply": "Example seller reply: thank you for checking the specification.",
      "reply_by": "seed-worker",
      "published": true,
      "created_at": "2026-10-22T13:00:00.000Z",
      "sample_data": true
    },
    {
      "id": "2e463d29-2674-4b76-b70f-972e5ff377e8",
      "order_id": "441664bc-c8d2-4f48-8df3-78504a1ef436",
      "product_id": "power-up-power-steering-fluid-1l",
      "customer_id": "30000000-0000-4000-8000-000000000002",
      "display_name": "Demo Workshop 02",
      "rating": 5,
      "body": "Fictional verified-purchase feedback: received the selected specification and checked the packaging.",
      "reply": "Example seller reply: thank you for checking the specification.",
      "reply_by": "seed-worker",
      "published": true,
      "created_at": "2026-10-18T02:00:00.000Z",
      "sample_data": true
    },
    {
      "id": "3ce02933-b13e-467b-9de3-659bd7182cc7",
      "order_id": "8424ad93-a3a6-4458-a46a-7aa1778ad160",
      "product_id": "toyota-5w-30-engine-oil-4l",
      "customer_id": "30000000-0000-4000-8000-000000000010",
      "display_name": "Demo Workshop 10",
      "rating": 4,
      "body": "Fictional verified-purchase feedback: received the selected specification and checked the packaging.",
      "reply": "Example seller reply: thank you for checking the specification.",
      "reply_by": "seed-worker",
      "published": true,
      "created_at": "2026-10-16T13:00:00.000Z",
      "sample_data": true
    },
    {
      "id": "99fef462-ece2-4286-9992-2af1c96212c8",
      "order_id": "57b7fc9c-af3e-4c07-b147-751efdb14810",
      "product_id": "top-1-green-radiator-coolant-500ml",
      "customer_id": "30000000-0000-4000-8000-000000000002",
      "display_name": "Demo Workshop 02",
      "rating": 3,
      "body": "Fictional verified-purchase feedback: received the selected specification and checked the packaging.",
      "reply": "Example seller reply: thank you for checking the specification.",
      "reply_by": "seed-worker",
      "published": true,
      "created_at": "2026-10-12T02:00:00.000Z",
      "sample_data": true
    },
    {
      "id": "50bfbad2-577e-4eed-b346-ab235c528e73",
      "order_id": "a0a03351-c591-4d54-8519-334ceded68f1",
      "product_id": "trw-gdb7707-front-brake-pads",
      "customer_id": "30000000-0000-4000-8000-000000000006",
      "display_name": "Demo Workshop 06",
      "rating": 5,
      "body": "Fictional verified-purchase feedback: received the selected specification and checked the packaging.",
      "reply": "Example seller reply: thank you for checking the specification.",
      "reply_by": "seed-worker",
      "published": true,
      "created_at": "2026-10-08T10:00:00.000Z",
      "sample_data": true
    },
    {
      "id": "ed2c716f-0dbe-43d0-866e-92f8dad1659c",
      "order_id": "0921b3fa-282d-471d-8434-44cd94bf210d",
      "product_id": "trw-gdb8977-front-brake-pads",
      "customer_id": "30000000-0000-4000-8000-000000000010",
      "display_name": "Demo Workshop 10",
      "rating": 4,
      "body": "Fictional verified-purchase feedback: received the selected specification and checked the packaging.",
      "reply": "Example seller reply: thank you for checking the specification.",
      "reply_by": "seed-worker",
      "published": true,
      "created_at": "2026-10-04T13:00:00.000Z",
      "sample_data": true
    },
    {
      "id": "ba50efd5-6148-4e39-a653-00040f06a209",
      "order_id": "e731e604-9a6f-4980-8ee5-cbf3c0a1cbe1",
      "product_id": "bendix-dot-4-brake-and-clutch-fluid-1l",
      "customer_id": "30000000-0000-4000-8000-000000000002",
      "display_name": "Demo Workshop 02",
      "rating": 5,
      "body": "Fictional verified-purchase feedback: received the selected specification and checked the packaging.",
      "reply": "Example seller reply: thank you for checking the specification.",
      "reply_by": "seed-worker",
      "published": true,
      "created_at": "2026-09-30T02:00:00.000Z",
      "sample_data": true
    },
    {
      "id": "a01c182f-a91a-415f-ae5b-e16525944c68",
      "order_id": "a3b59873-f017-4067-abf1-3ef0202b6f37",
      "product_id": "cabin-filter-for-proton-x50",
      "customer_id": "30000000-0000-4000-8000-000000000006",
      "display_name": "Demo Workshop 06",
      "rating": 5,
      "body": "Fictional verified-purchase feedback: received the selected specification and checked the packaging.",
      "reply": "Example seller reply: thank you for checking the specification.",
      "reply_by": "seed-worker",
      "published": true,
      "created_at": "2026-09-26T10:00:00.000Z",
      "sample_data": true
    },
    {
      "id": "954fdf03-0ecf-4ec2-a10d-6310f1ab4915",
      "order_id": "fdfbdca8-095c-4917-a859-c9f3c44aa894",
      "product_id": "sae-40-engine-oil-1l",
      "customer_id": "30000000-0000-4000-8000-000000000010",
      "display_name": "Demo Workshop 10",
      "rating": 3,
      "body": "Fictional verified-purchase feedback: received the selected specification and checked the packaging.",
      "reply": "Example seller reply: thank you for checking the specification.",
      "reply_by": "seed-worker",
      "published": true,
      "created_at": "2026-09-22T13:00:00.000Z",
      "sample_data": true
    },
    {
      "id": "3bbf524d-b87e-47c1-a485-1baf674ce91d",
      "order_id": "1cf203d3-58d9-4a66-9a83-0040c66e3e10",
      "product_id": "sae-40-engine-oil-1l",
      "customer_id": "30000000-0000-4000-8000-000000000002",
      "display_name": "Demo Workshop 02",
      "rating": 5,
      "body": "Fictional verified-purchase feedback: received the selected specification and checked the packaging.",
      "reply": "Example seller reply: thank you for checking the specification.",
      "reply_by": "seed-worker",
      "published": true,
      "created_at": "2026-09-18T02:00:00.000Z",
      "sample_data": true
    },
    {
      "id": "556e0de1-160f-49cf-9fec-dc1a3030b4e5",
      "order_id": "562a8186-8922-41da-87d0-3f9761e08b2b",
      "product_id": "castrol-80w-90-manual-gear-oil-4l",
      "customer_id": "30000000-0000-4000-8000-000000000006",
      "display_name": "Demo Workshop 06",
      "rating": 5,
      "body": "Fictional verified-purchase feedback: received the selected specification and checked the packaging.",
      "reply": "Example seller reply: thank you for checking the specification.",
      "reply_by": "seed-worker",
      "published": true,
      "created_at": "2026-09-14T10:00:00.000Z",
      "sample_data": true
    },
    {
      "id": "46bf70b6-e409-4970-8b8d-bd97554dbcac",
      "order_id": "d3011c8c-6e6e-40ee-8ffa-32507f6b6106",
      "product_id": "ngk-lkar7c-9-spark-plugs-4-pack",
      "customer_id": "30000000-0000-4000-8000-000000000010",
      "display_name": "Demo Workshop 10",
      "rating": 4,
      "body": "Fictional verified-purchase feedback: received the selected specification and checked the packaging.",
      "reply": "Example seller reply: thank you for checking the specification.",
      "reply_by": "seed-worker",
      "published": true,
      "created_at": "2026-09-10T13:00:00.000Z",
      "sample_data": true
    },
    {
      "id": "70081fb3-28f3-4c79-bde2-96b386d225d0",
      "order_id": "9f83a097-a7c4-4ec1-a544-1b385935c1c6",
      "product_id": "cabin-filter-for-proton-x50",
      "customer_id": "30000000-0000-4000-8000-000000000002",
      "display_name": "Demo Workshop 02",
      "rating": 5,
      "body": "Fictional verified-purchase feedback: received the selected specification and checked the packaging.",
      "reply": "Example seller reply: thank you for checking the specification.",
      "reply_by": "seed-worker",
      "published": true,
      "created_at": "2026-09-06T02:00:00.000Z",
      "sample_data": true
    },
    {
      "id": "e49067f1-e9f2-4e06-a624-4fbd8cc5bc63",
      "order_id": "b97631df-1749-49d5-8fc7-fc2dde9e8116",
      "product_id": "x-traseal-carburetor-and-choke-cleaner-400ml",
      "customer_id": "30000000-0000-4000-8000-000000000010",
      "display_name": "Demo Workshop 10",
      "rating": 4,
      "body": "Fictional verified-purchase feedback: received the selected specification and checked the packaging.",
      "reply": "Example seller reply: thank you for checking the specification.",
      "reply_by": "seed-worker",
      "published": true,
      "created_at": "2026-08-29T13:00:00.000Z",
      "sample_data": true
    },
    {
      "id": "88a65aae-c530-47b5-bf1f-035462542345",
      "order_id": "38aa5f81-d407-4784-9974-2fea74a8eee4",
      "product_id": "power-up-power-steering-fluid-1l",
      "customer_id": "30000000-0000-4000-8000-000000000002",
      "display_name": "Demo Workshop 02",
      "rating": 5,
      "body": "Fictional verified-purchase feedback: received the selected specification and checked the packaging.",
      "reply": "Example seller reply: thank you for checking the specification.",
      "reply_by": "seed-worker",
      "published": true,
      "created_at": "2026-08-25T02:00:00.000Z",
      "sample_data": true
    },
    {
      "id": "bd0486fb-c6e2-45c2-ad04-0b48a9475039",
      "order_id": "b689b1fa-5ffc-47a2-a111-b0f4bc4c9ca8",
      "product_id": "toyota-fully-synthetic-0w-20-engine-oil-4l",
      "customer_id": "30000000-0000-4000-8000-000000000006",
      "display_name": "Demo Workshop 06",
      "rating": 5,
      "body": "Fictional verified-purchase feedback: received the selected specification and checked the packaging.",
      "reply": "Example seller reply: thank you for checking the specification.",
      "reply_by": "seed-worker",
      "published": true,
      "created_at": "2026-08-21T10:00:00.000Z",
      "sample_data": true
    },
    {
      "id": "a3566410-fb4f-4780-ae70-0291344906d9",
      "order_id": "f0d054f2-45c0-455f-abfa-70ccccd8089e",
      "product_id": "bardahl-15w-40-engine-oil-4l",
      "customer_id": "30000000-0000-4000-8000-000000000010",
      "display_name": "Demo Workshop 10",
      "rating": 4,
      "body": "Fictional verified-purchase feedback: received the selected specification and checked the packaging.",
      "reply": "Example seller reply: thank you for checking the specification.",
      "reply_by": "seed-worker",
      "published": true,
      "created_at": "2026-08-17T13:00:00.000Z",
      "sample_data": true
    }
  ],
  "wishlist": [
    {
      "user_id": "30000000-0000-4000-8000-000000000001",
      "product_id": "toyota-fully-synthetic-0w-20-engine-oil-4l",
      "created_at": "2026-10-27T09:21:21.350Z",
      "sample_data": true
    },
    {
      "user_id": "30000000-0000-4000-8000-000000000001",
      "product_id": "x-traseal-carburetor-and-choke-cleaner-400ml",
      "created_at": "2026-10-27T09:21:21.350Z",
      "sample_data": true
    },
    {
      "user_id": "30000000-0000-4000-8000-000000000002",
      "product_id": "castrol-gtx-ultraclean-15w-40-engine-oil-4l",
      "created_at": "2026-10-26T09:21:21.350Z",
      "sample_data": true
    },
    {
      "user_id": "30000000-0000-4000-8000-000000000002",
      "product_id": "cabin-filter-for-proton-x50",
      "created_at": "2026-10-26T09:21:21.350Z",
      "sample_data": true
    },
    {
      "user_id": "30000000-0000-4000-8000-000000000002",
      "product_id": "cvt-gearbox-filter-and-gasket-set",
      "created_at": "2026-10-26T09:21:21.350Z",
      "sample_data": true
    },
    {
      "user_id": "30000000-0000-4000-8000-000000000003",
      "product_id": "proton-blue-radiator-coolant-4l",
      "created_at": "2026-10-25T09:21:21.350Z",
      "sample_data": true
    },
    {
      "user_id": "30000000-0000-4000-8000-000000000003",
      "product_id": "engine-air-filter-for-proton-x70",
      "created_at": "2026-10-25T09:21:21.350Z",
      "sample_data": true
    },
    {
      "user_id": "30000000-0000-4000-8000-000000000003",
      "product_id": "petrol-filter-for-proton-iriz-saga-vvt-persona-vvt",
      "created_at": "2026-10-25T09:21:21.350Z",
      "sample_data": true
    },
    {
      "user_id": "30000000-0000-4000-8000-000000000003",
      "product_id": "silicone-air-filter-housing-bush-1-piece",
      "created_at": "2026-10-25T09:21:21.350Z",
      "sample_data": true
    },
    {
      "user_id": "30000000-0000-4000-8000-000000000004",
      "product_id": "cabin-filter-for-proton-x70",
      "created_at": "2026-10-24T09:21:21.350Z",
      "sample_data": true
    },
    {
      "user_id": "30000000-0000-4000-8000-000000000004",
      "product_id": "manual-gear-oil-80w-90-4l",
      "created_at": "2026-10-24T09:21:21.350Z",
      "sample_data": true
    },
    {
      "user_id": "30000000-0000-4000-8000-000000000004",
      "product_id": "perodua-fully-synthetic-0w-20-oil-3-5l-filter",
      "created_at": "2026-10-24T09:21:21.350Z",
      "sample_data": true
    },
    {
      "user_id": "30000000-0000-4000-8000-000000000004",
      "product_id": "ngk-lkr6c-spark-plug",
      "created_at": "2026-10-24T09:21:21.350Z",
      "sample_data": true
    },
    {
      "user_id": "30000000-0000-4000-8000-000000000004",
      "product_id": "10w-30-engine-oil-perodua-oil-filter-bundle",
      "created_at": "2026-10-24T09:21:21.350Z",
      "sample_data": true
    },
    {
      "user_id": "30000000-0000-4000-8000-000000000005",
      "product_id": "top-1-green-radiator-coolant-500ml",
      "created_at": "2026-10-23T09:21:21.350Z",
      "sample_data": true
    },
    {
      "user_id": "30000000-0000-4000-8000-000000000005",
      "product_id": "denso-k20tnr-s-spark-plugs-4-pack",
      "created_at": "2026-10-23T09:21:21.350Z",
      "sample_data": true
    },
    {
      "user_id": "30000000-0000-4000-8000-000000000006",
      "product_id": "manual-gear-oil-ep-140-1l",
      "created_at": "2026-10-22T09:21:21.350Z",
      "sample_data": true
    },
    {
      "user_id": "30000000-0000-4000-8000-000000000006",
      "product_id": "ngk-lkar7c-9-spark-plugs-4-pack",
      "created_at": "2026-10-22T09:21:21.350Z",
      "sample_data": true
    },
    {
      "user_id": "30000000-0000-4000-8000-000000000006",
      "product_id": "power-up-power-steering-fluid-1l",
      "created_at": "2026-10-22T09:21:21.350Z",
      "sample_data": true
    },
    {
      "user_id": "30000000-0000-4000-8000-000000000007",
      "product_id": "aftermarket-engine-oil-filters-10-pack",
      "created_at": "2026-10-21T09:21:21.350Z",
      "sample_data": true
    },
    {
      "user_id": "30000000-0000-4000-8000-000000000007",
      "product_id": "perodua-radiator-coolant-1l",
      "created_at": "2026-10-21T09:21:21.350Z",
      "sample_data": true
    },
    {
      "user_id": "30000000-0000-4000-8000-000000000007",
      "product_id": "bardahl-10w-30-engine-oil-3-quarts",
      "created_at": "2026-10-21T09:21:21.350Z",
      "sample_data": true
    },
    {
      "user_id": "30000000-0000-4000-8000-000000000007",
      "product_id": "castrol-gtx-10w-30-engine-oil-4l",
      "created_at": "2026-10-21T09:21:21.350Z",
      "sample_data": true
    },
    {
      "user_id": "30000000-0000-4000-8000-000000000008",
      "product_id": "silicone-air-filter-housing-bush-1-piece",
      "created_at": "2026-10-20T09:21:21.350Z",
      "sample_data": true
    },
    {
      "user_id": "30000000-0000-4000-8000-000000000008",
      "product_id": "denso-k16pru-11-spark-plugs-3-pack",
      "created_at": "2026-10-20T09:21:21.350Z",
      "sample_data": true
    },
    {
      "user_id": "30000000-0000-4000-8000-000000000008",
      "product_id": "castrol-magnatec-10w-40-engine-oil-4l",
      "created_at": "2026-10-20T09:21:21.350Z",
      "sample_data": true
    },
    {
      "user_id": "30000000-0000-4000-8000-000000000008",
      "product_id": "cabin-filter-for-perodua-myvi-alza-axia-bezza",
      "created_at": "2026-10-20T09:21:21.350Z",
      "sample_data": true
    },
    {
      "user_id": "30000000-0000-4000-8000-000000000008",
      "product_id": "front-brake-pads-for-proton-gen-2-persona-neo",
      "created_at": "2026-10-20T09:21:21.350Z",
      "sample_data": true
    },
    {
      "user_id": "30000000-0000-4000-8000-000000000009",
      "product_id": "ngk-lkr6c-spark-plug",
      "created_at": "2026-10-19T09:21:21.350Z",
      "sample_data": true
    },
    {
      "user_id": "30000000-0000-4000-8000-000000000009",
      "product_id": "10w-30-engine-oil-perodua-oil-filter-bundle",
      "created_at": "2026-10-19T09:21:21.350Z",
      "sample_data": true
    },
    {
      "user_id": "30000000-0000-4000-8000-000000000010",
      "product_id": "bardahl-15w-40-engine-oil-4l",
      "created_at": "2026-10-18T09:21:21.350Z",
      "sample_data": true
    },
    {
      "user_id": "30000000-0000-4000-8000-000000000010",
      "product_id": "castrol-80w-90-manual-gear-oil-4l",
      "created_at": "2026-10-18T09:21:21.350Z",
      "sample_data": true
    },
    {
      "user_id": "30000000-0000-4000-8000-000000000010",
      "product_id": "bosch-super-4-fr78x-spark-plugs-4-pack",
      "created_at": "2026-10-18T09:21:21.350Z",
      "sample_data": true
    },
    {
      "user_id": "30000000-0000-4000-8000-000000000011",
      "product_id": "castrol-gtx-10w-30-engine-oil-3l",
      "created_at": "2026-10-17T09:21:21.350Z",
      "sample_data": true
    },
    {
      "user_id": "30000000-0000-4000-8000-000000000011",
      "product_id": "toyota-5w-30-engine-oil-4l",
      "created_at": "2026-10-17T09:21:21.350Z",
      "sample_data": true
    },
    {
      "user_id": "30000000-0000-4000-8000-000000000011",
      "product_id": "proton-atf-hts-4at-fully-synthetic-fluid-3l",
      "created_at": "2026-10-17T09:21:21.350Z",
      "sample_data": true
    },
    {
      "user_id": "30000000-0000-4000-8000-000000000011",
      "product_id": "trw-gdb1198-front-brake-pads",
      "created_at": "2026-10-17T09:21:21.350Z",
      "sample_data": true
    },
    {
      "user_id": "30000000-0000-4000-8000-000000000012",
      "product_id": "castrol-gtx-10w-30-engine-oil-4l",
      "created_at": "2026-10-16T09:21:21.350Z",
      "sample_data": true
    },
    {
      "user_id": "30000000-0000-4000-8000-000000000012",
      "product_id": "bosch-super-4-wr78x-spark-plugs-4-pack",
      "created_at": "2026-10-16T09:21:21.350Z",
      "sample_data": true
    },
    {
      "user_id": "30000000-0000-4000-8000-000000000012",
      "product_id": "trw-gdb7742-front-brake-pads",
      "created_at": "2026-10-16T09:21:21.350Z",
      "sample_data": true
    },
    {
      "user_id": "30000000-0000-4000-8000-000000000012",
      "product_id": "toyota-fully-synthetic-0w-20-engine-oil-4l",
      "created_at": "2026-10-16T09:21:21.350Z",
      "sample_data": true
    },
    {
      "user_id": "30000000-0000-4000-8000-000000000012",
      "product_id": "x-traseal-carburetor-and-choke-cleaner-400ml",
      "created_at": "2026-10-16T09:21:21.350Z",
      "sample_data": true
    }
  ],
  "activity": [
    {
      "user_id": "30000000-0000-4000-8000-000000000001",
      "event": "session_started",
      "product_id": null,
      "session_id": "4c2444c4-6115-4654-b794-9be42b11eea3",
      "created_at": "2026-10-28T07:06:21.350Z",
      "sample_data": true
    },
    {
      "user_id": "30000000-0000-4000-8000-000000000001",
      "event": "view_product",
      "product_id": "toyota-fully-synthetic-0w-20-engine-oil-4l",
      "session_id": "4c2444c4-6115-4654-b794-9be42b11eea3",
      "created_at": "2026-10-28T07:11:21.350Z",
      "sample_data": true
    },
    {
      "user_id": "30000000-0000-4000-8000-000000000001",
      "event": "checkout_started",
      "product_id": null,
      "session_id": "4c2444c4-6115-4654-b794-9be42b11eea3",
      "created_at": "2026-10-28T07:16:21.350Z",
      "sample_data": true
    },
    {
      "user_id": "30000000-0000-4000-8000-000000000001",
      "event": "order_placed",
      "product_id": null,
      "session_id": "4c2444c4-6115-4654-b794-9be42b11eea3",
      "created_at": "2026-10-28T07:21:21.350Z",
      "sample_data": true
    },
    {
      "user_id": "30000000-0000-4000-8000-000000000002",
      "event": "session_started",
      "product_id": null,
      "session_id": "96af834c-3399-48e5-aaf3-d89fd63ffaa5",
      "created_at": "2026-10-28T06:06:21.350Z",
      "sample_data": true
    },
    {
      "user_id": "30000000-0000-4000-8000-000000000002",
      "event": "view_product",
      "product_id": "cabin-filter-for-proton-x50",
      "session_id": "96af834c-3399-48e5-aaf3-d89fd63ffaa5",
      "created_at": "2026-10-28T06:11:21.350Z",
      "sample_data": true
    },
    {
      "user_id": "30000000-0000-4000-8000-000000000002",
      "event": "checkout_started",
      "product_id": null,
      "session_id": "96af834c-3399-48e5-aaf3-d89fd63ffaa5",
      "created_at": "2026-10-28T06:16:21.350Z",
      "sample_data": true
    },
    {
      "user_id": "30000000-0000-4000-8000-000000000002",
      "event": "order_placed",
      "product_id": null,
      "session_id": "96af834c-3399-48e5-aaf3-d89fd63ffaa5",
      "created_at": "2026-10-28T06:21:21.350Z",
      "sample_data": true
    },
    {
      "user_id": "30000000-0000-4000-8000-000000000003",
      "event": "session_started",
      "product_id": null,
      "session_id": "9ee51503-d4c5-489b-9c6f-0802b56727a8",
      "created_at": "2026-10-28T05:06:21.350Z",
      "sample_data": true
    },
    {
      "user_id": "30000000-0000-4000-8000-000000000003",
      "event": "view_product",
      "product_id": "castrol-gtx-ultraclean-15w-40-engine-oil-4l",
      "session_id": "9ee51503-d4c5-489b-9c6f-0802b56727a8",
      "created_at": "2026-10-28T05:11:21.350Z",
      "sample_data": true
    },
    {
      "user_id": "30000000-0000-4000-8000-000000000003",
      "event": "checkout_started",
      "product_id": null,
      "session_id": "9ee51503-d4c5-489b-9c6f-0802b56727a8",
      "created_at": "2026-10-28T05:16:21.350Z",
      "sample_data": true
    },
    {
      "user_id": "30000000-0000-4000-8000-000000000003",
      "event": "order_placed",
      "product_id": null,
      "session_id": "9ee51503-d4c5-489b-9c6f-0802b56727a8",
      "created_at": "2026-10-28T05:21:21.350Z",
      "sample_data": true
    },
    {
      "user_id": "30000000-0000-4000-8000-000000000004",
      "event": "session_started",
      "product_id": null,
      "session_id": "7b26be84-6594-4323-9029-6a9593ba9b0c",
      "created_at": "2026-10-25T04:45:00.000Z",
      "sample_data": true
    },
    {
      "user_id": "30000000-0000-4000-8000-000000000004",
      "event": "view_product",
      "product_id": "trw-gdb7986-front-brake-pads",
      "session_id": "7b26be84-6594-4323-9029-6a9593ba9b0c",
      "created_at": "2026-10-25T04:50:00.000Z",
      "sample_data": true
    },
    {
      "user_id": "30000000-0000-4000-8000-000000000004",
      "event": "checkout_started",
      "product_id": null,
      "session_id": "7b26be84-6594-4323-9029-6a9593ba9b0c",
      "created_at": "2026-10-25T04:55:00.000Z",
      "sample_data": true
    },
    {
      "user_id": "30000000-0000-4000-8000-000000000004",
      "event": "order_placed",
      "product_id": null,
      "session_id": "7b26be84-6594-4323-9029-6a9593ba9b0c",
      "created_at": "2026-10-25T05:00:00.000Z",
      "sample_data": true
    },
    {
      "user_id": "30000000-0000-4000-8000-000000000005",
      "event": "session_started",
      "product_id": null,
      "session_id": "89e0ca0f-3a8d-44c2-a13c-3037b6a77d56",
      "created_at": "2026-10-24T05:45:00.000Z",
      "sample_data": true
    },
    {
      "user_id": "30000000-0000-4000-8000-000000000005",
      "event": "view_product",
      "product_id": "proton-cvt-transmission-fluid-1l",
      "session_id": "89e0ca0f-3a8d-44c2-a13c-3037b6a77d56",
      "created_at": "2026-10-24T05:50:00.000Z",
      "sample_data": true
    },
    {
      "user_id": "30000000-0000-4000-8000-000000000005",
      "event": "checkout_started",
      "product_id": null,
      "session_id": "89e0ca0f-3a8d-44c2-a13c-3037b6a77d56",
      "created_at": "2026-10-24T05:55:00.000Z",
      "sample_data": true
    },
    {
      "user_id": "30000000-0000-4000-8000-000000000005",
      "event": "order_placed",
      "product_id": null,
      "session_id": "89e0ca0f-3a8d-44c2-a13c-3037b6a77d56",
      "created_at": "2026-10-24T06:00:00.000Z",
      "sample_data": true
    },
    {
      "user_id": "30000000-0000-4000-8000-000000000006",
      "event": "session_started",
      "product_id": null,
      "session_id": "269ec726-bc15-45f1-9ca0-9cc09aed472c",
      "created_at": "2026-10-23T09:45:00.000Z",
      "sample_data": true
    },
    {
      "user_id": "30000000-0000-4000-8000-000000000006",
      "event": "view_product",
      "product_id": "x-traseal-carburetor-and-choke-cleaner-400ml",
      "session_id": "269ec726-bc15-45f1-9ca0-9cc09aed472c",
      "created_at": "2026-10-23T09:50:00.000Z",
      "sample_data": true
    },
    {
      "user_id": "30000000-0000-4000-8000-000000000006",
      "event": "checkout_started",
      "product_id": null,
      "session_id": "269ec726-bc15-45f1-9ca0-9cc09aed472c",
      "created_at": "2026-10-23T09:55:00.000Z",
      "sample_data": true
    },
    {
      "user_id": "30000000-0000-4000-8000-000000000006",
      "event": "order_placed",
      "product_id": null,
      "session_id": "269ec726-bc15-45f1-9ca0-9cc09aed472c",
      "created_at": "2026-10-23T10:00:00.000Z",
      "sample_data": true
    },
    {
      "user_id": "30000000-0000-4000-8000-000000000007",
      "event": "session_started",
      "product_id": null,
      "session_id": "580e5a1f-ed80-4c3c-baa9-42ab50074f0a",
      "created_at": "2026-10-22T11:45:00.000Z",
      "sample_data": true
    },
    {
      "user_id": "30000000-0000-4000-8000-000000000007",
      "event": "view_product",
      "product_id": "10w-30-engine-oil-perodua-oil-filter-bundle",
      "session_id": "580e5a1f-ed80-4c3c-baa9-42ab50074f0a",
      "created_at": "2026-10-22T11:50:00.000Z",
      "sample_data": true
    },
    {
      "user_id": "30000000-0000-4000-8000-000000000007",
      "event": "checkout_started",
      "product_id": null,
      "session_id": "580e5a1f-ed80-4c3c-baa9-42ab50074f0a",
      "created_at": "2026-10-22T11:55:00.000Z",
      "sample_data": true
    },
    {
      "user_id": "30000000-0000-4000-8000-000000000007",
      "event": "order_placed",
      "product_id": null,
      "session_id": "580e5a1f-ed80-4c3c-baa9-42ab50074f0a",
      "created_at": "2026-10-22T12:00:00.000Z",
      "sample_data": true
    },
    {
      "user_id": "30000000-0000-4000-8000-000000000008",
      "event": "session_started",
      "product_id": null,
      "session_id": "3fafbe6f-d2aa-45d4-858a-94e33e0ac13a",
      "created_at": "2026-10-21T12:45:00.000Z",
      "sample_data": true
    },
    {
      "user_id": "30000000-0000-4000-8000-000000000008",
      "event": "view_product",
      "product_id": "bendix-dot-4-brake-and-clutch-fluid-1l",
      "session_id": "3fafbe6f-d2aa-45d4-858a-94e33e0ac13a",
      "created_at": "2026-10-21T12:50:00.000Z",
      "sample_data": true
    },
    {
      "user_id": "30000000-0000-4000-8000-000000000008",
      "event": "checkout_started",
      "product_id": null,
      "session_id": "3fafbe6f-d2aa-45d4-858a-94e33e0ac13a",
      "created_at": "2026-10-21T12:55:00.000Z",
      "sample_data": true
    },
    {
      "user_id": "30000000-0000-4000-8000-000000000008",
      "event": "order_placed",
      "product_id": null,
      "session_id": "3fafbe6f-d2aa-45d4-858a-94e33e0ac13a",
      "created_at": "2026-10-21T13:00:00.000Z",
      "sample_data": true
    },
    {
      "user_id": "30000000-0000-4000-8000-000000000009",
      "event": "session_started",
      "product_id": null,
      "session_id": "cab6db08-a614-472a-9cec-746993361037",
      "created_at": "2026-10-20T11:45:00.000Z",
      "sample_data": true
    },
    {
      "user_id": "30000000-0000-4000-8000-000000000009",
      "event": "view_product",
      "product_id": "manual-gear-oil-80w-90-4l",
      "session_id": "cab6db08-a614-472a-9cec-746993361037",
      "created_at": "2026-10-20T11:50:00.000Z",
      "sample_data": true
    },
    {
      "user_id": "30000000-0000-4000-8000-000000000009",
      "event": "checkout_started",
      "product_id": null,
      "session_id": "cab6db08-a614-472a-9cec-746993361037",
      "created_at": "2026-10-20T11:55:00.000Z",
      "sample_data": true
    },
    {
      "user_id": "30000000-0000-4000-8000-000000000009",
      "event": "order_placed",
      "product_id": null,
      "session_id": "cab6db08-a614-472a-9cec-746993361037",
      "created_at": "2026-10-20T12:00:00.000Z",
      "sample_data": true
    },
    {
      "user_id": "30000000-0000-4000-8000-000000000010",
      "event": "session_started",
      "product_id": null,
      "session_id": "a38514c3-616a-4bb9-bdb9-322355d136cc",
      "created_at": "2026-10-19T12:45:00.000Z",
      "sample_data": true
    },
    {
      "user_id": "30000000-0000-4000-8000-000000000010",
      "event": "view_product",
      "product_id": "x-traseal-carburetor-and-choke-cleaner-400ml",
      "session_id": "a38514c3-616a-4bb9-bdb9-322355d136cc",
      "created_at": "2026-10-19T12:50:00.000Z",
      "sample_data": true
    },
    {
      "user_id": "30000000-0000-4000-8000-000000000010",
      "event": "checkout_started",
      "product_id": null,
      "session_id": "a38514c3-616a-4bb9-bdb9-322355d136cc",
      "created_at": "2026-10-19T12:55:00.000Z",
      "sample_data": true
    },
    {
      "user_id": "30000000-0000-4000-8000-000000000010",
      "event": "order_placed",
      "product_id": null,
      "session_id": "a38514c3-616a-4bb9-bdb9-322355d136cc",
      "created_at": "2026-10-19T13:00:00.000Z",
      "sample_data": true
    },
    {
      "user_id": "30000000-0000-4000-8000-000000000011",
      "event": "session_started",
      "product_id": null,
      "session_id": "f6f068bb-3fa9-4cd1-bb43-3ec7f77dfa2b",
      "created_at": "2026-10-18T11:45:00.000Z",
      "sample_data": true
    },
    {
      "user_id": "30000000-0000-4000-8000-000000000011",
      "event": "view_product",
      "product_id": "top-1-green-radiator-coolant-500ml",
      "session_id": "f6f068bb-3fa9-4cd1-bb43-3ec7f77dfa2b",
      "created_at": "2026-10-18T11:50:00.000Z",
      "sample_data": true
    },
    {
      "user_id": "30000000-0000-4000-8000-000000000011",
      "event": "checkout_started",
      "product_id": null,
      "session_id": "f6f068bb-3fa9-4cd1-bb43-3ec7f77dfa2b",
      "created_at": "2026-10-18T11:55:00.000Z",
      "sample_data": true
    },
    {
      "user_id": "30000000-0000-4000-8000-000000000011",
      "event": "order_placed",
      "product_id": null,
      "session_id": "f6f068bb-3fa9-4cd1-bb43-3ec7f77dfa2b",
      "created_at": "2026-10-18T12:00:00.000Z",
      "sample_data": true
    },
    {
      "user_id": "30000000-0000-4000-8000-000000000012",
      "event": "session_started",
      "product_id": null,
      "session_id": "6dd5f614-f9bd-4f57-b324-0cd44afe656f",
      "created_at": "2026-10-17T12:45:00.000Z",
      "sample_data": true
    },
    {
      "user_id": "30000000-0000-4000-8000-000000000012",
      "event": "view_product",
      "product_id": "cabin-filter-for-proton-x50",
      "session_id": "6dd5f614-f9bd-4f57-b324-0cd44afe656f",
      "created_at": "2026-10-17T12:50:00.000Z",
      "sample_data": true
    },
    {
      "user_id": "30000000-0000-4000-8000-000000000012",
      "event": "checkout_started",
      "product_id": null,
      "session_id": "6dd5f614-f9bd-4f57-b324-0cd44afe656f",
      "created_at": "2026-10-17T12:55:00.000Z",
      "sample_data": true
    },
    {
      "user_id": "30000000-0000-4000-8000-000000000012",
      "event": "order_placed",
      "product_id": null,
      "session_id": "6dd5f614-f9bd-4f57-b324-0cd44afe656f",
      "created_at": "2026-10-17T13:00:00.000Z",
      "sample_data": true
    },
    {
      "user_id": "30000000-0000-4000-8000-000000000001",
      "event": "session_started",
      "product_id": null,
      "session_id": "4364a113-0d4c-4118-a41a-4c10c0bcde24",
      "created_at": "2026-10-16T00:45:00.000Z",
      "sample_data": true
    },
    {
      "user_id": "30000000-0000-4000-8000-000000000001",
      "event": "view_product",
      "product_id": "bosch-super-4-wr78x-spark-plugs-4-pack",
      "session_id": "4364a113-0d4c-4118-a41a-4c10c0bcde24",
      "created_at": "2026-10-16T00:50:00.000Z",
      "sample_data": true
    },
    {
      "user_id": "30000000-0000-4000-8000-000000000001",
      "event": "checkout_started",
      "product_id": null,
      "session_id": "4364a113-0d4c-4118-a41a-4c10c0bcde24",
      "created_at": "2026-10-16T00:55:00.000Z",
      "sample_data": true
    },
    {
      "user_id": "30000000-0000-4000-8000-000000000001",
      "event": "order_placed",
      "product_id": null,
      "session_id": "4364a113-0d4c-4118-a41a-4c10c0bcde24",
      "created_at": "2026-10-16T01:00:00.000Z",
      "sample_data": true
    },
    {
      "user_id": "30000000-0000-4000-8000-000000000002",
      "event": "session_started",
      "product_id": null,
      "session_id": "e59a4b26-f258-4026-9ac3-5b9b4bd2f85a",
      "created_at": "2026-10-15T01:45:00.000Z",
      "sample_data": true
    },
    {
      "user_id": "30000000-0000-4000-8000-000000000002",
      "event": "view_product",
      "product_id": "power-up-power-steering-fluid-1l",
      "session_id": "e59a4b26-f258-4026-9ac3-5b9b4bd2f85a",
      "created_at": "2026-10-15T01:50:00.000Z",
      "sample_data": true
    },
    {
      "user_id": "30000000-0000-4000-8000-000000000002",
      "event": "checkout_started",
      "product_id": null,
      "session_id": "e59a4b26-f258-4026-9ac3-5b9b4bd2f85a",
      "created_at": "2026-10-15T01:55:00.000Z",
      "sample_data": true
    },
    {
      "user_id": "30000000-0000-4000-8000-000000000002",
      "event": "order_placed",
      "product_id": null,
      "session_id": "e59a4b26-f258-4026-9ac3-5b9b4bd2f85a",
      "created_at": "2026-10-15T02:00:00.000Z",
      "sample_data": true
    },
    {
      "user_id": "30000000-0000-4000-8000-000000000003",
      "event": "session_started",
      "product_id": null,
      "session_id": "cbb943dc-f281-45ef-b517-eaf7ee29d137",
      "created_at": "2026-10-20T02:45:00.000Z",
      "sample_data": true
    },
    {
      "user_id": "30000000-0000-4000-8000-000000000003",
      "event": "view_product",
      "product_id": "front-brake-pads-for-proton-gen-2-persona-neo",
      "session_id": "cbb943dc-f281-45ef-b517-eaf7ee29d137",
      "created_at": "2026-10-20T02:50:00.000Z",
      "sample_data": true
    },
    {
      "user_id": "30000000-0000-4000-8000-000000000003",
      "event": "checkout_started",
      "product_id": null,
      "session_id": "cbb943dc-f281-45ef-b517-eaf7ee29d137",
      "created_at": "2026-10-20T02:55:00.000Z",
      "sample_data": true
    },
    {
      "user_id": "30000000-0000-4000-8000-000000000003",
      "event": "order_placed",
      "product_id": null,
      "session_id": "cbb943dc-f281-45ef-b517-eaf7ee29d137",
      "created_at": "2026-10-20T03:00:00.000Z",
      "sample_data": true
    },
    {
      "user_id": "30000000-0000-4000-8000-000000000004",
      "event": "session_started",
      "product_id": null,
      "session_id": "8d7ea11b-c57a-48a2-b809-b09027c0fb3f",
      "created_at": "2026-10-19T04:45:00.000Z",
      "sample_data": true
    },
    {
      "user_id": "30000000-0000-4000-8000-000000000004",
      "event": "view_product",
      "product_id": "bardahl-15w-40-engine-oil-4l",
      "session_id": "8d7ea11b-c57a-48a2-b809-b09027c0fb3f",
      "created_at": "2026-10-19T04:50:00.000Z",
      "sample_data": true
    },
    {
      "user_id": "30000000-0000-4000-8000-000000000004",
      "event": "checkout_started",
      "product_id": null,
      "session_id": "8d7ea11b-c57a-48a2-b809-b09027c0fb3f",
      "created_at": "2026-10-19T04:55:00.000Z",
      "sample_data": true
    },
    {
      "user_id": "30000000-0000-4000-8000-000000000004",
      "event": "order_placed",
      "product_id": null,
      "session_id": "8d7ea11b-c57a-48a2-b809-b09027c0fb3f",
      "created_at": "2026-10-19T05:00:00.000Z",
      "sample_data": true
    },
    {
      "user_id": "30000000-0000-4000-8000-000000000005",
      "event": "session_started",
      "product_id": null,
      "session_id": "fe99782e-1973-4c38-b925-f9d58013f41f",
      "created_at": "2026-10-18T05:45:00.000Z",
      "sample_data": true
    },
    {
      "user_id": "30000000-0000-4000-8000-000000000005",
      "event": "view_product",
      "product_id": "petrol-filter-for-proton-iriz-saga-vvt-persona-vvt",
      "session_id": "fe99782e-1973-4c38-b925-f9d58013f41f",
      "created_at": "2026-10-18T05:50:00.000Z",
      "sample_data": true
    },
    {
      "user_id": "30000000-0000-4000-8000-000000000005",
      "event": "checkout_started",
      "product_id": null,
      "session_id": "fe99782e-1973-4c38-b925-f9d58013f41f",
      "created_at": "2026-10-18T05:55:00.000Z",
      "sample_data": true
    },
    {
      "user_id": "30000000-0000-4000-8000-000000000005",
      "event": "order_placed",
      "product_id": null,
      "session_id": "fe99782e-1973-4c38-b925-f9d58013f41f",
      "created_at": "2026-10-18T06:00:00.000Z",
      "sample_data": true
    },
    {
      "user_id": "30000000-0000-4000-8000-000000000006",
      "event": "session_started",
      "product_id": null,
      "session_id": "bab20c8b-c486-41bf-9dba-7bc73a05bf59",
      "created_at": "2026-10-17T09:45:00.000Z",
      "sample_data": true
    },
    {
      "user_id": "30000000-0000-4000-8000-000000000006",
      "event": "view_product",
      "product_id": "10w-30-engine-oil-perodua-oil-filter-bundle",
      "session_id": "bab20c8b-c486-41bf-9dba-7bc73a05bf59",
      "created_at": "2026-10-17T09:50:00.000Z",
      "sample_data": true
    },
    {
      "user_id": "30000000-0000-4000-8000-000000000006",
      "event": "checkout_started",
      "product_id": null,
      "session_id": "bab20c8b-c486-41bf-9dba-7bc73a05bf59",
      "created_at": "2026-10-17T09:55:00.000Z",
      "sample_data": true
    },
    {
      "user_id": "30000000-0000-4000-8000-000000000006",
      "event": "order_placed",
      "product_id": null,
      "session_id": "bab20c8b-c486-41bf-9dba-7bc73a05bf59",
      "created_at": "2026-10-17T10:00:00.000Z",
      "sample_data": true
    },
    {
      "user_id": "30000000-0000-4000-8000-000000000007",
      "event": "session_started",
      "product_id": null,
      "session_id": "daf9ade7-13ff-4fca-b6db-e4c986ded54b",
      "created_at": "2026-10-16T11:45:00.000Z",
      "sample_data": true
    },
    {
      "user_id": "30000000-0000-4000-8000-000000000007",
      "event": "view_product",
      "product_id": "trw-gdb1198-front-brake-pads",
      "session_id": "daf9ade7-13ff-4fca-b6db-e4c986ded54b",
      "created_at": "2026-10-16T11:50:00.000Z",
      "sample_data": true
    },
    {
      "user_id": "30000000-0000-4000-8000-000000000007",
      "event": "checkout_started",
      "product_id": null,
      "session_id": "daf9ade7-13ff-4fca-b6db-e4c986ded54b",
      "created_at": "2026-10-16T11:55:00.000Z",
      "sample_data": true
    },
    {
      "user_id": "30000000-0000-4000-8000-000000000007",
      "event": "order_placed",
      "product_id": null,
      "session_id": "daf9ade7-13ff-4fca-b6db-e4c986ded54b",
      "created_at": "2026-10-16T12:00:00.000Z",
      "sample_data": true
    },
    {
      "user_id": "30000000-0000-4000-8000-000000000008",
      "event": "session_started",
      "product_id": null,
      "session_id": "f0cd5b1e-9c54-4c7c-bb03-9d0f7dfdbabe",
      "created_at": "2026-10-15T12:45:00.000Z",
      "sample_data": true
    },
    {
      "user_id": "30000000-0000-4000-8000-000000000008",
      "event": "view_product",
      "product_id": "perodua-fully-synthetic-0w-20-oil-3-5l-filter",
      "session_id": "f0cd5b1e-9c54-4c7c-bb03-9d0f7dfdbabe",
      "created_at": "2026-10-15T12:50:00.000Z",
      "sample_data": true
    },
    {
      "user_id": "30000000-0000-4000-8000-000000000008",
      "event": "checkout_started",
      "product_id": null,
      "session_id": "f0cd5b1e-9c54-4c7c-bb03-9d0f7dfdbabe",
      "created_at": "2026-10-15T12:55:00.000Z",
      "sample_data": true
    },
    {
      "user_id": "30000000-0000-4000-8000-000000000008",
      "event": "order_placed",
      "product_id": null,
      "session_id": "f0cd5b1e-9c54-4c7c-bb03-9d0f7dfdbabe",
      "created_at": "2026-10-15T13:00:00.000Z",
      "sample_data": true
    },
    {
      "user_id": "30000000-0000-4000-8000-000000000009",
      "event": "session_started",
      "product_id": null,
      "session_id": "a89a8117-272f-48c6-b5bc-baceb50f8161",
      "created_at": "2026-10-14T11:45:00.000Z",
      "sample_data": true
    },
    {
      "user_id": "30000000-0000-4000-8000-000000000009",
      "event": "view_product",
      "product_id": "ngk-lkar7c-9-spark-plugs-4-pack",
      "session_id": "a89a8117-272f-48c6-b5bc-baceb50f8161",
      "created_at": "2026-10-14T11:50:00.000Z",
      "sample_data": true
    },
    {
      "user_id": "30000000-0000-4000-8000-000000000009",
      "event": "checkout_started",
      "product_id": null,
      "session_id": "a89a8117-272f-48c6-b5bc-baceb50f8161",
      "created_at": "2026-10-14T11:55:00.000Z",
      "sample_data": true
    },
    {
      "user_id": "30000000-0000-4000-8000-000000000009",
      "event": "order_placed",
      "product_id": null,
      "session_id": "a89a8117-272f-48c6-b5bc-baceb50f8161",
      "created_at": "2026-10-14T12:00:00.000Z",
      "sample_data": true
    },
    {
      "user_id": "30000000-0000-4000-8000-000000000010",
      "event": "session_started",
      "product_id": null,
      "session_id": "0d888d62-f735-43ed-9af3-dc5d0e3d6d22",
      "created_at": "2026-10-13T12:45:00.000Z",
      "sample_data": true
    },
    {
      "user_id": "30000000-0000-4000-8000-000000000010",
      "event": "view_product",
      "product_id": "toyota-5w-30-engine-oil-4l",
      "session_id": "0d888d62-f735-43ed-9af3-dc5d0e3d6d22",
      "created_at": "2026-10-13T12:50:00.000Z",
      "sample_data": true
    },
    {
      "user_id": "30000000-0000-4000-8000-000000000010",
      "event": "checkout_started",
      "product_id": null,
      "session_id": "0d888d62-f735-43ed-9af3-dc5d0e3d6d22",
      "created_at": "2026-10-13T12:55:00.000Z",
      "sample_data": true
    },
    {
      "user_id": "30000000-0000-4000-8000-000000000010",
      "event": "order_placed",
      "product_id": null,
      "session_id": "0d888d62-f735-43ed-9af3-dc5d0e3d6d22",
      "created_at": "2026-10-13T13:00:00.000Z",
      "sample_data": true
    },
    {
      "user_id": "30000000-0000-4000-8000-000000000011",
      "event": "session_started",
      "product_id": null,
      "session_id": "03ee64d2-6b15-482f-a4b6-1187d6ddff37",
      "created_at": "2026-10-12T11:45:00.000Z",
      "sample_data": true
    },
    {
      "user_id": "30000000-0000-4000-8000-000000000011",
      "event": "view_product",
      "product_id": "bendix-dot-4-brake-and-clutch-fluid-1l",
      "session_id": "03ee64d2-6b15-482f-a4b6-1187d6ddff37",
      "created_at": "2026-10-12T11:50:00.000Z",
      "sample_data": true
    },
    {
      "user_id": "30000000-0000-4000-8000-000000000011",
      "event": "checkout_started",
      "product_id": null,
      "session_id": "03ee64d2-6b15-482f-a4b6-1187d6ddff37",
      "created_at": "2026-10-12T11:55:00.000Z",
      "sample_data": true
    },
    {
      "user_id": "30000000-0000-4000-8000-000000000011",
      "event": "order_placed",
      "product_id": null,
      "session_id": "03ee64d2-6b15-482f-a4b6-1187d6ddff37",
      "created_at": "2026-10-12T12:00:00.000Z",
      "sample_data": true
    },
    {
      "user_id": "30000000-0000-4000-8000-000000000012",
      "event": "session_started",
      "product_id": null,
      "session_id": "59093aae-0b98-45b8-ac11-530a3fcb1605",
      "created_at": "2026-10-11T12:45:00.000Z",
      "sample_data": true
    },
    {
      "user_id": "30000000-0000-4000-8000-000000000012",
      "event": "view_product",
      "product_id": "manual-gear-oil-ep-140-1l",
      "session_id": "59093aae-0b98-45b8-ac11-530a3fcb1605",
      "created_at": "2026-10-11T12:50:00.000Z",
      "sample_data": true
    },
    {
      "user_id": "30000000-0000-4000-8000-000000000012",
      "event": "checkout_started",
      "product_id": null,
      "session_id": "59093aae-0b98-45b8-ac11-530a3fcb1605",
      "created_at": "2026-10-11T12:55:00.000Z",
      "sample_data": true
    },
    {
      "user_id": "30000000-0000-4000-8000-000000000012",
      "event": "order_placed",
      "product_id": null,
      "session_id": "59093aae-0b98-45b8-ac11-530a3fcb1605",
      "created_at": "2026-10-11T13:00:00.000Z",
      "sample_data": true
    },
    {
      "user_id": "30000000-0000-4000-8000-000000000001",
      "event": "session_started",
      "product_id": null,
      "session_id": "b6c0dbc3-7560-4e2e-b13f-3c4f9cf82e81",
      "created_at": "2026-10-10T00:45:00.000Z",
      "sample_data": true
    },
    {
      "user_id": "30000000-0000-4000-8000-000000000001",
      "event": "view_product",
      "product_id": "x-traseal-carburetor-and-choke-cleaner-400ml",
      "session_id": "b6c0dbc3-7560-4e2e-b13f-3c4f9cf82e81",
      "created_at": "2026-10-10T00:50:00.000Z",
      "sample_data": true
    },
    {
      "user_id": "30000000-0000-4000-8000-000000000001",
      "event": "checkout_started",
      "product_id": null,
      "session_id": "b6c0dbc3-7560-4e2e-b13f-3c4f9cf82e81",
      "created_at": "2026-10-10T00:55:00.000Z",
      "sample_data": true
    },
    {
      "user_id": "30000000-0000-4000-8000-000000000001",
      "event": "order_placed",
      "product_id": null,
      "session_id": "b6c0dbc3-7560-4e2e-b13f-3c4f9cf82e81",
      "created_at": "2026-10-10T01:00:00.000Z",
      "sample_data": true
    },
    {
      "user_id": "30000000-0000-4000-8000-000000000002",
      "event": "session_started",
      "product_id": null,
      "session_id": "07d4fbe6-2a01-4925-9ea6-c887e06f63af",
      "created_at": "2026-10-09T01:45:00.000Z",
      "sample_data": true
    },
    {
      "user_id": "30000000-0000-4000-8000-000000000002",
      "event": "view_product",
      "product_id": "top-1-green-radiator-coolant-500ml",
      "session_id": "07d4fbe6-2a01-4925-9ea6-c887e06f63af",
      "created_at": "2026-10-09T01:50:00.000Z",
      "sample_data": true
    },
    {
      "user_id": "30000000-0000-4000-8000-000000000002",
      "event": "checkout_started",
      "product_id": null,
      "session_id": "07d4fbe6-2a01-4925-9ea6-c887e06f63af",
      "created_at": "2026-10-09T01:55:00.000Z",
      "sample_data": true
    },
    {
      "user_id": "30000000-0000-4000-8000-000000000002",
      "event": "order_placed",
      "product_id": null,
      "session_id": "07d4fbe6-2a01-4925-9ea6-c887e06f63af",
      "created_at": "2026-10-09T02:00:00.000Z",
      "sample_data": true
    },
    {
      "user_id": "30000000-0000-4000-8000-000000000003",
      "event": "session_started",
      "product_id": null,
      "session_id": "398d432f-67b0-4339-acce-8d92d3c039fd",
      "created_at": "2026-10-08T02:45:00.000Z",
      "sample_data": true
    },
    {
      "user_id": "30000000-0000-4000-8000-000000000003",
      "event": "view_product",
      "product_id": "petrol-filter-for-proton-iriz-saga-vvt-persona-vvt",
      "session_id": "398d432f-67b0-4339-acce-8d92d3c039fd",
      "created_at": "2026-10-08T02:50:00.000Z",
      "sample_data": true
    },
    {
      "user_id": "30000000-0000-4000-8000-000000000003",
      "event": "checkout_started",
      "product_id": null,
      "session_id": "398d432f-67b0-4339-acce-8d92d3c039fd",
      "created_at": "2026-10-08T02:55:00.000Z",
      "sample_data": true
    },
    {
      "user_id": "30000000-0000-4000-8000-000000000003",
      "event": "order_placed",
      "product_id": null,
      "session_id": "398d432f-67b0-4339-acce-8d92d3c039fd",
      "created_at": "2026-10-08T03:00:00.000Z",
      "sample_data": true
    },
    {
      "user_id": "30000000-0000-4000-8000-000000000004",
      "event": "session_started",
      "product_id": null,
      "session_id": "3c7468a9-4c3e-4ae4-aa71-a07ed9767047",
      "created_at": "2026-10-07T04:45:00.000Z",
      "sample_data": true
    },
    {
      "user_id": "30000000-0000-4000-8000-000000000004",
      "event": "view_product",
      "product_id": "ngk-lzkar7a-spark-plug",
      "session_id": "3c7468a9-4c3e-4ae4-aa71-a07ed9767047",
      "created_at": "2026-10-07T04:50:00.000Z",
      "sample_data": true
    },
    {
      "user_id": "30000000-0000-4000-8000-000000000004",
      "event": "checkout_started",
      "product_id": null,
      "session_id": "3c7468a9-4c3e-4ae4-aa71-a07ed9767047",
      "created_at": "2026-10-07T04:55:00.000Z",
      "sample_data": true
    },
    {
      "user_id": "30000000-0000-4000-8000-000000000004",
      "event": "order_placed",
      "product_id": null,
      "session_id": "3c7468a9-4c3e-4ae4-aa71-a07ed9767047",
      "created_at": "2026-10-07T05:00:00.000Z",
      "sample_data": true
    },
    {
      "user_id": "30000000-0000-4000-8000-000000000005",
      "event": "session_started",
      "product_id": null,
      "session_id": "d0bf3ff5-9ec1-48ce-933e-a67f3103d4e0",
      "created_at": "2026-10-06T05:45:00.000Z",
      "sample_data": true
    },
    {
      "user_id": "30000000-0000-4000-8000-000000000005",
      "event": "view_product",
      "product_id": "power-up-power-steering-fluid-1l",
      "session_id": "d0bf3ff5-9ec1-48ce-933e-a67f3103d4e0",
      "created_at": "2026-10-06T05:50:00.000Z",
      "sample_data": true
    },
    {
      "user_id": "30000000-0000-4000-8000-000000000005",
      "event": "checkout_started",
      "product_id": null,
      "session_id": "d0bf3ff5-9ec1-48ce-933e-a67f3103d4e0",
      "created_at": "2026-10-06T05:55:00.000Z",
      "sample_data": true
    },
    {
      "user_id": "30000000-0000-4000-8000-000000000005",
      "event": "order_placed",
      "product_id": null,
      "session_id": "d0bf3ff5-9ec1-48ce-933e-a67f3103d4e0",
      "created_at": "2026-10-06T06:00:00.000Z",
      "sample_data": true
    },
    {
      "user_id": "30000000-0000-4000-8000-000000000006",
      "event": "session_started",
      "product_id": null,
      "session_id": "3b022b89-b190-4803-9e1c-493f90127a9d",
      "created_at": "2026-10-05T09:45:00.000Z",
      "sample_data": true
    },
    {
      "user_id": "30000000-0000-4000-8000-000000000006",
      "event": "view_product",
      "product_id": "trw-gdb7707-front-brake-pads",
      "session_id": "3b022b89-b190-4803-9e1c-493f90127a9d",
      "created_at": "2026-10-05T09:50:00.000Z",
      "sample_data": true
    },
    {
      "user_id": "30000000-0000-4000-8000-000000000006",
      "event": "checkout_started",
      "product_id": null,
      "session_id": "3b022b89-b190-4803-9e1c-493f90127a9d",
      "created_at": "2026-10-05T09:55:00.000Z",
      "sample_data": true
    },
    {
      "user_id": "30000000-0000-4000-8000-000000000006",
      "event": "order_placed",
      "product_id": null,
      "session_id": "3b022b89-b190-4803-9e1c-493f90127a9d",
      "created_at": "2026-10-05T10:00:00.000Z",
      "sample_data": true
    },
    {
      "user_id": "30000000-0000-4000-8000-000000000007",
      "event": "session_started",
      "product_id": null,
      "session_id": "ec36f62d-ef79-4f54-92f6-52d2985bcbaf",
      "created_at": "2026-10-04T11:45:00.000Z",
      "sample_data": true
    },
    {
      "user_id": "30000000-0000-4000-8000-000000000007",
      "event": "view_product",
      "product_id": "castrol-magnatec-10w-40-engine-oil-4l",
      "session_id": "ec36f62d-ef79-4f54-92f6-52d2985bcbaf",
      "created_at": "2026-10-04T11:50:00.000Z",
      "sample_data": true
    },
    {
      "user_id": "30000000-0000-4000-8000-000000000007",
      "event": "checkout_started",
      "product_id": null,
      "session_id": "ec36f62d-ef79-4f54-92f6-52d2985bcbaf",
      "created_at": "2026-10-04T11:55:00.000Z",
      "sample_data": true
    },
    {
      "user_id": "30000000-0000-4000-8000-000000000007",
      "event": "order_placed",
      "product_id": null,
      "session_id": "ec36f62d-ef79-4f54-92f6-52d2985bcbaf",
      "created_at": "2026-10-04T12:00:00.000Z",
      "sample_data": true
    },
    {
      "user_id": "30000000-0000-4000-8000-000000000008",
      "event": "session_started",
      "product_id": null,
      "session_id": "7a2b8f6c-50ef-4eab-8ae5-d6e92dc76fce",
      "created_at": "2026-10-03T12:45:00.000Z",
      "sample_data": true
    },
    {
      "user_id": "30000000-0000-4000-8000-000000000008",
      "event": "view_product",
      "product_id": "cabin-filter-for-proton-x50",
      "session_id": "7a2b8f6c-50ef-4eab-8ae5-d6e92dc76fce",
      "created_at": "2026-10-03T12:50:00.000Z",
      "sample_data": true
    },
    {
      "user_id": "30000000-0000-4000-8000-000000000008",
      "event": "checkout_started",
      "product_id": null,
      "session_id": "7a2b8f6c-50ef-4eab-8ae5-d6e92dc76fce",
      "created_at": "2026-10-03T12:55:00.000Z",
      "sample_data": true
    },
    {
      "user_id": "30000000-0000-4000-8000-000000000008",
      "event": "order_placed",
      "product_id": null,
      "session_id": "7a2b8f6c-50ef-4eab-8ae5-d6e92dc76fce",
      "created_at": "2026-10-03T13:00:00.000Z",
      "sample_data": true
    },
    {
      "user_id": "30000000-0000-4000-8000-000000000009",
      "event": "session_started",
      "product_id": null,
      "session_id": "b373609a-66b4-4ed6-88f4-ee85b17ebecc",
      "created_at": "2026-10-02T11:45:00.000Z",
      "sample_data": true
    },
    {
      "user_id": "30000000-0000-4000-8000-000000000009",
      "event": "view_product",
      "product_id": "toyota-5w-30-engine-oil-4l",
      "session_id": "b373609a-66b4-4ed6-88f4-ee85b17ebecc",
      "created_at": "2026-10-02T11:50:00.000Z",
      "sample_data": true
    },
    {
      "user_id": "30000000-0000-4000-8000-000000000009",
      "event": "checkout_started",
      "product_id": null,
      "session_id": "b373609a-66b4-4ed6-88f4-ee85b17ebecc",
      "created_at": "2026-10-02T11:55:00.000Z",
      "sample_data": true
    },
    {
      "user_id": "30000000-0000-4000-8000-000000000009",
      "event": "order_placed",
      "product_id": null,
      "session_id": "b373609a-66b4-4ed6-88f4-ee85b17ebecc",
      "created_at": "2026-10-02T12:00:00.000Z",
      "sample_data": true
    },
    {
      "user_id": "30000000-0000-4000-8000-000000000010",
      "event": "session_started",
      "product_id": null,
      "session_id": "76790cf0-0550-45a4-92e1-211579e42ab0",
      "created_at": "2026-10-01T12:45:00.000Z",
      "sample_data": true
    },
    {
      "user_id": "30000000-0000-4000-8000-000000000010",
      "event": "view_product",
      "product_id": "trw-gdb8977-front-brake-pads",
      "session_id": "76790cf0-0550-45a4-92e1-211579e42ab0",
      "created_at": "2026-10-01T12:50:00.000Z",
      "sample_data": true
    },
    {
      "user_id": "30000000-0000-4000-8000-000000000010",
      "event": "checkout_started",
      "product_id": null,
      "session_id": "76790cf0-0550-45a4-92e1-211579e42ab0",
      "created_at": "2026-10-01T12:55:00.000Z",
      "sample_data": true
    },
    {
      "user_id": "30000000-0000-4000-8000-000000000010",
      "event": "order_placed",
      "product_id": null,
      "session_id": "76790cf0-0550-45a4-92e1-211579e42ab0",
      "created_at": "2026-10-01T13:00:00.000Z",
      "sample_data": true
    },
    {
      "user_id": "30000000-0000-4000-8000-000000000011",
      "event": "session_started",
      "product_id": null,
      "session_id": "dde4f6c9-851f-4282-9f8b-0e9e90a6005c",
      "created_at": "2026-09-30T11:45:00.000Z",
      "sample_data": true
    },
    {
      "user_id": "30000000-0000-4000-8000-000000000011",
      "event": "view_product",
      "product_id": "dexron-iii-atf-d3-transmission-fluid-1l",
      "session_id": "dde4f6c9-851f-4282-9f8b-0e9e90a6005c",
      "created_at": "2026-09-30T11:50:00.000Z",
      "sample_data": true
    },
    {
      "user_id": "30000000-0000-4000-8000-000000000011",
      "event": "checkout_started",
      "product_id": null,
      "session_id": "dde4f6c9-851f-4282-9f8b-0e9e90a6005c",
      "created_at": "2026-09-30T11:55:00.000Z",
      "sample_data": true
    },
    {
      "user_id": "30000000-0000-4000-8000-000000000011",
      "event": "order_placed",
      "product_id": null,
      "session_id": "dde4f6c9-851f-4282-9f8b-0e9e90a6005c",
      "created_at": "2026-09-30T12:00:00.000Z",
      "sample_data": true
    },
    {
      "user_id": "30000000-0000-4000-8000-000000000012",
      "event": "session_started",
      "product_id": null,
      "session_id": "b3f2641b-cd4c-41e8-a148-bb849ba38c3d",
      "created_at": "2026-09-29T12:45:00.000Z",
      "sample_data": true
    },
    {
      "user_id": "30000000-0000-4000-8000-000000000012",
      "event": "view_product",
      "product_id": "toyota-5w-30-engine-oil-4l",
      "session_id": "b3f2641b-cd4c-41e8-a148-bb849ba38c3d",
      "created_at": "2026-09-29T12:50:00.000Z",
      "sample_data": true
    },
    {
      "user_id": "30000000-0000-4000-8000-000000000012",
      "event": "checkout_started",
      "product_id": null,
      "session_id": "b3f2641b-cd4c-41e8-a148-bb849ba38c3d",
      "created_at": "2026-09-29T12:55:00.000Z",
      "sample_data": true
    },
    {
      "user_id": "30000000-0000-4000-8000-000000000012",
      "event": "order_placed",
      "product_id": null,
      "session_id": "b3f2641b-cd4c-41e8-a148-bb849ba38c3d",
      "created_at": "2026-09-29T13:00:00.000Z",
      "sample_data": true
    },
    {
      "user_id": "30000000-0000-4000-8000-000000000001",
      "event": "session_started",
      "product_id": null,
      "session_id": "a6a0e032-947b-4f12-ba76-99fdc712b527",
      "created_at": "2026-09-28T00:45:00.000Z",
      "sample_data": true
    },
    {
      "user_id": "30000000-0000-4000-8000-000000000001",
      "event": "view_product",
      "product_id": "perodua-fully-synthetic-0w-20-oil-3-5l-filter",
      "session_id": "a6a0e032-947b-4f12-ba76-99fdc712b527",
      "created_at": "2026-09-28T00:50:00.000Z",
      "sample_data": true
    },
    {
      "user_id": "30000000-0000-4000-8000-000000000001",
      "event": "checkout_started",
      "product_id": null,
      "session_id": "a6a0e032-947b-4f12-ba76-99fdc712b527",
      "created_at": "2026-09-28T00:55:00.000Z",
      "sample_data": true
    },
    {
      "user_id": "30000000-0000-4000-8000-000000000001",
      "event": "order_placed",
      "product_id": null,
      "session_id": "a6a0e032-947b-4f12-ba76-99fdc712b527",
      "created_at": "2026-09-28T01:00:00.000Z",
      "sample_data": true
    },
    {
      "user_id": "30000000-0000-4000-8000-000000000002",
      "event": "session_started",
      "product_id": null,
      "session_id": "6f2086a1-7a95-463c-9acd-60d4641760b8",
      "created_at": "2026-09-27T01:45:00.000Z",
      "sample_data": true
    },
    {
      "user_id": "30000000-0000-4000-8000-000000000002",
      "event": "view_product",
      "product_id": "bendix-dot-4-brake-and-clutch-fluid-1l",
      "session_id": "6f2086a1-7a95-463c-9acd-60d4641760b8",
      "created_at": "2026-09-27T01:50:00.000Z",
      "sample_data": true
    },
    {
      "user_id": "30000000-0000-4000-8000-000000000002",
      "event": "checkout_started",
      "product_id": null,
      "session_id": "6f2086a1-7a95-463c-9acd-60d4641760b8",
      "created_at": "2026-09-27T01:55:00.000Z",
      "sample_data": true
    },
    {
      "user_id": "30000000-0000-4000-8000-000000000002",
      "event": "order_placed",
      "product_id": null,
      "session_id": "6f2086a1-7a95-463c-9acd-60d4641760b8",
      "created_at": "2026-09-27T02:00:00.000Z",
      "sample_data": true
    },
    {
      "user_id": "30000000-0000-4000-8000-000000000003",
      "event": "session_started",
      "product_id": null,
      "session_id": "c6744d7a-74fb-411f-b5d4-2625806b426c",
      "created_at": "2026-09-26T02:45:00.000Z",
      "sample_data": true
    },
    {
      "user_id": "30000000-0000-4000-8000-000000000003",
      "event": "view_product",
      "product_id": "castrol-140-manual-gear-oil-4l",
      "session_id": "c6744d7a-74fb-411f-b5d4-2625806b426c",
      "created_at": "2026-09-26T02:50:00.000Z",
      "sample_data": true
    },
    {
      "user_id": "30000000-0000-4000-8000-000000000003",
      "event": "checkout_started",
      "product_id": null,
      "session_id": "c6744d7a-74fb-411f-b5d4-2625806b426c",
      "created_at": "2026-09-26T02:55:00.000Z",
      "sample_data": true
    },
    {
      "user_id": "30000000-0000-4000-8000-000000000003",
      "event": "order_placed",
      "product_id": null,
      "session_id": "c6744d7a-74fb-411f-b5d4-2625806b426c",
      "created_at": "2026-09-26T03:00:00.000Z",
      "sample_data": true
    },
    {
      "user_id": "30000000-0000-4000-8000-000000000004",
      "event": "session_started",
      "product_id": null,
      "session_id": "14e8ecaf-039d-4cf5-ab2a-0449c755dc71",
      "created_at": "2026-09-25T04:45:00.000Z",
      "sample_data": true
    },
    {
      "user_id": "30000000-0000-4000-8000-000000000004",
      "event": "view_product",
      "product_id": "x-traseal-carburetor-and-choke-cleaner-400ml",
      "session_id": "14e8ecaf-039d-4cf5-ab2a-0449c755dc71",
      "created_at": "2026-09-25T04:50:00.000Z",
      "sample_data": true
    },
    {
      "user_id": "30000000-0000-4000-8000-000000000004",
      "event": "checkout_started",
      "product_id": null,
      "session_id": "14e8ecaf-039d-4cf5-ab2a-0449c755dc71",
      "created_at": "2026-09-25T04:55:00.000Z",
      "sample_data": true
    },
    {
      "user_id": "30000000-0000-4000-8000-000000000004",
      "event": "order_placed",
      "product_id": null,
      "session_id": "14e8ecaf-039d-4cf5-ab2a-0449c755dc71",
      "created_at": "2026-09-25T05:00:00.000Z",
      "sample_data": true
    },
    {
      "user_id": "30000000-0000-4000-8000-000000000005",
      "event": "session_started",
      "product_id": null,
      "session_id": "0ce5e1d0-31fc-48c7-80c3-ecb60c4ac98d",
      "created_at": "2026-09-24T05:45:00.000Z",
      "sample_data": true
    },
    {
      "user_id": "30000000-0000-4000-8000-000000000005",
      "event": "view_product",
      "product_id": "top-1-green-radiator-coolant-500ml",
      "session_id": "0ce5e1d0-31fc-48c7-80c3-ecb60c4ac98d",
      "created_at": "2026-09-24T05:50:00.000Z",
      "sample_data": true
    },
    {
      "user_id": "30000000-0000-4000-8000-000000000005",
      "event": "checkout_started",
      "product_id": null,
      "session_id": "0ce5e1d0-31fc-48c7-80c3-ecb60c4ac98d",
      "created_at": "2026-09-24T05:55:00.000Z",
      "sample_data": true
    },
    {
      "user_id": "30000000-0000-4000-8000-000000000005",
      "event": "order_placed",
      "product_id": null,
      "session_id": "0ce5e1d0-31fc-48c7-80c3-ecb60c4ac98d",
      "created_at": "2026-09-24T06:00:00.000Z",
      "sample_data": true
    },
    {
      "user_id": "30000000-0000-4000-8000-000000000006",
      "event": "session_started",
      "product_id": null,
      "session_id": "60c02f83-82d8-41c2-8492-54487a7a258a",
      "created_at": "2026-09-23T09:45:00.000Z",
      "sample_data": true
    },
    {
      "user_id": "30000000-0000-4000-8000-000000000006",
      "event": "view_product",
      "product_id": "cabin-filter-for-proton-x50",
      "session_id": "60c02f83-82d8-41c2-8492-54487a7a258a",
      "created_at": "2026-09-23T09:50:00.000Z",
      "sample_data": true
    },
    {
      "user_id": "30000000-0000-4000-8000-000000000006",
      "event": "checkout_started",
      "product_id": null,
      "session_id": "60c02f83-82d8-41c2-8492-54487a7a258a",
      "created_at": "2026-09-23T09:55:00.000Z",
      "sample_data": true
    },
    {
      "user_id": "30000000-0000-4000-8000-000000000006",
      "event": "order_placed",
      "product_id": null,
      "session_id": "60c02f83-82d8-41c2-8492-54487a7a258a",
      "created_at": "2026-09-23T10:00:00.000Z",
      "sample_data": true
    },
    {
      "user_id": "30000000-0000-4000-8000-000000000007",
      "event": "session_started",
      "product_id": null,
      "session_id": "329d6ce8-2de0-4830-ba26-37eff46df815",
      "created_at": "2026-09-22T11:45:00.000Z",
      "sample_data": true
    },
    {
      "user_id": "30000000-0000-4000-8000-000000000007",
      "event": "view_product",
      "product_id": "denso-k20tnr-s-spark-plugs-4-pack",
      "session_id": "329d6ce8-2de0-4830-ba26-37eff46df815",
      "created_at": "2026-09-22T11:50:00.000Z",
      "sample_data": true
    },
    {
      "user_id": "30000000-0000-4000-8000-000000000007",
      "event": "checkout_started",
      "product_id": null,
      "session_id": "329d6ce8-2de0-4830-ba26-37eff46df815",
      "created_at": "2026-09-22T11:55:00.000Z",
      "sample_data": true
    },
    {
      "user_id": "30000000-0000-4000-8000-000000000007",
      "event": "order_placed",
      "product_id": null,
      "session_id": "329d6ce8-2de0-4830-ba26-37eff46df815",
      "created_at": "2026-09-22T12:00:00.000Z",
      "sample_data": true
    },
    {
      "user_id": "30000000-0000-4000-8000-000000000008",
      "event": "session_started",
      "product_id": null,
      "session_id": "01eaedf6-9e6e-4528-9aef-d04ec391c6ac",
      "created_at": "2026-09-21T12:45:00.000Z",
      "sample_data": true
    },
    {
      "user_id": "30000000-0000-4000-8000-000000000008",
      "event": "view_product",
      "product_id": "power-up-power-steering-fluid-1l",
      "session_id": "01eaedf6-9e6e-4528-9aef-d04ec391c6ac",
      "created_at": "2026-09-21T12:50:00.000Z",
      "sample_data": true
    },
    {
      "user_id": "30000000-0000-4000-8000-000000000008",
      "event": "checkout_started",
      "product_id": null,
      "session_id": "01eaedf6-9e6e-4528-9aef-d04ec391c6ac",
      "created_at": "2026-09-21T12:55:00.000Z",
      "sample_data": true
    },
    {
      "user_id": "30000000-0000-4000-8000-000000000008",
      "event": "order_placed",
      "product_id": null,
      "session_id": "01eaedf6-9e6e-4528-9aef-d04ec391c6ac",
      "created_at": "2026-09-21T13:00:00.000Z",
      "sample_data": true
    },
    {
      "user_id": "30000000-0000-4000-8000-000000000009",
      "event": "session_started",
      "product_id": null,
      "session_id": "8267e173-ab4f-4cf9-ae07-a0b07360215e",
      "created_at": "2026-09-20T11:45:00.000Z",
      "sample_data": true
    },
    {
      "user_id": "30000000-0000-4000-8000-000000000009",
      "event": "view_product",
      "product_id": "trw-gdb7742-front-brake-pads",
      "session_id": "8267e173-ab4f-4cf9-ae07-a0b07360215e",
      "created_at": "2026-09-20T11:50:00.000Z",
      "sample_data": true
    },
    {
      "user_id": "30000000-0000-4000-8000-000000000009",
      "event": "checkout_started",
      "product_id": null,
      "session_id": "8267e173-ab4f-4cf9-ae07-a0b07360215e",
      "created_at": "2026-09-20T11:55:00.000Z",
      "sample_data": true
    },
    {
      "user_id": "30000000-0000-4000-8000-000000000009",
      "event": "order_placed",
      "product_id": null,
      "session_id": "8267e173-ab4f-4cf9-ae07-a0b07360215e",
      "created_at": "2026-09-20T12:00:00.000Z",
      "sample_data": true
    },
    {
      "user_id": "30000000-0000-4000-8000-000000000010",
      "event": "session_started",
      "product_id": null,
      "session_id": "373dd8e0-9fd0-49c2-b962-4e2f94544296",
      "created_at": "2026-09-19T12:45:00.000Z",
      "sample_data": true
    },
    {
      "user_id": "30000000-0000-4000-8000-000000000010",
      "event": "view_product",
      "product_id": "sae-40-engine-oil-1l",
      "session_id": "373dd8e0-9fd0-49c2-b962-4e2f94544296",
      "created_at": "2026-09-19T12:50:00.000Z",
      "sample_data": true
    },
    {
      "user_id": "30000000-0000-4000-8000-000000000010",
      "event": "checkout_started",
      "product_id": null,
      "session_id": "373dd8e0-9fd0-49c2-b962-4e2f94544296",
      "created_at": "2026-09-19T12:55:00.000Z",
      "sample_data": true
    },
    {
      "user_id": "30000000-0000-4000-8000-000000000010",
      "event": "order_placed",
      "product_id": null,
      "session_id": "373dd8e0-9fd0-49c2-b962-4e2f94544296",
      "created_at": "2026-09-19T13:00:00.000Z",
      "sample_data": true
    },
    {
      "user_id": "30000000-0000-4000-8000-000000000011",
      "event": "session_started",
      "product_id": null,
      "session_id": "97bb129d-f891-48bd-88d2-6edf394c5962",
      "created_at": "2026-09-18T11:45:00.000Z",
      "sample_data": true
    },
    {
      "user_id": "30000000-0000-4000-8000-000000000011",
      "event": "view_product",
      "product_id": "petrol-filter-for-proton-iriz-saga-vvt-persona-vvt",
      "session_id": "97bb129d-f891-48bd-88d2-6edf394c5962",
      "created_at": "2026-09-18T11:50:00.000Z",
      "sample_data": true
    },
    {
      "user_id": "30000000-0000-4000-8000-000000000011",
      "event": "checkout_started",
      "product_id": null,
      "session_id": "97bb129d-f891-48bd-88d2-6edf394c5962",
      "created_at": "2026-09-18T11:55:00.000Z",
      "sample_data": true
    },
    {
      "user_id": "30000000-0000-4000-8000-000000000011",
      "event": "order_placed",
      "product_id": null,
      "session_id": "97bb129d-f891-48bd-88d2-6edf394c5962",
      "created_at": "2026-09-18T12:00:00.000Z",
      "sample_data": true
    },
    {
      "user_id": "30000000-0000-4000-8000-000000000012",
      "event": "session_started",
      "product_id": null,
      "session_id": "ed51abc4-1722-4493-b8f9-0c92eaa4fcdc",
      "created_at": "2026-09-17T12:45:00.000Z",
      "sample_data": true
    },
    {
      "user_id": "30000000-0000-4000-8000-000000000012",
      "event": "view_product",
      "product_id": "perodua-fully-synthetic-0w-20-oil-3-5l-filter",
      "session_id": "ed51abc4-1722-4493-b8f9-0c92eaa4fcdc",
      "created_at": "2026-09-17T12:50:00.000Z",
      "sample_data": true
    },
    {
      "user_id": "30000000-0000-4000-8000-000000000012",
      "event": "checkout_started",
      "product_id": null,
      "session_id": "ed51abc4-1722-4493-b8f9-0c92eaa4fcdc",
      "created_at": "2026-09-17T12:55:00.000Z",
      "sample_data": true
    },
    {
      "user_id": "30000000-0000-4000-8000-000000000012",
      "event": "order_placed",
      "product_id": null,
      "session_id": "ed51abc4-1722-4493-b8f9-0c92eaa4fcdc",
      "created_at": "2026-09-17T13:00:00.000Z",
      "sample_data": true
    },
    {
      "user_id": "30000000-0000-4000-8000-000000000001",
      "event": "session_started",
      "product_id": null,
      "session_id": "01de7f8f-38b9-43fa-8de2-1a9d1611bbe1",
      "created_at": "2026-09-16T00:45:00.000Z",
      "sample_data": true
    },
    {
      "user_id": "30000000-0000-4000-8000-000000000001",
      "event": "view_product",
      "product_id": "trw-gdb3459-front-brake-pads",
      "session_id": "01de7f8f-38b9-43fa-8de2-1a9d1611bbe1",
      "created_at": "2026-09-16T00:50:00.000Z",
      "sample_data": true
    },
    {
      "user_id": "30000000-0000-4000-8000-000000000001",
      "event": "checkout_started",
      "product_id": null,
      "session_id": "01de7f8f-38b9-43fa-8de2-1a9d1611bbe1",
      "created_at": "2026-09-16T00:55:00.000Z",
      "sample_data": true
    },
    {
      "user_id": "30000000-0000-4000-8000-000000000001",
      "event": "order_placed",
      "product_id": null,
      "session_id": "01de7f8f-38b9-43fa-8de2-1a9d1611bbe1",
      "created_at": "2026-09-16T01:00:00.000Z",
      "sample_data": true
    },
    {
      "user_id": "30000000-0000-4000-8000-000000000002",
      "event": "session_started",
      "product_id": null,
      "session_id": "c6adc34a-e6e3-4b83-b20d-56133ec3cc59",
      "created_at": "2026-09-15T01:45:00.000Z",
      "sample_data": true
    },
    {
      "user_id": "30000000-0000-4000-8000-000000000002",
      "event": "view_product",
      "product_id": "sae-40-engine-oil-1l",
      "session_id": "c6adc34a-e6e3-4b83-b20d-56133ec3cc59",
      "created_at": "2026-09-15T01:50:00.000Z",
      "sample_data": true
    },
    {
      "user_id": "30000000-0000-4000-8000-000000000002",
      "event": "checkout_started",
      "product_id": null,
      "session_id": "c6adc34a-e6e3-4b83-b20d-56133ec3cc59",
      "created_at": "2026-09-15T01:55:00.000Z",
      "sample_data": true
    },
    {
      "user_id": "30000000-0000-4000-8000-000000000002",
      "event": "order_placed",
      "product_id": null,
      "session_id": "c6adc34a-e6e3-4b83-b20d-56133ec3cc59",
      "created_at": "2026-09-15T02:00:00.000Z",
      "sample_data": true
    },
    {
      "user_id": "30000000-0000-4000-8000-000000000003",
      "event": "session_started",
      "product_id": null,
      "session_id": "27913b1a-939e-4610-b2b2-a7494ff3b5b9",
      "created_at": "2026-09-14T02:45:00.000Z",
      "sample_data": true
    },
    {
      "user_id": "30000000-0000-4000-8000-000000000003",
      "event": "view_product",
      "product_id": "bendix-dot-4-brake-and-clutch-fluid-1l",
      "session_id": "27913b1a-939e-4610-b2b2-a7494ff3b5b9",
      "created_at": "2026-09-14T02:50:00.000Z",
      "sample_data": true
    },
    {
      "user_id": "30000000-0000-4000-8000-000000000003",
      "event": "checkout_started",
      "product_id": null,
      "session_id": "27913b1a-939e-4610-b2b2-a7494ff3b5b9",
      "created_at": "2026-09-14T02:55:00.000Z",
      "sample_data": true
    },
    {
      "user_id": "30000000-0000-4000-8000-000000000003",
      "event": "order_placed",
      "product_id": null,
      "session_id": "27913b1a-939e-4610-b2b2-a7494ff3b5b9",
      "created_at": "2026-09-14T03:00:00.000Z",
      "sample_data": true
    },
    {
      "user_id": "30000000-0000-4000-8000-000000000004",
      "event": "session_started",
      "product_id": null,
      "session_id": "6589cef3-cd44-45a9-bfe4-33661868e718",
      "created_at": "2026-09-13T04:45:00.000Z",
      "sample_data": true
    },
    {
      "user_id": "30000000-0000-4000-8000-000000000004",
      "event": "view_product",
      "product_id": "castrol-gtx-10w-30-engine-oil-3l",
      "session_id": "6589cef3-cd44-45a9-bfe4-33661868e718",
      "created_at": "2026-09-13T04:50:00.000Z",
      "sample_data": true
    },
    {
      "user_id": "30000000-0000-4000-8000-000000000004",
      "event": "checkout_started",
      "product_id": null,
      "session_id": "6589cef3-cd44-45a9-bfe4-33661868e718",
      "created_at": "2026-09-13T04:55:00.000Z",
      "sample_data": true
    },
    {
      "user_id": "30000000-0000-4000-8000-000000000004",
      "event": "order_placed",
      "product_id": null,
      "session_id": "6589cef3-cd44-45a9-bfe4-33661868e718",
      "created_at": "2026-09-13T05:00:00.000Z",
      "sample_data": true
    },
    {
      "user_id": "30000000-0000-4000-8000-000000000005",
      "event": "session_started",
      "product_id": null,
      "session_id": "cb37f707-b669-4586-b36d-0a72e7c6bd01",
      "created_at": "2026-09-12T05:45:00.000Z",
      "sample_data": true
    },
    {
      "user_id": "30000000-0000-4000-8000-000000000005",
      "event": "view_product",
      "product_id": "bendix-dot-4-brake-and-clutch-fluid-1l",
      "session_id": "cb37f707-b669-4586-b36d-0a72e7c6bd01",
      "created_at": "2026-09-12T05:50:00.000Z",
      "sample_data": true
    },
    {
      "user_id": "30000000-0000-4000-8000-000000000005",
      "event": "checkout_started",
      "product_id": null,
      "session_id": "cb37f707-b669-4586-b36d-0a72e7c6bd01",
      "created_at": "2026-09-12T05:55:00.000Z",
      "sample_data": true
    },
    {
      "user_id": "30000000-0000-4000-8000-000000000005",
      "event": "order_placed",
      "product_id": null,
      "session_id": "cb37f707-b669-4586-b36d-0a72e7c6bd01",
      "created_at": "2026-09-12T06:00:00.000Z",
      "sample_data": true
    },
    {
      "user_id": "30000000-0000-4000-8000-000000000006",
      "event": "session_started",
      "product_id": null,
      "session_id": "3ae4950f-1a94-4050-b41b-1ab6734bed0d",
      "created_at": "2026-09-11T09:45:00.000Z",
      "sample_data": true
    },
    {
      "user_id": "30000000-0000-4000-8000-000000000006",
      "event": "view_product",
      "product_id": "castrol-80w-90-manual-gear-oil-4l",
      "session_id": "3ae4950f-1a94-4050-b41b-1ab6734bed0d",
      "created_at": "2026-09-11T09:50:00.000Z",
      "sample_data": true
    },
    {
      "user_id": "30000000-0000-4000-8000-000000000006",
      "event": "checkout_started",
      "product_id": null,
      "session_id": "3ae4950f-1a94-4050-b41b-1ab6734bed0d",
      "created_at": "2026-09-11T09:55:00.000Z",
      "sample_data": true
    },
    {
      "user_id": "30000000-0000-4000-8000-000000000006",
      "event": "order_placed",
      "product_id": null,
      "session_id": "3ae4950f-1a94-4050-b41b-1ab6734bed0d",
      "created_at": "2026-09-11T10:00:00.000Z",
      "sample_data": true
    },
    {
      "user_id": "30000000-0000-4000-8000-000000000007",
      "event": "session_started",
      "product_id": null,
      "session_id": "b8e44302-59fb-43a1-aef9-88b627b9ec8b",
      "created_at": "2026-09-10T11:45:00.000Z",
      "sample_data": true
    },
    {
      "user_id": "30000000-0000-4000-8000-000000000007",
      "event": "view_product",
      "product_id": "x-traseal-carburetor-and-choke-cleaner-400ml",
      "session_id": "b8e44302-59fb-43a1-aef9-88b627b9ec8b",
      "created_at": "2026-09-10T11:50:00.000Z",
      "sample_data": true
    },
    {
      "user_id": "30000000-0000-4000-8000-000000000007",
      "event": "checkout_started",
      "product_id": null,
      "session_id": "b8e44302-59fb-43a1-aef9-88b627b9ec8b",
      "created_at": "2026-09-10T11:55:00.000Z",
      "sample_data": true
    },
    {
      "user_id": "30000000-0000-4000-8000-000000000007",
      "event": "order_placed",
      "product_id": null,
      "session_id": "b8e44302-59fb-43a1-aef9-88b627b9ec8b",
      "created_at": "2026-09-10T12:00:00.000Z",
      "sample_data": true
    },
    {
      "user_id": "30000000-0000-4000-8000-000000000008",
      "event": "session_started",
      "product_id": null,
      "session_id": "0af11d49-3870-4a2c-95e2-dbd7cacd3321",
      "created_at": "2026-09-09T12:45:00.000Z",
      "sample_data": true
    },
    {
      "user_id": "30000000-0000-4000-8000-000000000008",
      "event": "view_product",
      "product_id": "top-1-green-radiator-coolant-500ml",
      "session_id": "0af11d49-3870-4a2c-95e2-dbd7cacd3321",
      "created_at": "2026-09-09T12:50:00.000Z",
      "sample_data": true
    },
    {
      "user_id": "30000000-0000-4000-8000-000000000008",
      "event": "checkout_started",
      "product_id": null,
      "session_id": "0af11d49-3870-4a2c-95e2-dbd7cacd3321",
      "created_at": "2026-09-09T12:55:00.000Z",
      "sample_data": true
    },
    {
      "user_id": "30000000-0000-4000-8000-000000000008",
      "event": "order_placed",
      "product_id": null,
      "session_id": "0af11d49-3870-4a2c-95e2-dbd7cacd3321",
      "created_at": "2026-09-09T13:00:00.000Z",
      "sample_data": true
    },
    {
      "user_id": "30000000-0000-4000-8000-000000000009",
      "event": "session_started",
      "product_id": null,
      "session_id": "eb67b669-b67c-4135-a618-1a53d153bd78",
      "created_at": "2026-09-08T11:45:00.000Z",
      "sample_data": true
    },
    {
      "user_id": "30000000-0000-4000-8000-000000000009",
      "event": "view_product",
      "product_id": "petrol-filter-for-proton-iriz-saga-vvt-persona-vvt",
      "session_id": "eb67b669-b67c-4135-a618-1a53d153bd78",
      "created_at": "2026-09-08T11:50:00.000Z",
      "sample_data": true
    },
    {
      "user_id": "30000000-0000-4000-8000-000000000009",
      "event": "checkout_started",
      "product_id": null,
      "session_id": "eb67b669-b67c-4135-a618-1a53d153bd78",
      "created_at": "2026-09-08T11:55:00.000Z",
      "sample_data": true
    },
    {
      "user_id": "30000000-0000-4000-8000-000000000009",
      "event": "order_placed",
      "product_id": null,
      "session_id": "eb67b669-b67c-4135-a618-1a53d153bd78",
      "created_at": "2026-09-08T12:00:00.000Z",
      "sample_data": true
    },
    {
      "user_id": "30000000-0000-4000-8000-000000000010",
      "event": "session_started",
      "product_id": null,
      "session_id": "f4533766-cf73-4f91-83ae-b09255ea3592",
      "created_at": "2026-09-07T12:45:00.000Z",
      "sample_data": true
    },
    {
      "user_id": "30000000-0000-4000-8000-000000000010",
      "event": "view_product",
      "product_id": "ngk-lkar7c-9-spark-plugs-4-pack",
      "session_id": "f4533766-cf73-4f91-83ae-b09255ea3592",
      "created_at": "2026-09-07T12:50:00.000Z",
      "sample_data": true
    },
    {
      "user_id": "30000000-0000-4000-8000-000000000010",
      "event": "checkout_started",
      "product_id": null,
      "session_id": "f4533766-cf73-4f91-83ae-b09255ea3592",
      "created_at": "2026-09-07T12:55:00.000Z",
      "sample_data": true
    },
    {
      "user_id": "30000000-0000-4000-8000-000000000010",
      "event": "order_placed",
      "product_id": null,
      "session_id": "f4533766-cf73-4f91-83ae-b09255ea3592",
      "created_at": "2026-09-07T13:00:00.000Z",
      "sample_data": true
    },
    {
      "user_id": "30000000-0000-4000-8000-000000000011",
      "event": "session_started",
      "product_id": null,
      "session_id": "909171a8-9dc4-4368-be34-85ab3c12e423",
      "created_at": "2026-09-06T11:45:00.000Z",
      "sample_data": true
    },
    {
      "user_id": "30000000-0000-4000-8000-000000000011",
      "event": "view_product",
      "product_id": "power-up-power-steering-fluid-1l",
      "session_id": "909171a8-9dc4-4368-be34-85ab3c12e423",
      "created_at": "2026-09-06T11:50:00.000Z",
      "sample_data": true
    },
    {
      "user_id": "30000000-0000-4000-8000-000000000011",
      "event": "checkout_started",
      "product_id": null,
      "session_id": "909171a8-9dc4-4368-be34-85ab3c12e423",
      "created_at": "2026-09-06T11:55:00.000Z",
      "sample_data": true
    },
    {
      "user_id": "30000000-0000-4000-8000-000000000011",
      "event": "order_placed",
      "product_id": null,
      "session_id": "909171a8-9dc4-4368-be34-85ab3c12e423",
      "created_at": "2026-09-06T12:00:00.000Z",
      "sample_data": true
    },
    {
      "user_id": "30000000-0000-4000-8000-000000000012",
      "event": "session_started",
      "product_id": null,
      "session_id": "bde662b8-64b5-47e0-87c7-ced95da1c195",
      "created_at": "2026-09-05T12:45:00.000Z",
      "sample_data": true
    },
    {
      "user_id": "30000000-0000-4000-8000-000000000012",
      "event": "view_product",
      "product_id": "trw-gdb7986-front-brake-pads",
      "session_id": "bde662b8-64b5-47e0-87c7-ced95da1c195",
      "created_at": "2026-09-05T12:50:00.000Z",
      "sample_data": true
    },
    {
      "user_id": "30000000-0000-4000-8000-000000000012",
      "event": "checkout_started",
      "product_id": null,
      "session_id": "bde662b8-64b5-47e0-87c7-ced95da1c195",
      "created_at": "2026-09-05T12:55:00.000Z",
      "sample_data": true
    },
    {
      "user_id": "30000000-0000-4000-8000-000000000012",
      "event": "order_placed",
      "product_id": null,
      "session_id": "bde662b8-64b5-47e0-87c7-ced95da1c195",
      "created_at": "2026-09-05T13:00:00.000Z",
      "sample_data": true
    },
    {
      "user_id": "30000000-0000-4000-8000-000000000001",
      "event": "session_started",
      "product_id": null,
      "session_id": "872ab169-e200-403d-9025-ea3f07e30835",
      "created_at": "2026-09-04T00:45:00.000Z",
      "sample_data": true
    },
    {
      "user_id": "30000000-0000-4000-8000-000000000001",
      "event": "view_product",
      "product_id": "bardahl-10w-30-engine-oil-3-quarts",
      "session_id": "872ab169-e200-403d-9025-ea3f07e30835",
      "created_at": "2026-09-04T00:50:00.000Z",
      "sample_data": true
    },
    {
      "user_id": "30000000-0000-4000-8000-000000000001",
      "event": "checkout_started",
      "product_id": null,
      "session_id": "872ab169-e200-403d-9025-ea3f07e30835",
      "created_at": "2026-09-04T00:55:00.000Z",
      "sample_data": true
    },
    {
      "user_id": "30000000-0000-4000-8000-000000000001",
      "event": "order_placed",
      "product_id": null,
      "session_id": "872ab169-e200-403d-9025-ea3f07e30835",
      "created_at": "2026-09-04T01:00:00.000Z",
      "sample_data": true
    },
    {
      "user_id": "30000000-0000-4000-8000-000000000002",
      "event": "session_started",
      "product_id": null,
      "session_id": "9b66db6d-71b6-4285-87a5-f13f785913cc",
      "created_at": "2026-09-03T01:45:00.000Z",
      "sample_data": true
    },
    {
      "user_id": "30000000-0000-4000-8000-000000000002",
      "event": "view_product",
      "product_id": "cabin-filter-for-proton-x50",
      "session_id": "9b66db6d-71b6-4285-87a5-f13f785913cc",
      "created_at": "2026-09-03T01:50:00.000Z",
      "sample_data": true
    },
    {
      "user_id": "30000000-0000-4000-8000-000000000002",
      "event": "checkout_started",
      "product_id": null,
      "session_id": "9b66db6d-71b6-4285-87a5-f13f785913cc",
      "created_at": "2026-09-03T01:55:00.000Z",
      "sample_data": true
    },
    {
      "user_id": "30000000-0000-4000-8000-000000000002",
      "event": "order_placed",
      "product_id": null,
      "session_id": "9b66db6d-71b6-4285-87a5-f13f785913cc",
      "created_at": "2026-09-03T02:00:00.000Z",
      "sample_data": true
    },
    {
      "user_id": "30000000-0000-4000-8000-000000000003",
      "event": "session_started",
      "product_id": null,
      "session_id": "bd7ee061-baf1-42ed-85e7-2c4ab0449ee9",
      "created_at": "2026-09-02T02:45:00.000Z",
      "sample_data": true
    },
    {
      "user_id": "30000000-0000-4000-8000-000000000003",
      "event": "view_product",
      "product_id": "castrol-gtx-10w-30-engine-oil-3l",
      "session_id": "bd7ee061-baf1-42ed-85e7-2c4ab0449ee9",
      "created_at": "2026-09-02T02:50:00.000Z",
      "sample_data": true
    },
    {
      "user_id": "30000000-0000-4000-8000-000000000003",
      "event": "checkout_started",
      "product_id": null,
      "session_id": "bd7ee061-baf1-42ed-85e7-2c4ab0449ee9",
      "created_at": "2026-09-02T02:55:00.000Z",
      "sample_data": true
    },
    {
      "user_id": "30000000-0000-4000-8000-000000000003",
      "event": "order_placed",
      "product_id": null,
      "session_id": "bd7ee061-baf1-42ed-85e7-2c4ab0449ee9",
      "created_at": "2026-09-02T03:00:00.000Z",
      "sample_data": true
    },
    {
      "user_id": "30000000-0000-4000-8000-000000000004",
      "event": "session_started",
      "product_id": null,
      "session_id": "ffc055c6-e8da-4e20-b0cf-37c487470332",
      "created_at": "2026-09-01T04:45:00.000Z",
      "sample_data": true
    },
    {
      "user_id": "30000000-0000-4000-8000-000000000004",
      "event": "view_product",
      "product_id": "front-brake-pads-for-proton-gen-2-persona-neo",
      "session_id": "ffc055c6-e8da-4e20-b0cf-37c487470332",
      "created_at": "2026-09-01T04:50:00.000Z",
      "sample_data": true
    },
    {
      "user_id": "30000000-0000-4000-8000-000000000004",
      "event": "checkout_started",
      "product_id": null,
      "session_id": "ffc055c6-e8da-4e20-b0cf-37c487470332",
      "created_at": "2026-09-01T04:55:00.000Z",
      "sample_data": true
    },
    {
      "user_id": "30000000-0000-4000-8000-000000000004",
      "event": "order_placed",
      "product_id": null,
      "session_id": "ffc055c6-e8da-4e20-b0cf-37c487470332",
      "created_at": "2026-09-01T05:00:00.000Z",
      "sample_data": true
    },
    {
      "user_id": "30000000-0000-4000-8000-000000000005",
      "event": "session_started",
      "product_id": null,
      "session_id": "a274b7ae-40e5-4d81-a6ac-616f9f51c1f2",
      "created_at": "2026-08-31T05:45:00.000Z",
      "sample_data": true
    },
    {
      "user_id": "30000000-0000-4000-8000-000000000005",
      "event": "view_product",
      "product_id": "petrol-filter-for-proton-iriz-saga-vvt-persona-vvt",
      "session_id": "a274b7ae-40e5-4d81-a6ac-616f9f51c1f2",
      "created_at": "2026-08-31T05:50:00.000Z",
      "sample_data": true
    },
    {
      "user_id": "30000000-0000-4000-8000-000000000005",
      "event": "checkout_started",
      "product_id": null,
      "session_id": "a274b7ae-40e5-4d81-a6ac-616f9f51c1f2",
      "created_at": "2026-08-31T05:55:00.000Z",
      "sample_data": true
    },
    {
      "user_id": "30000000-0000-4000-8000-000000000005",
      "event": "order_placed",
      "product_id": null,
      "session_id": "a274b7ae-40e5-4d81-a6ac-616f9f51c1f2",
      "created_at": "2026-08-31T06:00:00.000Z",
      "sample_data": true
    },
    {
      "user_id": "30000000-0000-4000-8000-000000000006",
      "event": "session_started",
      "product_id": null,
      "session_id": "716c006c-d21f-4a08-82fe-56f8256dab26",
      "created_at": "2026-08-30T09:45:00.000Z",
      "sample_data": true
    },
    {
      "user_id": "30000000-0000-4000-8000-000000000006",
      "event": "view_product",
      "product_id": "denso-k20tnr-s-spark-plugs-4-pack",
      "session_id": "716c006c-d21f-4a08-82fe-56f8256dab26",
      "created_at": "2026-08-30T09:50:00.000Z",
      "sample_data": true
    },
    {
      "user_id": "30000000-0000-4000-8000-000000000006",
      "event": "checkout_started",
      "product_id": null,
      "session_id": "716c006c-d21f-4a08-82fe-56f8256dab26",
      "created_at": "2026-08-30T09:55:00.000Z",
      "sample_data": true
    },
    {
      "user_id": "30000000-0000-4000-8000-000000000006",
      "event": "order_placed",
      "product_id": null,
      "session_id": "716c006c-d21f-4a08-82fe-56f8256dab26",
      "created_at": "2026-08-30T10:00:00.000Z",
      "sample_data": true
    },
    {
      "user_id": "30000000-0000-4000-8000-000000000007",
      "event": "session_started",
      "product_id": null,
      "session_id": "078492d5-37b4-4ea1-9b8a-13e2c141f9fb",
      "created_at": "2026-08-29T11:45:00.000Z",
      "sample_data": true
    },
    {
      "user_id": "30000000-0000-4000-8000-000000000007",
      "event": "view_product",
      "product_id": "toyota-fully-synthetic-0w-20-engine-oil-4l",
      "session_id": "078492d5-37b4-4ea1-9b8a-13e2c141f9fb",
      "created_at": "2026-08-29T11:50:00.000Z",
      "sample_data": true
    },
    {
      "user_id": "30000000-0000-4000-8000-000000000007",
      "event": "checkout_started",
      "product_id": null,
      "session_id": "078492d5-37b4-4ea1-9b8a-13e2c141f9fb",
      "created_at": "2026-08-29T11:55:00.000Z",
      "sample_data": true
    },
    {
      "user_id": "30000000-0000-4000-8000-000000000007",
      "event": "order_placed",
      "product_id": null,
      "session_id": "078492d5-37b4-4ea1-9b8a-13e2c141f9fb",
      "created_at": "2026-08-29T12:00:00.000Z",
      "sample_data": true
    },
    {
      "user_id": "30000000-0000-4000-8000-000000000008",
      "event": "session_started",
      "product_id": null,
      "session_id": "c1f86c4f-fdc1-48e5-98e1-b645a7eb1cd3",
      "created_at": "2026-08-28T12:45:00.000Z",
      "sample_data": true
    },
    {
      "user_id": "30000000-0000-4000-8000-000000000008",
      "event": "view_product",
      "product_id": "bendix-dot-4-brake-and-clutch-fluid-1l",
      "session_id": "c1f86c4f-fdc1-48e5-98e1-b645a7eb1cd3",
      "created_at": "2026-08-28T12:50:00.000Z",
      "sample_data": true
    },
    {
      "user_id": "30000000-0000-4000-8000-000000000008",
      "event": "checkout_started",
      "product_id": null,
      "session_id": "c1f86c4f-fdc1-48e5-98e1-b645a7eb1cd3",
      "created_at": "2026-08-28T12:55:00.000Z",
      "sample_data": true
    },
    {
      "user_id": "30000000-0000-4000-8000-000000000008",
      "event": "order_placed",
      "product_id": null,
      "session_id": "c1f86c4f-fdc1-48e5-98e1-b645a7eb1cd3",
      "created_at": "2026-08-28T13:00:00.000Z",
      "sample_data": true
    },
    {
      "user_id": "30000000-0000-4000-8000-000000000009",
      "event": "session_started",
      "product_id": null,
      "session_id": "a2c213dc-dc6d-4ff8-85a7-11955b2e937d",
      "created_at": "2026-08-27T11:45:00.000Z",
      "sample_data": true
    },
    {
      "user_id": "30000000-0000-4000-8000-000000000009",
      "event": "view_product",
      "product_id": "dexron-iii-atf-d3-transmission-fluid-1l",
      "session_id": "a2c213dc-dc6d-4ff8-85a7-11955b2e937d",
      "created_at": "2026-08-27T11:50:00.000Z",
      "sample_data": true
    },
    {
      "user_id": "30000000-0000-4000-8000-000000000009",
      "event": "checkout_started",
      "product_id": null,
      "session_id": "a2c213dc-dc6d-4ff8-85a7-11955b2e937d",
      "created_at": "2026-08-27T11:55:00.000Z",
      "sample_data": true
    },
    {
      "user_id": "30000000-0000-4000-8000-000000000009",
      "event": "order_placed",
      "product_id": null,
      "session_id": "a2c213dc-dc6d-4ff8-85a7-11955b2e937d",
      "created_at": "2026-08-27T12:00:00.000Z",
      "sample_data": true
    },
    {
      "user_id": "30000000-0000-4000-8000-000000000010",
      "event": "session_started",
      "product_id": null,
      "session_id": "990449a8-a234-484b-8721-f0c8de82e304",
      "created_at": "2026-08-26T12:45:00.000Z",
      "sample_data": true
    },
    {
      "user_id": "30000000-0000-4000-8000-000000000010",
      "event": "view_product",
      "product_id": "x-traseal-carburetor-and-choke-cleaner-400ml",
      "session_id": "990449a8-a234-484b-8721-f0c8de82e304",
      "created_at": "2026-08-26T12:50:00.000Z",
      "sample_data": true
    },
    {
      "user_id": "30000000-0000-4000-8000-000000000010",
      "event": "checkout_started",
      "product_id": null,
      "session_id": "990449a8-a234-484b-8721-f0c8de82e304",
      "created_at": "2026-08-26T12:55:00.000Z",
      "sample_data": true
    },
    {
      "user_id": "30000000-0000-4000-8000-000000000010",
      "event": "order_placed",
      "product_id": null,
      "session_id": "990449a8-a234-484b-8721-f0c8de82e304",
      "created_at": "2026-08-26T13:00:00.000Z",
      "sample_data": true
    },
    {
      "user_id": "30000000-0000-4000-8000-000000000011",
      "event": "session_started",
      "product_id": null,
      "session_id": "f077d141-f723-4c71-b1ce-853d82cf826d",
      "created_at": "2026-08-25T11:45:00.000Z",
      "sample_data": true
    },
    {
      "user_id": "30000000-0000-4000-8000-000000000011",
      "event": "view_product",
      "product_id": "top-1-green-radiator-coolant-500ml",
      "session_id": "f077d141-f723-4c71-b1ce-853d82cf826d",
      "created_at": "2026-08-25T11:50:00.000Z",
      "sample_data": true
    },
    {
      "user_id": "30000000-0000-4000-8000-000000000011",
      "event": "checkout_started",
      "product_id": null,
      "session_id": "f077d141-f723-4c71-b1ce-853d82cf826d",
      "created_at": "2026-08-25T11:55:00.000Z",
      "sample_data": true
    },
    {
      "user_id": "30000000-0000-4000-8000-000000000011",
      "event": "order_placed",
      "product_id": null,
      "session_id": "f077d141-f723-4c71-b1ce-853d82cf826d",
      "created_at": "2026-08-25T12:00:00.000Z",
      "sample_data": true
    },
    {
      "user_id": "30000000-0000-4000-8000-000000000012",
      "event": "session_started",
      "product_id": null,
      "session_id": "f3f5aabc-539c-4a95-9adb-0f2cc116a840",
      "created_at": "2026-08-24T12:45:00.000Z",
      "sample_data": true
    },
    {
      "user_id": "30000000-0000-4000-8000-000000000012",
      "event": "view_product",
      "product_id": "cabin-filter-for-proton-x50",
      "session_id": "f3f5aabc-539c-4a95-9adb-0f2cc116a840",
      "created_at": "2026-08-24T12:50:00.000Z",
      "sample_data": true
    },
    {
      "user_id": "30000000-0000-4000-8000-000000000012",
      "event": "checkout_started",
      "product_id": null,
      "session_id": "f3f5aabc-539c-4a95-9adb-0f2cc116a840",
      "created_at": "2026-08-24T12:55:00.000Z",
      "sample_data": true
    },
    {
      "user_id": "30000000-0000-4000-8000-000000000012",
      "event": "order_placed",
      "product_id": null,
      "session_id": "f3f5aabc-539c-4a95-9adb-0f2cc116a840",
      "created_at": "2026-08-24T13:00:00.000Z",
      "sample_data": true
    },
    {
      "user_id": "30000000-0000-4000-8000-000000000001",
      "event": "session_started",
      "product_id": null,
      "session_id": "0c3b8451-9fea-4190-ae7e-be5e10cec79d",
      "created_at": "2026-08-23T00:45:00.000Z",
      "sample_data": true
    },
    {
      "user_id": "30000000-0000-4000-8000-000000000001",
      "event": "view_product",
      "product_id": "ngk-lkr6c-spark-plug",
      "session_id": "0c3b8451-9fea-4190-ae7e-be5e10cec79d",
      "created_at": "2026-08-23T00:50:00.000Z",
      "sample_data": true
    },
    {
      "user_id": "30000000-0000-4000-8000-000000000001",
      "event": "checkout_started",
      "product_id": null,
      "session_id": "0c3b8451-9fea-4190-ae7e-be5e10cec79d",
      "created_at": "2026-08-23T00:55:00.000Z",
      "sample_data": true
    },
    {
      "user_id": "30000000-0000-4000-8000-000000000001",
      "event": "order_placed",
      "product_id": null,
      "session_id": "0c3b8451-9fea-4190-ae7e-be5e10cec79d",
      "created_at": "2026-08-23T01:00:00.000Z",
      "sample_data": true
    },
    {
      "user_id": "30000000-0000-4000-8000-000000000002",
      "event": "session_started",
      "product_id": null,
      "session_id": "a3f329bc-3c3a-4119-b206-40a12af35c92",
      "created_at": "2026-08-22T01:45:00.000Z",
      "sample_data": true
    },
    {
      "user_id": "30000000-0000-4000-8000-000000000002",
      "event": "view_product",
      "product_id": "power-up-power-steering-fluid-1l",
      "session_id": "a3f329bc-3c3a-4119-b206-40a12af35c92",
      "created_at": "2026-08-22T01:50:00.000Z",
      "sample_data": true
    },
    {
      "user_id": "30000000-0000-4000-8000-000000000002",
      "event": "checkout_started",
      "product_id": null,
      "session_id": "a3f329bc-3c3a-4119-b206-40a12af35c92",
      "created_at": "2026-08-22T01:55:00.000Z",
      "sample_data": true
    },
    {
      "user_id": "30000000-0000-4000-8000-000000000002",
      "event": "order_placed",
      "product_id": null,
      "session_id": "a3f329bc-3c3a-4119-b206-40a12af35c92",
      "created_at": "2026-08-22T02:00:00.000Z",
      "sample_data": true
    },
    {
      "user_id": "30000000-0000-4000-8000-000000000003",
      "event": "session_started",
      "product_id": null,
      "session_id": "cb095283-674d-449d-83ca-1db2e51c7300",
      "created_at": "2026-08-21T02:45:00.000Z",
      "sample_data": true
    },
    {
      "user_id": "30000000-0000-4000-8000-000000000003",
      "event": "view_product",
      "product_id": "trw-gdb1198-front-brake-pads",
      "session_id": "cb095283-674d-449d-83ca-1db2e51c7300",
      "created_at": "2026-08-21T02:50:00.000Z",
      "sample_data": true
    },
    {
      "user_id": "30000000-0000-4000-8000-000000000003",
      "event": "checkout_started",
      "product_id": null,
      "session_id": "cb095283-674d-449d-83ca-1db2e51c7300",
      "created_at": "2026-08-21T02:55:00.000Z",
      "sample_data": true
    },
    {
      "user_id": "30000000-0000-4000-8000-000000000003",
      "event": "order_placed",
      "product_id": null,
      "session_id": "cb095283-674d-449d-83ca-1db2e51c7300",
      "created_at": "2026-08-21T03:00:00.000Z",
      "sample_data": true
    },
    {
      "user_id": "30000000-0000-4000-8000-000000000004",
      "event": "session_started",
      "product_id": null,
      "session_id": "c324af2c-bf78-4474-bbf9-142b88ec1a04",
      "created_at": "2026-08-20T04:45:00.000Z",
      "sample_data": true
    },
    {
      "user_id": "30000000-0000-4000-8000-000000000004",
      "event": "view_product",
      "product_id": "castrol-gtx-10w-30-engine-oil-4l",
      "session_id": "c324af2c-bf78-4474-bbf9-142b88ec1a04",
      "created_at": "2026-08-20T04:50:00.000Z",
      "sample_data": true
    },
    {
      "user_id": "30000000-0000-4000-8000-000000000004",
      "event": "checkout_started",
      "product_id": null,
      "session_id": "c324af2c-bf78-4474-bbf9-142b88ec1a04",
      "created_at": "2026-08-20T04:55:00.000Z",
      "sample_data": true
    },
    {
      "user_id": "30000000-0000-4000-8000-000000000004",
      "event": "order_placed",
      "product_id": null,
      "session_id": "c324af2c-bf78-4474-bbf9-142b88ec1a04",
      "created_at": "2026-08-20T05:00:00.000Z",
      "sample_data": true
    },
    {
      "user_id": "30000000-0000-4000-8000-000000000005",
      "event": "session_started",
      "product_id": null,
      "session_id": "8b9e45fa-cc15-4ff6-a4db-b0cf293c5c0c",
      "created_at": "2026-08-19T05:45:00.000Z",
      "sample_data": true
    },
    {
      "user_id": "30000000-0000-4000-8000-000000000005",
      "event": "view_product",
      "product_id": "petrol-filter-for-proton-iriz-saga-vvt-persona-vvt",
      "session_id": "8b9e45fa-cc15-4ff6-a4db-b0cf293c5c0c",
      "created_at": "2026-08-19T05:50:00.000Z",
      "sample_data": true
    },
    {
      "user_id": "30000000-0000-4000-8000-000000000005",
      "event": "checkout_started",
      "product_id": null,
      "session_id": "8b9e45fa-cc15-4ff6-a4db-b0cf293c5c0c",
      "created_at": "2026-08-19T05:55:00.000Z",
      "sample_data": true
    },
    {
      "user_id": "30000000-0000-4000-8000-000000000005",
      "event": "order_placed",
      "product_id": null,
      "session_id": "8b9e45fa-cc15-4ff6-a4db-b0cf293c5c0c",
      "created_at": "2026-08-19T06:00:00.000Z",
      "sample_data": true
    },
    {
      "user_id": "30000000-0000-4000-8000-000000000006",
      "event": "session_started",
      "product_id": null,
      "session_id": "aace97d3-4583-4f66-98c0-94282175f6e6",
      "created_at": "2026-08-18T09:45:00.000Z",
      "sample_data": true
    },
    {
      "user_id": "30000000-0000-4000-8000-000000000006",
      "event": "view_product",
      "product_id": "toyota-fully-synthetic-0w-20-engine-oil-4l",
      "session_id": "aace97d3-4583-4f66-98c0-94282175f6e6",
      "created_at": "2026-08-18T09:50:00.000Z",
      "sample_data": true
    },
    {
      "user_id": "30000000-0000-4000-8000-000000000006",
      "event": "checkout_started",
      "product_id": null,
      "session_id": "aace97d3-4583-4f66-98c0-94282175f6e6",
      "created_at": "2026-08-18T09:55:00.000Z",
      "sample_data": true
    },
    {
      "user_id": "30000000-0000-4000-8000-000000000006",
      "event": "order_placed",
      "product_id": null,
      "session_id": "aace97d3-4583-4f66-98c0-94282175f6e6",
      "created_at": "2026-08-18T10:00:00.000Z",
      "sample_data": true
    },
    {
      "user_id": "30000000-0000-4000-8000-000000000007",
      "event": "session_started",
      "product_id": null,
      "session_id": "fc939bf5-1159-4e59-96f8-2a187dc1c214",
      "created_at": "2026-08-17T11:45:00.000Z",
      "sample_data": true
    },
    {
      "user_id": "30000000-0000-4000-8000-000000000007",
      "event": "view_product",
      "product_id": "trw-gdb7707-front-brake-pads",
      "session_id": "fc939bf5-1159-4e59-96f8-2a187dc1c214",
      "created_at": "2026-08-17T11:50:00.000Z",
      "sample_data": true
    },
    {
      "user_id": "30000000-0000-4000-8000-000000000007",
      "event": "checkout_started",
      "product_id": null,
      "session_id": "fc939bf5-1159-4e59-96f8-2a187dc1c214",
      "created_at": "2026-08-17T11:55:00.000Z",
      "sample_data": true
    },
    {
      "user_id": "30000000-0000-4000-8000-000000000007",
      "event": "order_placed",
      "product_id": null,
      "session_id": "fc939bf5-1159-4e59-96f8-2a187dc1c214",
      "created_at": "2026-08-17T12:00:00.000Z",
      "sample_data": true
    },
    {
      "user_id": "30000000-0000-4000-8000-000000000008",
      "event": "session_started",
      "product_id": null,
      "session_id": "058494bb-aad5-4596-9172-45ea66c68026",
      "created_at": "2026-08-16T12:45:00.000Z",
      "sample_data": true
    },
    {
      "user_id": "30000000-0000-4000-8000-000000000008",
      "event": "view_product",
      "product_id": "castrol-magnatec-10w-40-engine-oil-4l",
      "session_id": "058494bb-aad5-4596-9172-45ea66c68026",
      "created_at": "2026-08-16T12:50:00.000Z",
      "sample_data": true
    },
    {
      "user_id": "30000000-0000-4000-8000-000000000008",
      "event": "checkout_started",
      "product_id": null,
      "session_id": "058494bb-aad5-4596-9172-45ea66c68026",
      "created_at": "2026-08-16T12:55:00.000Z",
      "sample_data": true
    },
    {
      "user_id": "30000000-0000-4000-8000-000000000008",
      "event": "order_placed",
      "product_id": null,
      "session_id": "058494bb-aad5-4596-9172-45ea66c68026",
      "created_at": "2026-08-16T13:00:00.000Z",
      "sample_data": true
    },
    {
      "user_id": "30000000-0000-4000-8000-000000000009",
      "event": "session_started",
      "product_id": null,
      "session_id": "ef7ef8fc-c1a0-4cdd-8fef-aef2a3bbc2ff",
      "created_at": "2026-08-15T11:45:00.000Z",
      "sample_data": true
    },
    {
      "user_id": "30000000-0000-4000-8000-000000000009",
      "event": "view_product",
      "product_id": "castrol-80w-90-manual-gear-oil-4l",
      "session_id": "ef7ef8fc-c1a0-4cdd-8fef-aef2a3bbc2ff",
      "created_at": "2026-08-15T11:50:00.000Z",
      "sample_data": true
    },
    {
      "user_id": "30000000-0000-4000-8000-000000000009",
      "event": "checkout_started",
      "product_id": null,
      "session_id": "ef7ef8fc-c1a0-4cdd-8fef-aef2a3bbc2ff",
      "created_at": "2026-08-15T11:55:00.000Z",
      "sample_data": true
    },
    {
      "user_id": "30000000-0000-4000-8000-000000000009",
      "event": "order_placed",
      "product_id": null,
      "session_id": "ef7ef8fc-c1a0-4cdd-8fef-aef2a3bbc2ff",
      "created_at": "2026-08-15T12:00:00.000Z",
      "sample_data": true
    },
    {
      "user_id": "30000000-0000-4000-8000-000000000010",
      "event": "session_started",
      "product_id": null,
      "session_id": "a5a31a69-33af-4c85-939f-5b8a88dbc947",
      "created_at": "2026-08-14T12:45:00.000Z",
      "sample_data": true
    },
    {
      "user_id": "30000000-0000-4000-8000-000000000010",
      "event": "view_product",
      "product_id": "bardahl-15w-40-engine-oil-4l",
      "session_id": "a5a31a69-33af-4c85-939f-5b8a88dbc947",
      "created_at": "2026-08-14T12:50:00.000Z",
      "sample_data": true
    },
    {
      "user_id": "30000000-0000-4000-8000-000000000010",
      "event": "checkout_started",
      "product_id": null,
      "session_id": "a5a31a69-33af-4c85-939f-5b8a88dbc947",
      "created_at": "2026-08-14T12:55:00.000Z",
      "sample_data": true
    },
    {
      "user_id": "30000000-0000-4000-8000-000000000010",
      "event": "order_placed",
      "product_id": null,
      "session_id": "a5a31a69-33af-4c85-939f-5b8a88dbc947",
      "created_at": "2026-08-14T13:00:00.000Z",
      "sample_data": true
    },
    {
      "user_id": "30000000-0000-4000-8000-000000000011",
      "event": "session_started",
      "product_id": null,
      "session_id": "14d69de0-5631-4033-bc8c-ff53a1964082",
      "created_at": "2026-08-13T11:45:00.000Z",
      "sample_data": true
    },
    {
      "user_id": "30000000-0000-4000-8000-000000000011",
      "event": "view_product",
      "product_id": "bendix-dot-4-brake-and-clutch-fluid-1l",
      "session_id": "14d69de0-5631-4033-bc8c-ff53a1964082",
      "created_at": "2026-08-13T11:50:00.000Z",
      "sample_data": true
    },
    {
      "user_id": "30000000-0000-4000-8000-000000000011",
      "event": "checkout_started",
      "product_id": null,
      "session_id": "14d69de0-5631-4033-bc8c-ff53a1964082",
      "created_at": "2026-08-13T11:55:00.000Z",
      "sample_data": true
    },
    {
      "user_id": "30000000-0000-4000-8000-000000000011",
      "event": "order_placed",
      "product_id": null,
      "session_id": "14d69de0-5631-4033-bc8c-ff53a1964082",
      "created_at": "2026-08-13T12:00:00.000Z",
      "sample_data": true
    },
    {
      "user_id": "30000000-0000-4000-8000-000000000012",
      "event": "session_started",
      "product_id": null,
      "session_id": "38202973-3df2-4dda-88a4-07baa7f4f85b",
      "created_at": "2026-08-12T12:45:00.000Z",
      "sample_data": true
    },
    {
      "user_id": "30000000-0000-4000-8000-000000000012",
      "event": "view_product",
      "product_id": "proton-atf-hts-4at-fully-synthetic-fluid-3l",
      "session_id": "38202973-3df2-4dda-88a4-07baa7f4f85b",
      "created_at": "2026-08-12T12:50:00.000Z",
      "sample_data": true
    },
    {
      "user_id": "30000000-0000-4000-8000-000000000012",
      "event": "checkout_started",
      "product_id": null,
      "session_id": "38202973-3df2-4dda-88a4-07baa7f4f85b",
      "created_at": "2026-08-12T12:55:00.000Z",
      "sample_data": true
    },
    {
      "user_id": "30000000-0000-4000-8000-000000000012",
      "event": "order_placed",
      "product_id": null,
      "session_id": "38202973-3df2-4dda-88a4-07baa7f4f85b",
      "created_at": "2026-08-12T13:00:00.000Z",
      "sample_data": true
    }
  ],
  "sample_data_version": 1,
  "sample_inventory": [
    {
      "product_id": "toyota-fully-synthetic-0w-20-engine-oil-4l",
      "opening_units": 120,
      "reserved_or_sold_units": 25,
      "restored_units": 0,
      "closing_units": 95
    },
    {
      "product_id": "sae-40-engine-oil-1l",
      "opening_units": 127,
      "reserved_or_sold_units": 23,
      "restored_units": 0,
      "closing_units": 104
    },
    {
      "product_id": "bendix-dot-4-brake-and-clutch-fluid-1l",
      "opening_units": 134,
      "reserved_or_sold_units": 119,
      "restored_units": 32,
      "closing_units": 47
    },
    {
      "product_id": "castrol-gtx-ultraclean-15w-40-engine-oil-4l",
      "opening_units": 141,
      "reserved_or_sold_units": 22,
      "restored_units": 0,
      "closing_units": 119
    },
    {
      "product_id": "proton-cvt-transmission-fluid-1l",
      "opening_units": 148,
      "reserved_or_sold_units": 24,
      "restored_units": 0,
      "closing_units": 124
    },
    {
      "product_id": "x-traseal-carburetor-and-choke-cleaner-400ml",
      "opening_units": 155,
      "reserved_or_sold_units": 39,
      "restored_units": 15,
      "closing_units": 131
    },
    {
      "product_id": "proton-blue-radiator-coolant-4l",
      "opening_units": 162,
      "reserved_or_sold_units": 0,
      "restored_units": 0,
      "closing_units": 162
    },
    {
      "product_id": "automatic-gearbox-filter-for-axia-bezza",
      "opening_units": 169,
      "reserved_or_sold_units": 0,
      "restored_units": 0,
      "closing_units": 169
    },
    {
      "product_id": "cabin-filter-for-proton-x50",
      "opening_units": 176,
      "reserved_or_sold_units": 62,
      "restored_units": 0,
      "closing_units": 114
    },
    {
      "product_id": "cabin-filter-for-proton-x70",
      "opening_units": 183,
      "reserved_or_sold_units": 9,
      "restored_units": 0,
      "closing_units": 174
    },
    {
      "product_id": "engine-air-filter-for-proton-x50",
      "opening_units": 190,
      "reserved_or_sold_units": 0,
      "restored_units": 0,
      "closing_units": 190
    },
    {
      "product_id": "engine-air-filter-for-proton-x70",
      "opening_units": 197,
      "reserved_or_sold_units": 62,
      "restored_units": 0,
      "closing_units": 135
    },
    {
      "product_id": "top-1-green-radiator-coolant-500ml",
      "opening_units": 204,
      "reserved_or_sold_units": 33,
      "restored_units": 0,
      "closing_units": 171
    },
    {
      "product_id": "cvt-gearbox-filter-and-gasket-set",
      "opening_units": 211,
      "reserved_or_sold_units": 0,
      "restored_units": 0,
      "closing_units": 211
    },
    {
      "product_id": "manual-gear-oil-80w-90-4l",
      "opening_units": 218,
      "reserved_or_sold_units": 37,
      "restored_units": 0,
      "closing_units": 181
    },
    {
      "product_id": "manual-gear-oil-ep-140-1l",
      "opening_units": 225,
      "reserved_or_sold_units": 41,
      "restored_units": 0,
      "closing_units": 184
    },
    {
      "product_id": "petrol-filter-for-proton-iriz-saga-vvt-persona-vvt",
      "opening_units": 232,
      "reserved_or_sold_units": 47,
      "restored_units": 11,
      "closing_units": 196
    },
    {
      "product_id": "denso-k20tnr-s-spark-plugs-4-pack",
      "opening_units": 239,
      "reserved_or_sold_units": 10,
      "restored_units": 4,
      "closing_units": 233
    },
    {
      "product_id": "aftermarket-engine-oil-filters-10-pack",
      "opening_units": 246,
      "reserved_or_sold_units": 33,
      "restored_units": 8,
      "closing_units": 221
    },
    {
      "product_id": "perodua-fully-synthetic-0w-20-oil-3-5l-filter",
      "opening_units": 253,
      "reserved_or_sold_units": 29,
      "restored_units": 0,
      "closing_units": 224
    },
    {
      "product_id": "ngk-lkar7c-9-spark-plugs-4-pack",
      "opening_units": 120,
      "reserved_or_sold_units": 5,
      "restored_units": 0,
      "closing_units": 115
    },
    {
      "product_id": "silicone-air-filter-housing-bush-1-piece",
      "opening_units": 127,
      "reserved_or_sold_units": 0,
      "restored_units": 0,
      "closing_units": 127
    },
    {
      "product_id": "castrol-140-manual-gear-oil-4l",
      "opening_units": 134,
      "reserved_or_sold_units": 14,
      "restored_units": 4,
      "closing_units": 124
    },
    {
      "product_id": "perodua-radiator-coolant-1l",
      "opening_units": 141,
      "reserved_or_sold_units": 58,
      "restored_units": 20,
      "closing_units": 103
    },
    {
      "product_id": "ngk-lkr6c-spark-plug",
      "opening_units": 148,
      "reserved_or_sold_units": 1,
      "restored_units": 0,
      "closing_units": 147
    },
    {
      "product_id": "power-up-power-steering-fluid-1l",
      "opening_units": 155,
      "reserved_or_sold_units": 69,
      "restored_units": 0,
      "closing_units": 86
    },
    {
      "product_id": "denso-k16pru-11-spark-plugs-3-pack",
      "opening_units": 162,
      "reserved_or_sold_units": 0,
      "restored_units": 0,
      "closing_units": 162
    },
    {
      "product_id": "bardahl-15w-40-engine-oil-4l",
      "opening_units": 169,
      "reserved_or_sold_units": 28,
      "restored_units": 0,
      "closing_units": 141
    },
    {
      "product_id": "bardahl-10w-30-engine-oil-3-quarts",
      "opening_units": 176,
      "reserved_or_sold_units": 18,
      "restored_units": 0,
      "closing_units": 158
    },
    {
      "product_id": "10w-30-engine-oil-perodua-oil-filter-bundle",
      "opening_units": 183,
      "reserved_or_sold_units": 27,
      "restored_units": 27,
      "closing_units": 183
    },
    {
      "product_id": "castrol-gtx-10w-30-engine-oil-3l",
      "opening_units": 190,
      "reserved_or_sold_units": 60,
      "restored_units": 18,
      "closing_units": 148
    },
    {
      "product_id": "castrol-magnatec-10w-40-engine-oil-4l",
      "opening_units": 197,
      "reserved_or_sold_units": 32,
      "restored_units": 0,
      "closing_units": 165
    },
    {
      "product_id": "castrol-80w-90-manual-gear-oil-4l",
      "opening_units": 204,
      "reserved_or_sold_units": 13,
      "restored_units": 0,
      "closing_units": 191
    },
    {
      "product_id": "castrol-gtx-10w-30-engine-oil-4l",
      "opening_units": 211,
      "reserved_or_sold_units": 42,
      "restored_units": 0,
      "closing_units": 169
    },
    {
      "product_id": "dexron-iii-atf-d3-transmission-fluid-1l",
      "opening_units": 218,
      "reserved_or_sold_units": 25,
      "restored_units": 17,
      "closing_units": 210
    },
    {
      "product_id": "toyota-5w-30-engine-oil-4l",
      "opening_units": 225,
      "reserved_or_sold_units": 29,
      "restored_units": 0,
      "closing_units": 196
    },
    {
      "product_id": "cabin-filter-for-perodua-myvi-alza-axia-bezza",
      "opening_units": 232,
      "reserved_or_sold_units": 20,
      "restored_units": 1,
      "closing_units": 213
    },
    {
      "product_id": "bosch-super-4-fr78x-spark-plugs-4-pack",
      "opening_units": 239,
      "reserved_or_sold_units": 0,
      "restored_units": 0,
      "closing_units": 239
    },
    {
      "product_id": "bosch-super-4-wr78x-spark-plugs-4-pack",
      "opening_units": 246,
      "reserved_or_sold_units": 1,
      "restored_units": 0,
      "closing_units": 245
    },
    {
      "product_id": "ngk-lzkar7a-spark-plug",
      "opening_units": 253,
      "reserved_or_sold_units": 12,
      "restored_units": 0,
      "closing_units": 241
    },
    {
      "product_id": "proton-atf-hts-4at-fully-synthetic-fluid-3l",
      "opening_units": 120,
      "reserved_or_sold_units": 19,
      "restored_units": 0,
      "closing_units": 101
    },
    {
      "product_id": "front-brake-pads-for-proton-gen-2-persona-neo",
      "opening_units": 127,
      "reserved_or_sold_units": 23,
      "restored_units": 1,
      "closing_units": 105
    },
    {
      "product_id": "trw-gdb7707-front-brake-pads",
      "opening_units": 134,
      "reserved_or_sold_units": 26,
      "restored_units": 7,
      "closing_units": 115
    },
    {
      "product_id": "trw-gdb7742-front-brake-pads",
      "opening_units": 141,
      "reserved_or_sold_units": 21,
      "restored_units": 0,
      "closing_units": 120
    },
    {
      "product_id": "trw-gdb7986-front-brake-pads",
      "opening_units": 148,
      "reserved_or_sold_units": 33,
      "restored_units": 0,
      "closing_units": 115
    },
    {
      "product_id": "trw-gdb1198-front-brake-pads",
      "opening_units": 155,
      "reserved_or_sold_units": 37,
      "restored_units": 0,
      "closing_units": 118
    },
    {
      "product_id": "trw-gdb8977-front-brake-pads",
      "opening_units": 162,
      "reserved_or_sold_units": 27,
      "restored_units": 0,
      "closing_units": 135
    },
    {
      "product_id": "trw-gdb3459-front-brake-pads",
      "opening_units": 169,
      "reserved_or_sold_units": 16,
      "restored_units": 11,
      "closing_units": 164
    },
    {
      "product_id": "trw-gdb7856-front-brake-pads",
      "opening_units": 7,
      "reserved_or_sold_units": 0,
      "restored_units": 0,
      "closing_units": 7
    },
    {
      "product_id": "trw-gdb7690-front-brake-pads",
      "opening_units": 8,
      "reserved_or_sold_units": 0,
      "restored_units": 0,
      "closing_units": 8
    },
    {
      "product_id": "supercircuit-proton-x70-downpipe",
      "opening_units": 4,
      "reserved_or_sold_units": 0,
      "restored_units": 0,
      "closing_units": 4
    },
    {
      "product_id": "supercircuit-proton-x50-downpipe",
      "opening_units": 5,
      "reserved_or_sold_units": 0,
      "restored_units": 0,
      "closing_units": 5
    },
    {
      "product_id": "supercircuit-proton-preve-suprima-s-exora-bold-downpipe",
      "opening_units": 6,
      "reserved_or_sold_units": 0,
      "restored_units": 0,
      "closing_units": 6
    },
    {
      "product_id": "liqui-moly-dot-4-brake-fluid-500ml",
      "opening_units": 0,
      "reserved_or_sold_units": 0,
      "restored_units": 0,
      "closing_units": 0
    },
    {
      "product_id": "liqui-moly-dot-5-1-ev-brake-fluid-500ml",
      "opening_units": 0,
      "reserved_or_sold_units": 0,
      "restored_units": 0,
      "closing_units": 0
    },
    {
      "product_id": "bosch-aerotwin-plus-ap32-wiper-blade-single-pack",
      "opening_units": 0,
      "reserved_or_sold_units": 0,
      "restored_units": 0,
      "closing_units": 0
    }
  ],
  "sample_summary": {
    "customers": 12,
    "orders": 84,
    "activity_events": 336,
    "reviews": 18,
    "refunds": 7,
    "days": 90,
    "generated_at": "2026-10-28T09:21:21.350Z"
  }
}$sample_payload$::jsonb;
 marker constant text := 'gearlane-analytics-demo-v1';
 notice_id constant uuid := '31000000-0000-4000-8000-000000000001';
 shift interval;admin_id uuid;worker_id uuid;backup jsonb;expected jsonb;activity_ids jsonb;
begin
 perform pg_advisory_xact_lock(hashtext(marker));
 if exists(select 1 from public.audit_events where action='sample_scenario_seeded_v1' and target=marker) then
  raise notice 'This sample scenario is already installed. No rows or stock were changed.';return;
 end if;
 select id into admin_id from public.profiles where role='admin' and is_active order by created_at,id limit 1;
 if admin_id is null then raise exception 'Create and activate the first administrator before adding examples.';end if;
 select id into worker_id from public.profiles where role='worker' and is_active order by created_at,id limit 1;
 worker_id:=coalesce(worker_id,admin_id);
 shift:=now()-(data->'sample_summary'->>'generated_at')::timestamptz;
 if exists(select 1 from jsonb_array_elements(data->'users') u join auth.users a on a.id=(u->>'id')::uuid or lower(a.email)=lower(u->>'email')) then
  raise exception 'A sample customer ID or email is already in use. No data was changed.';
 end if;
 if exists(select 1 from jsonb_array_elements(data->'sample_inventory') i left join public.products p on p.id=i->>'product_id' where p.id is null) then
  raise exception 'Some catalogue products are missing. Apply 005-catalogue.sql before this example.';
 end if;
 perform p.id from public.products p join jsonb_array_elements(data->'sample_inventory') i on p.id=i->>'product_id' order by p.id for update of p;
 select jsonb_agg(jsonb_build_object('id',p.id,'stock',p.stock,'price_confirmed',p.price_confirmed,'version',p.version)) into backup
 from public.products p join jsonb_array_elements(data->'sample_inventory') i on p.id=i->>'product_id';

 -- Non-login Auth placeholders, matching Supabase's documented seed pattern.
 -- No password, identity, invitation, session or email is created.
 insert into auth.users(id,email,raw_user_meta_data)
 select (u->>'id')::uuid,u->>'email',jsonb_build_object('full_name',u->>'full_name','phone',u->>'phone','business_type',u->>'business_type') from jsonb_array_elements(data->'users') u;
 update public.profiles p set created_at=(u->>'created_at')::timestamptz+shift
 from jsonb_array_elements(data->'users') u where p.id=(u->>'id')::uuid;

 -- Remaining units = fictional opening receipts - sold/reserved units + returns.
 update public.products p set stock=p.stock+(i->>'closing_units')::integer,
 price_confirmed=case when p.stock+(i->>'closing_units')::integer>0 then true else p.price_confirmed end,version=p.version+1
 from jsonb_array_elements(data->'sample_inventory') i where p.id=i->>'product_id';
 select jsonb_agg(jsonb_build_object('id',p.id,'stock',p.stock,'price_confirmed',p.price_confirmed,'version',p.version)) into expected
 from public.products p join jsonb_array_elements(data->'sample_inventory') i on p.id=i->>'product_id';

 -- Use current database selling prices, product labels and delivery configuration.
 with totals as (
  select (o->>'id')::uuid id,sum((item->>'quantity')::integer*p.price_cents)::bigint subtotal
  from jsonb_array_elements(data->'orders') o cross join lateral jsonb_array_elements(o->'items') item
  join public.products p on p.id=item->>'product_id' group by o->>'id'
 )
 insert into public.orders(id,customer_id,status,payment_status,address,subtotal_cents,discount_cents,shipping_cents,total_cents,payment_reference,payment_note,paid_verified_by,tracking_number,carrier,received_at,cancel_reason,idempotency_key,created_at,expires_at,updated_at,payment_instructions)
 select (o->>'id')::uuid,(o->>'customer_id')::uuid,o->>'status',o->>'payment_status',o->'address',t.subtotal,0,
 case when s.free_shipping_cents>0 and t.subtotal>=s.free_shipping_cents then 0 else s.shipping_cents end,
 t.subtotal+case when s.free_shipping_cents>0 and t.subtotal>=s.free_shipping_cents then 0 else s.shipping_cents end,
 o->>'payment_reference','FICTIONAL TEST ORDER — no bank transfer occurred.',case when o->>'payment_status' in('verified','refunded') then worker_id else null end,
 o->>'tracking_number',o->>'carrier',(o->>'received_at')::timestamptz+shift,o->>'cancel_reason',(o->>'idempotency_key')::uuid,
 (o->>'created_at')::timestamptz+shift,(o->>'expires_at')::timestamptz+shift,(o->>'updated_at')::timestamptz+shift,
 jsonb_build_object('bank_name','DEMO — DO NOT TRANSFER','bank_account_name','FICTIONAL EXAMPLE ONLY','bank_account_number','0000000000')
 from jsonb_array_elements(data->'orders') o join totals t on t.id=(o->>'id')::uuid cross join public.store_settings s where s.id=1;

 insert into public.order_items(id,order_id,product_id,name,sku,category,quantity,price_cents,line_total_cents)
 select (i->>'id')::uuid,(o->>'id')::uuid,p.id,p.name,p.sku,p.category,(i->>'quantity')::integer,p.price_cents,(i->>'quantity')::integer*p.price_cents
 from jsonb_array_elements(data->'orders') o cross join lateral jsonb_array_elements(o->'items') i join public.products p on p.id=i->>'product_id';
 insert into public.order_events(id,order_id,actor_id,event,note,created_at)
 select (e->>'id')::uuid,(o->>'id')::uuid,case e->>'actor_id' when 'seed-admin' then admin_id when 'seed-worker' then worker_id else (e->>'actor_id')::uuid end,
 e->>'event',e->>'note',(e->>'created_at')::timestamptz+shift
 from jsonb_array_elements(data->'orders') o cross join lateral jsonb_array_elements(o->'events') e;
 insert into public.refunds(id,order_id,customer_id,reason,status,amount_cents,staff_note,transfer_reference,return_received,stock_restored,created_at,updated_at)
 select (r->>'id')::uuid,o.id,(r->>'customer_id')::uuid,r->>'reason',r->>'status',o.total_cents,r->>'staff_note',r->>'transfer_reference',(r->>'return_received')::boolean,(r->>'stock_restored')::boolean,(r->>'created_at')::timestamptz+shift,(r->>'updated_at')::timestamptz+shift
 from jsonb_array_elements(data->'refunds') r join public.orders o on o.id=(r->>'order_id')::uuid;
 insert into public.reviews(id,order_id,product_id,customer_id,display_name,rating,body,reply,reply_by,published,created_at)
 select (r->>'id')::uuid,(r->>'order_id')::uuid,r->>'product_id',(r->>'customer_id')::uuid,r->>'display_name',(r->>'rating')::integer,r->>'body',r->>'reply',case when r->>'reply_by' is not null then worker_id else null end,true,(r->>'created_at')::timestamptz+shift from jsonb_array_elements(data->'reviews') r;
 insert into public.wishlist(user_id,product_id,created_at)
 select (w->>'user_id')::uuid,w->>'product_id',(w->>'created_at')::timestamptz+shift from jsonb_array_elements(data->'wishlist') w;
 with added as (
  insert into public.activity_events(user_id,event,product_id,session_id,created_at)
  select (a->>'user_id')::uuid,a->>'event',a->>'product_id',(a->>'session_id')::uuid,(a->>'created_at')::timestamptz+shift from jsonb_array_elements(data->'activity') a returning id
 ) select jsonb_agg(id) into activity_ids from added;
 insert into public.announcements(id,title,body,active)
 values(notice_id,'Testing data enabled','This test store includes fictional customer orders, sales, reviews and stock quantities. No sample payment or shipment is real.',true);
 insert into public.audit_events(actor_id,action,target,details)
 values(admin_id,'sample_scenario_seeded_v1',marker,jsonb_build_object('summary',data->'sample_summary','products_before',backup,'products_after',expected,
 'order_ids',(select jsonb_agg(o->>'id') from jsonb_array_elements(data->'orders') o),
 'customer_ids',(select jsonb_agg(u->>'id') from jsonb_array_elements(data->'users') u),
 'activity_ids',activity_ids,'announcement_id',notice_id));
 raise notice 'Added 84 fictional orders, 12 non-login customers and sample inventory. Existing prices and settings were preserved.';
end $seed$;
commit;
select 'Sample analytics installed (or already present)' result,
 (select count(*) from public.profiles where email like 'sample-buyer-%@example.invalid') sample_customers,
 (select count(*) from public.orders o join public.profiles p on p.id=o.customer_id where p.email like 'sample-buyer-%@example.invalid') sample_orders;
