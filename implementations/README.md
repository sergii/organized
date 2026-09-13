# Implementations

`implementations/` contains non-normative, region-specific mappings from Organized's durable knowledge to things that actually exist in a market.

This layer is intentionally separate from `knowledge/`.

Durable knowledge should describe concepts and recommendations that can generalize across countries, products, suppliers, and time. An implementation may name local standards, suppliers, SKUs, prices, availability, or product-specific trade-offs that can change without changing the underlying knowledge.

For example:

```text
Durable knowledge
  moisture-sensitive item + damp/uncontrolled storage
    -> prefer a moisture-resistant container

Ukraine implementation
  -> polypropylene tote is commonly available
  -> cardboard is a poor default for a damp garage/basement
  -> map to current Ukrainian suppliers, sizes, and price ranges
```

## Rules

- Implementations are not canonical facts about the world.
- Every market observation that can become stale should carry an `observed_at` date and provenance URL.
- Supplier names and prices belong here, not in durable principles or concepts.
- A product or supplier may satisfy more than one canonical use case.
- Prefer capability-based mapping (`has_handles`, `recloseable`, `moisture_resistant`) over retailer category names such as "archive box" or "moving box".
- Product recommendations should explain the trade-off, not merely point to a seller.
- Product-specific business choices, such as selling a rechibox-branded equivalent, can be represented alongside third-party alternatives without changing the canonical knowledge.

## Layout

```text
implementations/
├── README.md
└── ua/
    └── household-storage-containers.yml
```

Country directories use ISO 3166-1 alpha-2 codes where practical.
