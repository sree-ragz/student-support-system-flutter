import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';


class BrowserApp extends StatelessWidget {
   BrowserApp( {required this.value,super.key});
   final String value;
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home:WebViewScreen(value: value) ,
    );
  }
}

class WebViewScreen extends StatefulWidget {
  const WebViewScreen({required this.value,super.key});
final String value;
  @override
  State<WebViewScreen> createState() => _WebViewScreenState();
}

class _WebViewScreenState extends State<WebViewScreen> {
  InAppWebViewController? webViewController;
  var initialUrl="";
  var urlController=TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title:Text("S Cube Browser"),
      backgroundColor: Colors.deepPurple,),
      body: Column(
        children: [
          Expanded(
            child: 
          InAppWebView(
            onWebViewCreated: (controller)=>webViewController=controller,
            initialUrlRequest: URLRequest(url:Uri.parse(initialUrl+widget.value),
          ),),)
        ],
      ),
    );
    
  }
}
