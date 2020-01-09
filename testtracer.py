from testtracer import Tracer

tracer = Tracer()

with tracer.start_active_span("myspan") as scope:
    scope.span.set_tag("foo", "bar")
    with tracer.start_active_span("myspan2") as scope:
        scope.span.set_baggage_item("key", "val")
