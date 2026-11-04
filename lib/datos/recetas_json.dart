import '../dominio/receta.dart';

Dificultad dificultadDesdeTexto(Object? valor) => switch (valor) {
  'Easy' => Dificultad.facil,
  'Medium' => Dificultad.media,
  'Hard' => Dificultad.dificil,
  _ => Dificultad.desconocida,
};

Receta recetaDesdeJson(Map<String, dynamic> json) {
  switch (json) {
    case {
      'id': int id,
      'name': String nombre,
      'cuisine': String cocina,
      'prepTimeMinutes': int preparacion,
      'cookTimeMinutes': int coccion,
      'servings': int porciones,
      'rating': num calificacion,
    }:
      return Receta(
        id: id,
        nombre: nombre,
        cocina: cocina,
        dificultad: dificultadDesdeTexto(json['difficulty']),
        minutosPreparacion: preparacion,
        minutosCoccion: coccion,
        porciones: porciones,
        calificacion: calificacion.toDouble(),
        etiquetas: _listaTextosOpcional(json, 'tags'),
        ingredientes: _listaTextosOpcional(json, 'ingredients'),
      );
    default:
      throw const FormatException('Faltan campos de la receta o tienen tipos incorrectos.');
  }
}

List<String> _listaTextosOpcional(Map<String, dynamic> json, String campo) {
  if (!json.containsKey(campo)) return const [];

  final valor = json[campo];
  if (valor is! List) {
    throw FormatException('$campo debe ser una lista de textos.');
  }

  final textos = <String>[];
  for (final elemento in valor) {
    if (elemento is! String) {
      throw FormatException('$campo debe contener solo textos.');
    }
    textos.add(elemento);
  }
  return textos;
}

PaginaRecetas paginaDesdeJson(Map<String, dynamic> json) {
  switch (json) {
    case {'recipes': List elementos, 'total': int total}:
      final recetas = <Receta>[];
      for (final elemento in elementos) {
        if (elemento is! Map<String, dynamic>) {
          throw const FormatException('Cada receta debe ser un objeto.');
        }
        recetas.add(recetaDesdeJson(elemento));
      }
      return PaginaRecetas(recetas: recetas, total: total);
    default:
      throw const FormatException('La página debe incluir recipes y total válidos.');
  }
}
