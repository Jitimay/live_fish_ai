import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:live_fish_ai/models/fish_catch.dart';

part 'catch_log_event.dart';
part 'catch_log_state.dart';

class CatchLogBloc extends Bloc<CatchLogEvent, CatchLogState> {
  CatchLogBloc() : super(const CatchLogState()) {
    on<CatchesSubscriptionRequested>(_onSubscriptionRequested);
  }

  Future<void> _onSubscriptionRequested(
    CatchesSubscriptionRequested event,
    Emitter<CatchLogState> emit,
  ) async {
    emit(state.copyWith(status: CatchLogStatus.loading));

    final box = Hive.box<FishCatch>('fish_catches');
    emit(state.copyWith(
      status: CatchLogStatus.success,
      catches: box.values.toList(),
    ));

    await emit.forEach<BoxEvent>(
      box.watch(),
      onData: (data) {
        return state.copyWith(
          status: CatchLogStatus.success,
          catches: box.values.toList(),
        );
      },
      onError: (_, __) => state.copyWith(status: CatchLogStatus.failure),
    );
  }
}
