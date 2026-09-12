# Personal world model

Organized separates **general knowledge about organization** from **the state of a particular person's physical world**.

The knowledge model answers questions such as:

- what principles tend to work;
- what trade-offs matter;
- what workflow fits a case;
- what evidence supports or contradicts a claim.

The personal world model answers different questions:

- what items exist;
- who owns them;
- who currently has custody of them;
- where they are;
- what state they are in;
- what decision has been made about them.

An agent can combine both layers:

```text
Organized knowledge
       +
personal world state
       +
goal and constraints
       ↓
contextual recommendation
```

## Possession is not location

A thing can belong to one person while being physically somewhere else.

Therefore these facts must not be collapsed into one field:

- **ownership** - who legally or practically owns the item;
- **custody** - who currently holds or controls it;
- **location** - where it physically is;
- **disposition** - what lifecycle decision currently applies to it.

Examples:

```text
ownership: me
custody: friend
location: friend's garage
disposition: loaned
```

and:

```text
ownership: friend
previous_owner: me
disposition: gifted
```

The second item should normally leave active inventory because ownership and responsibility have ended.

## Active inventory

Active inventory is not a list of everything a person has ever owned. It is the set of items or responsibilities that still require awareness, retrieval, maintenance, decisions, or future action.

Typical reasons an item remains active:

- it is owned and stored locally;
- it is owned but stored elsewhere;
- it is loaned out and may need to return;
- it is in repair;
- it is listed for sale;
- its ownership or disposition is unresolved.

Typical terminal states:

- gifted;
- sold;
- donated;
- recycled;
- discarded.

Historical records may remain for provenance, accounting, warranty, memory, or analytics without keeping the item in active inventory.

## Future model

The repository does not yet define a complete item schema. Real sessions should reveal which fields are actually useful before an application data model is fixed.

Likely dimensions include:

- identity and category;
- ownership and custody;
- location;
- lifecycle state;
- acquisition history;
- replacement cost;
- resale value;
- sentimental or historical value;
- maintenance burden;
- storage burden;
- mobility burden;
- last use and expected future use.

These are candidate dimensions, not mandatory fields for every item.
