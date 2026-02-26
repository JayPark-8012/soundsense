import 'package:flutter/widgets.dart';
import 'package:soundsense/l10n/app_localizations.dart';

/// context.l10n 단축키
extension L10nExtension on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this)!;
}
