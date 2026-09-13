Convert the user's messy natural-language description into the supplied situation schema.

Rules:
- Facts are only things the user stated or that are directly entailed by what they stated.
- Do not turn an inference into a fact.
- Use null for unknown scalar facts.
- Preserve uncertainty explicitly.
- Hypotheses may contain useful inferences, but they must stay separate from facts and include confidence from 0 to 1.
- Keep labels short, stable, and machine-friendly.
