import 'package:fpdart/fpdart.dart';
import 'package:music_player/core/error/failure.dart';
import 'package:music_player/core/usecases/usecase.dart';
import 'package:music_player/features/analytics/domain/repositories/analytics_repository.dart';

class GetArtistAnalyticsStats implements UseCase<Map<String, dynamic>, String> {
  final AnalyticsRepository repository;

  GetArtistAnalyticsStats(this.repository);

  @override
  Future<Either<Failure, Map<String, dynamic>>> call(String artistName) async {
    return await repository.getArtistStats(artistName);
  }
}
