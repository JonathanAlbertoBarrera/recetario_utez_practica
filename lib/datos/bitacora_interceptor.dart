import 'dart:developer' as developer;

import 'package:dio/dio.dart';

class BitacoraInterceptor extends Interceptor {
  BitacoraInterceptor({void Function(String linea)? escribir})
    : _escribir = escribir ?? ((linea) => developer.log(linea));

  final void Function(String linea) _escribir;
  static const _claveTiempo = 'recetario.bitacora.tiempo';

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    options.extra[_claveTiempo] = Stopwatch()..start();
    _escribir('→ ${options.method} ${options.path}');
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    final opciones = response.requestOptions;
    final milisegundos = _detenerTiempo(opciones);
    _escribir(
      '← ${response.statusCode} ${opciones.method} ${opciones.path} ($milisegundos ms)',
    );
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final opciones = err.requestOptions;
    final milisegundos = _detenerTiempo(opciones);
    final codigo = err.response?.statusCode;
    final textoCodigo = codigo == null ? '' : ' $codigo';
    _escribir(
      '✗ ${err.type.name}$textoCodigo ${opciones.method} ${opciones.path} ($milisegundos ms)',
    );
    handler.next(err);
  }

  int _detenerTiempo(RequestOptions opciones) {
    final reloj = opciones.extra.remove(_claveTiempo);
    if (reloj is! Stopwatch) return 0;
    reloj.stop();
    return reloj.elapsedMilliseconds;
  }
}
