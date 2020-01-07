#include "otinterop_span.h"

#include <w3copentracing/tracer.h>
#include <opentracing/span.h>
#include <opentracing/string_view.h>

#include <memory>
#include <iostream>

namespace otinterop {

class Tracer: public w3copentracing::Tracer {
 public:

  Tracer();

  std::unique_ptr<opentracing::Span> StartSpanWithOptions(
      opentracing::string_view operation_name, const opentracing::StartSpanOptions& options) const
      noexcept override;

  using w3copentracing::Tracer::Extract;
  using w3copentracing::Tracer::Inject;

  opentracing::expected<void> Inject(const opentracing::SpanContext& sc,
                                     std::ostream& writer) const override;

  opentracing::expected<std::unique_ptr<opentracing::SpanContext>> Extract(
      std::istream& reader) const override;

  void Close() noexcept override;

};

}