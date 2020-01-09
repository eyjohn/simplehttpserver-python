import w3copentracing
import opentracing
import time
from typing import Callable, Optional


class Span(opentracing.Span):
    def __init__(self,
                 collector: Callable[[dict], None],
                 tracer: opentracing.Tracer,
                 context: w3copentracing.SpanContext,
                 operation_name: Optional[str] = None,
                 start_time: Optional[float] = None,
                 tags: dict = {},
                 references: list = []):
        self.collector = collector
        if start_time is None:
            start_time = time.time()
        self.data = {
            "context": context,
            "operation_name": operation_name,
            "references": references if references is not None else [],
            "tags": tags if tags is not None else {},
            "logs": [],
            "start_time": start_time,
            "finish_time": None,
        }
        opentracing.Span.__init__(self, tracer, context)

    def set_operation_name(self, operation_name: str):
        self.data["operation_name"] = operation_name
        return self

    def finish(self, finish_time: Optional[float] = None):
        if finish_time is not None:
            self.data["finish_time"] = finish_time
        if self.data["finish_time"] is None:
            self.data["finish_time"] = time.time()
        self.collector(self.data)
        return self

    def set_tag(self, key: str, value):
        self.data["tags"][key] = value
        return self

    def log_kv(self, key_values, timestamp: float = None):
        if timestamp is None:
            timestamp = time.time()
        self.data["logs"].append((timestamp, key_values))
        return self

    def set_baggage_item(self, key: str, value: str):
        if self.context.baggage is None:
            self.context.baggage = {}
        self.context.baggage[key] = value
        return self

    def get_baggage_item(self, key: str) -> Optional[str]:
        return self.context.baggage.get(key, None)
