import 'package:fpdart/fpdart.dart';
import 'package:osserva/core/error/failure.dart';
import 'package:osserva/core/usecases/usecase.dart';
import 'package:osserva/features/analytics/domain/entities/artist_stats.dart';
import 'package:osserva/features/analytics/domain/repositories/analytics_repository.dart';

class GetArtistAnalyticsStats implements UseCase<ArtistStats, String> {
  final AnalyticsRepository repository;

  GetArtistAnalyticsStats(this.repository);

  @override
  Future<Either<Failure, ArtistStats>> call(String artistName) async {
    return await repository.getArtistStats(artistName);
  }
}
