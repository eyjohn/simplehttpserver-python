#pragma once

#include "otinterop_span.h"

#include <opentracing/span.h>
#include <opentracing/string_view.h>
#include <w3copentracing/tracer.h>

#include <iostream>
#include <memory>
#include <vector>

namespace otinterop {

class Tracer : public w3copentracing::Tracer,
               public std::enable_shared_from_this<Tracer> {
 public:
  std::unique_ptr<opentracing::Span> StartProxySpan(
      w3copentracing::SpanContext context);

  std::unique_ptr<opentracing::Span> StartSpanWithOptions(
      opentracing::string_view operation_name,
      const opentracing::StartSpanOptions& options) const noexcept override;

  using w3copentracing::Tracer::Extract;
  using w3copentracing::Tracer::Inject;

  opentracing::expected<void> Inject(const opentracing::SpanContext& sc,
                                     std::ostream& writer) const override;

  opentracing::expected<std::unique_ptr<opentracing::SpanContext>> Extract(
      std::istream& reader) const override;

  void Close() noexcept override;

  using TrackedSpans = std::vector<std::shared_ptr<SpanCollectedData>>;

  // Get all known tracked spans and clear the list
  TrackedSpans consume_tracked_spans();

 private:
  mutable TrackedSpans tracked_spans_;
};

}  // namespace otinterop