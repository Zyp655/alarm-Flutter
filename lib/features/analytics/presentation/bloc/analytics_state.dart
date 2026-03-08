import 'package:equatable/equatable.dart';
import '../../domain/entities/heatmap_entry.dart';
import '../../domain/entities/velocity_data.dart';
import '../../domain/entities/benchmark_data.dart';
import '../../domain/entities/analytics_summary.dart';

abstract class AnalyticsState extends Equatable {
  const AnalyticsState();

  @override
  List<Object?> get props => [];
}

class AnalyticsInitial extends AnalyticsState {}

class AnalyticsLoading extends AnalyticsState {}

class AnalyticsDashboardLoaded extends AnalyticsState {
  final AnalyticsSummary summary;
  final List<HeatmapEntry> heatmap;

  const AnalyticsDashboardLoaded({
    required this.summary,
    required this.heatmap,
  });

  @override
  List<Object?> get props => [summary, heatmap];
}

class VelocityLoaded extends AnalyticsState {
  final VelocityData velocity;

  const VelocityLoaded({required this.velocity});

  @override
  List<Object?> get props => [velocity];
}

class BenchmarkLoaded extends AnalyticsState {
  final BenchmarkData benchmark;

  const BenchmarkLoaded({required this.benchmark});

  @override
  List<Object?> get props => [benchmark];
}

class AnalyticsError extends AnalyticsState {
  final String message;

  const AnalyticsError({required this.message});

  @override
  List<Object?> get props => [message];
}

class ActivityTracked extends AnalyticsState {}
