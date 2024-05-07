import 'package:easy_localization/easy_localization.dart';
import 'package:intl/date_symbol_data_local.dart';

extension DateTimeExtension on DateTime {
  String format([String? locale]) {
    if (locale != null && locale.isNotEmpty) {
      initializeDateFormatting(locale);
    }
    String pattern = 'date_format'.tr();
    return DateFormat(pattern, locale).format(this);
  }
}
