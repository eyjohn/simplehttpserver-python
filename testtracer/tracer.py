import w3copentracing
import opentracing
import time
from opentracing.scope_managers import ThreadLocalScopeManager
from .span import Span


class Tracer(w3copentracing.Tracer):
    def __init__(self, scope_manager=None):
        """Initialize a MockTracer instance."""
        scope_manager = ThreadLocalScopeManager() \
            if scope_manager is None else scope_manager

        w3copentracing.Tracer.__init__(self, scope_manager)

    def start_active_span(self,
                          operation_name,
                          child_of=None,
                          references=None,
                          tags=None,
                          start_time=None,
                          ignore_active_span=False,
                          finish_on_close=True):
        span = self.start_span(
            operation_name=operation_name,
            child_of=child_of,
            references=references,
            tags=tags,
            start_time=start_time,
            ignore_active_span=ignore_active_span,
        )
        return self.scope_manager.activate(span, finish_on_close)

    def start_span(self,
                   operation_name=None,
                   child_of=None,
                   references=None,
                   tags=None,
                   start_time=None,
                   ignore_active_span=False):

        start_time = time.time() if start_time is None else start_time

        parent_ctx = None
        if child_of is not None:
            parent_ctx = (
                child_of if isinstance(child_of, opentracing.SpanContext)
                else child_of.context)
        elif references is not None and len(references) > 0:
            parent_ctx = references[0].referenced_context

        if not ignore_active_span and parent_ctx is None:
            scope = self.scope_manager.active
            if scope is not None:
                parent_ctx = scope.span.context

        ctx = w3copentracing.SpanContext(
            span_id=w3copentracing.generate_span_id())

        if parent_ctx is not None:
            if parent_ctx.baggage is not None:
                ctx.baggage = parent_ctx.baggage.copy()
            ctx.trace_id = parent_ctx.trace_id
        else:
            ctx.trace_id = w3copentracing.generate_trace_id()

        return Span(collector=print,
                    tracer=self,
                    context=ctx,
                    operation_name=operation_name,
                    start_time=start_time,
                    tags=tags,
                    references=references)
