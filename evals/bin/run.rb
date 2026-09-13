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
    text = output_text(response)

    {
      "response_id" => response["id"],
      "model" => response["model"],
      "latency_ms" => elapsed_ms,
      "usage" => response["usage"],
      "text" => text
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

def knowledge_index
  @knowledge_index ||= begin
    index = {}
    patterns = ["knowledge/**/*.yml", "cases/*.yml"]
    patterns.flat_map { |pattern| Dir.glob(File.join(ROOT, pattern)) }.sort.each do |path|
      data = YAML.safe_load_file(path, permitted_classes: [], aliases: false)
      id = data["id"]
      index[id] = path if id
    end
    index
  end
end

def grounded_context(case_rel)
  case_data = load_yaml(case_rel)
  ids = [case_data["id"]] + Array(case_data["principles"]) + Array(case_data["heuristics"])
  records = ids.filter_map do |id|
    path = knowledge_index[id]
    next unless path

    [id, YAML.safe_load_file(path, permitted_classes: [], aliases: false)]
  end

  text = records.map do |id, data|
    "# #{id}\n#{YAML.dump(data)}"
  end.join("\n")

  [ids, text]
end

def strict_schema(rel)
  schema = load_yaml(rel)
  schema.delete("$schema")
  schema.delete("title")
  schema
end

def with_word_count(result)
  result.merge("word_count" => result.fetch("text").scan(/\S+/).length)
end

scenario_id = ARGV.fetch(0, "ORG-EVAL-0001")
scenario_rel = "evals/scenarios/#{scenario_id}.yml"
scenario_path = File.join(ROOT, scenario_rel)
abort "unknown scenario: #{scenario_id}" unless File.file?(scenario_path)

api_key = ENV["OPENAI_API_KEY"].to_s
abort "OPENAI_API_KEY is required for an actual eval run" if api_key.empty?

model = ENV.fetch("OPENAI_MODEL", "gpt-5.6-sol")
judge_model = ENV.fetch("OPENAI_JUDGE_MODEL", model)
reasoning_effort = ENV.fetch("OPENAI_REASONING_EFFORT", "high")
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

base_instructions = read("evals/prompts/advice.md")
knowledge_ids, knowledge_text = grounded_context(scenario.dig("knowledge", "case"))

conditions = {
  "baseline" => base_instructions,
  "grounded" => <<~INSTRUCTIONS
    #{base_instructions}

    The following Organized domain knowledge is available as reference knowledge. Use it only when relevant. Do not treat it as user-provided facts and do not mention internal IDs.

    <organized_knowledge>
    #{knowledge_text}
    </organized_knowledge>
  INSTRUCTIONS
}

order = conditions.keys.shuffle(random: Random.new(SecureRandom.random_number(2**31)))
answers = {}
order.each do |condition|
  answers[condition] = with_word_count(
    client.call(input: user_input, instructions: conditions.fetch(condition))
  )
end

labels = %w[x y].shuffle(random: Random.new(SecureRandom.random_number(2**31)))
label_to_condition = {
  labels[0] => "baseline",
  labels[1] => "grounded"
}

rubric = read("evals/rubrics/advice-quality.yml")
judge_input = <<~INPUT
  USER MESSAGE:
  #{user_input}

  RUBRIC:
  #{rubric}

  RESPONSE X:
  #{answers.fetch(label_to_condition.fetch("x")).fetch("text")}

  RESPONSE Y:
  #{answers.fetch(label_to_condition.fetch("y")).fetch("text")}
INPUT

judge = judge_client.call(
  input: judge_input,
  instructions: read("evals/prompts/judge.md"),
  schema: strict_schema("evals/schemas/advice-evaluation-v1.schema.yml"),
  schema_name: "advice_evaluation_v1"
)
judge["data"] = JSON.parse(judge.delete("text"))
judge["blind_mapping"] = label_to_condition

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
  "user_input" => user_input,
  "knowledge_ids" => knowledge_ids,
  "execution_order" => order,
  "extraction" => extraction,
  "answers" => answers,
  "judge" => judge
}

output_dir = File.join(ROOT, "tmp/evals", scenario_id)
FileUtils.mkdir_p(output_dir)
output_path = File.join(output_dir, "#{run_id}.json")
File.write(output_path, JSON.pretty_generate(result) + "\n")

puts "wrote #{output_path.delete_prefix("#{ROOT}/")}" 
puts "baseline latency=#{answers.dig('baseline', 'latency_ms')}ms words=#{answers.dig('baseline', 'word_count')}"
puts "grounded latency=#{answers.dig('grounded', 'latency_ms')}ms words=#{answers.dig('grounded', 'word_count')}"
puts "blind judge winner=#{judge.dig('data', 'winner')} mapping=#{label_to_condition}"
