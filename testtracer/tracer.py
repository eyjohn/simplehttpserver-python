from w3copentracing import generate_span_id, generate_trace_id, SpanContext, Tracer as W3CTracer
import opentracing
import time
from opentracing.scope_managers import ThreadLocalScopeManager
from .span import Span
import sys


class Tracer(W3CTracer):
    def __init__(self, scope_manager=None):
        """Initialize a MockTracer instance."""
        scope_manager = ThreadLocalScopeManager() \
            if scope_manager is None else scope_manager

        W3CTracer.__init__(self, scope_manager)

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

        # Work out parent context from parameters (reference/child_of)
        parent_ctx = None
        if child_of is not None:
            parent_ctx = (
                child_of if isinstance(child_of, opentracing.SpanContext)
                else child_of.context)
        elif references is not None and len(references) > 0:
            parent_ctx = references[0].referenced_context

        # Can we deduce parent_ctx from scope?
        if not ignore_active_span and parent_ctx is None:
            scope = self.scope_manager.active
            if scope is not None:
                parent_ctx = scope.span.context

        ctx = SpanContext(span_id=generate_span_id())
        if parent_ctx is not None:
            # Deduce trace_id from parent
            if parent_ctx.baggage is not None:
                ctx.baggage = parent_ctx.baggage.copy()
            ctx.trace_id = parent_ctx.trace_id

            # Make sure parent ctx is included in references, or add it
            if (references is None or
                    parent_ctx not in [r.referenced_context for r in references]):
                if references is None:
                    references = []
                references = [opentracing.child_of(parent_ctx)]
        else:
            ctx.trace_id = generate_trace_id()

        return Span(collector=lambda x: print(x, file=sys.stderr),
                    tracer=self,
                    context=ctx,
                    operation_name=operation_name,
                    start_time=start_time,
                    tags=tags,
                    references=references)
