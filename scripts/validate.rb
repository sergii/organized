#!/usr/bin/env ruby
# frozen_string_literal: true

require "date"
require "pathname"
require "set"
require "yaml"
require "json_schemer"

ROOT = Pathname.new(__dir__).join("..").expand_path

SCHEMA_RULES = [
  [%r{\Aknowledge/principles/.+\.yml\z}, "principle.schema.yml"],
  [%r{\Aknowledge/heuristics/.+\.yml\z}, "heuristic.schema.yml"],
  [%r{\Aknowledge/concepts/.+\.yml\z}, "concept.schema.yml"],
  [%r{\Aknowledge/practices/.+\.yml\z}, "practice.schema.yml"],
  [%r{\Aknowledge/anti-patterns/.+\.yml\z}, "anti-pattern.schema.yml"],
  [%r{\Acases/.+\.yml\z}, "case.schema.yml"],
  [%r{\Asessions/.+\.yml\z}, "session.schema.yml"],
  [%r{\Aobservations/.+\.yml\z}, "observation.schema.yml"],
  [%r{\Aoutcomes/.+\.yml\z}, "outcome.schema.yml"],
  [%r{\Aquestions/.+\.yml\z}, "question.schema.yml"],
  [%r{\Agaps/.+\.yml\z}, "gap.schema.yml"],
  [%r{\Aconflicts/.+\.yml\z}, "conflict.schema.yml"],
  [%r{\Asources/.+\.yml\z}, "source.schema.yml"]
].freeze

ENTITY_GLOBS = [
  "knowledge/**/*.yml", "cases/*.yml", "sessions/*.yml", "observations/*.yml",
  "outcomes/*.yml", "questions/*.yml", "gaps/*.yml", "conflicts/*.yml", "sources/*.yml"
].freeze

ORG_ID = /\AORG-(?:PR|HEU|PRA|AP|CON|CASE|SES|OBS|OUT|SRC|Q|GAP|CF)-\d{4}\z/
LOCALIZABLE_TYPES = Set.new(%w[principle heuristic practice anti-pattern concept case]).freeze
FORBIDDEN_MANUAL_BACKLINKS = Set.new(%w[observation_ids session_ids outcome_ids question_ids gap_ids conflict_ids open_gaps conflicts example_sessions]).freeze

errors = []

def load_yaml(path, errors)
  YAML.safe_load(File.read(path), permitted_classes: [Date, Time], aliases: false) || {}
rescue StandardError => e
  errors << "#{path.relative_path_from(ROOT)}: YAML error: #{e.message}"
  {}
end

def walk_strings(value, &block)
  case value
  when Hash
    value.each_value { |child| walk_strings(child, &block) }
  when Array
    value.each { |child| walk_strings(child, &block) }
  when String
    yield value
  end
end

schema_cache = {}
records = {}
id_to_path = {}

files = ENTITY_GLOBS.flat_map { |glob| Dir[ROOT.join(glob).to_s] }.uniq.sort

files.each do |filename|
  path = Pathname.new(filename)
  relative = path.relative_path_from(ROOT).to_s
  data = load_yaml(path, errors)
  records[relative] = data

  id = data["id"]
  if id
    if id_to_path.key?(id)
      errors << "#{relative}: duplicate id #{id}; already defined in #{id_to_path[id]}"
    else
      id_to_path[id] = relative
    end

    expected_filename = "#{id}.yml"
    errors << "#{relative}: filename must be #{expected_filename}" unless path.basename.to_s == expected_filename
  else
    errors << "#{relative}: missing id"
  end

  rule = SCHEMA_RULES.find { |pattern, _| pattern.match?(relative) }
  unless rule
    errors << "#{relative}: no schema mapping"
    next
  end

  schema_name = rule.last
  schemer = schema_cache[schema_name] ||= begin
    schema = load_yaml(ROOT.join("schemas", schema_name), errors)
    JSONSchemer.schema(schema)
  end

  schemer.validate(data).each do |error|
    pointer = error["data_pointer"].to_s
    type = error["type"] || "validation"
    details = error["details"]
    errors << "#{relative}#{pointer}: #{type} #{details}".strip
  end
end

records.each do |relative, data|
  walk_strings(data) do |value|
    next unless ORG_ID.match?(value)
    errors << "#{relative}: unresolved reference #{value}" unless id_to_path.key?(value)
  end
end

records.each do |relative, data|
  next unless relative.start_with?("knowledge/", "cases/", "sessions/")
  forbidden = data.keys & FORBIDDEN_MANUAL_BACKLINKS.to_a
  errors << "#{relative}: manual backlink fields are forbidden: #{forbidden.join(', ')}" unless forbidden.empty?
end

localizable = records.values.select { |data| LOCALIZABLE_TYPES.include?(data["type"]) }
%w[en uk].each do |locale_name|
  locale_path = ROOT.join("locales", "#{locale_name}.yml")
  locale = load_yaml(locale_path, errors)

  localizable.each do |entity|
    section = entity["type"] == "case" ? "cases" : "knowledge"
    entry = locale.dig(section, entity["id"])
    unless entry
      errors << "locales/#{locale_name}.yml: missing #{section}.#{entity['id']}"
      next
    end

    unless entry["source_revision"] == entity["revision"]
      errors << "locales/#{locale_name}.yml: #{entity['id']} source_revision=#{entry['source_revision'].inspect}, expected #{entity['revision']}"
    end
  end

  { "knowledge" => localizable.reject { |e| e["type"] == "case" }.map { |e| e["id"] }.to_set,
    "cases" => localizable.select { |e| e["type"] == "case" }.map { |e| e["id"] }.to_set }.each do |section, known_ids|
    actual_ids = Set.new((locale[section] || {}).keys)
    (actual_ids - known_ids).each { |id| errors << "locales/#{locale_name}.yml: unknown localized id #{id}" }
  end
end

glossary = load_yaml(ROOT.join("locales", "glossary.yml"), errors)
(glossary["terms"] || {}).each do |term, translations|
  %w[en uk].each do |locale_name|
    value = translations[locale_name]
    errors << "locales/glossary.yml: #{term}.#{locale_name} is missing" if value.nil? || value.to_s.strip.empty?
  end
end

if errors.empty?
  puts "OK: validated #{records.size} records, #{id_to_path.size} unique IDs, locales en/uk, and referential integrity."
  exit 0
end

warn "Validation failed with #{errors.size} error(s):"
errors.each { |error| warn "- #{error}" }
exit 1
