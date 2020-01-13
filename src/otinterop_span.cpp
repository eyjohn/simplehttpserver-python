#include "otinterop_tracer.h"

#include <chrono>

using namespace opentracing;

namespace otinterop {

Span::Span(std::shared_ptr<SpanCollectedData> data,
           w3copentracing::SpanContext context,
           std::shared_ptr<const opentracing::Tracer> tracer,
           opentracing::string_view operation_name,
           const opentracing::StartSpanOptions& options)
    : data_(std::move(data)),
      context_(std::move(context)),
      tracer_(std::move(tracer)),
      finished_(false) {
  assert(data_);
  assert(tracer_);
  data_->operation_name = operation_name;
  if (options.start_system_timestamp != opentracing::SystemTime{}) {
    data_->start_time = options.start_system_timestamp;
  } else if (options.start_steady_timestamp != opentracing::SteadyTime{}) {
    data_->start_time =
        std::chrono::system_clock::now() +
        (options.start_steady_timestamp - std::chrono::steady_clock::now());
  } else {
    data_->start_time = std::chrono::system_clock::now();
  }
  for (const auto& ref : options.references) {
    data_->references.emplace_back(
        ref.first,
        *dynamic_cast<const w3copentracing::SpanContext*>(ref.second));
  }
  for (const auto& tag : options.tags) {
    data_->tags[tag.first] = tag.second;
  }
}

Span::~Span() {
  if (!finished_) {
    FinishWithOptions({});
  }
}

void Span::FinishWithOptions(
    const opentracing::FinishSpanOptions& options) noexcept {
  if (options.finish_steady_timestamp != opentracing::SteadyTime{}) {
    data_->finish_time =
        std::chrono::system_clock::now() +
        (options.finish_steady_timestamp - std::chrono::steady_clock::now());
  } else {
    data_->finish_time = std::chrono::system_clock::now();
  }
  data_->logs.insert(data_->logs.end(), options.log_records.begin(),
                     options.log_records.end());
  finished_ = true;
}

void Span::SetOperationName(opentracing::string_view name) noexcept {
  data_->operation_name = name;
}

void Span::SetTag(opentracing::string_view key,
                  const opentracing::Value& value) noexcept {
  data_->tags[key] = value;
}

void Span::Log(std::initializer_list<
               std::pair<opentracing::string_view, opentracing::Value>>
                   fields) noexcept {
  data_->logs.push_back(
      opentracing::LogRecord{std::chrono::system_clock::now(),
                             std::vector<opentracing::LogRecord::Field>(
                                 fields.begin(), fields.end())});
}

void Span::Log(opentracing::SystemTime timestamp,
               std::initializer_list<
                   std::pair<opentracing::string_view, opentracing::Value>>
                   fields) noexcept {
  data_->logs.push_back(opentracing::LogRecord{
      timestamp, std::vector<opentracing::LogRecord::Field>(fields.begin(),
                                                            fields.end())});
}

void Span::Log(
    opentracing::SystemTime timestamp,
    const std::vector<std::pair<opentracing::string_view, opentracing::Value>>&
        fields) noexcept {
  data_->logs.push_back(opentracing::LogRecord{
      timestamp, std::vector<opentracing::LogRecord::Field>(fields.begin(),
                                                            fields.end())});
}

void Span::SetBaggageItem(opentracing::string_view restricted_key,
                          opentracing::string_view value) noexcept {
  data_->baggage[restricted_key] = value;
}

std::string Span::BaggageItem(opentracing::string_view restricted_key) const
    noexcept {
  const auto it = data_->baggage.find(restricted_key);
  if (it != data_->baggage.end()) {
    return it->second;
  }
  return {};
}

const opentracing::SpanContext& Span::context() const noexcept {
  return context_;
}

const opentracing::Tracer& Span::tracer() const noexcept { return *tracer_; }

SpanCollectedData& Span::data() { return *data_; }

}  // namespace otinterop
