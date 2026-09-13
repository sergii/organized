#!/usr/bin/env ruby
# frozen_string_literal: true

require "date"
require "fileutils"
require "json"
require "pathname"
require "yaml"
require "json_schemer"

ROOT = Pathname.new(__dir__).join("..").expand_path
DEFAULT_OUTPUT = ROOT.join("dist", "organized-v1.jsonl")
SCHEMA_PATH = ROOT.join("schemas", "runtime-knowledge-record-v1.schema.yml")

SOURCE_GLOBS = [
  "knowledge/principles/*.yml",
  "knowledge/heuristics/*.yml",
  "knowledge/practices/*.yml",
  "knowledge/anti-patterns/*.yml",
  "knowledge/concepts/*.yml",
  "cases/*.yml"
].freeze

METADATA_KEYS = %w[id type slug revision status evidence_status related sources].freeze

output_path = Pathname.new(ARGV.fetch(0, DEFAULT_OUTPUT.to_s)).expand_path

schema = YAML.safe_load_file(SCHEMA_PATH, permitted_classes: [], aliases: false)
schemer = JSONSchemer.schema(schema)


def load_record(path)
  YAML.safe_load_file(path, permitted_classes: [Date, Time], aliases: false) || {}
end


def summary_for(record)
  record["statement"] ||
    record["definition"] ||
    record.dig("situation", "summary") ||
    record["slug"]
end


def collect_text(value, output)
  case value
  when Hash
    value.each do |key, child|
      next if METADATA_KEYS.include?(key)

      collect_text(child, output)
    end
  when Array
    value.each { |child| collect_text(child, output) }
  when String
    stripped = value.strip
    output << stripped unless stripped.empty? || stripped.match?(/\AORG-[A-Z]+-\d{4}\z/)
  end
end


def retrieval_text_for(record)
  parts = [record["slug"], summary_for(record)]
  collect_text(record, parts)
  parts.compact.map(&:strip).reject(&:empty?).uniq.join("\n")
end

paths = SOURCE_GLOBS.flat_map { |glob| Dir[ROOT.join(glob).to_s] }.uniq.sort
records = paths.map do |filename|
  path = Pathname.new(filename)
  source_path = path.relative_path_from(ROOT).to_s
  content = load_record(path)

  {
    "contract_version" => 1,
    "id" => content.fetch("id"),
    "type" => content.fetch("type"),
    "slug" => content.fetch("slug"),
    "revision" => content.fetch("revision"),
    "status" => content.fetch("status"),
    "evidence_status" => content["evidence_status"],
    "summary" => summary_for(content),
    "retrieval_text" => retrieval_text_for(content),
    "source_path" => source_path,
    "content" => content
  }.compact
end.sort_by { |record| record.fetch("id") }

errors = []
records.each_with_index do |record, index|
  schemer.validate(record).each do |error|
    errors << "record #{index + 1} (#{record['id']}): #{error['data_pointer']} #{error['type']} #{error['details']}"
  end
end

unless errors.empty?
  warn "Runtime export validation failed with #{errors.size} error(s):"
  errors.each { |error| warn "- #{error}" }
  exit 1
end

FileUtils.mkdir_p(output_path.dirname)
File.open(output_path, "w") do |file|
  records.each { |record| file.puts(JSON.generate(record)) }
end

puts "Exported #{records.size} runtime knowledge records to #{output_path}"
