part of 'catch_log_bloc.dart';

enum CatchLogStatus { initial, loading, success, failure }

class CatchLogState extends Equatable {
  const CatchLogState({
    this.status = CatchLogStatus.initial,
    this.catches = const [],
  });

  final CatchLogStatus status;
  final List<FishCatch> catches;

  CatchLogState copyWith({
    CatchLogStatus? status,
    List<FishCatch>? catches,
  }) {
    return CatchLogState(
      status: status ?? this.status,
      catches: catches ?? this.catches,
    );
  }

  @override
  List<Object> get props => [status, catches];
}
