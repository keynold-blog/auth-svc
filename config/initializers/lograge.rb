# frozen_string_literal: true

Rails.application.configure do
  config.lograge.enabled = true
  # Store the lograge JSON files in a separate file
  config.lograge.keep_original_rails_log = Rails.env.development?
  # Don't use the Logstash formatter since this requires logstash-event, an
  # unmaintained gem that monkey patches `Time`
  config.lograge.formatter = Lograge::Formatters::Json.new
end
