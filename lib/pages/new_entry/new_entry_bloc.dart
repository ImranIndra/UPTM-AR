import 'package:rxdart/rxdart.dart';
import '../../models/errors.dart';
import '../../models/urgent_type.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NewEntryBloc {
  BehaviorSubject<UrgentType>? _selectedUrgentType$;
  ValueStream<UrgentType>? get selectedUrgentType =>
      _selectedUrgentType$!.stream;

  BehaviorSubject<int>? _selectedInterval$;
  BehaviorSubject<int>? get selectIntervals => _selectedInterval$;

  BehaviorSubject<String>? _selectedTimeOfDay$;
  BehaviorSubject<String>? get selectedTimeOfDay$ => _selectedTimeOfDay$;

  //error state
  BehaviorSubject<EntryError>? _errorState$;
  BehaviorSubject<EntryError>? get errorState$ => _errorState$;

  NewEntryBloc() {
    _selectedUrgentType$ =
        BehaviorSubject<UrgentType>.seeded(UrgentType.None);

    _selectedTimeOfDay$ = BehaviorSubject<String>.seeded('none');
    _selectedInterval$ = BehaviorSubject<int>.seeded(0);
    _errorState$ = BehaviorSubject<EntryError>();
  }

  void dispose() {
    _selectedUrgentType$!.close();
    _selectedTimeOfDay$!.close();
    _selectedInterval$!.close();
  }

  void submitError(EntryError error) {
    _errorState$!.add(error);
  }

  void updateInterval(int interval) {
    _selectedInterval$!.add(interval);
  }

  void updateTime(String time) {
    _selectedTimeOfDay$!.add(time);
  }

  void updateSelectedUrgent(UrgentType type) {
    UrgentType tempType = _selectedUrgentType$!.value;
    if (type == tempType) {
      _selectedUrgentType$!.add(UrgentType.None);
    } else {
      _selectedUrgentType$!.add(type);
    }
  }
}
