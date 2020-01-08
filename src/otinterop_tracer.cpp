#include "otinterop_tracer.h"

using namespace opentracing;
using namespace std;

namespace otinterop {

Tracer::Tracer() {}

unique_ptr<opentracing::Span> Tracer::StartSpanWithOptions(
    opentracing::string_view operation_name,
    const StartSpanOptions& options) const noexcept {
  return {};
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

}  // namespace otinterop
