# frozen_string_literal: true

require "fileutils"
require "json"
require "net/http"
require "securerandom"
require "time"
require "uri"
require "yaml"

ROOT = File.expand_path("../..", __dir__)
API_URI = URI("https://api.openai.com/v1/responses")

class OpenAIResponses
  def initialize(api_key:, model:, reasoning_effort:)
    @api_key = api_key
    @model = model
    @reasoning_effort = reasoning_effort
  end

  def call(input:, instructions:, schema: nil, schema_name: nil)
    payload = {
      model: @model,
      input: input,
      instructions: instructions,
      reasoning: { effort: @reasoning_effort },
      store: false
    }

    if schema
      payload[:text] = {
        format: {
          type: "json_schema",
          name: schema_name,
          schema: schema,
          strict: true
        }
      }
    end

    started = Process.clock_gettime(Process::CLOCK_MONOTONIC)
    response = post(payload)
    elapsed_ms = ((Process.clock_gettime(Process::CLOCK_MONOTONIC) - started) * 1000).round

    {
      "response_id" => response["id"],
      "model" => response["model"],
      "latency_ms" => elapsed_ms,
      "usage" => response["usage"],
      "text" => output_text(response)
    }
  end

  private

  def post(payload)
    request = Net::HTTP::Post.new(API_URI)
    request["Authorization"] = "Bearer #{@api_key}"
    request["Content-Type"] = "application/json"
    request.body = JSON.generate(payload)

    http = Net::HTTP.new(API_URI.host, API_URI.port)
    http.use_ssl = true
    http.open_timeout = 30
    http.read_timeout = 180
    response = http.request(request)

    body = JSON.parse(response.body)
    return body if response.is_a?(Net::HTTPSuccess)

    raise "OpenAI API #{response.code}: #{body.dig('error', 'message') || response.body}"
  end

  def output_text(response)
    response.fetch("output", []).each do |item|
      item.fetch("content", []).each do |content|
        return content["text"] if content["type"] == "output_text"
      end
    end

    raise "OpenAI response contained no output_text"
  end
end

def load_yaml(rel)
  YAML.safe_load_file(File.join(ROOT, rel), permitted_classes: [], aliases: false)
end

def read(rel)
  File.read(File.join(ROOT, rel))
end

def strict_schema(rel)
  schema = load_yaml(rel)
  schema.delete("$schema")
  schema.delete("title")
  schema
end

def knowledge_index
  @knowledge_index ||= begin
    index = {}
    ["knowledge/**/*.yml", "cases/*.yml"].flat_map { |pattern| Dir.glob(File.join(ROOT, pattern)) }.sort.each do |path|
      data = YAML.safe_load_file(path, permitted_classes: [], aliases: false)
      index[data["id"]] = path if data["id"]
    end
    index
  end
end

def linked_knowledge(case_rel)
  case_data = load_yaml(case_rel)
  ids = Array(case_data["principles"]) + Array(case_data["heuristics"])
  [case_data, ids]
end

def records_for(ids)
  ids.filter_map do |id|
    path = knowledge_index[id]
    next unless path

    [id, YAML.safe_load_file(path, permitted_classes: [], aliases: false)]
  end
end

def records_text(records)
  records.map { |id, data| "# #{id}\n#{YAML.dump(data)}" }.join("\n")
end

def retrieval_catalog(records)
  records.map do |id, data|
    summary = data["statement"] || data["intent"] || data["slug"]
    "#{id} | #{data['slug']} | #{summary}"
  end.join("\n")
end

def retrieval_schema(ids)
  {
    "type" => "object",
    "additionalProperties" => false,
    "required" => ["selected_ids"],
    "properties" => {
      "selected_ids" => {
        "type" => "array",
        "items" => { "type" => "string", "enum" => ids },
        "maxItems" => [3, ids.length].min
      }
    }
  }
end

def with_word_count(result)
  result.merge("word_count" => result.fetch("text").scan(/\S+/).length)
end

scenario_id = ARGV.fetch(0, "ORG-EVAL-0001")
scenario_rel = "evals/scenarios/#{scenario_id}.yml"
abort "unknown scenario: #{scenario_id}" unless File.file?(File.join(ROOT, scenario_rel))

api_key = ENV["OPENAI_API_KEY"].to_s
abort "OPENAI_API_KEY is required for an actual eval run" if api_key.empty?

model = ENV.fetch("OPENAI_MODEL", "gpt-5.6-sol")
judge_model = ENV.fetch("OPENAI_JUDGE_MODEL", model)
reasoning_effort = ENV.fetch("OPENAI_REASONING_EFFORT", "high")
repetitions = Integer(ENV.fetch("EVAL_REPETITIONS", "1"), 10)
abort "EVAL_REPETITIONS must be between 1 and 10" unless (1..10).cover?(repetitions)

scenario = load_yaml(scenario_rel)
user_input = scenario.fetch("user_input")
client = OpenAIResponses.new(api_key: api_key, model: model, reasoning_effort: reasoning_effort)
judge_client = OpenAIResponses.new(api_key: api_key, model: judge_model, reasoning_effort: reasoning_effort)

extraction = client.call(
  input: user_input,
  instructions: read("evals/prompts/extract-situation.md"),
  schema: strict_schema("evals/schemas/situation-extraction-v1.schema.yml"),
  schema_name: "situation_extraction_v1"
)
extraction["data"] = JSON.parse(extraction.delete("text"))
situation_json = JSON.pretty_generate(extraction.fetch("data"))

case_data, linked_ids = linked_knowledge(scenario.dig("knowledge", "case"))
linked_records = records_for(linked_ids)
full_records = [[case_data.fetch("id"), case_data]] + linked_records

retrieval = client.call(
  input: <<~INPUT,
    USER MESSAGE:
    #{user_input}

    STRUCTURED SITUATION:
    #{situation_json}

    AVAILABLE KNOWLEDGE:
    #{retrieval_catalog(linked_records)}
  INPUT
  instructions: read("evals/prompts/retrieve.md"),
  schema: retrieval_schema(linked_ids),
  schema_name: "organized_retrieval_v1"
)
retrieval["data"] = JSON.parse(retrieval.delete("text"))
retrieved_ids = retrieval.dig("data", "selected_ids")
retrieved_records = records_for(retrieved_ids)

base_instructions = read("evals/prompts/advice.md")
structured_context = <<~CONTEXT
  Organized first converted the user's natural message into this structured situation model. It is an interpretation, not a new source of user facts. Preserve uncertainty.

  <situation_model>
  #{situation_json}
  </situation_model>
CONTEXT

conditions = {
  "naked" => base_instructions,
  "full" => <<~INSTRUCTIONS,
    #{base_instructions}

    #{structured_context}

    The following is the full Organized case context and all linked knowledge. Use only what is relevant. Do not mention internal IDs.

    <organized_knowledge>
    #{records_text(full_records)}
    </organized_knowledge>
  INSTRUCTIONS
  "retrieved" => <<~INSTRUCTIONS
    #{base_instructions}

    #{structured_context}

    The following small set was semantically retrieved from Organized for this situation. Use only what is relevant. Do not mention internal IDs.

    <organized_knowledge>
    #{records_text(retrieved_records)}
    </organized_knowledge>
  INSTRUCTIONS
}

rubric = read("evals/rubrics/advice-quality.yml")
runs = []
wins = Hash.new(0)

repetitions.times do |index|
  execution_order = conditions.keys.shuffle(random: Random.new(SecureRandom.random_number(2**31)))
  answers = {}
  execution_order.each do |condition|
    answers[condition] = with_word_count(client.call(input: user_input, instructions: conditions.fetch(condition)))
  end

  labels = %w[x y z].shuffle(random: Random.new(SecureRandom.random_number(2**31)))
  label_to_condition = labels.zip(conditions.keys).to_h
  judge_input = <<~INPUT
    USER MESSAGE:
    #{user_input}

    RUBRIC:
    #{rubric}

    RESPONSE X:
    #{answers.fetch(label_to_condition.fetch("x")).fetch("text")}

    RESPONSE Y:
    #{answers.fetch(label_to_condition.fetch("y")).fetch("text")}

    RESPONSE Z:
    #{answers.fetch(label_to_condition.fetch("z")).fetch("text")}
  INPUT

  judge = judge_client.call(
    input: judge_input,
    instructions: read("evals/prompts/judge.md"),
    schema: strict_schema("evals/schemas/advice-evaluation-v1.schema.yml"),
    schema_name: "advice_evaluation_v1"
  )
  judge["data"] = JSON.parse(judge.delete("text"))
  judge["blind_mapping"] = label_to_condition

  blind_winner = judge.dig("data", "winner")
  winner = blind_winner == "tie" ? "tie" : label_to_condition.fetch(blind_winner)
  wins[winner] += 1

  runs << {
    "repetition" => index + 1,
    "execution_order" => execution_order,
    "answers" => answers,
    "judge" => judge,
    "winner" => winner
  }

  puts "repetition=#{index + 1}/#{repetitions} winner=#{winner} mapping=#{label_to_condition}"
end

run_id = "#{Time.now.utc.strftime('%Y%m%dT%H%M%SZ')}-#{SecureRandom.hex(4)}"
result = {
  "run_id" => run_id,
  "created_at" => Time.now.utc.iso8601,
  "git_sha" => ENV["GITHUB_SHA"],
  "github_run_id" => ENV["GITHUB_RUN_ID"],
  "scenario_id" => scenario.fetch("id"),
  "model" => model,
  "judge_model" => judge_model,
  "reasoning_effort" => reasoning_effort,
  "repetitions" => repetitions,
  "user_input" => user_input,
  "extraction" => extraction,
  "full_knowledge_ids" => full_records.map(&:first),
  "retrieval" => retrieval,
  "retrieved_knowledge_ids" => retrieved_ids,
  "runs" => runs,
  "aggregate" => { "wins" => wins }
}

output_dir = File.join(ROOT, "tmp/evals", scenario_id)
FileUtils.mkdir_p(output_dir)
output_path = File.join(output_dir, "#{run_id}.json")
File.write(output_path, JSON.pretty_generate(result) + "\n")

puts "wrote #{output_path.delete_prefix("#{ROOT}/")}" 
puts "retrieved=#{retrieved_ids.join(',')}"
puts "wins=#{wins}"
