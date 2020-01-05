#include <opentracing/tracer.h>
#include <opentracing/span.h>
#include <opentracing/propagation.h>
#include <opentracing/string_view.h>

#include <memory>
#include <string>
#include <map>
#include <optional>
#include <iostream>
#include <functional>

namespace otinterop {

class SpanContext : public opentracing::SpanContext {
 public:

  void ForeachBaggageItem(
      std::function<bool(const std::string& key, const std::string& value)> f)
      const override;

  std::string ToTraceID() const noexcept override;

  std::string ToSpanID() const noexcept override;

  std::unique_ptr<opentracing::SpanContext> Clone() const noexcept override;

 private:
  std::map<std::string, std::string> baggage_;
};

class Span : public opentracing::Span {
 public:
  Span(std::shared_ptr<const opentracing::Tracer>&& tracer, 
       opentracing::string_view operation_name, 
       const opentracing::StartSpanOptions& options);

  void FinishWithOptions(const opentracing::FinishSpanOptions& options) noexcept override;

  void SetOperationName(opentracing::string_view name) noexcept override;

  void SetTag(opentracing::string_view key,
              const opentracing::Value& value) noexcept override;

  void Log(std::initializer_list<std::pair<opentracing::string_view, opentracing::Value>>
               fields) noexcept override;

  void Log(opentracing::SystemTime timestamp,
           std::initializer_list<std::pair<opentracing::string_view, opentracing::Value>>
               fields) noexcept override;

  void Log(opentracing::SystemTime timestamp,
           const std::vector<std::pair<opentracing::string_view, opentracing::Value>>&
               fields) noexcept override;

  void SetBaggageItem(opentracing::string_view restricted_key,
                      opentracing::string_view value) noexcept override;

  std::string BaggageItem(opentracing::string_view restricted_key) const noexcept override;

  const opentracing::SpanContext& context() const noexcept override;

  const opentracing::Tracer& tracer() const noexcept override;

  struct LogData {
    opentracing::SystemTime time;
    std::string key;
    opentracing::Value value;
  };

  struct SpanData {
    std::optional<SystemTime> start_time;
    std::optional<SystemTime> finish_time;
    std::map<std::string, opentracing::Value> tags;
    std::map<std::string, std::string> baggage;
    std::vector<LogData> logs;
  };

private:

};

class Tracer: public opentracing::Tracer {
 public:

  Tracer();

  std::unique_ptr<opentracing::Span> StartSpanWithOptions(
      opentracing::string_view operation_name, const opentracing::StartSpanOptions& options) const
      noexcept override;

  using opentracing::Tracer::Extract;
  using opentracing::Tracer::Inject;

  opentracing::expected<void> Inject(const opentracing::SpanContext& sc,
                                     std::ostream& writer) const override;

  opentracing::expected<void> Inject(const opentracing::SpanContext& sc,
                                     const opentracing::TextMapWriter& writer) const override;

  opentracing::expected<void> Inject(const opentracing::SpanContext& sc,
                                     const opentracing::HTTPHeadersWriter& writer) const override;

  opentracing::expected<std::unique_ptr<opentracing::SpanContext>> Extract(
      std::istream& reader) const override;

  opentracing::expected<std::unique_ptr<opentracing::SpanContext>> Extract(
      const opentracing::TextMapReader& reader) const override;

  opentracing::expected<std::unique_ptr<opentracing::SpanContext>> Extract(
      const opentracing::HTTPHeadersReader& reader) const override;

  void Close() noexcept override;

};

}