import 'package:flutter/foundation.dart';
import 'package:recetario_utez/datos/recetas_repositorio.dart';
import 'package:recetario_utez/dominio/receta.dart';
import '../dominio/falla_red.dart';
import 'mensajes.dart';

sealed class EstadoRecetas { const EstadoRecetas(); }
final class RecetasInicial extends EstadoRecetas { const RecetasInicial(); }
final class RecetasCargando extends EstadoRecetas { const RecetasCargando(); }
final class RecetasListas extends EstadoRecetas { const RecetasListas(this.recetas, this.total); final List<Receta> recetas; final int total; }
final class RecetasVacias extends EstadoRecetas { const RecetasVacias(this.busqueda); final String busqueda; }
final class RecetasFallidas extends EstadoRecetas { const RecetasFallidas(this.mensaje); final String mensaje; }
class RecetasViewModel extends ChangeNotifier {
  RecetasViewModel(RecetasRepositorio repositorio) : _repositorio = repositorio;

  final RecetasRepositorio _repositorio;
  EstadoRecetas _estado = const RecetasInicial();
  String _ultimaBusqueda = '';
  bool _liberado = false;

  EstadoRecetas get estado => _estado;

  bool get cargando => _estado is RecetasCargando;

  String get ultimaBusqueda => _ultimaBusqueda;

  int get rapidas => switch (_estado) {
    RecetasListas(:final recetas) =>
      recetas.where((receta) => receta.esRapida).length,
    _ => 0,
  };

  Future<void> buscar(String texto) async {
    if (_liberado || cargando) return;

    _ultimaBusqueda = texto.trim();
    _estado = const RecetasCargando();
    notifyListeners();

    // Un listener puede cerrar la pantalla al recibir el estado de carga.
    if (_liberado) return;

    try {
      final pagina = await _repositorio.buscar(texto: _ultimaBusqueda);
      if (_liberado) return;
      _estado = pagina.recetas.isEmpty
          ? RecetasVacias(_ultimaBusqueda)
          : RecetasListas(pagina.recetas, pagina.total);
    } on FallaRed catch (falla) {
      if (_liberado) return;
      _estado = RecetasFallidas(mensajePara(falla));
    } catch (_) {
      if (_liberado) return;
      _estado = const RecetasFallidas(mensajeInesperado);
    }

    notifyListeners();
  }

  Future<void> reintentar() => buscar(_ultimaBusqueda);

  @override
  void dispose() {
    _liberado = true;
    super.dispose();
  }
}
