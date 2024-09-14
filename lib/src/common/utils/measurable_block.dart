MeasurableResult<T> measurableBlock<T>(T Function() block) {
  final stopwatch = Stopwatch()..start();
  final result = block();
  stopwatch.stop();
  return MeasurableResult<T>(
    data: result,
    duration: stopwatch.elapsed,
  );
}

class MeasurableResult<T> {
  const MeasurableResult({
    required this.data,
    required this.duration,
  });

  final T data;
  final Duration duration;
}
