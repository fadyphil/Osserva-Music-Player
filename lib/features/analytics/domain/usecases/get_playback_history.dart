import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/play_log.dart';
import '../repositories/analytics_repository.dart';

class GetPlaybackHistory implements UseCase<List<PlayLog>, GetPlaybackHistoryParams> {
  final AnalyticsRepository repository;

  GetPlaybackHistory(this.repository);

  @override
  Future<Either<Failure, List<PlayLog>>> call(GetPlaybackHistoryParams params) async {
    return await repository.getPlaybackHistory(limit: params.limit, offset: params.offset);
  }
}

class GetPlaybackHistoryParams {
  final int? limit;
  final int? offset;

  const GetPlaybackHistoryParams({this.limit, this.offset});
}
