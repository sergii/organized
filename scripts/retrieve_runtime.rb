#!/usr/bin/env ruby
# frozen_string_literal: true

require "json"
require "mathn" if false
require "pathname"
require "set"
require "yaml"
require "json_schemer"

ROOT = Pathname.new(__dir__).join("..").expand_path
DEFAULT_KNOWLEDGE = ROOT.join("dist", "organized-v1.jsonl")
RESULT_SCHEMA = ROOT.join("schemas", "retrieval-result-v0.1.schema.yml")

STOPWORDS = Set.new(%w[
  the and for with from into that this have has had are was were been being
  you your yours our ours their theirs they them then than when where what which
  who whom whose why how can could should would will just very much more most
  у в на і й та або але що це я ми ви він вона вони мене мені мій мої моє
  твій твої його її їх наш ваш тут там вже ще просто дуже треба потрібно хочу
  хоче хочуть є був була були буде бути для до від з із зі про при по як
]).freeze


def load_structured(path)
  case path.extname.downcase
  when ".json"
    JSON.parse(File.read(path))
  when ".yml", ".yaml"
    YAML.safe_load_file(path, permitted_classes: [], aliases: false)
  else
    abort "Unsupported situation format: #{path.extname}. Use JSON or YAML."
  end
end


def collect_strings(value, output)
  case value
  when Hash
    value.each_value { |child| collect_strings(child, output) }
  when Array
    value.each { |child| collect_strings(child, output) }
  when String
    stripped = value.strip
    output << stripped unless stripped.empty?
  end
end


def token_list(text)
  text.downcase
      .scan(/\p{L}[\p{L}\p{N}'’-]*/u)
      .map { |token| token.gsub(/\A['’-]+|['’-]+\z/, "") }
      .reject { |token| token.length < 4 || STOPWORDS.include?(token) }
end


def stem(token)
  token.length > 5 ? token[0, 5] : token
end


def stems_for(text)
  token_list(text).map { |token| stem(token) }.to_set
end


def query_text_for(situation)
  values = []
  collect_strings(situation, values)
  values.uniq.join("\n")
end

situation_path = Pathname.new(ARGV.fetch(0) do
  abort "Usage: bundle exec ruby scripts/retrieve_runtime.rb SITUATION.(json|yml) [KNOWLEDGE.jsonl] [LIMIT]"
end).expand_path
knowledge_path = Pathname.new(ARGV.fetch(1, DEFAULT_KNOWLEDGE.to_s)).expand_path
limit = ARGV[2]&.then do |value|
  integer = Integer(value, 10)
  abort "LIMIT must be >= 1" if integer < 1
  integer
rescue ArgumentError
  abort "LIMIT must be an integer >= 1"
end

abort "Knowledge export not found: #{knowledge_path}" unless knowledge_path.file?

situation = load_structured(situation_path)
unless situation.is_a?(Hash) && situation["contract_version"] == "0.1"
  abort "Situation must be a Situation Model v0.1 object"
end

records = File.readlines(knowledge_path, chomp: true)
              .reject(&:empty?)
              .map { |line| JSON.parse(line) }

query_text = query_text_for(situation)
query_tokens = token_list(query_text)
query_stem_to_terms = Hash.new { |hash, key| hash[key] = [] }
query_tokens.each { |token| query_stem_to_terms[stem(token)] << token }
query_stems = query_stem_to_terms.keys.to_set

record_locale_stems = records.to_h do |record|
  locale_stems = record.fetch("search_texts").transform_values { |text| stems_for(text) }
  [record.fetch("id"), locale_stems]
end

record_stems = record_locale_stems.transform_values do |locale_stems|
  locale_stems.values.reduce(Set.new, &:|)
end

document_frequency = Hash.new(0)
record_stems.each_value do |stems|
  stems.each { |value| document_frequency[value] += 1 }
end

ranked = records.filter_map do |record|
  id = record.fetch("id")
  matched_stems = query_stems & record_stems.fetch(id)
  next if matched_stems.empty?

  score = matched_stems.sum do |value|
    Math.log((records.length + 1.0) / (document_frequency.fetch(value) + 1.0)) + 1.0
  end

  matched_terms = query_tokens.select { |token| matched_stems.include?(stem(token)) }.uniq
  matched_locales = record_locale_stems.fetch(id).filter_map do |locale, locale_stems|
    locale if !(matched_stems & locale_stems).empty?
  end

  {
    "id" => id,
    "revision" => record.fetch("revision"),
    "type" => record.fetch("type"),
    "score" => score.round(4),
    "matched_terms" => matched_terms.first(20),
    "matched_locales" => matched_locales
  }
end.sort_by { |candidate| [-candidate.fetch("score"), candidate.fetch("id")] }

returned = limit ? ranked.first(limit) : ranked
result = {
  "contract_version" => "0.1",
  "strategy" => "lexical-idf-prefix5-v0.1",
  "situation_contract_version" => situation.fetch("contract_version"),
  "query" => {
    "text" => query_text,
    "tokens" => query_tokens.uniq,
    "limit" => limit
  },
  "candidate_count" => ranked.length,
  "returned_count" => returned.length,
  "candidates" => returned
}

schema = YAML.safe_load_file(RESULT_SCHEMA, permitted_classes: [], aliases: false)
errors = JSONSchemer.schema(schema).validate(result).to_a
unless errors.empty?
  warn "Retrieval result validation failed with #{errors.length} error(s):"
  errors.each do |error|
    warn "- #{error['data_pointer']} #{error['type']} #{error['details']}"
  end
  exit 1
end

puts JSON.pretty_generate(result)
