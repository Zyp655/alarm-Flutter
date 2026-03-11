import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/usecases/get_leaderboard_usecase.dart';
import 'leaderboard_event.dart';
import 'leaderboard_state.dart';

class LeaderboardBloc extends Bloc<LeaderboardEvent, LeaderboardState> {
  final GetLeaderboardUseCase getLeaderboard;

  LeaderboardBloc({required this.getLeaderboard})
    : super(LeaderboardInitial()) {
    on<LoadLeaderboard>(_onLoadLeaderboard);
  }

  Future<void> _onLoadLeaderboard(
    LoadLeaderboard event,
    Emitter<LeaderboardState> emit,
  ) async {
    emit(LeaderboardLoading());

    final result = await getLeaderboard(
      GetLeaderboardParams(classId: event.classId, period: event.period),
    );

    result.fold(
      (failure) => emit(LeaderboardError(failure.message)),
      (entries) =>
          emit(LeaderboardLoaded(entries: entries, period: event.period)),
    );
  }
}
