import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:webview_flutter/webview_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  Color themeColor = Colors.white;
  try {
    final configStr = await rootBundle.loadString('assets/config.json');
    final config = jsonDecode(configStr);
    final hex = config['themeColor'] as String?;
    if (hex != null) {
      themeColor = _parseHexColor(hex);
    }
  } catch (e) {
    debugPrint('Error loading config: $e');
  }

  final isDark = themeColor.computeLuminance() < 0.5;
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
    statusBarColor: themeColor,
    statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
    statusBarBrightness: isDark ? Brightness.dark : Brightness.light,
    systemNavigationBarColor: themeColor,
    systemNavigationBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
  ));

  runApp(MyApp(themeColor: themeColor));
}

Color _parseHexColor(String hex) {
  try {
    String cleanHex = hex.toUpperCase().replaceAll('#', '');
    if (cleanHex.length == 6) {
      cleanHex = 'FF$cleanHex';
    } else if (cleanHex.length == 3) {
      final r = cleanHex[0];
      final g = cleanHex[1];
      final b = cleanHex[2];
      cleanHex = 'FF$r$r$g$g$b$b';
    }
    return Color(int.parse(cleanHex, radix: 16));
  } catch (_) {
    final lower = hex.toLowerCase().trim();
    if (lower == 'white') return Colors.white;
    if (lower == 'black') return Colors.black;
    if (lower == 'red') return Colors.red;
    if (lower == 'blue') return Colors.blue;
    if (lower == 'green') return Colors.green;
    if (lower == 'yellow') return Colors.yellow;
    if (lower == 'grey' || lower == 'gray') return Colors.grey;
    return Colors.white;
  }
}

class MyApp extends StatelessWidget {
  final Color themeColor;
  const MyApp({super.key, required this.themeColor});

  @override
  Widget build(BuildContext context) {
    final isDark = themeColor.computeLuminance() < 0.5;
    return MaterialApp(
      title: 'App Wrapper',
      theme: ThemeData(
        useMaterial3: true,
        brightness: isDark ? Brightness.dark : Brightness.light,
        scaffoldBackgroundColor: themeColor,
      ),
      home: WebViewScreen(themeColor: themeColor),
      debugShowCheckedModeBanner: false,
    );
  }
}

class WebViewScreen extends StatefulWidget {
  final Color themeColor;
  const WebViewScreen({super.key, required this.themeColor});

  @override
  State<WebViewScreen> createState() => _WebViewScreenState();
}

class _WebViewScreenState extends State<WebViewScreen> {
  late final WebViewController _controller;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(widget.themeColor)
      ..loadFlutterAsset('assets/web/index.html');
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.themeColor.computeLuminance() < 0.5;
    final systemOverlayStyle = SystemUiOverlayStyle(
      statusBarColor: widget.themeColor,
      statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
      statusBarBrightness: isDark ? Brightness.dark : Brightness.light,
      systemNavigationBarColor: widget.themeColor,
      systemNavigationBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
      systemNavigationBarDividerColor: Colors.transparent,
    );

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: systemOverlayStyle,
      child: Scaffold(
        body: SafeArea(
          child: WebViewWidget(controller: _controller),
        ),
      ),
    );
  }
}
