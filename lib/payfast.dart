import 'package:flutter/material.dart';

class PayFast extends StatelessWidget {
  final String passPhrase;
  final bool useSandBox;
  final dynamic data;
  final Function onPaymentCancelled;
  final Function onPaymentCompleted;
  final String onsiteActivationScriptUrl;

  const PayFast({
    required this.useSandBox,
    required this.passPhrase,
    required this.data,
    required this.onsiteActivationScriptUrl,
    required this.onPaymentCancelled,
    required this.onPaymentCompleted,
    Key? key,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Material(
      child: Scaffold(
          body: Center(
              child: PayFast(
                data: data,
                passPhrase: passPhrase,
                useSandBox: useSandBox,
                onsiteActivationScriptUrl: onsiteActivationScriptUrl,
                onPaymentCancelled: () => onPaymentCancelled(), 
                onPaymentCompleted: () => onPaymentCompleted(),
          )
        )
      ),
    );
  }
}