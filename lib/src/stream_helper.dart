import 'dart:async';

class StreamHelper<T> extends Stream<T> {
  StreamController<T> _ctl = StreamController.broadcast();
  Stream<T> get stream => _ctl.stream;

  void addData(T value) {
    _ctl.add(value);
  }

  dispose() {
    _ctl.close();
  }

  @override
  StreamSubscription<T> listen(void Function(T event) onData,
      {Function onError, void Function() onDone, bool cancelOnError}) {
    return stream.listen(
      onData,
      cancelOnError: cancelOnError,
      onDone: onDone,
      onError: onError,
    );
  }
}
