import 'package:dio/dio.dart';

import '../dominio/falla_red.dart';

FallaRed traducirError(DioException e) {
  return switch (e.type) {
    DioExceptionType.connectionTimeout ||
    DioExceptionType.sendTimeout ||
    DioExceptionType.transformTimeout ||
    DioExceptionType.receiveTimeout => const TiempoAgotado(),
    DioExceptionType.badResponse => switch (e.response?.statusCode) {
      final int codigo when codigo >= 500 => ErrorDelServidor(codigo),
      final int codigo => PeticionRechazada(codigo),
      null => const SinConexion(),
    },
    DioExceptionType.unknown when e.error is FormatException =>
      const RespuestaInvalida(),
    DioExceptionType.unknown ||
    DioExceptionType.connectionError ||
    DioExceptionType.badCertificate ||
    DioExceptionType.cancel => const SinConexion(),
  };
}
