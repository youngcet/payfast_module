import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:payfast/payfast.dart';

import 'hex-color.dart';

void main() {
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
  ));
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PayFast Widget',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or press Run > Flutter Hot Reload in a Flutter IDE). Notice that the
        // counter didn't reset back to zero; the application is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'PayFast Widget'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
   static const platform = MethodChannel('com.xdev.payfast/payment');
   Widget? _widget;
   var jData;
   bool showAppBar = true;
   String appBarTitle = '';
   String appBarBackgroundColor = '';
   Color spinnerColor = Colors.red;
   
  @override
  void initState() {
    platform.setMethodCallHandler(_receiveFromHost);
    super.initState();
  }

  void onPaymentCancelled() async {
    try {
      await platform.invokeMethod<void>('onPaymentCancelled');
    } on PlatformException catch (e) {
      debugPrint('Error during onPaymentCancelled: ${e.message}');
    }
  }

  void onPaymentCompleted() async{
    try {
      await platform.invokeMethod<void>('onPaymentCompleted');
    } on PlatformException catch (e) {
      debugPrint('Error during onPaymentCompleted: ${e.message}');
    }
  }

  Future<void> _receiveFromHost(MethodCall call) async {
    bool useSandBox = true;
    String passPhrase = '';
    dynamic paymentData;
    String onsiteActivationScriptUrl = '';
    String? payButtonText;
    String? onPaymentCancelledText;
    String? onPaymentCompletedText;
    String? paymentSummaryTitle;
    Color? paymentSummaryAmountColor;

    try {
      if (call.method == "initialise") {
        final String data = call.arguments;
        jData = await jsonDecode(data);

        useSandBox = jData['useSandBox'];
        passPhrase = jData['passPhrase'];
        paymentData = jData['data'];
        onsiteActivationScriptUrl = jData['onsiteActivationScriptUrl'];

        // optional parameters
        if (jData.containsKey('appBar')){
          showAppBar = jData['appBar']['show'];
          appBarTitle = jData['appBar']['title'];
          appBarBackgroundColor = jData['appBar']['backgroundColor'];
        }
        
        if (jData.containsKey('spinnerColor')){
          spinnerColor = HexColor(jData['spinnerColor']);
        }

        if (jData.containsKey('payButtonText')){
          payButtonText = jData['payButtonText'];
        }

        if (jData.containsKey('onPaymentCancelledText')){
          onPaymentCancelledText = jData['onPaymentCancelledText'];
        }

        if (jData.containsKey('onPaymentCompletedText')){
          onPaymentCompletedText = jData['onPaymentCompletedText'];
        }

        if (jData.containsKey('paymentSummaryTitle')){
          paymentSummaryTitle = jData['paymentSummaryTitle'];
        }

        if (jData.containsKey('paymentSummaryAmountColor')){
          paymentSummaryAmountColor = HexColor(jData['paymentSummaryAmountColor']);
        }

        try {
          setState(() {
            _widget = PayFast(
              useSandBox: useSandBox, 
              passPhrase: passPhrase, 
              data: paymentData, 
              onsiteActivationScriptUrl: onsiteActivationScriptUrl, 
              onPaymentCancelled: () => onPaymentCancelled(), 
              onPaymentCompleted: () => onPaymentCompleted(),
              payButtonText: payButtonText,
              onPaymentCancelledText: onPaymentCancelledText,
              onPaymentCompletedText: onPaymentCompletedText,
              paymentSummaryTitle: paymentSummaryTitle,
              paymentSummaryAmountColor: paymentSummaryAmountColor
            );
          });
        } catch (e, stackTrace) {
          debugPrint('Error during setState: $e');
          debugPrint('Stack trace: $stackTrace');
        }
      }
    } on PlatformException catch (error) {
      debugPrint('PlatformException: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: (showAppBar) ? AppBar(
        backgroundColor: (appBarBackgroundColor.isNotEmpty) ? HexColor(appBarBackgroundColor) : Colors.blue,
        title: (appBarTitle.isNotEmpty) ? Text(appBarTitle) : Text(widget.title),
      ) : null,
      body: Center(
        child: (_widget == null) 
        ? Container(
            width: 24,
            height: 24,
            padding: const EdgeInsets.all(2.0),
            child: CircularProgressIndicator(
              color: spinnerColor,
              strokeWidth: 3,
            ),
          )
        : _widget,
    ));
  }
}
