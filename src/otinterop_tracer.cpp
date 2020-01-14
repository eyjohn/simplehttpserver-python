#include "otinterop_tracer.h"
#include "otinterop_span.h"

#include <w3copentracing/span_context.h>
#include <algorithm>
#include <chrono>
#include <iterator>

using namespace opentracing;
using namespace std;

namespace otinterop {

std::unique_ptr<opentracing::Span> Tracer::StartProxySpan(
    w3copentracing::SpanContext context, PythonReference python_span) {
  shared_ptr<SpanCollectedData> span_data{
      new SpanCollectedData{context, python_span}};
  tracked_spans_.push_back(span_data);
  return unique_ptr<opentracing::Span>{
      new Span{span_data, context, shared_from_this(), {}, {}}};
}

unique_ptr<opentracing::Span> Tracer::StartSpanWithOptions(
    opentracing::string_view operation_name,
    const StartSpanOptions& options) const noexcept {
  w3copentracing::SpanContext::TraceID trace_id;
  if (options.references.empty()) {
    trace_id = w3copentracing::SpanContext::GenerateTraceID();
  } else {
    trace_id = dynamic_cast<const w3copentracing::SpanContext*>(
                   options.references[0].second)
                   ->trace_id;
  }

  w3copentracing::SpanContext context{
      trace_id, w3copentracing::SpanContext::GenerateSpanID()};

  shared_ptr<SpanCollectedData> span_data{new SpanCollectedData{context}};
  tracked_spans_.push_back(span_data);

  return unique_ptr<opentracing::Span>{new Span{
      span_data, context, shared_from_this(), operation_name, options}};
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

  // Split spans that are no longer held in any spans
  auto unheld_spans_it =
      partition(tracked_spans_.begin(), tracked_spans_.end(),
                [](const auto& span) { return span.use_count() > 1; });

  // Move over the unheld spans
  out.insert(out.end(), make_move_iterator(unheld_spans_it),
             make_move_iterator(tracked_spans_.end()));

  // Erase these spans from the original list
  tracked_spans_.erase(unheld_spans_it, tracked_spans_.end());

  // Append the remaining spans
  out.insert(out.end(), tracked_spans_.begin(), tracked_spans_.end());

  return out;
}

}  // namespace otinterop
