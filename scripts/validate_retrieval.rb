#!/usr/bin/env ruby
# frozen_string_literal: true

require "json"
require "open3"
require "pathname"
require "rbconfig"
require "tempfile"
require "yaml"

ROOT = Pathname.new(__dir__).join("..").expand_path
SITUATIONS_PATH = ROOT.join("examples", "situations", "v0.1.yml")
FIXTURES_PATH = ROOT.join("examples", "retrieval", "v0.1.yml")
RETRIEVER = ROOT.join("scripts", "retrieve_runtime.rb")
knowledge_path = Pathname.new(ARGV.fetch(0, ROOT.join("tmp", "organized-v1.jsonl").to_s)).expand_path

abort "Knowledge export not found: #{knowledge_path}" unless knowledge_path.file?

situations = YAML.safe_load_file(SITUATIONS_PATH, permitted_classes: [], aliases: false).fetch("examples")
by_id = situations.to_h { |entry| [entry.fetch("id"), entry.fetch("situation")] }
fixtures = YAML.safe_load_file(FIXTURES_PATH, permitted_classes: [], aliases: false).fetch("cases")

errors = []

fixtures.each do |fixture|
  fixture_id = fixture.fetch("id")
  situation_id = fixture.fetch("situation_id")
  situation = by_id[situation_id]

  unless situation
    errors << "#{fixture_id}: unknown situation_id #{situation_id}"
    next
  end

  Tempfile.create(["situation-", ".json"]) do |file|
    file.write(JSON.generate(situation))
    file.flush

    command = [RbConfig.ruby, RETRIEVER.to_s, file.path, knowledge_path.to_s, fixture.fetch("limit").to_s]
    stdout, stderr, status = Open3.capture3(*command)

    unless status.success?
      errors << "#{fixture_id}: retriever failed: #{stderr.strip}"
      next
    end

    result = JSON.parse(stdout)
    ids = result.fetch("candidates").map { |candidate| candidate.fetch("id") }

    fixture.fetch("must_include").each do |expected_id|
      errors << "#{fixture_id}: expected #{expected_id} in top #{fixture.fetch('limit')}, got #{ids.join(', ')}" unless ids.include?(expected_id)
    end
  end
end

if errors.empty?
  puts "OK: validated #{fixtures.length} deterministic retrieval fixture(s)."
  exit 0
end

warn "Retrieval fixture validation failed with #{errors.length} error(s):"
errors.each { |error| warn "- #{error}" }
exit 1
