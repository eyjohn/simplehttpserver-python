#include "otinterop_span.h"

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