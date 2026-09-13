# frozen_string_literal: true

require "yaml"

ROOT = File.expand_path("../..", __dir__)

errors = []

Dir.glob(File.join(ROOT, "evals/scenarios/*.yml")).sort.each do |path|
  data = YAML.safe_load_file(path, permitted_classes: [], aliases: false)
  rel = path.delete_prefix("#{ROOT}/")

  %w[id title status user_input knowledge hidden_expectations].each do |key|
    errors << "#{rel}: missing #{key}" unless data.key?(key)
  end

  case_path = data.dig("knowledge", "case")
  if case_path.nil? || case_path.empty?
    errors << "#{rel}: knowledge.case is required"
  elsif !File.file?(File.join(ROOT, case_path))
    errors << "#{rel}: knowledge.case does not exist: #{case_path}"
  end

  if data["user_input"].to_s.strip.empty?
    errors << "#{rel}: user_input must not be empty"
  end
end

%w[
  evals/schemas/situation-extraction-v1.schema.yml
  evals/schemas/advice-evaluation-v1.schema.yml
  evals/prompts/extract-situation.md
  evals/prompts/advice.md
  evals/prompts/judge.md
  evals/rubrics/advice-quality.yml
].each do |rel|
  errors << "missing required eval file: #{rel}" unless File.file?(File.join(ROOT, rel))
end

if errors.empty?
  puts "eval fixtures valid"
else
  warn errors.join("\n")
  exit 1
end
