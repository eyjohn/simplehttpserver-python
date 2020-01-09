#include "otinterop_tracer.h"
#include "otinterop_span.h"

#include <w3copentracing/span_context.h>

using namespace opentracing;
using namespace std;

namespace otinterop {

unique_ptr<opentracing::Span> Tracer::StartSpanWithOptions(
    opentracing::string_view operation_name,
    const StartSpanOptions& options) const noexcept {
  shared_ptr<SpanCollectedData> span_data{new SpanCollectedData{}};
  tracked_spans_.push_back(span_data);
  return unique_ptr<opentracing::Span>{
      new Span{span_data,
               w3copentracing::SpanContext{
                   w3copentracing::SpanContext::GenerateTraceID(),
                   w3copentracing::SpanContext::GenerateSpanID()},
               shared_from_this(), operation_name, options}};
}

void Tracer::Close() noexcept {}

expected<void> Tracer::Inject(const opentracing::SpanContext& sc,
                              ostream& writer) const {
  return {};
}

expected<unique_ptr<opentracing::SpanContext>> Tracer::Extract(
    istream& reader) const {
  return {};
}

Tracer::TrackedSpans Tracer::consume_tracked_spans() {
  TrackedSpans out;
  std::swap(tracked_spans_, out);
  return out;
}

}  // namespace otinterop
