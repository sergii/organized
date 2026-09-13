# Eval requests

`evals/requests/run.yml` is an ephemeral trigger file used by the `eval-runner` branch.

A chat-triggered run creates or updates a request on `eval-runner` based on the current `main` branch, for example:

```yaml
scenario: ORG-EVAL-0001
model: gpt-5.6-sol
judge_model: gpt-5.6-sol
reasoning_effort: high
repetitions: 5
```

Pushing that file can trigger the eval workflow, but paid model execution is fail-closed. The `run-eval` job runs only when the repository Actions variable `OPENAI_EVALS_ENABLED` is explicitly set to `true`.

The `OPENAI_API_KEY` secret may remain configured while this variable is absent or false. Fixture validation continues to run and does not spend model API credits.

The request file is intentionally not stored on `main`. Keep ephemeral run requests isolated from normal development history.
