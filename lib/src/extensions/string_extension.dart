import 'package:easy_localization/easy_localization.dart';
import 'package:intl/date_symbol_data_local.dart';

extension StringExtension on String {
  DateTime? parse([String? locale]) {
    if (isEmpty) {
      return null;
    }
    if (locale != null && locale.isNotEmpty) {
      initializeDateFormatting(locale);
    }
    String pattern = 'date_format'.tr();
    return DateFormat(pattern, locale).parse(this);
  }
}
