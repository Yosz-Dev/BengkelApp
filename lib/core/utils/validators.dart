/// Validator form yang dipakai bersama di seluruh aplikasi.
class Validators {
  Validators._();

  /// Wajib diisi.
  static String? required(String? value, {String field = 'Field'}) {
    if (value == null || value.trim().isEmpty) {
      return '$field wajib diisi';
    }
    return null;
  }

  /// Wajib berupa angka >= 0.
  static String? number(String? value, {String field = 'Field'}) {
    final base = required(value, field: field);
    if (base != null) return base;
    final parsed = num.tryParse(value!.replaceAll('.', '').trim());
    if (parsed == null) return '$field harus berupa angka';
    if (parsed < 0) return '$field tidak boleh negatif';
    return null;
  }

  /// Angka opsional (boleh kosong, jika diisi harus valid).
  static String? optionalNumber(String? value, {String field = 'Field'}) {
    if (value == null || value.trim().isEmpty) return null;
    return number(value, field: field);
  }

  /// Minimal panjang karakter.
  static String? minLength(
    String? value,
    int min, {
    String field = 'Field',
  }) {
    final base = required(value, field: field);
    if (base != null) return base;
    if (value!.trim().length < min) {
      return '$field minimal $min karakter';
    }
    return null;
  }
}
