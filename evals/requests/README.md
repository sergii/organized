# Eval requests

`evals/requests/run.yml` is an ephemeral trigger file used by the `eval-runner` branch.

A chat-triggered run creates a commit on `eval-runner` based on the current `main` branch and adds a request like:

```yaml
scenario: ORG-EVAL-0001
model: gpt-5.6-sol
judge_model: gpt-5.6-sol
reasoning_effort: high
```

Pushing that file to `eval-runner` starts the real eval workflow. Pull requests only validate eval fixtures and do not spend model credits.

The request file is intentionally not stored on `main`. Each run is based on the current `main` tree, so experiments use the latest committed Organized knowledge while remaining isolated from normal development history.
