part of 'catch_log_bloc.dart';

abstract class CatchLogEvent extends Equatable {
  const CatchLogEvent();

  @override
  List<Object> get props => [];
}

class CatchesSubscriptionRequested extends CatchLogEvent {
  const CatchesSubscriptionRequested();
}
