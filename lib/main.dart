// Copyright (c) 2024 Dthrawn.
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:home_widget/home_widget.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:file_picker/file_picker.dart';

enum AppVisualStyle { vibrant, titanium, deluxe }
enum AppColorPalette { royal, ocean, forest }

class VolumeSliderThumbShape extends SliderComponentShape {
  final double radius;
  final bool isDeluxe;
  const VolumeSliderThumbShape({this.radius = 10, this.isDeluxe = false});
  @override Size getPreferredSize(bool isEnabled, bool isDiscrete) => Size.fromRadius(radius);
  @override void paint(PaintingContext context, Offset center, {required Animation<double> activationAnimation, required Animation<double> enableAnimation, required bool isDiscrete, required TextPainter labelPainter, required RenderBox parentBox, required SliderThemeData sliderTheme, required TextDirection textDirection, required double value, required double textScaleFactor, required Size sizeWithOverflow}) {
    final Canvas canvas = context.canvas;
    final color = sliderTheme.thumbColor ?? Colors.blue;
    final shadowColor = Color.lerp(color, Colors.black, isDeluxe ? 0.5 : 0.4)!;
    final depth = isDeluxe ? 4.0 : 3.0;
    final shift = -depth / 2;
    canvas.drawCircle(center + Offset(0, shift), radius, Paint()..color = shadowColor);
    canvas.drawCircle(center + Offset(0, shift), radius, Paint()..color = color);
    canvas.drawCircle(center + Offset(0, shift), radius, Paint()..color = Colors.white.withValues(alpha: 0.2)..style = PaintingStyle.stroke..strokeWidth = 1);
  }
}

class AppStyle {
  static final ValueNotifier<ThemeMode> themeMode = ValueNotifier(ThemeMode.system);
  static final ValueNotifier<AppVisualStyle> visualStyle = ValueNotifier(AppVisualStyle.deluxe);
  static final ValueNotifier<AppColorPalette> colorPalette = ValueNotifier(AppColorPalette.royal);
  static final ValueNotifier<String> language = ValueNotifier('fr');

  static const Color deluxeBg = Color(0xFFF0F4F8);
  static const Color deluxeButton = Color(0xFF102A43);
  static const Color deluxeInput = Color(0xFFFFFFFF);
  static const Color deluxeOrange = Color(0xFFF97316);
  static const Color deluxeBorder = Color(0xFFD9E2EC);
  static const Color deluxeText = Color(0xFF102A43);

  
  static const Color primary = Color(0xFF7C3AED);
  static const Color primaryDark = Color(0xFFA78BFA); 
  static const Color gain = Color(0xFF059669);
  static const Color gainDark = Color(0xFF34D399); 
  static const Color discount = Color(0xFFF59E0B);
  static const Color discountDark = Color(0xFFFBBF24);
  static const Color textDark = Color(0xFF0F172A); 
  static const Color textLight = Color(0xFF64748B); 
  static const Color cardBorder = Color(0xFFE2E8F0); 

  static double arondir(double val) {
    double cents = val * 100;
    if ((cents - cents.floor()).abs() < 0.0001) return cents.roundToDouble() / 100.0;
    return cents.ceilToDouble() / 100.0;
  }
  static String n(double val) => arondir(val).toStringAsFixed(2);

  
  static const Color titaniumPrimary = Color(0xFF1E3A8A);
  static const Color titaniumBg = Color(0xFFF8FAFC);
  static const Color titaniumBorder = Color(0xFFCBD5E1);

  static Color getPrimaryColor(bool isDark, AppVisualStyle style, AppColorPalette palette) {
    if (isDark) {
      switch (palette) {
        case AppColorPalette.ocean: return const Color(0xFF38BDF8);
        case AppColorPalette.forest: return const Color(0xFFFB7185);
        default: return const Color(0xFFA78BFA);
      }
    } else {
      switch (palette) {
        case AppColorPalette.ocean: return const Color(0xFF0284C7);
        case AppColorPalette.forest: return const Color(0xFF9F1239);
        default: return const Color(0xFF6D28D9);
      }
    }
  }

  static Color getSecondaryColor(bool isDark, AppVisualStyle style, AppColorPalette palette) {
    if (isDark) {
      switch (palette) {
        case AppColorPalette.ocean: return const Color(0xFFFACC15);
        case AppColorPalette.forest: return const Color(0xFFE2E8F0);
        default: return const Color(0xFF34D399);
      }
    } else {
      switch (palette) {
        case AppColorPalette.ocean: return const Color(0xFFD97706);
        case AppColorPalette.forest: return const Color(0xFF1E293B);
        default: return const Color(0xFF059669);
      }
    }
  }

  static Color getDiscountColor(bool isDark, AppVisualStyle style, AppColorPalette palette) {
    if (isDark) {
      switch (palette) {
        case AppColorPalette.ocean: return const Color(0xFFF472B6);
        default: return const Color(0xFFFBBF24);
      }
    } else {
      switch (palette) {
        case AppColorPalette.ocean: return const Color(0xFFDB2777);
        default: return const Color(0xFFF59E0B);
      }
    }
  }

  static ThemeData getTheme(bool isDark) {
    final style = visualStyle.value;
    final palette = colorPalette.value;
    final primaryColor = getPrimaryColor(isDark, style, palette);
    final secondaryColor = getSecondaryColor(isDark, style, palette);
    
    Color bgColor;
    Color surfaceColor;

    if (isDark) {
      switch (palette) {
        case AppColorPalette.ocean:
          bgColor = const Color(0xFF082F49);
          surfaceColor = const Color(0xFF0C4A6E);
          break;
        case AppColorPalette.forest:
          bgColor = const Color(0xFF020617);
          surfaceColor = const Color(0xFF0F172A);
          break;
        default: // royal
          bgColor = const Color(0xFF030712);
          surfaceColor = const Color(0xFF111827);
      }
      if (style == AppVisualStyle.deluxe) {
        bgColor = const Color(0xFF0F172A);
        surfaceColor = const Color(0xFF102A43);
      }
    } else {
      surfaceColor = Colors.white;
      switch (style) {
        case AppVisualStyle.deluxe: bgColor = deluxeBg; break;
        case AppVisualStyle.titanium: bgColor = titaniumBg; break;
        default: bgColor = Colors.white;
      }
    }

    return ThemeData(
      useMaterial3: true,
      brightness: isDark ? Brightness.dark : Brightness.light,
      scaffoldBackgroundColor: bgColor,
      colorScheme: ColorScheme.fromSeed(
        brightness: isDark ? Brightness.dark : Brightness.light,
        seedColor: primaryColor,
        primary: primaryColor,
        secondary: secondaryColor,
        tertiary: getDiscountColor(isDark, style, palette),
        surface: surfaceColor,
        error: isDark ? const Color(0xFFEF4444) : const Color(0xFFB91C1C),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: isDark ? Colors.white : primaryColor,
          fontSize: 26,
          fontWeight: FontWeight.w900,
          letterSpacing: 0.5,
        ),
        elevation: 0,
        iconTheme: IconThemeData(color: isDark ? Colors.white : primaryColor),
      ),
      cardTheme: CardThemeData(
        color: isDark ? surfaceColor.withValues(alpha: 0.9) : Colors.white,
        elevation: style == AppVisualStyle.deluxe ? 4 : 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(style == AppVisualStyle.deluxe ? 20 : 14),
          side: style == AppVisualStyle.deluxe ? BorderSide.none : BorderSide(color: isDark ? Colors.white10 : cardBorder, width: 1),
        ),
      ),
      sliderTheme: SliderThemeData(
        thumbShape: VolumeSliderThumbShape(isDeluxe: style == AppVisualStyle.deluxe),
        overlayShape: const RoundSliderOverlayShape(overlayRadius: 20),
        activeTrackColor: primaryColor,
        inactiveTrackColor: primaryColor.withValues(alpha: 0.2),
        thumbColor: style == AppVisualStyle.deluxe ? deluxeOrange : primaryColor,
      ),
    );
  }

  static Future<void> loadSettings() async {
    final p = await SharedPreferences.getInstance();
    final mode = p.getString('themeMode') ?? 'system';
    themeMode.value = mode == 'light' ? ThemeMode.light : (mode == 'dark' ? ThemeMode.dark : ThemeMode.system);
    
    final vStyle = p.getString('visualStyle') ?? 'vibrant';
    final actualStyle = vStyle == 'deluxe' ? AppVisualStyle.deluxe : (vStyle == 'titanium' ? AppVisualStyle.titanium : AppVisualStyle.vibrant);
    if (actualStyle == AppVisualStyle.deluxe && !ProService.isPro.value) {
      visualStyle.value = AppVisualStyle.vibrant;
    } else {
      visualStyle.value = actualStyle;
    }

    final paletteName = p.getString('colorPalette') ?? 'royal';
    final actualPalette = AppColorPalette.values.firstWhere((e) => e.name == paletteName, orElse: () => AppColorPalette.royal);
    if (actualPalette == AppColorPalette.ocean && !ProService.isPro.value) {
      colorPalette.value = AppColorPalette.royal;
    } else {
      colorPalette.value = actualPalette;
    }

    language.value = p.getString('language') ?? 'fr';

    // Chargement des réglages de facturation par défaut
    Projet.tauxParDefaut = p.getDouble('tauxParDefaut') ?? 50.0;
    Projet.palierParDefaut = p.getInt('palierParDefaut') ?? 15;
    Projet.seuilParDefaut = p.getInt('seuilParDefaut') ?? 5;
    Projet.fraisParDefaut = p.getDouble('fraisParDefaut') ?? 0.0;
    Projet.devise = p.getString('devise') ?? '€';
  }

  static Future<void> saveVisualStyle(AppVisualStyle style) async {
    visualStyle.value = style;
    final p = await SharedPreferences.getInstance();
    await p.setString('visualStyle', style.name);
  }

  static Future<void> saveColorPalette(AppColorPalette palette) async {
    colorPalette.value = palette;
    final p = await SharedPreferences.getInstance();
    await p.setString('colorPalette', palette.name);
  }

  static Future<void> saveThemeMode(ThemeMode mode) async {
    themeMode.value = mode;
    final p = await SharedPreferences.getInstance();
    await p.setString('themeMode', mode == ThemeMode.light ? 'light' : (mode == ThemeMode.dark ? 'dark' : 'system'));
  }

  static Future<void> saveLanguage(String lang) async {
    language.value = lang;
    final p = await SharedPreferences.getInstance();
    await p.setString('language', lang);
  }
}

class IconPop extends StatelessWidget {
  final IconData icon;
  final Color color;
  const IconPop({super.key, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    final style = AppStyle.visualStyle.value;
    final isVibrant = style == AppVisualStyle.vibrant;
    
    return Container(
      padding: EdgeInsets.all(isVibrant ? 12 : 8),
      decoration: BoxDecoration(
        color: isVibrant ? color.withValues(alpha: 0.12) : color,
        borderRadius: BorderRadius.circular(isVibrant ? 16 : 10),
        border: isVibrant ? Border.all(color: color.withValues(alpha: 0.15), width: 1) : null,
        boxShadow: isVibrant ? null : [
          BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 2, offset: const Offset(0, 1))
        ],
      ),
      child: Icon(icon, color: isVibrant ? color : Colors.white, size: isVibrant ? 22 : 20),
    );
  }
}

class VolumeButton extends StatefulWidget {
  final VoidCallback onPressed;
  final Widget child;
  final Color? color;
  final bool mini;
  final bool isRound;
  const VolumeButton({super.key, required this.onPressed, required this.child, this.color, this.mini = false, this.isRound = false});

  @override
  State<VolumeButton> createState() => _VolumeButtonState();
}

class _VolumeButtonState extends State<VolumeButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final style = AppStyle.visualStyle.value;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseColor = widget.color ?? Theme.of(context).colorScheme.primary;
    final isVibrant = style == AppVisualStyle.vibrant;
    final isDeluxe = style == AppVisualStyle.deluxe;
    final borderRadius = widget.isRound ? BorderRadius.circular(100) : BorderRadius.circular(isVibrant ? 24 : 12);
    final double depth = isVibrant ? 0 : (widget.mini ? 3 : 5);
    final double currentDepth = _isPressed ? 0 : depth;
    final double topMargin = _isPressed ? depth : 0;

    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onPressed();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 60),
        margin: EdgeInsets.only(top: isVibrant ? 0 : topMargin, bottom: isVibrant ? 0 : (depth - currentDepth)),
        decoration: BoxDecoration(
          borderRadius: borderRadius,
          boxShadow: isVibrant 
            ? [BoxShadow(color: baseColor.withValues(alpha: 0.35), blurRadius: 18, offset: const Offset(0, 8))]
            : [
                BoxShadow(color: Color.lerp(baseColor, Colors.black, isDeluxe ? 0.6 : 0.4)!, offset: Offset(0, currentDepth), blurRadius: 0),
                if (!_isPressed) BoxShadow(color: Colors.black.withValues(alpha: 0.2), offset: Offset(0, depth + 2), blurRadius: 4),
              ],
        ),
        child: Container(
          padding: widget.isRound ? const EdgeInsets.all(16) : EdgeInsets.symmetric(horizontal: widget.mini ? (isVibrant ? 16 : 12) : (isVibrant ? 24 : 20), vertical: widget.mini ? (isVibrant ? 10 : 8) : (isVibrant ? 18 : 14)),
          decoration: BoxDecoration(
            color: baseColor,
            borderRadius: borderRadius,
            gradient: isVibrant ? null : LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [isDeluxe ? Color.lerp(baseColor, isDark ? Colors.black : Colors.white, 0.3)! : baseColor, baseColor],
            ),
            border: isVibrant ? null : Border.all(color: Colors.white.withValues(alpha: isDeluxe ? 0.25 : 0.15), width: 1.5),
          ),
          child: DefaultTextStyle.merge(
            style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: isVibrant ? -0.5 : 0.2, color: Colors.white, shadows: isVibrant ? null : [const Shadow(color: Colors.black26, offset: Offset(0, 1), blurRadius: 1)]),
            child: widget.child,
          ),
        ),
      ),
    );
  }
}

class VolumeCard extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final Color? color;
  final double sideBarWidth;
  final Color? backgroundColor;
  final EdgeInsetsGeometry? margin;
  const VolumeCard({super.key, required this.child, this.onTap, this.color, this.sideBarWidth = 6, this.backgroundColor, this.margin});

  @override
  Widget build(BuildContext context) {
    final style = AppStyle.visualStyle.value;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final shadowBase = color ?? Theme.of(context).colorScheme.primary;
    final baseBg = backgroundColor ?? Theme.of(context).colorScheme.surface;
    
    return Container(
      margin: margin ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: baseBg,
        borderRadius: BorderRadius.circular(style == AppVisualStyle.vibrant ? 26 : 14),
        boxShadow: style == AppVisualStyle.vibrant 
          ? [
              BoxShadow(color: shadowBase.withValues(alpha: 0.08), blurRadius: 24, offset: const Offset(0, 12)),
              BoxShadow(color: Colors.black.withValues(alpha: isDark ? 0.4 : 0.05), blurRadius: 8, offset: const Offset(0, 2)),
            ]
          : [
              BoxShadow(color: Color.lerp(shadowBase, Colors.black, style == AppVisualStyle.deluxe ? 0.6 : 0.4)!, offset: const Offset(0, 5), blurRadius: 0),
              BoxShadow(color: Colors.black.withValues(alpha: 0.2), offset: const Offset(0, 7), blurRadius: 4),
            ],
        border: Border.all(
          color: isDark ? Colors.white10 : (style == AppVisualStyle.deluxe ? AppStyle.deluxeBorder : AppStyle.cardBorder),
          width: style == AppVisualStyle.vibrant ? 1.2 : 1.5,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(style == AppVisualStyle.vibrant ? 26 : 14),
        child: IntrinsicHeight(
          child: Row(
            children: [
              if (color != null)
                Container(
                  width: sideBarWidth, 
                  decoration: BoxDecoration(
                    gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [color!, color!.withValues(alpha: 0.7)]),
                  ),
                ),
              Expanded(
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(onTap: onTap, child: Padding(padding: const EdgeInsets.all(12), child: child)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class WidgetManager {
  static const String appWidgetProvider = 'IgniteBillWidget';
  static Future<void> update(bool isRunning, {String? text}) async {
    await HomeWidget.saveWidgetData<bool>('is_running', isRunning);
    await HomeWidget.saveWidgetData<String>('widget_text', text ?? (isRunning ? 'En cours...' : S.start));
    await HomeWidget.updateWidget(androidName: appWidgetProvider);
  }
}

class RouletteMontant extends StatefulWidget {
  final double valeur;
  final String suffixe;
  final TextEditingController controller;
  final Function(double) onChanged;
  final Color color;
  final double? step;
  final double fontSize;
  final double width;
  const RouletteMontant({super.key, required this.valeur, required this.suffixe, required this.controller, required this.onChanged, this.color = AppStyle.primary, this.step, this.fontSize = 22, this.width = 80});

  @override
  State<RouletteMontant> createState() => _RouletteMontantState();
}

class _RouletteMontantState extends State<RouletteMontant> {
  bool _actif = false;

  @override
  Widget build(BuildContext context) {
    final style = AppStyle.visualStyle.value;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isVibrant = style == AppVisualStyle.vibrant;
    final isDeluxe = style == AppVisualStyle.deluxe;
    final primaryColor = widget.color == AppStyle.primary ? Theme.of(context).colorScheme.primary : widget.color;
    double effectiveStep = widget.step ?? (widget.suffixe.contains('/') ? 1 : 5);
    
    return GestureDetector(
      onVerticalDragStart: (_) => setState(() => _actif = true),
      onVerticalDragEnd: (_) => setState(() => _actif = false),
      onVerticalDragCancel: () => setState(() => _actif = false),
      onVerticalDragUpdate: (det) {
        double cur = double.tryParse(widget.controller.text.replaceAll(',', '.')) ?? 0;
        double v = (cur - (det.primaryDelta! / 5) * (effectiveStep / 5)).clamp(0, 9999);
        widget.controller.text = v.toStringAsFixed(v == v.toInt() ? 0 : 2);
        widget.onChanged(v);
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedOpacity(
            duration: const Duration(milliseconds: 150),
            opacity: _actif ? 0.7 : 0,
            child: Text((widget.valeur + effectiveStep).toStringAsFixed(0), 
                style: TextStyle(fontSize: 16, color: isDeluxe ? AppStyle.deluxeText.withValues(alpha: 0.5) : AppStyle.textLight, fontWeight: FontWeight.bold, letterSpacing: -1.0)),
          ),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            margin: EdgeInsets.only(top: (style == AppVisualStyle.titanium || style == AppVisualStyle.deluxe) ? (_actif ? (style == AppVisualStyle.deluxe ? 6 : 4) : 0) : 0),
            decoration: BoxDecoration(
              color: _actif ? primaryColor.withValues(alpha: 0.1) : (isVibrant ? Colors.transparent : (isDeluxe ? AppStyle.deluxeInput : Theme.of(context).colorScheme.surface)),
              borderRadius: BorderRadius.circular(10),
              border: isVibrant ? null : Border.all(color: _actif ? primaryColor : (isDeluxe ? AppStyle.deluxeBorder : (isDark ? Colors.white24 : AppStyle.titaniumBorder)), width: isDeluxe ? 2.0 : 1.5),
              boxShadow: isVibrant ? null : [
                if (style == AppVisualStyle.titanium || style == AppVisualStyle.deluxe) ...[
                   BoxShadow(color: Color.lerp(isDeluxe ? AppStyle.deluxeBorder : (isDark ? Colors.black : AppStyle.titaniumBorder), Colors.black, isDeluxe ? 0.2 : 0.1)!, offset: Offset(0, _actif ? 0 : (isDeluxe ? 4 : 4)), blurRadius: 0),
                   if (!_actif) BoxShadow(color: Colors.black.withValues(alpha: 0.1), offset: Offset(0, (isDeluxe ? 6 : 6)), blurRadius: 4),
                ] else ...[
                   BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 4, offset: const Offset(0, 1), spreadRadius: -1)
                ]
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (_actif) Icon(Icons.unfold_more_rounded, size: 16, color: primaryColor),
                SizedBox(
                  width: widget.width,
                  child: TextField(
                    controller: widget.controller,
                    textAlign: TextAlign.center,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]'))],
                    onTap: () => widget.controller.selection = TextSelection(baseOffset: 0, extentOffset: widget.controller.text.length),
                    decoration: InputDecoration(isDense: true, border: InputBorder.none, suffixText: widget.suffixe, suffixStyle: TextStyle(fontWeight: FontWeight.bold, color: isVibrant ? null : (isDeluxe ? AppStyle.deluxeText : AppStyle.textDark))),
                    style: TextStyle(fontWeight: FontWeight.w900, color: isDeluxe ? AppStyle.deluxeText : primaryColor, fontSize: widget.fontSize, letterSpacing: -1.0),
                    onChanged: (v) {
                      double? val = double.tryParse(v.replaceAll(',', '.'));
                      if (val != null) {
                        widget.onChanged(val);
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 4),
          AnimatedOpacity(
            duration: const Duration(milliseconds: 150),
            opacity: _actif ? 0.7 : 0,
            child: Text((widget.valeur - effectiveStep).clamp(0, 9999).toStringAsFixed(0), 
                style: TextStyle(fontSize: 16, color: isDeluxe ? AppStyle.deluxeText.withValues(alpha: 0.5) : AppStyle.textLight, fontWeight: FontWeight.bold, letterSpacing: -1.0)),
          ),
        ],
      ),
    );
  }
}

class S {
  static bool get _en => AppStyle.language.value == 'en';

  static String get projet => _en ? 'Project' : 'Projet'; 
  static String get appTitle => 'IgniteBill';
  static String get settings => _en ? 'Settings' : 'Paramètres';
  static String get start => _en ? 'Timer' : 'Chrono';
  static String get projectName => _en ? 'Name' : 'Nom';
  static String get sessionTitle => _en ? 'Session Title' : 'Titre de la session';
  static String get history => _en ? 'History' : 'Historique';
  static String get total => 'Total';
  static String get sessionTotal => _en ? 'SESSION TOTAL' : 'TOTAL DE LA SESSION';
  static String get manualTime => _en ? 'Add manual time' : 'Ajouter du temps manuel';
  static String get manualFee => _en ? 'Add additional fee' : 'Ajouter un frais annexe';
  static String get date => 'Date';
  static String get price => _en ? 'Price' : 'Prix';
  static String get hours => _en ? 'H' : 'H';
  static String get minutes => _en ? 'M' : 'M';
  static String get transferTo => _en ? 'Transfer to...' : 'Transférer vers...';
  static String get catchUpTime => _en ? 'Catch up time' : 'Rattraper le temps';
  static String get pressToCatchUp => _en ? 'Press to catch up' : 'Appuyez pour rattraper le temps';
  static String get finish => _en ? 'Finish' : 'Terminer';
  static String get pause => 'Pause';
  static String get resumeTimer => _en ? 'Start' : 'Démarrer';
  static String get delete => _en ? 'Delete' : 'Supprimer';
  static String get archive => _en ? 'Archive' : 'Archiver';
  static String get archives => _en ? 'Archives' : 'Archives';
  static String get unarchive => _en ? 'Unarchive' : 'Désarchiver';
  static String get rename => _en ? 'Rename' : 'Renommer';
  static String get cancel => _en ? 'Cancel' : 'Annuler';
  static String get save => _en ? 'Save' : 'Enregistrer';
  static String get ok => 'OK';
  static String get import => _en ? 'Import' : 'Importer';
  static String get backup => _en ? 'Backup' : 'Sauvegarder';
  static String get defaultSettings => _en ? 'DEFAULT SETTINGS' : 'RÉGLAGES PAR DÉFAUT';
  static String get hourlyRate => _en ? 'Hourly rate' : 'Taux horaire';
  static String get feesTravel => _en ? 'Fees / Travel' : 'Frais / Déplacement';
  static String get billingStep => _en ? 'Billing step' : 'Palier tarification';
  static String get minTimeBeforeStep => _en ? 'Min time before step' : 'Temps min avant un palier';
  static String get billingStepShort => _en ? 'Step' : 'Palier';
  static String get thresholdShort => _en ? 'Threshold' : 'Seuil';
  static String get exactBilling => _en ? '(Exact billing)' : '(Facturation exacte)';
  static String get saveAndClose => _en ? 'Save and close' : 'Enregistrer et fermer';
  static String get newProject => _en ? 'New $projet' : 'Nouveau $projet';
  static String get emptyProjets => _en ? 'No $projet yet.\nPress the Timer button ▶!' : 'Aucun $projet pour le moment.\nAppuyez sur le bouton Chrono ▶ !';
  static String get reset => 'Reset';
  static String get work => _en ? 'Work' : 'Travail';
  static String get fees => _en ? 'Fees' : 'Frais';
  static String get discount => _en ? 'Discount' : 'Remise';
  static String get projectRules => _en ? 'Project rules' : 'Règles du $projet';
  static String get applySteps => _en ? 'Apply steps' : 'Appliquer les paliers';
  static String get chooseProject => _en ? 'Choose a project' : 'Choisir un projet';
  static String get description => 'Description';
  static String get myProProfile => _en ? 'MY PRO IDENTITY' : 'MON IDENTITÉ PRO';
  static String get clientProfile => _en ? 'CLIENT INFO' : 'INFOS CLIENT';
  static String get taxIdLabel => _en ? 'ID Label (VAT, Tax...)' : 'Libellé identifiant (TVA, SIRET...)';
  static String get taxIdValue => _en ? 'ID Number' : 'Numéro identifiant';
  static String get bankInfo => _en ? 'Bank info (IBAN...)' : 'Coordonnées bancaires (IBAN...)';
  static String get legalMentions => _en ? 'Legal mentions / Footer' : 'Mentions légales / Bas de page';
  static String get export => 'Exporter';

  
  static String get backupSavedLocally => _en ? 'Backup saved locally' : 'Sauvegarde enregistrée localement';
  static String get errorPrefix => _en ? 'Error: ' : 'Erreur : ';
  static String get excelFileSaved => _en ? 'Excel file saved' : 'Fichier Excel enregistré';
  static String get reportSaved => _en ? 'Report saved' : 'Rapport enregistré';
  static String get importProjects => _en ? 'Import projects' : 'Importer des projets';
  static String get importProjectsPrompt => _en ? 'Do you want to add these projects to your current list or replace everything?' : 'Voulez-vous ajouter ces projets à votre liste actuelle ou tout remplacer ?';
  static String get replaceEverything => _en ? 'Replace everything' : 'Tout remplacer';
  static String get everythingReplaced => _en ? 'Everything has been replaced' : 'Tout a été remplacé';
  static String get add => _en ? 'Add' : 'Ajouter';
  static String get projectsAdded => _en ? 'project(s) added' : 'projet(s) ajouté(s)';
  static String get invalidFileFormat => _en ? 'Invalid file format' : 'Format de fichier invalide';
  static String get backupWarningTitle => _en ? 'Backup' : 'Sauvegarde';
  static String get backupWarningContent => _en ? 'It has been more than days without backup.\n\nBackup now?' : 'Cela fait plus de jours sans sauvegarde.\n\nSauvegarder maintenant ?';
  static String get create => _en ? 'Create' : 'Créer';
  static String get taxesToApplyDefault => _en ? 'TAXES TO APPLY (DEFAULT)' : 'TAXES À APPLIQUER (DÉFAUT)';
  static String get transferAllSessionsTo => _en ? 'Move all sessions to:' : 'Déplacer toutes les sessions vers :';
  static String get taxesAndAdditionalFees => _en ? 'TAXES & ADDITIONAL FEES' : 'TAXES & FRAIS ADDITIONNELS';
  static String get newTax => _en ? 'New tax' : 'Nouvelle taxe';
  static String get taxNameLabel => _en ? 'Name (e.g.: VAT 20%)' : 'Nom (ex: TVA 20%)';
  static String get value => _en ? 'Value' : 'Valeur';
  static String get addTax => _en ? 'Add a tax' : 'Ajouter une taxe';
  static String get personalization => _en ? 'Personalization' : 'Personnalisation';
  static String get shape => _en ? 'SHAPE' : 'FORME';
  static String get color => _en ? 'COLOR' : 'COULEUR';
  static String get theme => _en ? 'THEME' : 'THÈME';
  static String get automationsNewProjects => _en ? 'Automations (New Projects)' : 'Automatisations (Nouveaux Projets)';
  static String get identityAndBilling => _en ? 'Identity & Billing' : 'Identité & Facturation';
  static String get currency => _en ? 'Currency' : 'Devise';
  static String get languageLabel => _en ? 'Language' : 'Langue';
  static String get manageProInfoAndTaxes => _en ? 'Manage your info and default taxes' : 'Gérer vos infos et taxes par défaut';
  static String get appearance => _en ? 'Appearance' : 'Apparence';
  static String get changeSkinColorsTheme => _en ? 'Change skin, colors and theme' : 'Changer le skin, les couleurs et le thème';
  static String get dataAndSecurity => _en ? 'Data & Security' : 'Données & Sécurité';
  static String get proVersion => _en ? 'PRO Version (Support)' : 'Version PRO (Soutien)';
  static String get proDescription => _en 
    ? "Unlock the 'Deluxe' style, the 'Ocean' palette and PDF Export/Print. Support helps keep IgniteBill free and open source!" 
    : "Débloquez le style 'Deluxe', la palette 'Ocean' et l'Export/Impression PDF. Votre soutien aide à maintenir IgniteBill libre et open source !";
  static String get enterLicenseKey => _en ? 'Enter License Key' : 'Saisir la clé de licence';
  static String get licenseActive => _en ? 'Pro License Active' : 'Licence PRO active';
  static String get activatePro => _en ? 'Activate PRO' : 'Activer la PRO';
  static String get requestId => _en ? 'Request ID' : 'ID de demande';
  static String get copy => _en ? 'Copy' : 'Copier';
  static String get idCopied => _en ? 'ID copied to clipboard' : 'ID copié dans le presse-papier';
  static String get invalidKey => _en ? 'Invalid License Key' : 'Clé de licence invalide';
  static String get supportAppOnKofi => _en ? 'Support on Ko-fi' : 'Soutenir sur Ko-fi';
  static String get proUnlockedTitle => _en ? 'PRO Unlocked!' : 'PRO Débloqué !';
  static String get proUnlockedMessage => _en 
    ? 'Thank you for your support! All features are now unlocked.' 
    : 'Merci pour votre soutien ! Toutes les fonctions sont débloquées.';
  static String get licenseSection => _en ? 'License' : 'Licence';
  static String get exportShare => _en ? 'Export / Share' : 'Exporter / Partager';
  static String get jsonCsvTextReport => _en ? 'JSON, CSV or text Report' : 'JSON, CSV ou Rapport texte';
  static String get shareBackup => _en ? 'SHARE BACKUP' : 'PARTAGER LA SAUVEGARDE';
  static String get formatJsonCompleteBackup => _en ? 'JSON Format (Complete Backup)' : 'Format JSON (Backup complet)';
  static String get formatCsvExcel => _en ? 'CSV Format (Excel)' : 'Format CSV (Excel)';
  static String get textReport => _en ? 'Text report' : 'Rapport texte';
  static String get saveLocally => _en ? 'Save locally' : 'Sauvegarder en local';
  static String get saveFileOnDevice => _en ? 'Save a file on the device' : 'Enregistrer un fichier sur l\'appareil';
  static String get saveBackup => _en ? 'SAVE BACKUP' : 'ENREGISTRER LA SAUVEGARDE';
  static String get saveJsonBackup => _en ? 'Save JSON (Backup)' : 'Enregistrer le JSON (Backup)';
  static String get saveExcelCsv => _en ? 'Save Excel (CSV)' : 'Enregistrer l\'Excel (CSV)';
  static String get saveTextReport => _en ? 'Save Text (Report)' : 'Enregistrer le Texte (Rapport)';
  static String get restoreFromJson => _en ? 'Restore from a .json file' : 'Restaurer depuis un fichier .json';
  static String get other => _en ? 'Other' : 'Autre';
  static String get supportDevelopment => _en ? 'Support development' : 'Soutenir le développement';
  static String get buyDthrawnACoffee => _en ? 'Buy a coffee for Dthrawn' : 'Offrir un café à Dthrawn';
  static String get noArchivedProjects => _en ? 'No archived projects' : 'Aucun projet archivé';
  static String get supportDthrawn => _en ? 'Support Dthrawn' : 'Soutenir Dthrawn';
  static String get archiveConfirmTitle => _en ? 'Archive / Delete?' : 'Archiver / Supprimer ?';
  static String get unarchiveConfirmTitle => _en ? 'Unarchive / Delete?' : 'Désarchiver / Supprimer ?';
  static String get archiveWarning => _en ? 'Archiving hides the project from the active list. Deletion is irreversible and will erase all sessions.' : 'L\'archivage masque le projet de la liste active. La suppression est irréversible et effacera toutes les sessions.';
  static String get unarchiveWarning => _en ? 'Do you want to restore this project or delete it permanently?' : 'Voulez-vous restaurer ce projet ou le supprimer définitivement ?';
  static String get activeProjects => _en ? 'Active Projects' : 'Projets Actifs';
  static String get seeArchives => _en ? 'See Archives' : 'Voir les Archives';
  static String get sortByRecent => _en ? 'Sort by recent' : 'Trier par récent';
  static String get sortByName => _en ? 'Sort by name' : 'Trier par nom';
  static String get noSessions => _en ? 'No sessions' : 'Aucune session';
  static String get lastSession => _en ? 'Last:' : 'Dernière :';
  static String get inProgress => _en ? 'In progress...' : 'En cours ...';
  static String get legalMentionsTitle => _en ? 'Legal Mentions & Privacy' : 'Mentions Légales & Confidentialité';
  static String get understood => _en ? 'Understood' : 'Compris';
  static String get legalMentionsContent => _en 
    ? "1. Privacy (GDPR): IgniteBill is a 100% offline application. No personal or client data is collected, transmitted, or stored on external servers. All data remains locally on your device. It is essential for data security to lock your device.\n\n2. Tax Compliance: IgniteBill is a personal time tracking and editing utility. It is not a certified accounting or billing software. The user is solely responsible for legal, tax compliance, and the numbering of documents generated and transmitted to third parties."
    : "1. Confidentialité (RGPD) : IgniteBill est une application 100% hors-ligne. Aucune donnée personnelle ou client n'est collectée, transmise ou stockée sur des serveurs externes. Toutes les données demeurent localement sur votre appareil. Il est indispensable pour la sécurité des données de verrouiller votre appareil.\n\n2. Conformité Fiscale : IgniteBill est un utilitaire personnel de suivi de temps et d'aide à l'édition. Il ne s'agit pas d'un logiciel de comptabilité ou de facturation certifié (notamment au sens de l'art. 286 du CGI pour la loi anti-fraude à la TVA). L'utilisateur est seul responsable de la conformité légale, fiscale et de la numérotation des documents générés et transmis à des tiers.";
  static String get saveSession => _en ? 'Save' : 'Enregistrer';
  static String get assignTo => _en ? 'Assign to...' : 'Attribuer à ...';
  static String get newProjectEllipsis => _en ? '➕ New Project...' : '➕ Nouveau Projet...';
  static String get taxesToApply => _en ? 'TAXES TO APPLY' : 'TAXES À APPLIQUER';
  static String get clientAndBilling => _en ? 'CLIENT & BILLING' : 'CLIENT & FACTURATION';
  static String get clientName => _en ? 'Client Name' : 'Nom du Client';
  static String get clientAddress => _en ? 'Client Address' : 'Adresse Client';
  static String get clientIdentifierOptional => _en ? 'Identifier (Optional)' : 'Identifiant (Optionnel)';
  static String get paymentTerms => _en ? 'Payment terms' : 'Modalités de paiement';
  static String get print => _en ? 'PRINT' : 'IMPRIMER';
  static String get share => _en ? 'SHARE' : 'PARTAGER';
  static String get pricingRules => _en ? 'PRICING RULES' : 'RÈGLES DE TARIFICATION';
  static String get shareProject => _en ? 'SHARE PROJECT' : 'PARTAGER LE PROJET';
  static String get formatJsonProject => _en ? 'JSON Format (Project)' : 'Format JSON (Projet)';
  static String get saveProject => _en ? 'SAVE PROJECT' : 'ENREGISTRER LE PROJET';
  static String get saveJson => _en ? 'Save JSON' : 'Enregistrer le JSON';
  static String get deleteSessionConfirm => _en ? 'Delete this session?' : 'Supprimer cette session ?';
  static String get totalWithTaxes => _en ? 'TOTAL WITH TAXES: ' : 'TOTAL AVEC TAXES : ';
  static String get amountHT => _en ? 'AMOUNT' : 'MONTANT';
  static String get realTimePrefix => _en ? 'REAL: ' : 'RÉEL : ';
  static String get rateLabel => _en ? 'Rate: ' : 'Taux : ';
  static String get moveSession => _en ? 'MOVE' : 'DÉPLACER';
  static String get invoice => _en ? 'INVOICE' : 'FACTURE';
  static String get invoiceClientLabel => _en ? 'CLIENT:' : 'CLIENT :';
  static String get additionalFeesPdf => _en ? 'ADDITIONAL FEES' : 'FRAIS ANNEXES';
  static String get commercialGestures => _en ? 'COMMERCIAL GESTURES:' : 'GESTES COMMERCIAUX :';
  static String get freeTime => _en ? 'Free time:' : 'Temps offert :';
  static String get totalHT => _en ? 'Total HT:' : 'Total HT :';
  static String get totalTTC => _en ? 'TOTAL TTC:' : 'TOTAL TTC :';
  static String get pdfError => _en ? 'PDF Error: ' : 'Erreur PDF : ';
  static String get projectExportedJson => _en ? 'Project exported to JSON' : 'Projet exporté en JSON';
  static String get projectExportedCsv => _en ? 'Project exported to CSV' : 'Projet exporté en CSV';
  static String get projectExportedText => _en ? 'Project exported to Text' : 'Projet exporté en Texte';
  static String get duration => _en ? 'Duration' : 'Durée';
  static String get tax => _en ? 'Tax' : 'Taxe';
  static String get quickSession => _en ? 'Quick Session' : 'Session Rapide';
  static String get taxes => _en ? 'Taxes' : 'Taxes';
  static String get taxInitialization => _en ? 'Tax Initialization' : 'Initialisation taxes';
  static String get shareBackupText => _en ? 'Share Backup' : 'Partager la sauvegarde';
  static String get projectCsvExportText => _en ? 'Project CSV Export' : 'Export CSV du projet';
  static String get projectReportText => _en ? 'Project Report' : 'Rapport du projet';
  static String get phone => _en ? 'Phone' : 'Tél.';
  static String get lastBackupPrefix => _en ? 'Last backup: ' : 'Dernière sauvegarde : ';
  static String get daysAgo => _en ? ' days ago' : ' jours';
  static String get supportAppTitle => _en ? 'Support IgniteBill ❤️' : 'Merci d\'utiliser IgniteBill ! ❤️';
  static String get supportAppMessage => _en 
    ? "I develop IgniteBill alone in my free time. Originally built for my needs, I share it with pleasure! Support helps greatly to adapt it to your needs, maintain it, and keep it updated! ❤️"
    : "Je développe IgniteBill seul sur mon temps libre. Créée au départ pour mes besoins, je la partage avec plaisir ! Un petit soutien aide énormément pour l'adapter à vos besoins, la maintenir et la mettre à jour ! ❤️";
  static String get backupNow => _en ? 'Backup' : 'Sauvegarder';
  static String get supportHeart => _en ? 'Support ❤️' : 'Soutenir ❤️';
  static String get maybeLater => _en ? 'Maybe later' : 'Plus tard';
}

class ProService {
  static final ValueNotifier<bool> isPro = ValueNotifier(false);

  static Future<void> loadPro() async {
    try {
      final p = await SharedPreferences.getInstance();
      isPro.value = p.getBool('is_pro_active') ?? false;
    } catch (e) {
      debugPrint("ProService: Erreur lors du chargement: $e");
    }
  }

  static Future<String> getInstallationId() async {
    final p = await SharedPreferences.getInstance();
    String? id = p.getString('pro_installation_id');
    if (id == null) {
      final r = Random();
      const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
      String rnd(int len) => List.generate(len, (index) => chars[r.nextInt(chars.length)]).join();
      id = "IB-${rnd(4)}-${rnd(4)}";
      await p.setString('pro_installation_id', id);
    }
    return id;
  }

  static Future<bool> verifyAndActivate(String key) async {
    // Activation simple pour F-Droid et l'expérience utilisateur
    if (key.trim().isNotEmpty) {
      final p = await SharedPreferences.getInstance();
      await p.setBool('is_pro_active', true);
      isPro.value = true;
      return true;
    }
    return false;
  }
}

class ProDialog extends StatefulWidget {
  const ProDialog({super.key});
  @override State<ProDialog> createState() => _ProDialogState();
}

class _ProDialogState extends State<ProDialog> {
  final _keyCtrl = TextEditingController();
  bool _loading = false;

  @override Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Row(children: [const Icon(Icons.diamond_rounded, color: Colors.orange), const SizedBox(width: 10), Text(S.proVersion, style: const TextStyle(fontWeight: FontWeight.w900))]),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(S.proDescription, style: const TextStyle(fontSize: 14, height: 1.4)),
            const SizedBox(height: 20),
            FutureBuilder<String>(
              future: ProService.getInstallationId(),
              builder: (context, snapshot) {
                final id = snapshot.data ?? '...';
                return Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: Colors.grey.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.grey.withValues(alpha: 0.3))),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(S.requestId, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey)),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Expanded(child: Text(id, style: const TextStyle(fontFamily: 'monospace', fontWeight: FontWeight.bold, fontSize: 16))),
                          IconButton(
                            icon: const Icon(Icons.copy_rounded, size: 20),
                            onPressed: () {
                              Clipboard.setData(ClipboardData(text: id));
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(S.idCopied)));
                              }
                            },
                            tooltip: S.copy,
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              }
            ),
            const SizedBox(height: 15),
            TextField(controller: _keyCtrl, decoration: InputDecoration(labelText: S.enterLicenseKey, border: const OutlineInputBorder()), textCapitalization: TextCapitalization.characters),
            const SizedBox(height: 15),
            VolumeButton(
              mini: true,
              color: Colors.brown,
              onPressed: () => launchUrl(Uri.parse('https://ko-fi.com/dthrawn'), mode: LaunchMode.externalApplication),
              child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [const Icon(Icons.coffee_rounded, size: 18), const SizedBox(width: 8), Text(S.supportAppOnKofi)]),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: Text(S.cancel)),
        _loading ? const CircularProgressIndicator() : VolumeButton(
          mini: true,
          color: AppStyle.gain,
          onPressed: () {
            _handleActivation();
          },
          child: Text(S.activatePro),
        ),
      ],
    );
  }

  Future<void> _handleActivation() async {
    debugPrint("PRO: Activation clicked");
    if (_keyCtrl.text.isEmpty) {
      debugPrint("PRO: Key empty");
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(S.invalidKey), backgroundColor: Colors.red));
      return;
    }
    setState(() => _loading = true);
    try {
      debugPrint("PRO: Verifying with key ${ _keyCtrl.text }");
      final ok = await ProService.verifyAndActivate(_keyCtrl.text);
      debugPrint("PRO: Result: $ok");
      if (ok) {
        if (mounted) {
          Navigator.pop(context);
          showDialog(context: context, builder: (c) => AlertDialog(
            title: Text(S.proUnlockedTitle),
            content: Text(S.proUnlockedMessage),
            actions: [TextButton(onPressed: () => Navigator.pop(c), child: Text(S.ok))],
          ));
        }
      } else {
        if (mounted) {
          setState(() => _loading = false);
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(S.invalidKey), backgroundColor: Colors.red));
        }
      }
    } catch (e) {
      debugPrint("PRO: Error during activation: $e");
      if (mounted) setState(() => _loading = false);
    }
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  const canal = AndroidNotificationChannel('notif_chrono_v5', 'Suivi Facturation', importance: Importance.max, showBadge: true, playSound: false);
  final localNotif = FlutterLocalNotificationsPlugin();
  await localNotif.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()?.createNotificationChannel(canal);
  await localNotif.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()?.requestNotificationsPermission();
  await configurerServiceArrierePlan();
  await ProService.loadPro();
  await AppStyle.loadSettings();
  runApp(const MonApplication());
}

Future<void> configurerServiceArrierePlan() async {
  final service = FlutterBackgroundService();
  await service.configure(
    androidConfiguration: AndroidConfiguration(
      onStart: auDemarrageDuService, autoStart: false, isForegroundMode: true,
      notificationChannelId: 'notif_chrono_v5', initialNotificationTitle: '⏱️ IgniteBill : ${S.ok}',
      initialNotificationContent: S.inProgress, foregroundServiceNotificationId: 777,
    ),
    iosConfiguration: IosConfiguration(),
  );
}

@pragma('vm:entry-point')
void auDemarrageDuService(ServiceInstance service) async {
  if (service is AndroidServiceInstance) {
    service.setAsForegroundService();
    service.on('setAsForeground').listen((_) => service.setAsForegroundService());
    service.on('setAsBackground').listen((_) => service.setAsBackgroundService());
  }
  service.on('stopService').listen((_) => service.stopSelf());
  service.on('changerTitre').listen((event) {
    if (service is AndroidServiceInstance && event != null) {
      service.setForegroundNotificationInfo(title: "⏱️ IgniteBill : ${event['nom']}", content: S.inProgress);
    }
  });
}

class Taxe {
  String id; String nom; double valeur; bool estPourcentage;
  Taxe({required this.id, required this.nom, required this.valeur, required this.estPourcentage});
  Map<String, dynamic> toJson() => {'id': id, 'nom': nom, 'valeur': valeur, 'p': estPourcentage};
  static Taxe fromJson(Map<String, dynamic> json) => Taxe(id: json['id'], nom: json['nom'], valeur: json['valeur']?.toDouble() ?? 0.0, estPourcentage: json['p'] ?? true);
}

class Session {
  String id; DateTime date; int secondesReelles; int secondesFacturees; double prix; String titre; bool estFrais; bool estRemise;
  List<Taxe> taxesAppliquees;

  Session({required this.id, required this.date, required this.secondesReelles, required this.secondesFacturees, required this.prix, this.titre = 'Session', this.estFrais = false, this.estRemise = false, List<Taxe>? taxes})
    : taxesAppliquees = taxes ?? [];

  Map<String, dynamic> toJson() => {
    'id': id, 'date': date.toIso8601String(), 'secReelles': secondesReelles, 'secFacturees': secondesFacturees, 'prix': prix, 'titre': titre, 'estFrais': estFrais, 'estRemise': estRemise,
    'taxes': taxesAppliquees.map((t) => t.toJson()).toList()
  };

  static Session fromJson(Map<String, dynamic> json) => Session(
    id: json['id'], date: DateTime.parse(json['date']), secondesReelles: json['secReelles'], secondesFacturees: json['secFacturees'], prix: json['prix'], titre: json['titre'] ?? 'Session', estFrais: json['estFrais'] ?? false, estRemise: json['estRemise'] ?? false,
    taxes: json['taxes'] != null ? (json['taxes'] as List).map((t) => Taxe.fromJson(t)).toList() : []
  );

  double get totalTaxes {
    double total = 0;
    for (var t in taxesAppliquees) {
      double val = t.estPourcentage ? (prix * t.valeur / 100) : t.valeur;
      total += AppStyle.arondir(val);
    }
    return total;
  }

  double get totalAvecTaxes => AppStyle.arondir(prix + totalTaxes);
  String get dateFormatee => '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year.toString().substring(2)}';
  static String formater(int sec) {
    int h = sec ~/ 3600; int m = (sec % 3600) ~/ 60; int s = sec % 60;
    return '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }
  static String formaterSansSecondes(int sec) => '${(sec ~/ 3600).toString().padLeft(2, '0')}h${((sec % 3600) ~/ 60).toString().padLeft(2, '0')}';
}

class Projet {
  static double tauxParDefaut = 50.0; static int palierParDefaut = 15; static int seuilParDefaut = 5; static double fraisParDefaut = 0.0; static String devise = '€';
  String id; String nom; double tauxHoraire; List<Session> sessions; int palierMinutes; int seuilMinutes; double fraisFixes;
  String clientNom; String clientAdresse; String clientIdentifiant; String clientEmail; String clientTel; String clientModalitesPaiement; bool preferTTC;
  bool estArchive;

  int? _cachedSec;
  double? _cachedPrix;

  Projet({required this.id, required this.nom, double? tauxHoraire, int? palierMinutes, int? seuilMinutes, double? fraisFixes, List<Session>? sessions, this.clientNom = '', this.clientAdresse = '', this.clientIdentifiant = '', this.clientEmail = '', this.clientTel = '', this.clientModalitesPaiement = '', this.preferTTC = false, this.estArchive = false})
      : tauxHoraire = tauxHoraire ?? Projet.tauxParDefaut, palierMinutes = palierMinutes ?? Projet.palierParDefaut, seuilMinutes = seuilMinutes ?? Projet.seuilParDefaut, fraisFixes = fraisFixes ?? Projet.fraisParDefaut, sessions = sessions ?? [];

  void invalidate() { _cachedSec = null; _cachedPrix = null; }

  Map<String, dynamic> toJson() => {'id': id, 'nom': nom, 'taux': tauxHoraire, 'palier': palierMinutes, 'seuil': seuilMinutes, 'frais': fraisFixes, 'clientNom': clientNom, 'clientAdresse': clientAdresse, 'clientId': clientIdentifiant, 'clientEmail': clientEmail, 'clientTel': clientTel, 'clientPay': clientModalitesPaiement, 'ttc': preferTTC, 'archive': estArchive, 'sessions': sessions.map((s) => s.toJson()).toList()};

  static Projet fromJson(Map<String, dynamic> json) => Projet(
    id: json['id'], 
    nom: json['nom'], 
    tauxHoraire: json['taux'], 
    palierMinutes: json['palier'], 
    seuilMinutes: json['seuil'], 
    fraisFixes: json['frais'] ?? Projet.fraisParDefaut,
    clientNom: json['clientNom'] ?? '',
    clientAdresse: json['clientAdresse'] ?? '',
    clientIdentifiant: json['clientId'] ?? '',
    clientEmail: json['clientEmail'] ?? '',
    clientTel: json['clientTel'] ?? '',
    clientModalitesPaiement: json['clientPay'] ?? '',
    preferTTC: json['ttc'] ?? false,
    estArchive: json['archive'] ?? false,
    sessions: json['sessions'] != null ? (json['sessions'] as List).map((s) => Session.fromJson(s)).toList() : []
  );
  int calculerSecondesFacturees(int secReelles) {
    if (palierMinutes <= 1) return secReelles;
    int pSec = palierMinutes * 60; int sSec = seuilMinutes * 60;
    int blocs = secReelles ~/ pSec;
    if ((secReelles % pSec) >= sSec && secReelles > 0) blocs++;
    return blocs * pSec;
  }
  String get nomModeFacturation => palierMinutes <= 1 ? S.exactBilling : '${S.billingStepShort} : ${palierMinutes}m / ${S.thresholdShort} : ${seuilMinutes}m';
  
  int get secondesHistorique {
    if (_cachedSec != null) return _cachedSec!;
    int total = 0;
    for (var s in sessions) { if (!s.estRemise) total += s.secondesFacturees; }
    _cachedSec = total;
    return total;
  }
  
  double get prixTotalHistorique {
    if (_cachedPrix != null) return _cachedPrix!;
    double total = 0;
    for (var s in sessions) {
      if (s.estRemise) {
        total -= s.prix;
      } else {
        total += (preferTTC ? s.totalAvecTaxes : s.prix);
      }
    }
    double res = AppStyle.arondir(total);
    _cachedPrix = res;
    return res;
  }
  
  DateTime get derniereActivite => sessions.isEmpty ? DateTime.parse(id) : sessions.first.date;
}

class MonApplication extends StatefulWidget {
  const MonApplication({super.key});
  @override State<MonApplication> createState() => _MonApplicationState();
}
class _MonApplicationState extends State<MonApplication> with WidgetsBindingObserver {
  @override void initState() { super.initState(); WidgetsBinding.instance.addObserver(this); }
  @override void dispose() { WidgetsBinding.instance.removeObserver(this); super.dispose(); }
  @override void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) { FlutterBackgroundService().invoke('setAsBackground'); } else { FlutterBackgroundService().invoke('setAsForeground'); }
  }
  @override Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([AppStyle.language, AppStyle.themeMode, AppStyle.visualStyle, AppStyle.colorPalette, ProService.isPro]),
      builder: (context, _) {
        return MaterialApp(
          title: S.appTitle, debugShowCheckedModeBanner: false, 
          themeMode: AppStyle.themeMode.value,
          localizationsDelegates: const [GlobalMaterialLocalizations.delegate, GlobalWidgetsLocalizations.delegate, GlobalCupertinoLocalizations.delegate],
          supportedLocales: const [Locale('fr', ''), Locale('en', '')],
          theme: AppStyle.getTheme(false),
          darkTheme: AppStyle.getTheme(true),
          home: const EcranAccueil(),
        );
      },
    );
  }
}

class EcranAccueil extends StatefulWidget {
  const EcranAccueil({super.key});
  @override State<EcranAccueil> createState() => _EcranAccueilState();
}
class _EcranAccueilState extends State<EcranAccueil> with WidgetsBindingObserver {
  List<Projet> _projets = []; int _frequenceRappelJours = 7; DateTime? _dateDerniereSauvegarde; String _modeTri = 'recent';
  bool _popupChronoEnCours = false; bool _voirArchives = false;

  List<Projet> get _projetsAffiches => _projets.where((p) => p.estArchive == _voirArchives).toList();

  @override void initState() { 
    super.initState(); 
    WidgetsBinding.instance.addObserver(this);
    
    try { FlutterBackgroundService().invoke('stopService'); } catch (_) {}
    WidgetManager.update(false); 
    
    _initApp();

    if (!Platform.environment.containsKey('FLUTTER_TEST')) {
      HomeWidget.widgetClicked.listen((Uri? uri) { if (uri != null) _quickChrono(); });
    }
  }

  Future<void> _initApp() async {
    await _chargerDonnees();
    _verifierRappelSauvegarde();
    _trierProjets();
    _checkWidget();
  }

  void _checkWidget() async {
    bool? clicked = await HomeWidget.getWidgetData<bool>('DATA_WIDGET_CLICKED_FLAG');
    if (clicked == true) {
      await HomeWidget.saveWidgetData<bool>('DATA_WIDGET_CLICKED_FLAG', false);
      if (!_popupChronoEnCours) { Future.delayed(const Duration(milliseconds: 300), () { if (mounted) _quickChrono(); }); }
    }
  }

  @override void dispose() { WidgetsBinding.instance.removeObserver(this); super.dispose(); }
  @override void didChangeAppLifecycleState(AppLifecycleState state) { if (state == AppLifecycleState.resumed) { _checkWidget(); } }

  Future<void> _chargerDonnees() async {
    final prefs = await SharedPreferences.getInstance(); final projetsJson = prefs.getString('projets'); _frequenceRappelJours = prefs.getInt('frequenceRappelJours') ?? 7; _modeTri = prefs.getString('modeTri') ?? 'recent'; final dateBackupStr = prefs.getString('dateDerniereSauvegarde');
    if (dateBackupStr != null) { _dateDerniereSauvegarde = DateTime.parse(dateBackupStr); }
    if (projetsJson != null) { setState(() => _projets = (jsonDecode(projetsJson) as List).map((p) => Projet.fromJson(p)).toList()); }
  }
  void _trierProjets() {
    setState(() {
      if (_modeTri == 'alphabet') { _projets.sort((a, b) => a.nom.toLowerCase().compareTo(b.nom.toLowerCase())); } 
      else { _projets.sort((a, b) => b.derniereActivite.compareTo(a.derniereActivite)); }
    });
  }
  Future<void> _sauvegarderDonnees() async { final prefs = await SharedPreferences.getInstance(); await prefs.setString('projets', jsonEncode(_projets.map((p) => p.toJson()).toList())); await prefs.setString('modeTri', _modeTri); }
  Future<void> _resetCycleSauvegarde() async { final now = DateTime.now(); final prefs = await SharedPreferences.getInstance(); await prefs.setString('dateDerniereSauvegarde', now.toIso8601String()); setState(() => _dateDerniereSauvegarde = now); }
  Future<void> _exporterSauvegarde({bool saveAsFile = false}) async {
    try {
      final now = DateTime.now();
      final dateStr = '${now.day.toString().padLeft(2, '0')}${now.month.toString().padLeft(2, '0')}${now.year.toString().substring(2)}';
      final fileName = 'ignitebill_$dateStr.json';
      
      final jsonStr = jsonEncode(_projets.map((p) => p.toJson()).toList()); 
      final directory = await getTemporaryDirectory(); 
      final file = File('${directory.path}/$fileName'); 
      await file.writeAsString(jsonStr); 
      
      final prefs = await SharedPreferences.getInstance(); 
      await prefs.setString('dateDerniereSauvegarde', now.toIso8601String()); 
      setState(() => _dateDerniereSauvegarde = now);
      
      if (saveAsFile) {
        String? result = await FilePicker.platform.saveFile(
          fileName: fileName,
          type: FileType.custom,
          allowedExtensions: ['json'],
          bytes: await file.readAsBytes(),
        );
        if (result != null) {
          if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(S.backupSavedLocally)));
        }
      } else {
        await Share.shareXFiles([XFile(file.path)], text: S.shareBackupText);
      }
    } catch (e) { if (mounted) { ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("${S.errorPrefix}$e"), backgroundColor: Colors.red)); } }
  }
  Future<void> _exporterCSV({bool saveAsFile = false}) async {
    try {
      final now = DateTime.now();
      final dateStr = '${now.day.toString().padLeft(2, '0')}${now.month.toString().padLeft(2, '0')}${now.year.toString().substring(2)}';
      final fileName = 'ignitebill_$dateStr.csv';

      String csv = "Projet;Date;Titre;Type;Duree Facturee;Prix\n";
      for (var p in _projets) { 
        for (var s in p.sessions) { 
          String type = s.estRemise ? S.discount : (s.estFrais ? S.fees : S.work); 
          String duree = s.estFrais ? "-" : Session.formater(s.secondesFacturees); 
          csv += "${p.nom};${s.dateFormatee};${s.titre};$type;$duree;${AppStyle.n(s.prix)} ${Projet.devise}\n"; 
        } 
      }
      final directory = await getTemporaryDirectory(); 
      final file = File('${directory.path}/$fileName'); 
      await file.writeAsString(csv);
      
      if (saveAsFile) {
        String? result = await FilePicker.platform.saveFile(
          fileName: fileName,
          type: FileType.custom,
          allowedExtensions: ['csv'],
          bytes: await file.readAsBytes(),
        );
        if (result != null) {
          if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(S.excelFileSaved)));
        }
      } else {
        await Share.shareXFiles([XFile(file.path)], text: 'Export CSV.');
      }
    } catch (e) { if (mounted) { ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("${S.errorPrefix}$e"), backgroundColor: Colors.red)); } }
  }
  Future<void> _exporterPDF({bool saveAsFile = false}) async {
    try {
      final now = DateTime.now();
      final dateStr = '${now.day.toString().padLeft(2, '0')}${now.month.toString().padLeft(2, '0')}${now.year.toString().substring(2)}';
      final fileName = 'ignitebill_$dateStr.txt';

      String rapport = "RAPPORT DE FACTURATION\n======================\n\n";
      for (var p in _projets) { 
        rapport += "PROJET : ${p.nom}\nTotal : ${AppStyle.n(p.prixTotalHistorique)} ${Projet.devise}\n----------------------\n"; 
        for (var s in p.sessions) { 
          rapport += "${s.dateFormatee} - ${s.titre} : ${AppStyle.n(s.prix)} ${Projet.devise}\n"; 
        } 
        rapport += "\n"; 
      }
      final directory = await getTemporaryDirectory(); 
      final file = File('${directory.path}/$fileName'); 
      await file.writeAsString(rapport); 
      
      if (saveAsFile) {
        String? result = await FilePicker.platform.saveFile(
          fileName: fileName,
          type: FileType.custom,
          allowedExtensions: ['txt'],
          bytes: await file.readAsBytes(),
        );
        if (result != null) {
          if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(S.reportSaved)));
        }
      } else {
        await Share.shareXFiles([XFile(file.path)], text: 'Rapport.');
      }
    } catch (e) { if (mounted) { ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("${S.errorPrefix}$e"), backgroundColor: Colors.red)); } }
  }
  void _importerSauvegarde() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
      );

      if (result == null) return;

      File file = File(result.files.single.path!);
      String content = await file.readAsString();
      final decoded = jsonDecode(content.trim()) as List;
      final nouveauxProjets = decoded.map((p) => Projet.fromJson(p)).toList();

      if (!mounted) return;

      showDialog(
          context: context,
          builder: (context) => AlertDialog(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  title: Text(S.importProjects, style: TextStyle(fontWeight: FontWeight.bold)),
                  content: Text('${nouveauxProjets.length} ${S.importProjectsPrompt}'),
                  actionsPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  actions: [
                    Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: VolumeButton(
                                  mini: true,
                                  color: Colors.red.withValues(alpha: 0.8),
                                  onPressed: () {
                                    setState(() => _projets = nouveauxProjets);
                                    _sauvegarderDonnees();
                                    Navigator.pop(context);
                                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(S.everythingReplaced)));
                                  },
                                  child: Text(S.replaceEverything, style: const TextStyle(color: Colors.white, fontSize: 10))),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: VolumeButton(
                                  mini: true,
                                  color: AppStyle.gain,
                                  onPressed: () {
                                    if (mounted) {
                                      setState(() {
                                        for (var np in nouveauxProjets) {
                                          _projets.removeWhere((p) => p.id == np.id);
                                          _projets.add(np);
                                        }
                                      });
                                      _trierProjets();
                                      _sauvegarderDonnees();
                                      Navigator.pop(context);
                                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${nouveauxProjets.length} ${S.projectsAdded}')));
                                    }
                                  },
                                  child: Text(S.add, style: const TextStyle(color: Colors.white))),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        SizedBox(
                          width: double.infinity,
                          child: VolumeButton(
                              mini: true,
                              color: AppStyle.textLight,
                              onPressed: () => Navigator.pop(context),
                              child: Text(S.cancel)),
                        ),
                      ],
                    ),
                  ]));
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(S.invalidFileFormat), backgroundColor: Colors.red));
      }
    }
  }
  void _choisirMethodeSauvegarde() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(S.backup, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: VolumeButton(
                      color: Theme.of(context).colorScheme.secondary,
                      onPressed: () { Navigator.pop(ctx); _exporterSauvegarde(); },
                      child: Column(
                        children: [
                          const Icon(Icons.share_rounded, size: 32, color: Colors.white),
                          const SizedBox(height: 8),
                          Text(S.exportShare, textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.w900, color: Colors.white, fontSize: 13)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: VolumeButton(
                      color: Colors.blueGrey,
                      onPressed: () { Navigator.pop(ctx); _exporterSauvegarde(saveAsFile: true); },
                      child: Column(
                        children: [
                          const Icon(Icons.save_alt_rounded, size: 32, color: Colors.white),
                          const SizedBox(height: 8),
                          Text(S.saveLocally, textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.w900, color: Colors.white, fontSize: 13)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  void _verifierRappelSauvegarde() {
    if (_projets.isEmpty) return;
    final mnt = DateTime.now();
    final diffJours = _dateDerniereSauvegarde == null ? 999 : mnt.difference(_dateDerniereSauvegarde!).inDays;
    
    if (diffJours >= _frequenceRappelJours) {
      final joursLabel = _dateDerniereSauvegarde == null ? '∞' : diffJours.toString();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showMaterialBanner(
          MaterialBanner(
            elevation: 4,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            backgroundColor: Theme.of(context).colorScheme.primaryContainer,
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(S.supportAppMessage, style: TextStyle(color: Theme.of(context).colorScheme.onPrimaryContainer, fontSize: 13)),
                const SizedBox(height: 4),
                Text("${S.lastBackupPrefix}il y a $joursLabel${S.daysAgo}", style: TextStyle(color: Theme.of(context).colorScheme.onPrimaryContainer, fontWeight: FontWeight.w900, fontSize: 14)),
              ],
            ),
            leading: const Icon(Icons.favorite_rounded, color: Colors.red, size: 30),
            actions: [
              TextButton(
                onPressed: () { ScaffoldMessenger.of(context).hideCurrentMaterialBanner(); _resetCycleSauvegarde(); },
                child: Text(S.maybeLater, style: const TextStyle(fontWeight: FontWeight.bold)),
              ),
              TextButton(
                onPressed: () { ScaffoldMessenger.of(context).hideCurrentMaterialBanner(); _ouvrirLienSoutien(); },
                child: Text(S.supportHeart, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.red)),
              ),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(backgroundColor: AppStyle.gain, foregroundColor: Colors.white),
                onPressed: () { ScaffoldMessenger.of(context).hideCurrentMaterialBanner(); _choisirMethodeSauvegarde(); },
                icon: const Icon(Icons.save_rounded, size: 16),
                label: Text(S.backupNow),
              ),
            ],
          ),
        );
      });
    }
  }
  void _newProjet() async {
    final prefs = await SharedPreferences.getInstance();
    final taxesJson = prefs.getString('pro_taxes') ?? '[]';
    List<Taxe> globalTaxes = (jsonDecode(taxesJson) as List).map((t) => Taxe.fromJson(t)).toList();
    List<Taxe> selectedTaxes = [];

    final nCtrl = TextEditingController(); 
    final tCtrl = TextEditingController(text: Projet.tauxParDefaut.toString().replaceAll(RegExp(r'\.0$'), '')); 
    final fCtrl = TextEditingController(text: Projet.fraisParDefaut.toString().replaceAll(RegExp(r'\.0$'), '')); 
    int pal = Projet.palierParDefaut; 
    int seuil = Projet.seuilParDefaut;

    if (!mounted) return;
    showDialog(context: context, builder: (context) => StatefulBuilder(builder: (context, setDState) {
        final style = AppStyle.visualStyle.value;
        final isDark = Theme.of(context).brightness == Brightness.dark;
        final primaryColor = style == AppVisualStyle.deluxe ? AppStyle.deluxeButton : Theme.of(context).primaryColor;
        return AlertDialog(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)), title: Center(child: Text(S.newProject, style: TextStyle(fontWeight: FontWeight.bold))), content: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          TextField(controller: nCtrl, autofocus: true, onTap: () => nCtrl.selection = TextSelection(baseOffset: 0, extentOffset: nCtrl.text.length), decoration: InputDecoration(labelText: S.projectName, border: OutlineInputBorder()), textCapitalization: TextCapitalization.sentences), const SizedBox(height: 15),
          Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
            Column(children: [Text(S.hourlyRate, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: AppStyle.textLight, letterSpacing: 1)), RouletteMontant(valeur: double.tryParse(tCtrl.text.replaceAll(',', '.')) ?? 0, suffixe: ' ${Projet.devise}/h', controller: tCtrl, onChanged: (v) => setDState(() {}), step: 5, width: 90, fontSize: 18, color: primaryColor)]),
            Column(children: [Text(S.fees, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: AppStyle.textLight, letterSpacing: 1)), RouletteMontant(valeur: double.tryParse(fCtrl.text.replaceAll(',', '.')) ?? 0, suffixe: ' ${Projet.devise}', controller: fCtrl, onChanged: (v) => setDState(() {}), step: 5, width: 80, fontSize: 18, color: primaryColor)])]),
          const SizedBox(height: 20),
          Text('${S.billingStep} : ${pal}m', style: const TextStyle(fontWeight: FontWeight.bold)), Slider(value: pal.toDouble(), min: 1, max: 60, activeColor: primaryColor, onChanged: (v) => setDState(() { pal = v.round(); if (seuil > pal) { seuil = pal; } })), const SizedBox(height: 5), Text('${S.minTimeBeforeStep} : ${seuil}m', style: const TextStyle(fontWeight: FontWeight.bold)), Slider(value: seuil.toDouble(), min: 0, max: pal.toDouble(), activeColor: Theme.of(context).colorScheme.secondary, onChanged: pal == 1 ? null : (v) => setDState(() => seuil = v.round())),
          if (globalTaxes.isNotEmpty) ...[
            const Divider(height: 30),
            Center(child: Text(S.taxesToApplyDefault, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: AppStyle.textLight, letterSpacing: 1.2))),
            const SizedBox(height: 10),
            Center(
              child: Wrap(
                alignment: WrapAlignment.center,
                spacing: 8,
                runSpacing: 8,
                children: globalTaxes.map((gt) {
                  bool isSelected = selectedTaxes.any((st) => st.nom == gt.nom);
                  return InkWell(
                    onTap: () {
                      setDState(() {
                        if (!isSelected) {
                          selectedTaxes.add(gt);
                        } else {
                          selectedTaxes.removeWhere((st) => st.nom == gt.nom);
                        }
                      });
                    },
                    borderRadius: BorderRadius.circular(10),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected ? primaryColor : (isDark ? Colors.white.withValues(alpha: 0.05) : Colors.grey.withValues(alpha: 0.1)),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: isSelected ? primaryColor : (isDark ? Colors.white10 : Colors.black12), width: 1),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(gt.nom, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: isSelected ? Colors.white : (isDark ? Colors.white70 : AppStyle.textDark))),
                          Text("${gt.valeur}${gt.estPourcentage ? '%' : Projet.devise}", style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: isSelected ? Colors.white70 : AppStyle.textLight)),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ]
        ])), actions: [VolumeButton(mini: true, color: AppStyle.textLight, onPressed: () => Navigator.pop(context), child: Text(S.cancel)), VolumeButton(mini: true, color: primaryColor, onPressed: () { 
          String nomFinal = nCtrl.text.trim(); if (nomFinal.isEmpty) { int i = 1; while (_projets.any((p) => p.nom == 'Projet $i')) { i++; } nomFinal = 'Projet $i'; }
          
          
          setState(() {
            final nouveauProjet = Projet(
              id: DateTime.now().toString(), 
              nom: nomFinal, 
              tauxHoraire: double.tryParse(tCtrl.text.replaceAll(',', '.')) ?? Projet.tauxParDefaut, 
              palierMinutes: pal, 
              seuilMinutes: seuil, 
              fraisFixes: double.tryParse(fCtrl.text.replaceAll(',', '.')) ?? Projet.fraisParDefaut
            );
            if (selectedTaxes.isNotEmpty) {
              nouveauProjet.sessions.add(Session(
                id: DateTime.now().toString(),
                date: DateTime.now(),
                secondesReelles: 0,
                secondesFacturees: 0,
                prix: 0,
                titre: S.taxInitialization,
                taxes: List.from(selectedTaxes),
                estFrais: true,
              ));
            }
            _projets.add(nouveauProjet);
          }); 
          _sauvegarderDonnees(); 
          Navigator.pop(context);
        }, child: Text(S.create, style: TextStyle(color: Colors.white)))]);
    }));
  }
  void _quickChrono() {
    if (_popupChronoEnCours) return;
    setState(() => _popupChronoEnCours = true);
    showDialog(context: context, barrierDismissible: false, builder: (context) => DialogChronoRapide(projets: _projets, onSave: (projetId, nouveauNom, secondes, taux, palier, seuil, sessionNom, taxes) { 
      setState(() {
        Projet p; if (projetId == '__new__') { String nomFinal = nouveauNom.isEmpty ? 'Nouveau ${S.projet}' : nouveauNom; if (_projets.any((x) => x.nom.toLowerCase() == nomFinal.toLowerCase())) { int compteur = 1; String tentativeNom = "$nomFinal $compteur"; while (_projets.any((x) => x.nom.toLowerCase() == tentativeNom.toLowerCase())) { compteur++; tentativeNom = "$nomFinal $compteur"; } nomFinal = tentativeNom; } p = Projet(id: DateTime.now().toString(), nom: nomFinal, tauxHoraire: taux, palierMinutes: palier, seuilMinutes: seuil); _projets.add(p); } else { p = _projets.firstWhere((x) => x.id == projetId); p.tauxHoraire = taux; p.palierMinutes = palier; p.seuilMinutes = seuil; }
        int sf = p.calculerSecondesFacturees(secondes); p.sessions.insert(0, Session(id: DateTime.now().toString(), date: DateTime.now(), secondesReelles: secondes, secondesFacturees: sf, prix: AppStyle.arondir((sf / 3600) * taux), titre: sessionNom.isEmpty ? S.quickSession : sessionNom, taxes: taxes));
        p.invalidate();
      }); 
      _trierProjets(); _sauvegarderDonnees(); 
    })).then((_) => setState(() => _popupChronoEnCours = false));
  }

  void _transferProjet(Projet pSource) {
    String? projetCibleId;
    showDialog(context: context, builder: (c) => StatefulBuilder(builder: (ctx, setStateD) {
        final style = AppStyle.visualStyle.value;
        final primaryColor = style == AppVisualStyle.deluxe ? AppStyle.deluxeButton : Theme.of(context).primaryColor;
        return AlertDialog(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)), title: Center(child: Text(S.transferTo, style: const TextStyle(fontWeight: FontWeight.bold))), content: Column(mainAxisSize: MainAxisSize.min, children: [Center(child: Text(S.transferAllSessionsTo, style: const TextStyle(fontSize: 13, color: AppStyle.textLight))), const SizedBox(height: 15), DropdownButtonFormField<String>(isExpanded: true, decoration: const InputDecoration(border: OutlineInputBorder(), isDense: true), items: [..._projets.where((p) => p.id != pSource.id).map((p) => DropdownMenuItem(value: p.id, child: Text(p.nom, overflow: TextOverflow.ellipsis))), DropdownMenuItem(value: 'new', child: Text(S.newProjectEllipsis))], onChanged: (v) => setStateD(() => projetCibleId = v))]), actions: [VolumeButton(mini: true, color: AppStyle.textLight, onPressed: () => Navigator.pop(c), child: Text(S.cancel)), VolumeButton(mini: true, color: primaryColor, onPressed: () async {
                if (projetCibleId != null) {
                  Projet? cible; if (projetCibleId == 'new') { final nCtrl = TextEditingController(); bool cree = await showDialog(context: context, builder: (c2) => AlertDialog(title: Text(S.newProject), content: TextField(controller: nCtrl, autofocus: true, decoration: InputDecoration(labelText: S.projectName)), actions: [VolumeButton(mini: true, color: AppStyle.textLight, onPressed: () => Navigator.pop(c2, false), child: Text(S.cancel)), VolumeButton(mini: true, color: AppStyle.gain, onPressed: () => Navigator.pop(c2, true), child: Text(S.ok))])) ?? false; if (cree && nCtrl.text.trim().isNotEmpty) { cible = Projet(id: DateTime.now().toString(), nom: nCtrl.text.trim()); setState(() => _projets.add(cible!)); } } 
                  else { cible = _projets.firstWhere((p) => p.id == projetCibleId); }
                  if (cible != null) { 
                    setState(() { 
                      cible!.sessions.insertAll(0, pSource.sessions); 
                      pSource.sessions.clear(); 
                      cible.invalidate();
                      pSource.invalidate();
                    }); 
                    _sauvegarderDonnees(); 
                    if (mounted) { Navigator.of(context).pop(); } 
                    return; 
                  }
                }
                if (mounted) { Navigator.of(context).pop(); }
              }, child: Text(S.ok, style: const TextStyle(color: Colors.white)))]);
    }));
  }
  void _proProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final nCtrl = TextEditingController(text: prefs.getString('pro_nom') ?? '');
    final aCtrl = TextEditingController(text: prefs.getString('pro_adresse') ?? '');
    final eCtrl = TextEditingController(text: prefs.getString('pro_email') ?? '');
    final pCtrl = TextEditingController(text: prefs.getString('pro_tel') ?? '');
    final lCtrl = TextEditingController(text: prefs.getString('pro_label_id') ?? 'TVA');
    final vCtrl = TextEditingController(text: prefs.getString('pro_valeur_id') ?? '');
    final bCtrl = TextEditingController(text: prefs.getString('pro_banque') ?? '');
    final mCtrl = TextEditingController(text: prefs.getString('pro_mentions') ?? '');
    final taxesJson = prefs.getString('pro_taxes') ?? '[]';
    List<Taxe> taxes = (jsonDecode(taxesJson) as List).map((t) => Taxe.fromJson(t)).toList();

    if (!mounted) return;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => StatefulBuilder(builder: (ctx, setS) {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.85,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Container(
              width: 40, 
              height: 4, 
              decoration: BoxDecoration(
                color: Colors.grey.withValues(alpha: 0.3), 
                borderRadius: BorderRadius.circular(2)
              )
            ),
          ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Center(child: Text(S.myProProfile, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900))),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children: [
                      const SizedBox(height: 10),
                      TextField(controller: nCtrl, decoration: InputDecoration(labelText: S.projectName, border: OutlineInputBorder()), textCapitalization: TextCapitalization.words, maxLines: null, keyboardType: TextInputType.multiline),
                      const SizedBox(height: 10),
                      TextField(controller: aCtrl, decoration: InputDecoration(labelText: S.clientAddress, border: OutlineInputBorder()), maxLines: null, keyboardType: TextInputType.multiline),
                      const SizedBox(height: 10),
                      Row(children: [
                        Expanded(child: TextField(controller: eCtrl, decoration: const InputDecoration(labelText: 'Email', border: OutlineInputBorder()), keyboardType: TextInputType.emailAddress)),
                        const SizedBox(width: 10),
                        Expanded(child: TextField(controller: pCtrl, decoration: InputDecoration(labelText: S.phone, border: const OutlineInputBorder()), keyboardType: TextInputType.phone)),
                      ]),
                      const SizedBox(height: 10),
                      TextField(controller: lCtrl, decoration: InputDecoration(labelText: S.taxIdLabel, border: OutlineInputBorder())),
                      const SizedBox(height: 10),
                      TextField(controller: vCtrl, decoration: InputDecoration(labelText: S.taxIdValue, border: OutlineInputBorder())),
                      const SizedBox(height: 10),
                      TextField(controller: bCtrl, decoration: InputDecoration(labelText: S.bankInfo, border: OutlineInputBorder()), maxLines: null, keyboardType: TextInputType.multiline),
                      const SizedBox(height: 10),
                      TextField(controller: mCtrl, decoration: InputDecoration(labelText: S.legalMentions, border: OutlineInputBorder()), maxLines: null, keyboardType: TextInputType.multiline),
                      const Divider(height: 30),
                      Text(S.taxesAndAdditionalFees, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey)),
                      const SizedBox(height: 10),
                      ...taxes.map((t) => ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text("${t.nom} (${t.valeur}${t.estPourcentage ? '%' : Projet.devise})", style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                        trailing: IconButton(icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20), onPressed: () => setS(() => taxes.remove(t))),
                      )),
                      Center(
                        child: TextButton.icon(
                          onPressed: () {
                            final tn = TextEditingController(); final tv = TextEditingController(); bool isP = true;
                            showDialog(context: context, builder: (ctx3) => StatefulBuilder(builder: (ctx3, setS3) => AlertDialog(
                              title: Text(S.newTax),
                              content: Column(mainAxisSize: MainAxisSize.min, children: [
                                TextField(controller: tn, decoration: const InputDecoration(labelText: "Nom (ex: TVA 20%)")),
                                Row(children: [
                                  Expanded(child: TextField(controller: tv, decoration: const InputDecoration(labelText: "Valeur"), keyboardType: TextInputType.number)),
                                  const SizedBox(width: 10),
                                  ToggleButtons(
                                    isSelected: [isP, !isP],
                                    onPressed: (i) => setS3(() => isP = i == 0),
                                    children: [const Text("%"), Text(Projet.devise)],
                                  )
                                ])
                              ]),
                              actions: [
                                TextButton(onPressed: () => Navigator.pop(ctx3), child: Text(S.cancel)),
                                TextButton(onPressed: () {
                                  if (tn.text.isNotEmpty) {
                                    setS(() => taxes.add(Taxe(id: DateTime.now().toString(), nom: tn.text, valeur: double.tryParse(tv.text) ?? 0, estPourcentage: isP)));
                                    Navigator.pop(ctx3);
                                  }
                                }, child: Text(S.ok))
                              ],
                            )));
                          },
                          icon: const Icon(Icons.add_circle_outline, size: 18),
                          label: Text(S.addTax),
                        ),
                      )
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Expanded(
                      child: VolumeButton(mini: true, color: AppStyle.textLight, onPressed: () => Navigator.pop(ctx), child: Text(S.cancel, textAlign: TextAlign.center)),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: VolumeButton(mini: true, color: Theme.of(context).colorScheme.secondary, onPressed: () async {
                        await prefs.setString('pro_nom', nCtrl.text);
                        await prefs.setString('pro_adresse', aCtrl.text);
                        await prefs.setString('pro_email', eCtrl.text);
                        await prefs.setString('pro_tel', pCtrl.text);
                        await prefs.setString('pro_label_id', lCtrl.text);
                        await prefs.setString('pro_valeur_id', vCtrl.text);
                        await prefs.setString('pro_banque', bCtrl.text);
                        await prefs.setString('pro_mentions', mCtrl.text);
                        await prefs.setString('pro_taxes', jsonEncode(taxes.map((t) => t.toJson()).toList()));
                        if (!context.mounted) {
                          return;
                        }
                        Navigator.pop(ctx);
                      }, child: Text(S.save, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white))),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  Future<void> _ouvrirLienSoutien() async {
    final url = Uri.parse('https://ko-fi.com/dthrawn');
    if (await canLaunchUrl(url)) { await launchUrl(url, mode: LaunchMode.externalApplication); } 
    else { Share.share(url.toString()); }
  }

  void _sectSkin() {
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setS) {
          final style = AppStyle.visualStyle.value;
          final palette = AppStyle.colorPalette.value;
          final mode = AppStyle.themeMode.value;
          final isPro = ProService.isPro.value;
          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: Center(child: Text(S.personalization, style: const TextStyle(fontWeight: FontWeight.w900))),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(S.shape, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1.2)),
                Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
                  IconButton(icon: Icon(Icons.palette_rounded, color: style == AppVisualStyle.vibrant ? Theme.of(context).colorScheme.primary : Colors.grey), onPressed: () { AppStyle.saveVisualStyle(AppVisualStyle.vibrant); setS(() {}); }),
                  IconButton(icon: Icon(Icons.layers_rounded, color: style == AppVisualStyle.titanium ? AppStyle.titaniumPrimary : Colors.grey), onPressed: () { AppStyle.saveVisualStyle(AppVisualStyle.titanium); setS(() {}); }),
                  Stack(alignment: Alignment.topRight, children: [
                    IconButton(icon: Icon(Icons.diamond_rounded, color: style == AppVisualStyle.deluxe ? Theme.of(context).colorScheme.primary : Colors.grey), onPressed: () { if (isPro) { AppStyle.saveVisualStyle(AppVisualStyle.deluxe); setS(() {}); } else { showDialog(context: context, builder: (c) => const ProDialog()); } }),
                    if (!isPro) const IgnorePointer(child: Icon(Icons.lock, size: 14, color: Colors.orange)),
                  ]),
                ]),
                const Divider(),
                Text(S.color, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1.2)),
                Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
                  _optCol(setS, AppColorPalette.royal, const Color(0xFF7C3AED), palette == AppColorPalette.royal),
                  Stack(alignment: Alignment.topRight, children: [
                    _optCol(setS, AppColorPalette.ocean, const Color(0xFF0284C7), palette == AppColorPalette.ocean, isLocked: !isPro),
                    if (!isPro) const IgnorePointer(child: Icon(Icons.lock, size: 14, color: Colors.orange)),
                  ]),
                  _optCol(setS, AppColorPalette.forest, const Color(0xFF9F1239), palette == AppColorPalette.forest),
                ]),
                const Divider(),
                Text(S.theme, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1.2)),
                Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
                  IconButton(icon: Icon(Icons.wb_sunny_rounded, color: mode == ThemeMode.light ? Colors.orange : Colors.grey), onPressed: () { AppStyle.saveThemeMode(ThemeMode.light); setS(() {}); }),
                  IconButton(icon: Icon(Icons.nightlight_round, color: mode == ThemeMode.dark ? Colors.blue : Colors.grey), onPressed: () { AppStyle.saveThemeMode(ThemeMode.dark); setS(() {}); }),
                  IconButton(icon: Icon(Icons.brightness_auto_rounded, color: mode == ThemeMode.system ? Colors.green : Colors.grey), onPressed: () { AppStyle.saveThemeMode(ThemeMode.system); setS(() {}); }),
                ]),
              ],
            ),
            actionsAlignment: MainAxisAlignment.center,
            actions: [VolumeButton(mini: true, color: AppStyle.getPrimaryColor(Theme.of(context).brightness == Brightness.dark, style, palette), onPressed: () => Navigator.pop(ctx), child: Text(S.ok))],
          );
        }
      ),
    );
  }

  void _legal() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(S.legalMentionsTitle, style: const TextStyle(fontWeight: FontWeight.w900)),
        content: SingleChildScrollView(child: Text(S.legalMentionsContent, style: const TextStyle(fontSize: 14, height: 1.4))),
        actions: [
          VolumeButton(mini: true, color: Theme.of(context).colorScheme.primary, onPressed: () => Navigator.pop(ctx), child: Text(S.understood, style: const TextStyle(color: Colors.white))),
        ],
      ),
    );
  }

  Widget _optCol(StateSetter setS, AppColorPalette p, Color c, bool selected, {bool isLocked = false}) {
    return Container(
      decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: selected ? c : Colors.transparent, width: 2)),
      padding: const EdgeInsets.all(2),
      child: IconButton(icon: Icon(Icons.circle, color: c, size: 28), onPressed: () { if (isLocked) { showDialog(context: context, builder: (c) => const ProDialog()); } else { AppStyle.saveColorPalette(p); setS(() {}); } }),
    );
  }

  Widget _buildSettingsSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
          child: Text(title.toUpperCase(), style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: Colors.grey, letterSpacing: 1.2)),
        ),
        ...children,
        const SizedBox(height: 8),
      ],
    );
  }

  void _settings() {
    final tc = TextEditingController(text: Projet.tauxParDefaut.toString().replaceAll(RegExp(r'\.0$'), ''));
    final fc = TextEditingController(text: Projet.fraisParDefaut.toString().replaceAll(RegExp(r'\.0$'), ''));
    final dc = TextEditingController(text: Projet.devise);
    int pt = Projet.palierParDefaut;
    int st = Projet.seuilParDefaut;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) => StatefulBuilder(
        builder: (context, setS) => ValueListenableBuilder<AppColorPalette>(
          valueListenable: AppStyle.colorPalette,
          builder: (context, palette, _) => ValueListenableBuilder<AppVisualStyle>(
            valueListenable: AppStyle.visualStyle,
            builder: (context, style, _) {
              final isDark = Theme.of(context).brightness == Brightness.dark;
              final primaryColor = AppStyle.getPrimaryColor(isDark, style, palette);
              return Container(
                height: MediaQuery.of(context).size.height * 0.85,
                padding: const EdgeInsets.only(bottom: 20),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey.withValues(alpha: 0.3), borderRadius: BorderRadius.circular(2))),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(S.settings, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900)),
                          VolumeButton(mini: true, color: primaryColor, onPressed: () async {
                            setState(() {
                              Projet.tauxParDefaut = double.tryParse(tc.text.replaceAll(',', '.')) ?? Projet.tauxParDefaut;
                              Projet.fraisParDefaut = double.tryParse(fc.text.replaceAll(',', '.')) ?? Projet.fraisParDefaut;
                              Projet.palierParDefaut = pt; Projet.seuilParDefaut = st;
                              Projet.devise = dc.text.isEmpty ? '€' : dc.text;
                            });
                            final prefs = await SharedPreferences.getInstance();
                            await prefs.setDouble('tauxParDefaut', Projet.tauxParDefaut);
                            await prefs.setDouble('fraisParDefaut', Projet.fraisParDefaut);
                            await prefs.setInt('palierParDefaut', pt);
                            await prefs.setInt('seuilParDefaut', st);
                            await prefs.setString('devise', Projet.devise);
                            if (context.mounted) {
                              Navigator.pop(context);
                            }
                          }, child: Text(S.ok, style: TextStyle(color: Colors.white))),
                        ],
                      ),
                    ),
                    Expanded(
                      child: ListView(
                        children: [
                          _buildSettingsSection(S.automationsNewProjects, [
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              child: Column(
                                children: [
                                  Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
                                    Column(children: [Text(S.hourlyRate, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: AppStyle.textLight, letterSpacing: 1)), RouletteMontant(valeur: double.tryParse(tc.text.replaceAll(',', '.')) ?? 0, suffixe: ' ${Projet.devise}/h', controller: tc, onChanged: (v) => setS(() {}), step: 5, width: 90, fontSize: 18, color: primaryColor)]),
                                    Column(children: [Text(S.fees, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: AppStyle.textLight, letterSpacing: 1)), RouletteMontant(valeur: double.tryParse(fc.text.replaceAll(',', '.')) ?? 0, suffixe: ' ${Projet.devise}', controller: fc, onChanged: (v) => setS(() {}), step: 5, width: 80, fontSize: 18, color: primaryColor)])
                                  ]),
                                  const SizedBox(height: 15),
                                  Text('${S.billingStep} : ${pt}m', style: const TextStyle(fontWeight: FontWeight.bold)),
                                  Slider(value: pt.toDouble(), min: 1, max: 60, activeColor: primaryColor, onChanged: (v) => setS(() { pt = v.round(); if (st > pt) st = pt; })),
                                  Text('${S.minTimeBeforeStep} : ${st}m', style: const TextStyle(fontWeight: FontWeight.bold)),
                                  Slider(value: st.toDouble(), min: 0, max: pt.toDouble(), activeColor: Theme.of(context).colorScheme.secondary, onChanged: pt == 1 ? null : (v) => setS(() => st = v.round())),
                                ],
                              ),
                            ),
                          ]),
                          _buildSettingsSection(S.identityAndBilling, [
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              child: Row(
                                children: [
                                  SizedBox(
                                    width: 110,
                                    child: TextField(
                                      controller: dc,
                                      maxLength: 4,
                                      decoration: InputDecoration(labelText: S.currency, border: const OutlineInputBorder(), counterText: "", prefixIcon: const Icon(Icons.monetization_on_outlined, size: 20)),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      initialValue: AppStyle.language.value,
                      decoration: InputDecoration(labelText: S.languageLabel, border: const OutlineInputBorder(), prefixIcon: const Icon(Icons.language_rounded, size: 20)),
                      items: const [DropdownMenuItem(value: 'fr', child: Text('Français')), DropdownMenuItem(value: 'en', child: Text('English'))],
                      onChanged: (v) {
                        if (v != null) {
                          AppStyle.saveLanguage(v);
                          if (mounted) {
                            setState(() {});
                          }
                        }
                      },
                    ),
                  ),
                                ],
                              ),
                            ),
                            ListTile(
                              leading: IconPop(icon: Icons.person_pin_rounded, color: primaryColor),
                              title: Text(S.myProProfile, style: const TextStyle(fontWeight: FontWeight.bold)),
                              subtitle: Text(S.manageProInfoAndTaxes),
                              onTap: _proProfile,
                            ),
                          ]),
                      _buildSettingsSection(S.appearance, [
                        ListTile(
                          leading: const IconPop(icon: Icons.palette_rounded, color: Colors.blueGrey),
                          title: Text(S.personalization, style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text(S.changeSkinColorsTheme),
                          onTap: _sectSkin,
                        ),
                      ]),
                      _buildSettingsSection(S.dataAndSecurity, [
                        ListTile(
                          leading: IconPop(icon: Icons.share_rounded, color: Theme.of(context).colorScheme.secondary),
                          title: Text(S.exportShare, style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text(S.jsonCsvTextReport),
                          onTap: () => showModalBottomSheet(context: context, builder: (ctx) => SafeArea(child: Column(mainAxisSize: MainAxisSize.min, children: [
                            Padding(padding: const EdgeInsets.all(16), child: Text(S.shareBackup, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey))),
                            ListTile(leading: const Icon(Icons.code_rounded), title: Text(S.formatJsonCompleteBackup), onTap: () { Navigator.pop(ctx); _exporterSauvegarde(); }),
                            ListTile(leading: const Icon(Icons.table_chart_rounded), title: Text(S.formatCsvExcel), onTap: () { Navigator.pop(ctx); _exporterCSV(); }),
                            ListTile(leading: const Icon(Icons.description_outlined), title: Text(S.textReport), onTap: () { Navigator.pop(ctx); _exporterPDF(); }),
                          ]))),
                        ),
                        ListTile(
                          leading: const IconPop(icon: Icons.save_alt_rounded, color: Colors.blueGrey),
                          title: Text(S.saveLocally, style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text(S.saveFileOnDevice),
                          onTap: () => showModalBottomSheet(context: context, builder: (ctx) => SafeArea(child: Column(mainAxisSize: MainAxisSize.min, children: [
                            Padding(padding: const EdgeInsets.all(16), child: Text(S.saveBackup, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey))),
                            ListTile(leading: const Icon(Icons.save_alt_rounded), title: Text(S.saveJsonBackup), onTap: () { Navigator.pop(ctx); _exporterSauvegarde(saveAsFile: true); }), 
                            ListTile(leading: const Icon(Icons.table_rows_rounded), title: Text(S.saveExcelCsv), onTap: () { Navigator.pop(ctx); _exporterCSV(saveAsFile: true); }), 
                            ListTile(leading: const Icon(Icons.text_snippet_outlined), title: Text(S.saveTextReport), onTap: () { Navigator.pop(ctx); _exporterPDF(saveAsFile: true); }),
                          ]))),
                        ),
                        ListTile(
                          leading: IconPop(icon: Icons.file_open_rounded, color: Theme.of(context).colorScheme.primary),
                          title: Text(S.import, style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text(S.restoreFromJson),
                          onTap: _importerSauvegarde,
                        ),
                      ]),
                      _buildSettingsSection(S.other, [
                        ListTile(
                          leading: IconPop(icon: Icons.diamond_rounded, color: ProService.isPro.value ? Colors.green : Colors.orange),
                          title: Text(S.licenseSection, style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text(ProService.isPro.value ? S.licenseActive : S.activatePro),
                          onTap: () => showDialog(context: context, builder: (c) => const ProDialog()),
                        ),
                        ListTile(
                          leading: const IconPop(icon: Icons.coffee_rounded, color: Colors.brown),
                          title: Text(S.supportDevelopment, style: TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text(S.buyDthrawnACoffee),
                          onTap: _ouvrirLienSoutien,
                        ),
                        ListTile(
                          leading: const IconPop(icon: Icons.gavel_rounded, color: Colors.blueGrey),
                          title: Text(S.legalMentionsTitle, style: const TextStyle(fontWeight: FontWeight.bold)),
                          onTap: _legal,
                        ),
                      ]),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    ),
  ),
);
}

  @override Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final style = AppStyle.visualStyle.value;
    return Scaffold(
      appBar: AppBar(title: Text(_voirArchives ? S.archives : S.appTitle), actions: [
    PopupMenuButton<String>(
          icon: Icon(_voirArchives ? Icons.inventory_2_rounded : (_modeTri == 'alphabet' ? Icons.sort_by_alpha_rounded : Icons.history_rounded)),
          onSelected: (val) {
            if (val == 'tri') { setState(() => _modeTri = (_modeTri == 'alphabet' ? 'recent' : 'alphabet')); _trierProjets(); _sauvegarderDonnees(); }
            else if (val == 'archive') { setState(() => _voirArchives = !_voirArchives); }
          },
          itemBuilder: (ctx) => [
            PopupMenuItem(value: 'tri', child: Row(children: [Icon(_modeTri == 'alphabet' ? Icons.history_rounded : Icons.sort_by_alpha_rounded, size: 20), const SizedBox(width: 12), Text(_modeTri == 'alphabet' ? S.sortByRecent : S.sortByName)])),
            PopupMenuItem(value: 'archive', child: Row(children: [Icon(_voirArchives ? Icons.check_circle_outline_rounded : Icons.inventory_2_outlined, size: 20), const SizedBox(width: 12), Text(_voirArchives ? S.activeProjects : S.seeArchives)])),
          ],
        ),
        IconButton(icon: const Icon(Icons.tune_rounded), onPressed: _settings)
      ]),
      body: _projetsAffiches.isEmpty ? Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Center(child: Text(_voirArchives ? S.noArchivedProjects : S.emptyProjets, textAlign: TextAlign.center, style: const TextStyle(color: AppStyle.textLight, fontSize: 18, fontWeight: FontWeight.w600))),
        const SizedBox(height: 40),
        TextButton.icon(
          onPressed: _ouvrirLienSoutien,
          icon: const Icon(Icons.coffee_rounded, size: 18, color: Colors.brown),
          label: Text(S.supportDthrawn, style: TextStyle(color: AppStyle.textLight, fontSize: 12)),
        )
      ]) : ListView.builder(itemCount: _projetsAffiches.length + 1, itemBuilder: (context, index) {
        if (index == _projetsAffiches.length) {
          return Padding(
            padding: const EdgeInsets.only(top: 20, bottom: 100),
            child: Center(
              child: TextButton.icon(
                onPressed: _ouvrirLienSoutien,
                icon: const Icon(Icons.coffee_rounded, size: 16, color: Colors.brown),
                label: Text(S.supportDthrawn, style: TextStyle(color: AppStyle.textLight, fontSize: 11, fontWeight: FontWeight.bold)),
              ),
            ),
          );
        }
        final p = _projetsAffiches[index]; 
        final primaryColor = Theme.of(context).colorScheme.primary;
        return Hero(
          tag: 'projet_${p.id}',
          child: Dismissible(
              key: Key('projet_${p.id}'),
              direction: DismissDirection.horizontal,
              background: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  alignment: Alignment.centerLeft,
                  decoration: BoxDecoration(color: _voirArchives ? Theme.of(context).colorScheme.secondary : primaryColor, borderRadius: BorderRadius.circular(20)),
                  child: Row(children: [
                    Icon(_voirArchives ? Icons.unarchive_rounded : Icons.drive_file_move_rounded, color: Colors.white),
                    const SizedBox(width: 8),
                    Text(_voirArchives ? S.unarchive : S.transferTo, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold))
                  ])),
              secondaryBackground: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  alignment: Alignment.centerRight,
                  decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(20)),
                  child: Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                    Text(S.delete, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    const SizedBox(width: 8),
                    const Icon(Icons.delete_sweep_rounded, color: Colors.white)
                  ])),
              confirmDismiss: (direction) async {
                if (direction == DismissDirection.startToEnd) {
                  if (_voirArchives) {
                    setState(() { p.estArchive = false; });
                    _sauvegarderDonnees();
                    return true;
                  }
                  _transferProjet(p);
                  return false;
                } else {
                  return await showDialog(context: context, builder: (c) => AlertDialog(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    title: Text(_voirArchives ? S.unarchiveConfirmTitle : S.archiveConfirmTitle),
                    content: Text(_voirArchives ? S.unarchiveWarning : S.archiveWarning),
                    actionsPadding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
                    actions: [
                      Column(children: [
                        SizedBox(width: double.infinity, child: VolumeButton(mini: true, color: Theme.of(context).colorScheme.primary, onPressed: () {
                          setState(() { p.estArchive = !p.estArchive; });
                          _sauvegarderDonnees();
                          Navigator.pop(c, true);
                        }, child: Text(_voirArchives ? S.unarchive : S.archive, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white)))),
                        const SizedBox(height: 8),
                        SizedBox(width: double.infinity, child: VolumeButton(mini: true, color: AppStyle.textLight, onPressed: () => Navigator.pop(c, false), child: Text(S.cancel, textAlign: TextAlign.center))),
                        const SizedBox(height: 8),
                        SizedBox(width: double.infinity, child: VolumeButton(mini: true, color: Colors.red, onPressed: () {
                          setState(() => _projets.remove(p));
                          _sauvegarderDonnees();
                          Navigator.pop(c, true);
                        }, child: Text(S.delete, textAlign: TextAlign.center, style: TextStyle(color: Colors.white)))),
                      ])
                    ]
                  )) ?? false;
                }
              },
                  child: VolumeCard(
                    color: primaryColor,
                    sideBarWidth: 12,
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => EcranTimer(projet: p, tousLesProjets: _projets, onTransferer: (session, cible) { setState(() { p.sessions.remove(session); p.invalidate(); cible.sessions.insert(0, session); cible.invalidate(); }); _sauvegarderDonnees(); }, onSave: _sauvegarderDonnees))).then((_) => _trierProjets()),
                    child: ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: IconPop(icon: Icons.folder_copy_rounded, color: primaryColor), 
                      title: Text(p.nom, style: TextStyle(fontWeight: FontWeight.w900, fontSize: 19, color: isDark ? Colors.white : (style == AppVisualStyle.deluxe ? AppStyle.deluxeText : null))), 
                      subtitle: Text(p.sessions.isEmpty ? S.noSessions : "${S.lastSession} ${p.sessions.first.dateFormatee}", style: TextStyle(color: isDark ? Colors.white70 : (style == AppVisualStyle.deluxe ? AppStyle.deluxeText.withValues(alpha: 0.6) : AppStyle.textLight), fontWeight: FontWeight.w600)), 
                      trailing: Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.end, children: [
                        Text('${AppStyle.n(p.prixTotalHistorique)} ${Projet.devise}', style: TextStyle(fontWeight: FontWeight.w900, color: Theme.of(context).colorScheme.secondary, fontSize: 18, letterSpacing: -0.8)), 
                        Text(Session.formaterSansSecondes(p.secondesHistorique), style: TextStyle(fontWeight: FontWeight.w800, color: isDark ? Colors.white54 : (style == AppVisualStyle.deluxe ? AppStyle.deluxeText.withValues(alpha: 0.6) : AppStyle.textLight), fontSize: 13))
                      ]),
                    ),
                  )));
      }),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat, 
      floatingActionButton: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16), 
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween, 
          children: [
            Flexible(
              child: VolumeButton(
                onPressed: _quickChrono, 
                color: Theme.of(context).colorScheme.tertiary, 
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.play_circle_filled_rounded, size: 28, color: Colors.white), 
                    const SizedBox(width: 8), 
                    Flexible(child: Text(S.start, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: Colors.white), overflow: TextOverflow.ellipsis))
                  ]
                )
              ),
            ),
            const SizedBox(width: 12),
            Flexible(
              child: VolumeButton(
                onPressed: _newProjet, 
                color: Theme.of(context).colorScheme.primary, 
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.add_circle_outline_rounded, size: 24, color: Colors.white), 
                    const SizedBox(width: 8), 
                    Flexible(child: Text(S.newProject, style: const TextStyle(fontWeight: FontWeight.w700, color: Colors.white), overflow: TextOverflow.ellipsis))
                  ]
                )
              ),
            ),
          ]
        )
      )
    );
  }
}
class DialogChronoRapide extends StatefulWidget {
  final List<Projet> projets; final Function(String, String, int, double, int, int, String, List<Taxe>) onSave;
  const DialogChronoRapide({super.key, required this.projets, required this.onSave});
  @override State<DialogChronoRapide> createState() => _DialogChronoRapideState();
}
class _DialogChronoRapideState extends State<DialogChronoRapide> {
  Timer? _t; int _sec = 0; DateTime? _heureDemarrage; bool _actif = true; String? _pId; bool _newClient = false; bool _voirReglages = false; 
  bool _isFinalizing = false;
  final _nomCtrl = TextEditingController(); final _sessionNomCtrl = TextEditingController(); late TextEditingController _tauxCtrl; late TextEditingController _fraisCtrl; int _pal = Projet.palierParDefaut; int _seuil = Projet.seuilParDefaut;
  List<Taxe> _globalTaxes = [];
  final List<Taxe> _selectedTaxes = [];

  @override void initState() { 
    super.initState(); _tauxCtrl = TextEditingController(text: Projet.tauxParDefaut.toString().replaceAll(RegExp(r'\.0$'), '')); _fraisCtrl = TextEditingController(text: Projet.fraisParDefaut.toString().replaceAll(RegExp(r'\.0$'), '')); _chargerChronoSauvegarde();
    _t = Timer.periodic(const Duration(seconds: 1), (timer) { if (_actif && _heureDemarrage != null) { setState(() => _sec = DateTime.now().difference(_heureDemarrage!).inSeconds); } }); 
    _chargerTaxes();
  }

  Future<void> _chargerTaxes() async {
    final prefs = await SharedPreferences.getInstance();
    final taxesJson = prefs.getString('pro_taxes') ?? '[]';
    setState(() {
      _globalTaxes = (jsonDecode(taxesJson) as List).map((t) => Taxe.fromJson(t)).toList();
    });
  }

  Future<void> _chargerChronoSauvegarde() async {
    final prefs = await SharedPreferences.getInstance(); final hStr = prefs.getString('chrono_rapide_debut');
    if (hStr != null) { _heureDemarrage = DateTime.parse(hStr); _pId = prefs.getString('chrono_rapide_pid'); FlutterBackgroundService().startService(); Timer(const Duration(milliseconds: 300), () => FlutterBackgroundService().invoke('changerTitre', {'nom': '...'})); } 
    else { _heureDemarrage = DateTime.now(); await prefs.setString('chrono_rapide_debut', _heureDemarrage!.toIso8601String()); FlutterBackgroundService().startService(); Timer(const Duration(milliseconds: 300), () => FlutterBackgroundService().invoke('changerTitre', {'nom': '...'})); }
  }
  Future<void> _nettoyerChronoSauvegarde() async { final prefs = await SharedPreferences.getInstance(); await prefs.remove('chrono_rapide_debut'); await prefs.remove('chrono_rapide_pid'); }
  @override void dispose() { _t?.cancel(); FlutterBackgroundService().invoke('stopService'); _nomCtrl.dispose(); _sessionNomCtrl.dispose(); _tauxCtrl.dispose(); _fraisCtrl.dispose(); super.dispose(); }

  @override Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final style = AppStyle.visualStyle.value;
    final primaryColor = Theme.of(context).colorScheme.primary;
    final displayColor = Theme.of(context).colorScheme.tertiary;

    if (!_isFinalizing) {
      return AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Center(child: Text(S.inProgress, style: TextStyle(fontWeight: FontWeight.w800))),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(child: Text(Session.formater(_sec), style: TextStyle(fontSize: 62, fontWeight: FontWeight.w900, color: displayColor, letterSpacing: -1.5))),
          ],
        ),
        actions: [
          VolumeButton(mini: true, color: AppStyle.textLight, onPressed: () async { await _nettoyerChronoSauvegarde(); if (context.mounted) { Navigator.pop(context); } }, child: Text(S.cancel, style: const TextStyle(fontWeight: FontWeight.bold))),
          VolumeButton(mini: true, color: style == AppVisualStyle.deluxe ? AppStyle.deluxeButton : (Theme.of(context).colorScheme.secondary), onPressed: () => setState(() { _isFinalizing = true; _actif = false; }), child: Text(S.finish, style: TextStyle(fontWeight: FontWeight.w900, color: Colors.white)))
        ],
      );
    }

    return AlertDialog(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)), title: Center(child: Text(S.save, style: const TextStyle(fontWeight: FontWeight.w800))), content: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
      Center(child: Text(Session.formater(_sec), style: TextStyle(fontSize: 42, fontWeight: FontWeight.w900, color: displayColor, letterSpacing: -1.0))), const SizedBox(height: 20),
      DropdownButtonFormField<String>(initialValue: _pId, hint: Text(S.assignTo), decoration: const InputDecoration(border: OutlineInputBorder()), isExpanded: true, items: [...widget.projets.map((p) => DropdownMenuItem(value: p.id, child: Text(p.nom))), DropdownMenuItem(value: '__new__', child: Text(S.newProjectEllipsis))], onChanged: (v) async {
        _pId = v; final prefs = await SharedPreferences.getInstance(); if (v != null) { await prefs.setString('chrono_rapide_pid', v); }
        setState(() { _newClient = v == '__new__'; _voirReglages = _newClient; if (!_newClient && v != null) { final p = widget.projets.firstWhere((x) => x.id == v); _tauxCtrl.text = p.tauxHoraire.toString().replaceAll(RegExp(r'\.0$'), ''); _fraisCtrl.text = p.fraisFixes.toString().replaceAll(RegExp(r'\.0$'), ''); _pal = p.palierMinutes; _seuil = p.seuilMinutes; FlutterBackgroundService().invoke('changerTitre', {'nom': p.nom}); } }); 
      }),
      if (_newClient) Padding(padding: const EdgeInsets.only(top: 15), child: TextField(controller: _nomCtrl, onTap: () => _nomCtrl.selection = TextSelection(baseOffset: 0, extentOffset: _nomCtrl.text.length), decoration: InputDecoration(labelText: S.projectName, border: OutlineInputBorder()), textCapitalization: TextCapitalization.sentences)),
      const SizedBox(height: 15),
      TextField(controller: _sessionNomCtrl, decoration: InputDecoration(labelText: S.sessionTitle, border: OutlineInputBorder()), textCapitalization: TextCapitalization.sentences),
      if (_globalTaxes.isNotEmpty) ...[
        const SizedBox(height: 20),
        Center(child: Text(S.taxesToApply, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: AppStyle.textLight, letterSpacing: 1.2))),
        const SizedBox(height: 10),
        Center(
          child: Wrap(
            alignment: WrapAlignment.center,
            spacing: 8,
            runSpacing: 8,
            children: _globalTaxes.map((gt) {
              bool isSelected = _selectedTaxes.any((st) => st.nom == gt.nom);
              return InkWell(
                onTap: () {
                  setState(() {
                    if (!isSelected) {
                      _selectedTaxes.add(gt);
                    } else {
                      _selectedTaxes.removeWhere((st) => st.nom == gt.nom);
                    }
                  });
                },
                borderRadius: BorderRadius.circular(10),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected ? primaryColor : (isDark ? Colors.white.withValues(alpha: 0.05) : Colors.grey.withValues(alpha: 0.1)),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: isSelected ? primaryColor : (isDark ? Colors.white10 : Colors.black12), width: 1),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(gt.nom, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: isSelected ? Colors.white : (isDark ? Colors.white70 : AppStyle.textDark))),
                      Text("${gt.valeur}${gt.estPourcentage ? '%' : Projet.devise}", style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: isSelected ? Colors.white70 : AppStyle.textLight)),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
      if (_voirReglages) Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const SizedBox(height: 15), Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
          Column(children: [Text(S.hourlyRate, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: AppStyle.textLight, letterSpacing: 1)), RouletteMontant(valeur: double.tryParse(_tauxCtrl.text.replaceAll(',', '.')) ?? 0, suffixe: ' ${Projet.devise}/h', controller: _tauxCtrl, onChanged: (v) => setState(() {}), step: 5, width: 90, fontSize: 18, color: primaryColor)]),
          Column(children: [Text(S.fees, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: AppStyle.textLight, letterSpacing: 1)), RouletteMontant(valeur: double.tryParse(_fraisCtrl.text.replaceAll(',', '.')) ?? 0, suffixe: ' ${Projet.devise}', controller: _fraisCtrl, onChanged: (v) => setState(() {}), step: 5, width: 80, fontSize: 18, color: primaryColor)])]),
        const SizedBox(height: 20), Text('${S.billingStep} : ${_pal}m', style: const TextStyle(fontWeight: FontWeight.bold)), Slider(value: _pal.toDouble(), min: 1, max: 60, activeColor: primaryColor, onChanged: (v) => setState(() { _pal = v.round(); if (_seuil > _pal) { _seuil = _pal; } })), const SizedBox(height: 5), Text('${S.minTimeBeforeStep} : ${_seuil}m', style: const TextStyle(fontWeight: FontWeight.bold)), Slider(value: _seuil.toDouble(), min: 0, max: _pal.toDouble(), activeColor: Theme.of(context).colorScheme.secondary, onChanged: _pal == 1 ? null : (v) => setState(() => _seuil = v.round()))])])), actions: [
        VolumeButton(mini: true, color: AppStyle.textLight, onPressed: () => setState(() { _isFinalizing = false; _actif = true; _heureDemarrage = DateTime.now().subtract(Duration(seconds: _sec)); }), child: const Icon(Icons.arrow_back_rounded, color: Colors.white)),
        VolumeButton(mini: true, color: style == AppVisualStyle.deluxe ? AppStyle.deluxeButton : (Theme.of(context).colorScheme.secondary), onPressed: () { _nettoyerChronoSauvegarde(); widget.onSave(_pId ?? '__new__', _nomCtrl.text, _sec, double.tryParse(_tauxCtrl.text.replaceAll(',', '.')) ?? Projet.tauxParDefaut, _pal, _seuil, _sessionNomCtrl.text, _selectedTaxes); Navigator.pop(context); }, child: Text(S.save, style: TextStyle(fontWeight: FontWeight.w900, color: Colors.white)))
      ]);
  }
}

class EcranTimer extends StatefulWidget {
  final Projet projet; final List<Projet> tousLesProjets; final Function(Session, Projet) onTransferer; final VoidCallback onSave;
  const EcranTimer({super.key, required this.projet, required this.tousLesProjets, required this.onTransferer, required this.onSave});
  @override State<EcranTimer> createState() => _EcranTimerState();
}
class _EcranTimerState extends State<EcranTimer> {
  Timer? _timer; bool _estActif = false; final ValueNotifier<int> _secCoursNotifier = ValueNotifier<int>(0); int _secSauvegardees = 0; int _secRemisesSession = 0; DateTime? _hDemarrage; late TextEditingController _txCtrl;
  bool _hasGlobalTaxes = false;
  List<Taxe> _globalTaxesList = [];

  @override void initState() { 
    super.initState(); 
    _txCtrl = TextEditingController(text: widget.projet.tauxHoraire.toString().replaceAll(RegExp(r'\.0$'), '')); 
    _verifierTaxesGlobales();
  }

  Future<void> _verifierTaxesGlobales() async {
    final prefs = await SharedPreferences.getInstance();
    final taxesJson = prefs.getString('pro_taxes') ?? '[]';
    final List decoded = jsonDecode(taxesJson);
    if (mounted) {
      setState(() {
        _globalTaxesList = decoded.map((t) => Taxe.fromJson(t)).toList();
        _hasGlobalTaxes = _globalTaxesList.isNotEmpty;
      });
    }
  }

  @override void dispose() { _timer?.cancel(); _secCoursNotifier.dispose(); _txCtrl.dispose(); super.dispose(); }

  Future<pw.Document> _construireDocumentPDF() async {
    final prefs = await SharedPreferences.getInstance();
    final pdf = pw.Document();
    
    final proNom = prefs.getString('pro_nom') ?? '';
    final proAdresse = prefs.getString('pro_adresse') ?? '';
    final proEmail = prefs.getString('pro_email') ?? '';
    final proTel = prefs.getString('pro_tel') ?? '';
    final proLabel = prefs.getString('pro_label_id') ?? 'TVA';
    final proVal = prefs.getString('pro_valeur_id') ?? '';
    final proBanque = prefs.getString('pro_banque') ?? '';
    final proMentions = prefs.getString('pro_mentions') ?? '';

    
    final sessionsTravail = widget.projet.sessions.where((s) => !s.estFrais && !s.estRemise).toList();
    final sessionsRemise = widget.projet.sessions.where((s) => s.estRemise).toList();
    final sessionsFrais = widget.projet.sessions.where((s) => s.estFrais && !s.estRemise && s.prix > 0).toList();

    double totalRemises = 0;
    for (var s in sessionsRemise) { totalRemises += s.prix; }
    int secondesRemises = 0;
    for (var s in sessionsRemise) { secondesRemises += s.secondesReelles; }
    double totalHT = 0;
    for (var s in widget.projet.sessions) { if (!s.estRemise) totalHT += s.prix; }
    totalHT -= totalRemises;

    
    Map<String, double> taxesCumulees = {};
    bool aDesTaxes = false;
    for (var s in widget.projet.sessions.where((s) => !s.estRemise)) {
      if (s.taxesAppliquees.isNotEmpty) aDesTaxes = true;
      for (var t in s.taxesAppliquees) {
        double montantTaxe = t.estPourcentage ? (s.prix * t.valeur / 100) : t.valeur;
        taxesCumulees[t.nom] = (taxesCumulees[t.nom] ?? 0) + montantTaxe;
      }
    }

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (context) => [
          
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  if (proNom.isNotEmpty) pw.Text(proNom, style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 16)),
                  if (proAdresse.isNotEmpty) pw.Text(proAdresse, style: const pw.TextStyle(fontSize: 10)),
                  if (proEmail.isNotEmpty) pw.Text(proEmail, style: const pw.TextStyle(fontSize: 10)),
                  if (proTel.isNotEmpty) pw.Text(proTel, style: const pw.TextStyle(fontSize: 10)),
                  if (proVal.isNotEmpty) pw.Text("$proLabel : $proVal", style: const pw.TextStyle(fontSize: 10)),
                ],
              ),
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.end,
                children: [
                  pw.Text(S.invoice, style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 22, color: PdfColors.blueGrey)),
                  pw.Text("${S.date} : ${DateTime.now().day.toString().padLeft(2,'0')}/${DateTime.now().month.toString().padLeft(2,'0')}/${DateTime.now().year}"),
                  pw.SizedBox(height: 15),
                  if (widget.projet.clientNom.isNotEmpty) ...[
                    pw.Text(S.invoiceClientLabel, style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10)),
                    pw.Text(widget.projet.clientNom, style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                  ],
                  if (widget.projet.clientAdresse.isNotEmpty) pw.Text(widget.projet.clientAdresse, style: const pw.TextStyle(fontSize: 10)),
                  if (widget.projet.clientEmail.isNotEmpty) pw.Text(widget.projet.clientEmail, style: const pw.TextStyle(fontSize: 10)),
                  if (widget.projet.clientTel.isNotEmpty) pw.Text(widget.projet.clientTel, style: const pw.TextStyle(fontSize: 10)),
                  if (widget.projet.clientIdentifiant.isNotEmpty) pw.Text(widget.projet.clientIdentifiant, style: const pw.TextStyle(fontSize: 10)),
                ],
              ),
            ],
          ),
          pw.SizedBox(height: 30),

          
          pw.TableHelper.fromTextArray(
            border: null,
            headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.white),
            headerDecoration: const pw.BoxDecoration(color: PdfColors.blueGrey800),
            cellHeight: 25,
            cellAlignments: {
              0: pw.Alignment.center,
              1: pw.Alignment.centerLeft,
              2: pw.Alignment.center,
              if (aDesTaxes) 3: pw.Alignment.center,
              aDesTaxes ? 4 : 3: pw.Alignment.centerRight,
            },
            headers: [S.date, S.description, S.duration, if (aDesTaxes) S.tax, S.amountHT],
            data: sessionsTravail.map((s) => [
              s.dateFormatee,
              s.titre,
              Session.formaterSansSecondes(s.secondesFacturees),
              if (aDesTaxes) s.taxesAppliquees.map((t) => "${t.valeur}${t.estPourcentage ? '%' : Projet.devise}").join(', '),
              "${AppStyle.n(s.prix)} ${Projet.devise}"
            ]).toList(),
          ),

          
          if (sessionsFrais.isNotEmpty) ...[
            pw.SizedBox(height: 10),
            pw.Align(alignment: pw.Alignment.centerLeft, child: pw.Text(S.additionalFeesPdf, style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10))),
            pw.TableHelper.fromTextArray(
              border: null,
              cellHeight: 20,
              cellAlignments: {
                0: pw.Alignment.centerLeft, 
                if (aDesTaxes) 1: pw.Alignment.center,
                aDesTaxes ? 2 : 1: pw.Alignment.centerRight
              },
              headers: aDesTaxes ? ['', '', ''] : ['', ''], // Pas de headers pour les frais annexes mais alignement respecté
              data: sessionsFrais.map((s) => [
                s.titre, 
                if (aDesTaxes) s.taxesAppliquees.map((t) => "${t.valeur}${t.estPourcentage ? '%' : Projet.devise}").join(', '),
                "${AppStyle.n(s.prix)} ${Projet.devise}"
              ]).toList(),
            ),
          ],

          pw.Divider(thickness: 1, color: PdfColors.grey300),
          
          
          pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              
              pw.Expanded(
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    if (totalRemises > 0) ...[
                      pw.SizedBox(height: 5),
                      pw.Text(S.commercialGestures, style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10, color: PdfColors.blueGrey700)),
                      pw.Text("${S.freeTime} ${Session.formaterSansSecondes(secondesRemises)}", style: const pw.TextStyle(fontSize: 9, color: PdfColors.blueGrey600)),
                      pw.Text("- ${AppStyle.n(totalRemises)} ${Projet.devise}", style: pw.TextStyle(color: PdfColors.blueGrey700, fontSize: 12)),
                    ],
                  ],
                ),
              ),
              
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.end,
                children: [
                  pw.Text("${S.totalHT} ${AppStyle.n(totalHT)} ${Projet.devise}"),
                  ...taxesCumulees.entries.map((e) => pw.Text("${e.key} : ${AppStyle.n(e.value)} ${Projet.devise}")),
                  pw.SizedBox(height: 5),
                  pw.Container(
                    padding: const pw.EdgeInsets.all(6),
                    decoration: const pw.BoxDecoration(color: PdfColors.grey100),
                    child: pw.Text("${S.totalTTC} ${AppStyle.n(widget.projet.prixTotalHistorique)} ${Projet.devise}",
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 14)),
                  ),
                ],
              ),
            ],
          ),

          
          pw.SizedBox(height: 50),
          if (widget.projet.clientModalitesPaiement.trim().isNotEmpty) ...[
            pw.Text(S.paymentTerms.toUpperCase(), style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10)),
            pw.Container(
              width: double.infinity,
              padding: const pw.EdgeInsets.all(8),
              decoration: pw.BoxDecoration(border: pw.Border.all(color: PdfColors.grey200)),
              child: pw.Text(widget.projet.clientModalitesPaiement.trim(), style: const pw.TextStyle(fontSize: 9)),
            ),
            pw.SizedBox(height: 15),
          ],
          if (proBanque.trim().isNotEmpty) ...[
            pw.Text(S.bankInfo.toUpperCase(), style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10)),
            pw.Container(
              width: double.infinity,
              padding: const pw.EdgeInsets.all(8),
              decoration: pw.BoxDecoration(border: pw.Border.all(color: PdfColors.grey200)),
              child: pw.Text(proBanque.trim(), style: const pw.TextStyle(fontSize: 9)),
            ),
            pw.SizedBox(height: 15),
          ],
          if (proMentions.trim().isNotEmpty) ...[
            pw.Text(proMentions.trim(), style: pw.TextStyle(fontSize: 8, fontStyle: pw.FontStyle.italic, color: PdfColors.grey700)),
          ],
        ],
      ),
    );
    return pdf;
  }

  Future<void> _genererFacturePDF() async {
    try {
      final pdf = await _construireDocumentPDF();
      await Printing.layoutPdf(onLayout: (PdfPageFormat format) async => pdf.save());
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("${S.pdfError} $e"), backgroundColor: Colors.red));
    }
  }

  Future<void> _exporterProjetJSON({bool saveAsFile = false}) async { 
    try { 
      final now = DateTime.now();
      final dateStr = '${now.day.toString().padLeft(2, '0')}${now.month.toString().padLeft(2, '0')}${now.year.toString().substring(2)}';
      final fileName = 'ignitebill_${widget.projet.nom}_$dateStr.json';

      final jsonStr = jsonEncode([widget.projet.toJson()]); 
      final directory = await getTemporaryDirectory(); 
      final file = File('${directory.path}/$fileName'); 
      await file.writeAsString(jsonStr); 
      
      if (saveAsFile) {
        String? result = await FilePicker.platform.saveFile(
          fileName: fileName,
          type: FileType.custom,
          allowedExtensions: ['json'],
          bytes: await file.readAsBytes(),
        );
        if (result != null) {
          if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(S.projectExportedJson)));
        }
      } else {
        await Share.shareXFiles([XFile(file.path)], text: 'Export JSON');
      }
    } catch (e) { if (mounted) { ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("${S.errorPrefix}$e"), backgroundColor: Colors.red)); } } 
  }
  Future<void> _exporterProjetCSV({bool saveAsFile = false}) async { 
    try { 
      final now = DateTime.now();
      final dateStr = '${now.day.toString().padLeft(2, '0')}${now.month.toString().padLeft(2, '0')}${now.year.toString().substring(2)}';
      final fileName = 'ignitebill_${widget.projet.nom}_$dateStr.csv';

      String csv = "Projet;Date;Titre;Type;Duree Facturee;Prix\n"; 
      for (var s in widget.projet.sessions) { 
        String type = s.estRemise ? S.discount : (s.estFrais ? S.fees : S.work); 
        String duree = s.estFrais ? "-" : Session.formater(s.secondesFacturees); 
        csv += "${widget.projet.nom};${s.dateFormatee};${s.titre};$type;$duree;${AppStyle.n(s.prix)} ${Projet.devise}\n"; 
      } 
      final directory = await getTemporaryDirectory(); 
      final file = File('${directory.path}/$fileName'); 
      await file.writeAsString(csv); 
      
      if (saveAsFile) {
        String? result = await FilePicker.platform.saveFile(
          fileName: fileName,
          type: FileType.custom,
          allowedExtensions: ['csv'],
          bytes: await file.readAsBytes(),
        );
        if (result != null) {
          if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(S.projectExportedCsv)));
        }
      } else {
        await Share.shareXFiles([XFile(file.path)], text: "${S.projectCsvExportText} ${widget.projet.nom}");
      }
    } catch (e) { if (mounted) { ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("${S.errorPrefix}$e"), backgroundColor: Colors.red)); } } 
  }
  Future<void> _exporterProjetPDF({bool saveAsFile = false}) async { 
    try { 
      final now = DateTime.now();
      final dateStr = '${now.day.toString().padLeft(2, '0')}${now.month.toString().padLeft(2, '0')}${now.year.toString().substring(2)}';
      final fileName = 'ignitebill_${widget.projet.nom}_$dateStr.txt';

      String rapport = "RAPPORT DE FACTURATION - ${widget.projet.nom.toUpperCase()}\n======================\n\nTotal : ${AppStyle.n(widget.projet.prixTotalHistorique)} ${Projet.devise}\n----------------------\n"; 
      for (var s in widget.projet.sessions) { 
        rapport += "${s.dateFormatee} - ${s.titre} : ${AppStyle.n(s.prix)} ${Projet.devise}\n"; 
      } 
      final directory = await getTemporaryDirectory(); 
      final file = File('${directory.path}/$fileName'); 
      await file.writeAsString(rapport); 
      
      if (saveAsFile) {
        String? result = await FilePicker.platform.saveFile(
          fileName: fileName,
          type: FileType.custom,
          allowedExtensions: ['txt'],
          bytes: await file.readAsBytes(),
        );
        if (result != null) {
          if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(S.projectExportedText)));
        }
      } else {
        await Share.shareXFiles([XFile(file.path)], text: "${S.projectReportText} ${widget.projet.nom}");
      }
    } catch (e) { if (mounted) { ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("${S.errorPrefix}$e"), backgroundColor: Colors.red)); } }
  }

  void _basculerTimer() {
    if (_estActif) { _timer?.cancel(); FlutterBackgroundService().invoke('stopService'); if (_hDemarrage != null) { _secSauvegardees += DateTime.now().difference(_hDemarrage!).inSeconds; } setState(() { _estActif = false; _secCoursNotifier.value = _secSauvegardees; }); WidgetManager.update(false); }
    else { _hDemarrage = DateTime.now(); setState(() => _estActif = true); FlutterBackgroundService().startService(); Timer(const Duration(milliseconds: 500), () => FlutterBackgroundService().invoke('changerTitre', {'nom': widget.projet.nom})); _timer = Timer.periodic(const Duration(seconds: 1), (timer) { if (_estActif && _hDemarrage != null) { final s = _secSauvegardees + DateTime.now().difference(_hDemarrage!).inSeconds; _secCoursNotifier.value = s; if (s % 5 == 0) { WidgetManager.update(true, text: Session.formater(s)); } } }); WidgetManager.update(true); }
  }
  void _reinitialiserChrono() { _timer?.cancel(); FlutterBackgroundService().invoke('stopService'); setState(() { _secSauvegardees = 0; _secRemisesSession = 0; _hDemarrage = null; _estActif = false; _secCoursNotifier.value = 0; }); WidgetManager.update(false); }
  void _retirerPalier() { int pSec = widget.projet.palierMinutes * 60; if (_secCoursNotifier.value >= pSec) { setState(() { _secSauvegardees -= pSec; _secCoursNotifier.value -= pSec; _secRemisesSession += pSec; }); ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('-${widget.projet.palierMinutes} min'), duration: const Duration(seconds: 1))); } }
  void _enregistrerSession() async {
    final secActuelles = _secCoursNotifier.value; if (secActuelles == 0 && _secRemisesSession == 0) return;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final style = AppStyle.visualStyle.value;
    final primaryColor = Theme.of(context).colorScheme.primary;
    
    final prefs = await SharedPreferences.getInstance();
    final taxesJson = prefs.getString('pro_taxes') ?? '[]';
    List<Taxe> globalTaxes = (jsonDecode(taxesJson) as List).map((t) => Taxe.fromJson(t)).toList();
    List<Taxe> selectedTaxes = [];

    if (!mounted) return;
    final tc = TextEditingController(); 
    showDialog(context: context, builder: (c) => StatefulBuilder(builder: (ctx, setStateD) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      content: SingleChildScrollView(child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(controller: tc, onTap: () => tc.selection = TextSelection(baseOffset: 0, extentOffset: tc.text.length), decoration: InputDecoration(labelText: S.sessionTitle, border: const OutlineInputBorder())),
          if (globalTaxes.isNotEmpty) ...[
            const SizedBox(height: 20),
            Center(child: Text(S.taxesToApply, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: AppStyle.textLight, letterSpacing: 1.2))),
            const SizedBox(height: 10),
            Center(
              child: Wrap(
                alignment: WrapAlignment.center,
                spacing: 8,
                runSpacing: 8,
                children: globalTaxes.map((gt) {
                  bool isSelected = selectedTaxes.any((st) => st.nom == gt.nom);
                  return InkWell(
                    onTap: () {
                      setStateD(() {
                        if (!isSelected) {
                          selectedTaxes.add(gt);
                        } else {
                          selectedTaxes.removeWhere((st) => st.nom == gt.nom);
                        }
                      });
                    },
                    borderRadius: BorderRadius.circular(10),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected ? primaryColor : (isDark ? Colors.white.withValues(alpha: 0.05) : Colors.grey.withValues(alpha: 0.1)),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: isSelected ? primaryColor : (isDark ? Colors.white10 : Colors.black12), width: 1),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(gt.nom, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: isSelected ? Colors.white : (isDark ? Colors.white70 : AppStyle.textDark))),
                          Text("${gt.valeur}${gt.estPourcentage ? '%' : Projet.devise}", style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: isSelected ? Colors.white70 : AppStyle.textLight)),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ]
        ],
      )),
      actions: [
        VolumeButton(mini: true, color: AppStyle.textLight, onPressed: () => Navigator.pop(c), child: Text(S.cancel)), 
        VolumeButton(mini: true, color: style == AppVisualStyle.deluxe ? AppStyle.deluxeButton : (Theme.of(context).colorScheme.secondary), onPressed: () { 
          _timer?.cancel(); FlutterBackgroundService().invoke('stopService'); 
          int sf = widget.projet.calculerSecondesFacturees(secActuelles); 
          setState(() { 
            if (secActuelles > 0) { 
              widget.projet.sessions.insert(0, Session(
                id: DateTime.now().toString(), 
                date: DateTime.now(), 
                secondesReelles: secActuelles + _secRemisesSession, 
                secondesFacturees: sf, 
                prix: AppStyle.arondir((sf / 3600) * widget.projet.tauxHoraire), 
                titre: tc.text.isEmpty ? S.work : tc.text,
                taxes: List.from(selectedTaxes),
              )); 
            } 
            if (_secRemisesSession > 0) { 
              widget.projet.sessions.insert(0, Session(
                id: DateTime.now().toString(), 
                date: DateTime.now(), 
                secondesReelles: _secRemisesSession, 
                secondesFacturees: 0, 
                prix: AppStyle.arondir((_secRemisesSession / 3600) * widget.projet.tauxHoraire), 
                titre: S.discount, 
                estRemise: true
              )); 
            } 
            widget.projet.invalidate();
            _secSauvegardees = 0; _secRemisesSession = 0; _hDemarrage = null; _estActif = false; _secCoursNotifier.value = 0; 
          }); 
          WidgetManager.update(false); widget.onSave(); Navigator.pop(c); 
        }, child: Text(S.ok, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)))
      ]
    )));
  }
  void _ouvrirTransfertSession(Session s) {
    String? projetCibleId = widget.projet.id;
    showDialog(context: context, builder: (c) => StatefulBuilder(builder: (ctx, setStateD) => AlertDialog(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)), title: Center(child: Text(S.transferTo, style: TextStyle(fontWeight: FontWeight.bold))), content: Column(mainAxisSize: MainAxisSize.min, children: [Center(child: Text(S.transferAllSessionsTo, style: const TextStyle(fontSize: 13, color: AppStyle.textLight))), const SizedBox(height: 15), DropdownButtonFormField<String>(initialValue: projetCibleId, isExpanded: true, decoration: const InputDecoration(border: OutlineInputBorder(), isDense: true), items: [...widget.tousLesProjets.map((p) => DropdownMenuItem(value: p.id, child: Text(p.nom, overflow: TextOverflow.ellipsis))), DropdownMenuItem(value: 'new', child: Text(S.newProjectEllipsis))], onChanged: (v) => setStateD(() => projetCibleId = v))]),      actions: [VolumeButton(mini: true, color: AppStyle.textLight, onPressed: () => Navigator.pop(c), child: Text(S.cancel)), VolumeButton(mini: true, color: Theme.of(context).colorScheme.primary, onPressed: () async {
            if (projetCibleId != null && projetCibleId != widget.projet.id) {
              Projet? cible; if (projetCibleId == 'new') { final nCtrl = TextEditingController(); bool cree = await showDialog(context: context, builder: (c2) => AlertDialog(title: Text(S.newProject), content: TextField(controller: nCtrl, autofocus: true, decoration: InputDecoration(labelText: S.projectName)), actions: [VolumeButton(mini: true, color: AppStyle.textLight, onPressed: () => Navigator.pop(c2, false), child: Text(S.cancel)), VolumeButton(mini: true, color: Theme.of(context).colorScheme.secondary, onPressed: () => Navigator.pop(c2, true), child: Text(S.ok))])) ?? false; if (cree && nCtrl.text.trim().isNotEmpty) { cible = Projet(id: DateTime.now().toString(), nom: nCtrl.text.trim()); widget.tousLesProjets.add(cible); } } 
              else { cible = widget.tousLesProjets.firstWhere((p) => p.id == projetCibleId); }
              if (cible != null) { 
                setState(() {
                  widget.projet.sessions.remove(s); 
                  widget.projet.invalidate();
                  cible!.sessions.insert(0, s); 
                  cible.invalidate();
                });
                widget.onSave(); 
                if (mounted) { Navigator.of(context).pop(); } 
                return; 
              }
            }
            if (mounted) { Navigator.of(context).pop(); }
          }, child: Text(S.ok, style: TextStyle(color: Colors.white)))])));
  }

  void _ouvrirEditionSession(Session s) async {
    final prefs = await SharedPreferences.getInstance();
    final taxesJson = prefs.getString('pro_taxes') ?? '[]';
    List<Taxe> globalTaxes = (jsonDecode(taxesJson) as List).map((t) => Taxe.fromJson(t)).toList();

    final tc = TextEditingController(text: s.titre); final pc = TextEditingController(text: AppStyle.n(s.prix).replaceAll('.00', '')); final hc = TextEditingController(text: (s.secondesFacturees ~/ 3600).toString()); final mc = TextEditingController(text: ((s.secondesFacturees % 3600) ~/ 60).toString()); DateTime d = s.date;
    
    if (!mounted) return;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Theme.of(context).colorScheme.primary;

    showDialog(context: context, builder: (c) => StatefulBuilder(builder: (ctx, setStateD) => AlertDialog(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)), content: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [Expanded(child: TextField(controller: tc, onTap: () => tc.selection = TextSelection(baseOffset: 0, extentOffset: tc.text.length), decoration: InputDecoration(labelText: S.rename, border: const OutlineInputBorder()))), const SizedBox(width: 12), Column(mainAxisSize: MainAxisSize.min, children: [Text(S.moveSession, style: const TextStyle(fontSize: 8, color: AppStyle.textLight, fontWeight: FontWeight.w900, letterSpacing: 0.5)), IconButton(icon: Icon(Icons.drive_file_move_rounded, color: primaryColor, size: 24), onPressed: () { Navigator.pop(c); _ouvrirTransfertSession(s); }, padding: EdgeInsets.zero, constraints: const BoxConstraints())])]),
        const SizedBox(height: 12), Center(child: InkWell(onTap: () async { final nv = await showDatePicker(context: ctx, initialDate: d, firstDate: DateTime(2020), lastDate: DateTime(2030)); if (nv != null) { setStateD(() => d = nv); } }, borderRadius: BorderRadius.circular(12), child: Container(padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 20), decoration: BoxDecoration(border: Border.all(color: AppStyle.textLight.withValues(alpha: 0.2)), borderRadius: BorderRadius.circular(12)), child: Column(children: [Text(S.date, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: AppStyle.textLight, letterSpacing: 1.2)), const SizedBox(height: 4), Row(mainAxisSize: MainAxisSize.min, children: [Icon(Icons.calendar_month_rounded, color: primaryColor, size: 20), const SizedBox(width: 10), Text('${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: isDark ? Colors.white : AppStyle.textDark))])])))),
        if (!s.estFrais) Padding(padding: const EdgeInsets.only(top: 10), child: Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [RouletteMontant(valeur: double.tryParse(hc.text.replaceAll(',', '.')) ?? 0, suffixe: ' h', controller: hc, onChanged: (v) => setStateD(() {}), step: 1, fontSize: 20, width: 60, color: primaryColor), RouletteMontant(valeur: double.tryParse(mc.text.replaceAll(',', '.')) ?? 0, suffixe: ' m', controller: mc, onChanged: (v) => setStateD(() {}), step: 5, fontSize: 20, width: 60, color: primaryColor)])) else const SizedBox(height: 10),
        const SizedBox(height: 12), Center(child: Text(s.estFrais ? S.amountHT : "${S.realTimePrefix}${Session.formaterSansSecondes(s.secondesReelles)}", style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: AppStyle.textLight, letterSpacing: 1.2))), const SizedBox(height: 4), Center(child: RouletteMontant(valeur: double.tryParse(pc.text.replaceAll(',', '.')) ?? 0, suffixe: ' ${Projet.devise}', controller: pc, onChanged: (v) => setStateD(() {}), color: s.estRemise ? Theme.of(context).colorScheme.tertiary : (Theme.of(context).colorScheme.secondary), width: 90)),
        if (globalTaxes.isNotEmpty) ...[
          const Divider(height: 30),
          Center(child: Text(S.taxesToApply, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: AppStyle.textLight, letterSpacing: 1.2))),
          const SizedBox(height: 8),
          Center(
            child: Wrap(
              alignment: WrapAlignment.center,
              spacing: 8,
              runSpacing: 8,
              children: globalTaxes.map((gt) {
              bool isSelected = s.taxesAppliquees.any((st) => st.nom == gt.nom);
              return InkWell(
                onTap: () {
                  setStateD(() {
                    if (!isSelected) {
                      s.taxesAppliquees.add(gt);
                    } else {
                      s.taxesAppliquees.removeWhere((st) => st.nom == gt.nom);
                    }
                  });
                },
                borderRadius: BorderRadius.circular(10),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected ? primaryColor : (isDark ? Colors.white.withValues(alpha: 0.05) : Colors.grey.withValues(alpha: 0.1)),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: isSelected ? primaryColor : (isDark ? Colors.white10 : Colors.black12), width: 1),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(gt.nom, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: isSelected ? Colors.white : (isDark ? Colors.white70 : AppStyle.textDark))),
                      Text("${gt.valeur}${gt.estPourcentage ? '%' : Projet.devise}", style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: isSelected ? Colors.white70 : AppStyle.textLight)),
                    ],
                  ),
                ),
              );
            }).toList(),
            ),
          ),
          const SizedBox(height: 10),
          Center(
            child: Text("${S.totalWithTaxes}${AppStyle.n(s.totalAvecTaxes)} ${Projet.devise}", 
              style: TextStyle(fontWeight: FontWeight.w900, color: Theme.of(context).colorScheme.secondary)),
          ),
        ],
        const SizedBox(height: 10)])),
      actions: [VolumeButton(mini: true, color: Colors.red, onPressed: () { setState(() { widget.projet.sessions.remove(s); widget.projet.invalidate(); }); widget.onSave(); Navigator.pop(c); }, child: Text(S.delete, style: const TextStyle(color: Colors.white))), VolumeButton(mini: true, color: Theme.of(context).colorScheme.primary, onPressed: () { setState(() { s.titre = tc.text; s.date = d; s.prix = double.tryParse(pc.text.replaceAll(',', '.')) ?? s.prix; if (!s.estFrais) { if (s.estRemise) { s.secondesReelles = (int.tryParse(hc.text.replaceAll(',', '.')) ?? 0) * 3600 + (int.tryParse(mc.text.replaceAll(',', '.')) ?? 0) * 60; } else { s.secondesFacturees = (int.tryParse(hc.text.replaceAll(',', '.')) ?? 0) * 3600 + (int.tryParse(mc.text.replaceAll(',', '.')) ?? 0) * 60; } } widget.projet.invalidate(); }); widget.onSave(); Navigator.of(context).pop(); }, child: Text(S.save, style: const TextStyle(color: Colors.white)))])));
  }

  void _ajouterMenu(int type) {
    final tc = TextEditingController();
    final hc = TextEditingController(text: type == 0 ? '1' : widget.projet.fraisFixes.toString().replaceAll(RegExp(r'\.0$'), ''));
    final mc = TextEditingController(text: '0');
    DateTime d = DateTime.now();
    bool appliquerPaliers = true;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Theme.of(context).colorScheme.primary;

    showDialog(
      context: context,
      builder: (c) => StatefulBuilder(
        builder: (ctx, setStateD) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: tc,
                  onTap: () => tc.selection = TextSelection(baseOffset: 0, extentOffset: tc.text.length),
                  decoration: InputDecoration(labelText: type == 0 ? S.rename : S.description, border: const OutlineInputBorder()),
                ),
                const SizedBox(height: 10),
                Center(
                  child: InkWell(
                    onTap: () async {
                      final nv = await showDatePicker(context: ctx, initialDate: d, firstDate: DateTime(2020), lastDate: DateTime(2030));
                      if (nv != null) {
                        setStateD(() => d = nv);
                      }
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
                      decoration: BoxDecoration(border: Border.all(color: AppStyle.textLight.withValues(alpha: 0.2)), borderRadius: BorderRadius.circular(12)),
                      child: Column(
                        children: [
                          Text(S.date, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: AppStyle.textLight, letterSpacing: 1.2)),
                          const SizedBox(height: 4),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.calendar_month_rounded, color: primaryColor, size: 20),
                              const SizedBox(width: 10),
                              Text('${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: isDark ? Colors.white : AppStyle.textDark)),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                if (type == 0) ...[
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          children: [
                            Text(S.hours, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: AppStyle.textLight, letterSpacing: 1)),
                            RouletteMontant(
                              valeur: double.tryParse(hc.text.replaceAll(',', '.')) ?? 0,
                              suffixe: ' h',
                              controller: hc,
                              onChanged: (v) => setStateD(() {}),
                              step: 1,
                              fontSize: 20,
                              width: 60,
                              color: primaryColor,
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Column(
                          children: [
                            Text(S.minutes, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: AppStyle.textLight, letterSpacing: 1)),
                            RouletteMontant(
                              valeur: double.tryParse(mc.text.replaceAll(',', '.')) ?? 0,
                              suffixe: ' m',
                              controller: mc,
                              onChanged: (v) => setStateD(() {}),
                              step: 5,
                              fontSize: 20,
                              width: 60,
                              color: primaryColor,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(S.applySteps, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                    value: appliquerPaliers,
                    activeThumbColor: primaryColor,
                    onChanged: (v) => setStateD(() => appliquerPaliers = v),
                  ),
                ] else
                  Center(
                    child: Column(
                      children: [
                        Text(S.amountHT, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: AppStyle.textLight, letterSpacing: 1.2)),
                        RouletteMontant(
                          valeur: double.tryParse(hc.text.replaceAll(',', '.')) ?? 0,
                          suffixe: ' ${Projet.devise}',
                          controller: hc,
                          onChanged: (v) => setStateD(() {}),
                          step: 5,
                          width: 100,
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          actions: [
            VolumeButton(mini: true, color: AppStyle.textLight, onPressed: () => Navigator.pop(c), child: Text(S.cancel)),
            VolumeButton(
              mini: true,
              color: Theme.of(context).colorScheme.primary,
              onPressed: () {
                if (type == 0) {
                  int sec = ((double.tryParse(hc.text.replaceAll(',', '.')) ?? 0) * 3600).toInt() + ((double.tryParse(mc.text.replaceAll(',', '.')) ?? 0) * 60).toInt();
                  if (sec > 0) {
                    int sf = appliquerPaliers ? widget.projet.calculerSecondesFacturees(sec) : sec;
                    setState(() { 
                      widget.projet.sessions.insert(0, Session(id: DateTime.now().toString(), date: d, secondesReelles: sec, secondesFacturees: sf, prix: AppStyle.arondir((sf / 3600) * widget.projet.tauxHoraire), titre: tc.text.isEmpty ? S.work : tc.text));
                      widget.projet.invalidate();
                    });
                    widget.onSave();
                    Navigator.pop(c);
                  }
                } else {
                  double? px = double.tryParse(hc.text.replaceAll(',', '.'));
                  if (px != null) {
                    setState(() { 
                      widget.projet.sessions.insert(0, Session(id: DateTime.now().toString(), date: DateTime.now(), secondesReelles: 0, secondesFacturees: 0, prix: AppStyle.arondir(px), estFrais: true, titre: tc.text.isEmpty ? S.fees : tc.text));
                      widget.projet.invalidate();
                    });
                    widget.onSave();
                    Navigator.pop(c);
                  }
                }
              },
              child: Text(S.ok, style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  void _supprimerProjet() async {
    await showDialog<bool>(context: context, builder: (c) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text(widget.projet.estArchive ? S.unarchiveConfirmTitle : S.archiveConfirmTitle),
      content: Text(widget.projet.estArchive ? S.unarchiveWarning : S.archiveWarning),
      actionsPadding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
      actions: [
        Column(children: [
          SizedBox(width: double.infinity, child: VolumeButton(mini: true, color: Theme.of(context).colorScheme.primary, onPressed: () {
            setState(() { widget.projet.estArchive = !widget.projet.estArchive; });
            widget.onSave();
            Navigator.pop(c, true);
            Navigator.pop(context);
          }, child: Text(widget.projet.estArchive ? S.unarchive : S.archive, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white)))),
          const SizedBox(height: 8),
          SizedBox(width: double.infinity, child: VolumeButton(mini: true, color: AppStyle.textLight, onPressed: () => Navigator.pop(c, false), child: Text(S.cancel, textAlign: TextAlign.center))),
          const SizedBox(height: 8),
          SizedBox(width: double.infinity, child: VolumeButton(mini: true, color: Colors.red, onPressed: () {
            widget.tousLesProjets.remove(widget.projet);
            widget.onSave();
            Navigator.pop(c, true);
            Navigator.pop(context);
          }, child: Text(S.delete, textAlign: TextAlign.center, style: TextStyle(color: Colors.white)))),
        ])
      ]
    ));
  }

  void _afficherReglesProjet() {
    final primaryColor = Theme.of(context).colorScheme.primary;
    int pt = widget.projet.palierMinutes;
    int st = widget.projet.seuilMinutes;
    final frc = TextEditingController(text: widget.projet.fraisFixes.toString().replaceAll(RegExp(r'\.0$'), ''));

    showDialog(
      context: context,
      builder: (c) => StatefulBuilder(
        builder: (ctx, setD) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(child: Text(S.clientAndBilling, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: AppStyle.textLight, letterSpacing: 1.2))),
                const SizedBox(height: 15),
                VolumeButton(mini: true, color: primaryColor, onPressed: () {
                  final cn = TextEditingController(text: widget.projet.clientNom);
                  final ca = TextEditingController(text: widget.projet.clientAdresse);
                  final ci = TextEditingController(text: widget.projet.clientIdentifiant);
                  final ce = TextEditingController(text: widget.projet.clientEmail);
                  final ct = TextEditingController(text: widget.projet.clientTel);
                  final cp = TextEditingController(text: widget.projet.clientModalitesPaiement);
                  showDialog(context: context, builder: (ctx2) => AlertDialog(
                    title: Text(S.clientProfile),
                    content: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, children: [
                      TextField(controller: cn, decoration: InputDecoration(labelText: S.clientName, border: const OutlineInputBorder()), textCapitalization: TextCapitalization.words, maxLines: null, keyboardType: TextInputType.multiline),
                      const SizedBox(height: 10),
                      TextField(controller: ca, decoration: InputDecoration(labelText: S.clientAddress, border: const OutlineInputBorder()), maxLines: null, keyboardType: TextInputType.multiline),
                      const SizedBox(height: 10),
                      Row(children: [
                        Expanded(child: TextField(controller: ce, decoration: const InputDecoration(labelText: 'Email', border: OutlineInputBorder()), keyboardType: TextInputType.emailAddress)),
                        const SizedBox(width: 10),
                        Expanded(child: TextField(controller: ct, decoration: InputDecoration(labelText: S.phone, border: const OutlineInputBorder()), keyboardType: TextInputType.phone)),
                      ]),
                      const SizedBox(height: 10),
                      TextField(controller: ci, decoration: InputDecoration(labelText: S.clientIdentifierOptional, border: const OutlineInputBorder())),
                      const SizedBox(height: 10),
                      TextField(controller: cp, decoration: InputDecoration(labelText: S.paymentTerms, border: const OutlineInputBorder()), maxLines: null, keyboardType: TextInputType.multiline),
                    ])),
                    actions: [
                      VolumeButton(mini: true, color: Theme.of(context).colorScheme.secondary, onPressed: () {
                        setState(() {
                          widget.projet.clientNom = cn.text;
                          widget.projet.clientAdresse = ca.text;
                          widget.projet.clientIdentifiant = ci.text;
                          widget.projet.clientEmail = ce.text;
                          widget.projet.clientTel = ct.text;
                          widget.projet.clientModalitesPaiement = cp.text;
                        });
                        widget.onSave();
                        Navigator.pop(ctx2);
                      }, child: Text(S.ok, style: TextStyle(color: Colors.white)))
                    ],
                  ));
                }, child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Icon(widget.projet.clientNom.isEmpty ? Icons.person_add_rounded : Icons.check_circle_rounded, size: 18, color: Colors.white),
                  const SizedBox(width: 8),
                  Text(widget.projet.clientNom.isEmpty ? S.clientProfile : widget.projet.clientNom, style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis),
                ])),
                const SizedBox(height: 15),
                Row(children: [
                  Expanded(child: VolumeButton(mini: true, color: Colors.blueGrey, onPressed: () {
                    if (ProService.isPro.value) {
                      _genererFacturePDF();
                    } else {
                      showDialog(context: context, builder: (c) => const ProDialog());
                    }
                  }, child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [Stack(alignment: Alignment.topRight, children: [const Icon(Icons.print_rounded, size: 16, color: Colors.white), if (!ProService.isPro.value) const IgnorePointer(child: Icon(Icons.lock, size: 10, color: Colors.orange))]), const SizedBox(width: 6), Text(S.print, style: const TextStyle(fontSize: 10, color: Colors.white))]))),
                  const SizedBox(width: 8),
                  Expanded(child: VolumeButton(mini: true, color: Colors.blueGrey, onPressed: () async {
                    if (ProService.isPro.value) {
                      final pdf = await _construireDocumentPDF();
                      await Printing.sharePdf(bytes: await pdf.save(), filename: 'facture_${widget.projet.nom}.pdf');
                    } else {
                      showDialog(context: context, builder: (c) => const ProDialog());
                    }
                  }, child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [Stack(alignment: Alignment.topRight, children: [const Icon(Icons.share_rounded, size: 16, color: Colors.white), if (!ProService.isPro.value) const IgnorePointer(child: Icon(Icons.lock, size: 10, color: Colors.orange))]), const SizedBox(width: 6), Text(S.share, style: const TextStyle(fontSize: 10, color: Colors.white))]))),
                ]),
                const Divider(height: 30),
                Center(child: Text(S.pricingRules, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: AppStyle.textLight, letterSpacing: 1.2))),
                const SizedBox(height: 15),
                Center(
                  child: Column(
                    children: [
                      Text(S.feesTravel, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: AppStyle.textLight, letterSpacing: 1.2)),
                      RouletteMontant(
                        valeur: double.tryParse(frc.text.replaceAll(',', '.')) ?? 0,
                        suffixe: ' ${Projet.devise}',
                        controller: frc,
                        onChanged: (v) => setD(() {}),
                        step: 5,
                        width: 100,
                        color: primaryColor,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Text('${S.billingStep} : ${pt}m', style: const TextStyle(fontWeight: FontWeight.bold)),
                Slider(
                  value: pt.toDouble(),
                  min: 1,
                  max: 60,
                  activeColor: primaryColor,
                  onChanged: (v) => setD(() {
                    pt = v.round();
                    if (st > pt) {
                      st = pt;
                    }
                  }),
                ),
                const SizedBox(height: 5),
                Text('${S.minTimeBeforeStep} : ${st}m', style: const TextStyle(fontWeight: FontWeight.bold)),
                Slider(
                  value: st.toDouble(),
                  min: 0,
                  max: pt.toDouble(),
                  activeColor: Theme.of(context).colorScheme.secondary,
                  onChanged: pt == 1 ? null : (v) => setD(() => st = v.round()),
                ),
                const Divider(height: 30),
                Center(child: Text(S.backupWarningTitle, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: AppStyle.textLight, letterSpacing: 1.2))),
                const SizedBox(height: 15),
                Row(children: [
                  Expanded(child: VolumeButton(mini: true, color: Theme.of(context).colorScheme.secondary, onPressed: () { 
                    showModalBottomSheet(context: context, builder: (ctx) => SafeArea(child: Column(mainAxisSize: MainAxisSize.min, children: [
                      Padding(padding: const EdgeInsets.all(16), child: Text(S.shareProject, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey))),
                      ListTile(leading: const Icon(Icons.code_rounded), title: Text(S.formatJsonProject), onTap: () { Navigator.pop(ctx); _exporterProjetJSON(saveAsFile: false); }), 
                      ListTile(leading: const Icon(Icons.table_chart_rounded), title: Text(S.formatCsvExcel), onTap: () { Navigator.pop(ctx); _exporterProjetCSV(saveAsFile: false); }), 
                      ListTile(leading: const Icon(Icons.description_outlined), title: Text(S.textReport), onTap: () { Navigator.pop(ctx); _exporterProjetPDF(saveAsFile: false); }), 
                    ]))); 
                  }, child: Column(children: [const Icon(Icons.share_rounded, size: 20, color: Colors.white), Text(S.share, style: const TextStyle(fontSize: 10, color: Colors.white))]))),
                  const SizedBox(width: 8),
                  Expanded(child: VolumeButton(mini: true, color: Colors.blueGrey, onPressed: () { 
                    showModalBottomSheet(context: context, builder: (ctx) => SafeArea(child: Column(mainAxisSize: MainAxisSize.min, children: [
                      Padding(padding: const EdgeInsets.all(16), child: Text(S.saveProject, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey))),
                      ListTile(leading: const Icon(Icons.save_alt_rounded), title: Text(S.saveJson), onTap: () { Navigator.pop(ctx); _exporterProjetJSON(saveAsFile: true); }), 
                      ListTile(leading: const Icon(Icons.table_rows_rounded), title: Text(S.saveExcelCsv), onTap: () { Navigator.pop(ctx); _exporterProjetCSV(saveAsFile: true); }), 
                      ListTile(leading: const Icon(Icons.text_snippet_outlined), title: Text(S.saveTextReport), onTap: () { Navigator.pop(ctx); _exporterProjetPDF(saveAsFile: true); }), 
                    ]))); 
                  }, child: Column(children: [const Icon(Icons.save_rounded, size: 20, color: Colors.white), Text(S.save, style: const TextStyle(fontSize: 10, color: Colors.white))]))),
                ]),
              ],
            ),
          ),
          actions: [
            VolumeButton(
              mini: true,
              color: primaryColor,
              onPressed: () {
                setState(() {
                  widget.projet.palierMinutes = pt;
                  widget.projet.seuilMinutes = st;
                  widget.projet.fraisFixes = double.tryParse(frc.text.replaceAll(',', '.')) ?? widget.projet.fraisFixes;
                });
                widget.onSave();
                Navigator.pop(c);
              },
              child: Text(S.ok, style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  @override Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final style = AppStyle.visualStyle.value;
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Scaffold(
      appBar: AppBar(title: Text(widget.projet.nom), actions: [
        IconButton(
          tooltip: widget.projet.estArchive ? S.unarchive : S.archive,
          icon: const Icon(Icons.delete_sweep_rounded, color: Colors.redAccent),
          onPressed: _supprimerProjet,
        ),
        IconButton(icon: const Icon(Icons.tune_rounded), onPressed: _afficherReglesProjet)
      ]),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  if (widget.projet.clientNom.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Text("${S.invoiceClientLabel} ${widget.projet.clientNom.toUpperCase()}",
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: primaryColor, letterSpacing: 1.2)),
                    ),
                  Text(widget.projet.nomModeFacturation, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppStyle.textLight)), 
                  const SizedBox(height: 10),
                  ValueListenableBuilder<int>(
                    valueListenable: _secCoursNotifier,
                    builder: (context, sec, _) {
                      return InkWell(
                        onTap: () {
                          final hc = TextEditingController(text: (sec ~/ 3600).toString());
                          final mc = TextEditingController(text: ((sec % 3600) ~/ 60).toString()); 
                          showDialog(
                            context: context,
                            builder: (c) => StatefulBuilder(
                              builder: (ctx, setD) => AlertDialog(
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                title: Center(child: Text(S.catchUpTime, style: TextStyle(fontWeight: FontWeight.bold))),
                                content: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                      children: [
                                        RouletteMontant(valeur: double.tryParse(hc.text.replaceAll(',', '.')) ?? 0, suffixe: ' h', controller: hc, onChanged: (v) => setD(() {}), step: 1, fontSize: 24, width: 70, color: primaryColor),
                                        RouletteMontant(valeur: double.tryParse(mc.text.replaceAll(',', '.')) ?? 0, suffixe: ' m', controller: mc, onChanged: (v) => setD(() {}), step: 5, fontSize: 24, width: 70, color: primaryColor)
                                      ]
                                    )
                                  ]
                                ),
                                actions: [
                                  VolumeButton(mini: true, color: AppStyle.textLight, onPressed: () => Navigator.pop(c), child: Text(S.cancel)),
                                  VolumeButton(mini: true, color: primaryColor, onPressed: () {
                                    int ns = (int.tryParse(hc.text.replaceAll(',', '.'))??0)*3600 + (int.tryParse(mc.text.replaceAll(',', '.'))??0)*60;
                                    setState(() {
                                      _secSauvegardees = ns;
                                      _secCoursNotifier.value = ns;
                                      if (_estActif) { _hDemarrage = DateTime.now(); }
                                    });
                                    Navigator.pop(c);
                                  }, child: Text(S.ok, style: TextStyle(color: Colors.white)))
                                ]
                              )
                            )
                          );
                        },
                        child: Column(
                          children: [
                            Text(Session.formater(sec), style: TextStyle(fontSize: 68, fontWeight: FontWeight.w900, letterSpacing: -1.5, color: isDark ? Colors.white : AppStyle.textDark)),
                            Text(S.pressToCatchUp, style: const TextStyle(color: AppStyle.textLight, fontWeight: FontWeight.w700, fontSize: 13))
                          ]
                        )
                      );
                    }
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      VolumeButton(
                        onPressed: _basculerTimer,
                        color: _estActif ? (style == AppVisualStyle.deluxe ? AppStyle.deluxeOrange : const Color(0xFFF59E0B)) : primaryColor,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(_estActif ? Icons.pause_rounded : Icons.play_arrow_rounded, size: 28, color: Colors.white),
                            const SizedBox(width: 8),
                            Text(_estActif ? S.pause : S.resumeTimer, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Colors.white))
                          ]
                        )
                      )
                    ]
                  ),
                  ValueListenableBuilder<int>(
                    valueListenable: _secCoursNotifier,
                    builder: (context, sec, _) {
                      if (sec == 0 && _secRemisesSession == 0) { return const SizedBox.shrink(); }
                      return Padding(
                        padding: const EdgeInsets.only(top: 20),
                        child: Row(
                          children: [
                            Expanded(flex: 2, child: VolumeButton(onPressed: _enregistrerSession, color: style == AppVisualStyle.deluxe ? AppStyle.deluxeButton : (Theme.of(context).colorScheme.secondary), child: Text(S.save, style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900)))),
                            const SizedBox(width: 12),
                            Expanded(flex: 1, child: VolumeButton(onPressed: _reinitialiserChrono, color: Colors.red, child: Text(S.reset, style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900))))
                          ]
                        )
                      );
                    }
                  ),
                  const SizedBox(height: 32),
                  Stack(
                    alignment: Alignment.centerRight,
                    children: [
                      VolumeCard(
                        color: primaryColor,
                        child: Padding(
                          padding: const EdgeInsets.all(18),
                          child: Column(
                            children: [
                              Text(S.sessionTotal, style: TextStyle(fontWeight: FontWeight.w800, color: primaryColor, fontSize: 13, letterSpacing: 0.5)), 
                              ValueListenableBuilder<int>(
                                valueListenable: _secCoursNotifier,
                                builder: (context, sec, _) {
                                  double prix = (widget.projet.calculerSecondesFacturees(sec) / 3600) * widget.projet.tauxHoraire;
                                  return Text('${AppStyle.n(prix)} ${Projet.devise}', style: TextStyle(fontSize: 42, fontWeight: FontWeight.w900, color: Theme.of(context).colorScheme.secondary, letterSpacing: -0.5));
                                }
                              ),
                              Divider(color: isDark ? Colors.white10 : AppStyle.cardBorder),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(S.rateLabel, style: TextStyle(fontWeight: FontWeight.bold, color: isDark ? Colors.white : AppStyle.textDark)),
                                  RouletteMontant(valeur: widget.projet.tauxHoraire, suffixe: ' ${Projet.devise}/h', controller: _txCtrl, onChanged: (v) { setState(() { widget.projet.tauxHoraire = v; }); widget.onSave(); }, color: primaryColor)
                                ]
                              )
                            ]
                          )
                        )
                      ),
                      if (widget.projet.palierMinutes > 1)
                        Positioned(
                          right: 0,
                          child: Padding(
                            padding: const EdgeInsets.only(right: 4.0),
                            child: ValueListenableBuilder<int>(
                              valueListenable: _secCoursNotifier,
                              builder: (context, sec, _) {
                                return InkWell(
                                  onTap: sec >= widget.projet.palierMinutes * 60 ? _retirerPalier : null,
                                  borderRadius: BorderRadius.circular(40),
                                  child: Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle, boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.15), blurRadius: 10, offset: const Offset(0, 4))], border: Border.all(color: const Color(0xFFF59E0B).withValues(alpha: 0.3), width: 1.5)),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(Icons.card_giftcard_rounded, size: 30, color: Color(0xFFF59E0B)),
                                        Text('-${widget.projet.palierMinutes}m', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: Color(0xFFF59E0B)))
                                      ]
                                    )
                                  )
                                );
                              }
                            )
                          )
                        )
                    ]
                  ),
                  const SizedBox(height: 24),
                  ValueListenableBuilder<int>(
                    valueListenable: _secCoursNotifier,
                    builder: (context, sec, _) {
                      double prixS = (widget.projet.calculerSecondesFacturees(sec) / 3600) * widget.projet.tauxHoraire;
                      double totalHistorique = 0;
                      for (var s in widget.projet.sessions) {
                        if (s.estRemise) {
                          totalHistorique -= s.prix;
                        } else {
                          totalHistorique += (widget.projet.preferTTC ? s.totalAvecTaxes : s.prix);
                        }
                      }
                      
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text('${S.history} (${widget.projet.sessions.length})', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, letterSpacing: -0.5, color: isDark ? Colors.white : AppStyle.textDark)),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(S.total, style: TextStyle(color: AppStyle.textLight, fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 0.5)),
                                  Text('${AppStyle.n(totalHistorique + prixS)} ${Projet.devise}', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Theme.of(context).colorScheme.secondary, letterSpacing: -0.5))
                                ]
                              ),
                              if (_hasGlobalTaxes) ...[
                                const SizedBox(width: 10),
                                InkWell(
                                  onTap: () => setState(() { widget.projet.preferTTC = !widget.projet.preferTTC; widget.onSave(); }),
                                  borderRadius: BorderRadius.circular(8),
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 200),
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    margin: const EdgeInsets.only(bottom: 2),
                                    decoration: BoxDecoration(
                                      color: widget.projet.preferTTC ? primaryColor.withValues(alpha: 0.1) : Colors.grey.withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(color: widget.projet.preferTTC ? primaryColor : Colors.grey.withValues(alpha: 0.4), width: 1.5),
                                    ),
                                    child: Text(widget.projet.preferTTC ? "TTC" : "HT", style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: widget.projet.preferTTC ? primaryColor : Colors.grey)),
                                  ),
                                )
                              ]
                            ]
                          )
                        ]
                      );
                    }
                  )
                ]
              )
            )
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final s = widget.projet.sessions[index];
                final pColor = Theme.of(context).colorScheme.primary;
                return Dismissible(
                  key: Key('session_${s.id}'),
                  direction: DismissDirection.horizontal,
                  background: Container(padding: const EdgeInsets.symmetric(horizontal: 20), alignment: Alignment.centerLeft, decoration: BoxDecoration(color: pColor, borderRadius: BorderRadius.circular(12)), child: const Icon(Icons.drive_file_move_rounded, color: Colors.white)),
                  secondaryBackground: Container(padding: const EdgeInsets.symmetric(horizontal: 20), alignment: Alignment.centerRight, decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(12)), child: const Icon(Icons.delete_sweep_rounded, color: Colors.white)),
                  confirmDismiss: (direction) async {
                    if (direction == DismissDirection.startToEnd) {
                      _ouvrirTransfertSession(s);
                      return false;
                    } else {
                      bool delete = await showDialog(
                              context: context,
                              builder: (c) => AlertDialog(
                                  title: Text(S.delete),
                                  content: Text(S.deleteSessionConfirm),
                                  actions: [
                                    VolumeButton(mini: true, color: AppStyle.textLight, onPressed: () => Navigator.pop(c, false), child: Text(S.cancel)),
                                    VolumeButton(
                                        mini: true,
                                        color: Colors.red,
                                        onPressed: () => Navigator.pop(c, true),
                                        child: Text(S.delete, style: const TextStyle(color: Colors.white)))
                                  ])) ??
                          false;
                      if (delete) {
                        setState(() => widget.projet.sessions.remove(s));
                        widget.onSave();
                        return true;
                      }
                      return false;
                    }
                  },
                  child: VolumeCard(
                    color: s.estRemise ? Theme.of(context).colorScheme.tertiary : (s.estFrais ? (Theme.of(context).colorScheme.secondary) : pColor), 
                    onTap: () => _ouvrirEditionSession(s), 
                    child: ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: IconPop(icon: s.estRemise ? Icons.card_giftcard_rounded : (s.estFrais ? Icons.receipt_long_rounded : Icons.timer_rounded), color: s.estRemise ? Theme.of(context).colorScheme.tertiary : (s.estFrais ? (Theme.of(context).colorScheme.secondary) : pColor)),
                      title: Text(s.estRemise ? '${s.dateFormatee} • -${s.secondesReelles ~/ 60} min' : '${s.dateFormatee} • ${Session.formater(s.secondesFacturees)}', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: isDark ? Colors.white : AppStyle.textDark, letterSpacing: -0.5)),
                      subtitle: s.titre == S.work || s.titre == S.fees || s.titre == S.discount ? null : Text(s.titre, style: const TextStyle(fontWeight: FontWeight.w600, color: AppStyle.textLight)),
                      trailing: Text(s.estRemise ? '-${AppStyle.n(s.prix)} ${Projet.devise}' : '${AppStyle.n(widget.projet.preferTTC ? s.totalAvecTaxes : s.prix)} ${Projet.devise}', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: s.estRemise ? Theme.of(context).colorScheme.tertiary : (Theme.of(context).colorScheme.secondary), letterSpacing: -0.5))
                    )
                  )
                );
              },
              childCount: widget.projet.sessions.length
            )
          ),
          const SliverPadding(padding: EdgeInsets.only(bottom: 100)),
        ],
      ),
      floatingActionButton: style == AppVisualStyle.vibrant 
        ? FloatingActionButton(
            backgroundColor: Theme.of(context).colorScheme.primary,
            foregroundColor: Colors.white,
            elevation: 12,
            shape: const CircleBorder(),
            onPressed: () => _afficherMenuAjout(context),
            child: const Icon(Icons.add_rounded, size: 36),
          )
        : VolumeButton(
            isRound: true,
            color: Theme.of(context).colorScheme.primary,
            onPressed: () => _afficherMenuAjout(context),
            child: const Icon(Icons.add_rounded, size: 36, color: Colors.white),
          ),
    );
  }

  void _afficherMenuAjout(BuildContext context) {
    showModalBottomSheet(context: context, backgroundColor: Colors.transparent, elevation: 0, builder: (c) => Container(padding: const EdgeInsets.all(24), child: SafeArea(child: Column(mainAxisSize: MainAxisSize.min, children: [
                  Row(children: [
                      Expanded(child: VolumeButton(color: Theme.of(context).colorScheme.primary, onPressed: () { Navigator.pop(c); _ajouterMenu(0); }, child: Column(children: [Icon(Icons.timer_rounded, size: 32, color: Colors.white), SizedBox(height: 8), Text(S.manualTime, textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.w900, color: Colors.white, fontSize: 13))]))), const SizedBox(width: 16),
                      Expanded(child: VolumeButton(color: Theme.of(context).colorScheme.tertiary, onPressed: () { Navigator.pop(c); _ajouterMenu(1); }, child: Column(children: [Icon(Icons.receipt_long_rounded, size: 32, color: Colors.white), SizedBox(height: 8), Text(S.manualFee, textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.w900, color: Colors.white, fontSize: 13))])))]),
                  const SizedBox(height: 20)]))));
  }
}

class DialogRepriseChrono extends StatefulWidget {
  final Projet projet; final Session session; final VoidCallback onSave;
  const DialogRepriseChrono({super.key, required this.projet, required this.session, required this.onSave});
  @override State<DialogRepriseChrono> createState() => _DialogRepriseChronoState();
}
class _DialogRepriseChronoState extends State<DialogRepriseChrono> {
  Timer? _t; bool _a = true; late int _sec; DateTime? _h;
  @override void initState() { super.initState(); _sec = widget.session.secondesReelles; _h = DateTime.now(); FlutterBackgroundService().startService(); Timer(const Duration(milliseconds: 300), () => FlutterBackgroundService().invoke('changerTitre', {'nom': widget.projet.nom})); _t = Timer.periodic(const Duration(seconds: 1), (t) { if (_a) {
    setState(() { widget.session.secondesReelles = _sec + DateTime.now().difference(_h!).inSeconds; widget.session.secondesFacturees = widget.projet.calculerSecondesFacturees(widget.session.secondesReelles); widget.session.prix = AppStyle.arondir((widget.session.secondesFacturees / 3600) * widget.projet.tauxHoraire); });
  } }); }
  @override void dispose() { _t?.cancel(); FlutterBackgroundService().invoke('stopService'); widget.onSave(); super.dispose(); }
  @override Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final pColor = Theme.of(context).colorScheme.primary;
    return AlertDialog(title: Center(child: Text(widget.session.titre, style: TextStyle(color: isDark ? Colors.white : AppStyle.textDark))), content: Column(mainAxisSize: MainAxisSize.min, children: [Center(child: Text(Session.formater(widget.session.secondesReelles), style: TextStyle(fontSize: 48, fontWeight: FontWeight.w900, color: isDark ? Colors.white : AppStyle.textDark, letterSpacing: -1.5))), Center(child: Text('${AppStyle.n(widget.session.prix)} ${Projet.devise}', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.secondary)))]), actions: [Center(child: Row(mainAxisSize: MainAxisSize.min, children: [IconButton(icon: Icon(_a ? Icons.pause_circle_filled_rounded : Icons.play_circle_filled_rounded, size: 48, color: pColor), onPressed: () { setState(() { _a = !_a; if (_a) { _h = DateTime.now(); _sec = widget.session.secondesReelles; FlutterBackgroundService().startService(); } else { FlutterBackgroundService().invoke('stopService'); } }); }), const SizedBox(width: 20), VolumeButton(mini: true, color: Theme.of(context).colorScheme.secondary, onPressed: () { if (context.mounted) { Navigator.pop(context); } }, child: Text(S.finish, style: const TextStyle(color: Colors.white)))]))]); }
}
