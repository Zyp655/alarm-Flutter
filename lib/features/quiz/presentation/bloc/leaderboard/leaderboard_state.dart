import 'package:equatable/equatable.dart';
import '../../../domain/entities/leaderboard_entry.dart';

abstract class LeaderboardState extends Equatable {
  const LeaderboardState();

  @override
  List<Object?> get props => [];
}

class LeaderboardInitial extends LeaderboardState {}

class LeaderboardLoading extends LeaderboardState {}

class LeaderboardLoaded extends LeaderboardState {
  final List<LeaderboardEntry> entries;
  final String period;

  const LeaderboardLoaded({required this.entries, required this.period});

  @override
  List<Object?> get props => [entries, period];
}

class LeaderboardError extends LeaderboardState {
  final String message;

  const LeaderboardError(this.message);

  @override
  List<Object?> get props => [message];
}
