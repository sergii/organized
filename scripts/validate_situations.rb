#!/usr/bin/env ruby
# frozen_string_literal: true

require "json_schemer"
require "pathname"
require "yaml"

ROOT = Pathname.new(__dir__).join("..").expand_path
SCHEMA_PATH = ROOT.join("schemas", "situation-model-v0.1.schema.yml")
EXAMPLES_PATH = ROOT.join("examples", "situations", "v0.1.yml")

schema = YAML.safe_load_file(SCHEMA_PATH, permitted_classes: [], aliases: false)
schemer = JSONSchemer.schema(schema)
examples = YAML.safe_load_file(EXAMPLES_PATH, permitted_classes: [], aliases: false).fetch("examples")

errors = []
ids = {}

examples.each_with_index do |example, index|
  id = example["id"].to_s
  if id.empty?
    errors << "example #{index + 1}: missing id"
  elsif ids.key?(id)
    errors << "example #{index + 1}: duplicate id #{id}"
  else
    ids[id] = true
  end

  situation = example["situation"] || {}
  schemer.validate(situation).each do |error|
    errors << "#{id.empty? ? "example #{index + 1}" : id}: #{error['data_pointer']} #{error['type']} #{error['details']}"
  end
end

if errors.empty?
  puts "OK: validated #{examples.size} Situation Model v0.1 examples."
  exit 0
end

warn "Situation Model validation failed with #{errors.size} error(s):"
errors.each { |error| warn "- #{error}" }
exit 1
