#include <opentracing/propagation.h>
#include <opentracing/span.h>
#include <opentracing/string_view.h>
#include <opentracing/tracer.h>

#include <functional>
#include <iostream>
#include <map>
#include <memory>
#include <optional>
#include <string>

namespace otinterop {

class Span : public opentracing::Span {
 public:
  Span(std::shared_ptr<const opentracing::Tracer>&& tracer,
       opentracing::string_view operation_name,
       const opentracing::StartSpanOptions& options);

  void FinishWithOptions(
      const opentracing::FinishSpanOptions& options) noexcept override;

  void SetOperationName(opentracing::string_view name) noexcept override;

  void SetTag(opentracing::string_view key,
              const opentracing::Value& value) noexcept override;

  void Log(std::initializer_list<
           std::pair<opentracing::string_view, opentracing::Value>>
               fields) noexcept override;

  void Log(opentracing::SystemTime timestamp,
           std::initializer_list<
               std::pair<opentracing::string_view, opentracing::Value>>
               fields) noexcept override;

  void Log(opentracing::SystemTime timestamp,
           const std::vector<
               std::pair<opentracing::string_view, opentracing::Value>>&
               fields) noexcept override;

  void SetBaggageItem(opentracing::string_view restricted_key,
                      opentracing::string_view value) noexcept override;

  std::string BaggageItem(opentracing::string_view restricted_key) const
      noexcept override;

  const opentracing::SpanContext& context() const noexcept override;

  const opentracing::Tracer& tracer() const noexcept override;

  struct SpanData {
    std::optional<opentracing::SystemTime> start_time;
    std::optional<opentracing::SystemTime> finish_time;
    std::map<std::string, opentracing::Value> tags;
    std::map<std::string, std::string> baggage;
    std::vector<opentracing::LogRecord> logs;
  };
};

}  // namespace otinterop