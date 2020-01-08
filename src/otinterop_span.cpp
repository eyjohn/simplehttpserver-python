#include "otinterop_tracer.h"

using namespace opentracing;
using namespace std;

namespace otinterop {

Span::Span(std::shared_ptr<SpanCollectedData> data,
           w3copentracing::SpanContext context,
           std::shared_ptr<const opentracing::Tracer> tracer,
           opentracing::string_view operation_name,
           const opentracing::StartSpanOptions& options)
    : data_(data), context_(context), tracer_(tracer) {}

void Span::FinishWithOptions(
    const opentracing::FinishSpanOptions& options) noexcept {}

void Span::SetOperationName(opentracing::string_view name) noexcept {}

void Span::SetTag(opentracing::string_view key,
                  const opentracing::Value& value) noexcept {}

void Span::Log(std::initializer_list<
               std::pair<opentracing::string_view, opentracing::Value>>
                   fields) noexcept {}

void Span::Log(opentracing::SystemTime timestamp,
               std::initializer_list<
                   std::pair<opentracing::string_view, opentracing::Value>>
                   fields) noexcept {}

void Span::Log(
    opentracing::SystemTime timestamp,
    const std::vector<std::pair<opentracing::string_view, opentracing::Value>>&
        fields) noexcept {}

void Span::SetBaggageItem(opentracing::string_view restricted_key,
                          opentracing::string_view value) noexcept {}
std::string Span::BaggageItem(opentracing::string_view restricted_key) const
    noexcept {
  return {};
}

const opentracing::SpanContext& Span::context() const noexcept {
  return *(opentracing::SpanContext*)nullptr;
}

const opentracing::Tracer& Span::tracer() const noexcept {
  return *(opentracing::Tracer*)nullptr;
}

}  // namespace otinterop
