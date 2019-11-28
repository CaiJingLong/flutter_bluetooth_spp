import 'package:flutter/foundation.dart';

class ValueChangeNotifier<T> extends ValueNotifier<T> {
  ValueChangeNotifier() : super(null);

  List<ValueChanged<T>> _observers = [];

  void addObserver(ValueChanged<T> observer) {
    _observers.add(observer);
  }

  void removeObserver(ValueChanged<T> observer) {
    _observers.remove(observer);
  }

  void changeValue(T value) {
    this.value = value;
  }

  @override
  void notifyListeners() {
    notify();
    super.notifyListeners();
  }

  void notify() {
    for (final ob in _observers) {
      ob(value);
    }
  }
}
