from testtracer import Tracer
from opentracing import global_tracer, set_global_tracer, Format
tracer = Tracer()
set_global_tracer(tracer)

with global_tracer().start_active_span("first_span") as scope:
    scope.span.set_tag("tag_key", "tag_value")
    with global_tracer().start_active_span("second_span") as scope:
        scope.span.set_baggage_item("baggage_key", "baggage_value")
        carrier = {}
        global_tracer().inject(scope.span.context, Format.TEXT_MAP, carrier)
        print(f"Injected {carrier!r}")
