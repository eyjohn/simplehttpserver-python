#include "otinterop_tracer.h"

using namespace opentracing;
using namespace std;

namespace otinterop {

namespace {

template <class Carrier>
expected<void> InjectImpl(const opentracing::SpanContext& span_context,
                          Carrier& writer) {
  return {};
}

// template <class Carrier>
// static expected<void> InjectImpl(const PropagationOptions& propagation_options,
//                                  const SpanContext& span_context,
//                                  Carrier& writer) {
//   if (propagation_options.inject_error_code.value() != 0) {
//     return make_unexpected(propagation_options.inject_error_code);
//   }
//   auto mock_span_context = dynamic_cast<const MockSpanContext*>(&span_context);
//   if (mock_span_context == nullptr) {
//     return make_unexpected(invalid_span_context_error);
//   }
//   return mock_span_context->Inject(propagation_options, writer);
// }


template <class Carrier>
expected<unique_ptr<opentracing::SpanContext>> ExtractImpl(Carrier& reader) {
  return {};
}

// template <class Carrier>
// opentracing::expected<std::unique_ptr<opentracing::SpanContext>> ExtractImpl(
//     const PropagationOptions& propagation_options, Carrier& reader) {
//   if (propagation_options.extract_error_code.value() != 0) {
//     return opentracing::make_unexpected(propagation_options.extract_error_code);
//   }
//   MockSpanContext* mock_span_context;
//   try {
//     mock_span_context = new MockSpanContext{};
//   } catch (const std::bad_alloc&) {
//     return opentracing::make_unexpected(
//         make_error_code(std::errc::not_enough_memory));
//   }
//   std::unique_ptr<opentracing::SpanContext> span_context(mock_span_context);
//   auto result = mock_span_context->Extract(propagation_options, reader);
//   if (!result) {
//     return opentracing::make_unexpected(result.error());
//   }
//   if (!*result) {
//     span_context.reset();
//   }
//   return std::move(span_context);
// }

}

void SpanContext::ForeachBaggageItem(
    std::function<bool(const std::string& key, const std::string& value)> f)
    const
{}

std::string SpanContext::ToTraceID() const noexcept {
    return {};
}

std::string SpanContext::ToSpanID() const noexcept {
    return {};
}

std::unique_ptr<opentracing::SpanContext> SpanContext::Clone() const noexcept {
    return {};
}

Span::Span(std::shared_ptr<const opentracing::Tracer>&& tracer, 
    opentracing::string_view operation_name, 
    const opentracing::StartSpanOptions& options)
{}

void Span::FinishWithOptions(const opentracing::FinishSpanOptions& options) noexcept {
    
}

void Span::SetOperationName(opentracing::string_view name) noexcept {

}

void Span::SetTag(opentracing::string_view key,
                  const opentracing::Value& value) noexcept {
    
}

void Span::Log(std::initializer_list<std::pair<opentracing::string_view, opentracing::Value>>
            fields) noexcept {
    
}

void Span::Log(opentracing::SystemTime timestamp,
        std::initializer_list<std::pair<opentracing::string_view, opentracing::Value>>
            fields) noexcept {

}

void Span::Log(opentracing::SystemTime timestamp,
        const std::vector<std::pair<opentracing::string_view, opentracing::Value>>&
            fields) noexcept {
    
}

void Span::SetBaggageItem(opentracing::string_view restricted_key,
                          opentracing::string_view value) noexcept {

}
std::string Span::BaggageItem(opentracing::string_view restricted_key) const noexcept {
    return {};
}

const opentracing::SpanContext& Span::context() const noexcept {
    return *(opentracing::SpanContext*) nullptr;
}

const opentracing::Tracer& Span::tracer() const noexcept{
    return *(opentracing::Tracer*)nullptr;
}

}  // namespace otinterop
