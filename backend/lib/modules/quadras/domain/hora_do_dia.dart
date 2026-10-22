class HoraDoDia implements Comparable<HoraDoDia> {
  const HoraDoDia._(this.minutosDesdeMeiaNoite);

  factory HoraDoDia(int hora, int minuto) {
    final valida =
        hora >= 0 &&
        minuto >= 0 &&
        minuto < 60 &&
        (hora < 24 || (hora == 24 && minuto == 0));
    if (!valida) throw RangeError('Hora inválida: $hora:$minuto.');
    return HoraDoDia._(hora * 60 + minuto);
  }

  static final _formato = RegExp(r'^(\d{2}):(\d{2})$');

  static HoraDoDia? tentarLer(String texto) {
    final partes = _formato.firstMatch(texto.trim());
    if (partes == null) return null;
    try {
      return HoraDoDia(int.parse(partes[1]!), int.parse(partes[2]!));
    } on RangeError {
      return null;
    }
  }

  final int minutosDesdeMeiaNoite;

  int get hora => minutosDesdeMeiaNoite ~/ 60;

  int get minuto => minutosDesdeMeiaNoite % 60;

  bool operator <(HoraDoDia outra) =>
      minutosDesdeMeiaNoite < outra.minutosDesdeMeiaNoite;

  bool operator >(HoraDoDia outra) =>
      minutosDesdeMeiaNoite > outra.minutosDesdeMeiaNoite;

  int operator -(HoraDoDia outra) =>
      minutosDesdeMeiaNoite - outra.minutosDesdeMeiaNoite;

  @override
  int compareTo(HoraDoDia outra) =>
      minutosDesdeMeiaNoite.compareTo(outra.minutosDesdeMeiaNoite);

  @override
  bool operator ==(Object other) =>
      other is HoraDoDia &&
      other.minutosDesdeMeiaNoite == minutosDesdeMeiaNoite;

  @override
  int get hashCode => minutosDesdeMeiaNoite.hashCode;

  @override
  String toString() =>
      '${hora.toString().padLeft(2, '0')}:${minuto.toString().padLeft(2, '0')}';
}
