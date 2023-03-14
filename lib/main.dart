import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter WebView Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Regency Alliance'),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  MyHomePageState createState() => MyHomePageState();
}

class MyHomePageState extends State<MyHomePage> {
  final Completer<WebViewController> webController =
      Completer<WebViewController>();

  bool isLoading = false;

  int loadingProgress = 0;

  String home = "https://ebsandbox.regencyalliance.com";
  @override
  void initState() {
    super.initState();
    // Enable virtual display.
    if (Platform.isAndroid) WebView.platform = SurfaceAndroidWebView();
  }

  Future<void> refresh() async {
    return await webController.future.then((value) => value.reload());
  }

  Future<void> goHome() async {
    return await webController.future.then((value) => value.loadUrl(home));
  }

  Future<NavigationDecision> getNavigationDelegate(
      NavigationRequest request) async {
    if (request.url.contains("ebusiness.regencyalliance.com")) {
      // 1
      return NavigationDecision.navigate;
    }

    if (!request.isForMainFrame) {
      // 2
      return NavigationDecision.navigate;
    }

    // 5
    return NavigationDecision.prevent;
  }

  JavascriptChannel _toasterJavascriptChannel(BuildContext context) {
    return JavascriptChannel(
        name: 'Toaster',
        onMessageReceived: (JavascriptMessage message) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(message.message)),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    // final Size size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(6.0),
        child: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          bottom: isLoading
              ? PreferredSize(
                  preferredSize: const Size.fromHeight(6.0),
                  child: LinearProgressIndicator(
                    backgroundColor: Colors.pink.withOpacity(0.3),
                    valueColor:
                        const AlwaysStoppedAnimation<Color>(Colors.pink),
                    value: loadingProgress / 100,
                  ),
                )
              : null,
          // title: const Center(
          //   child: Text(
          //     'RegencyAlliance',
          //     style: TextStyle(
          //       color: Colors.black,
          //     ),
          //   ),
          // ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        onTap: (index) async {
          if (index == 0) {
            await goHome();
          } else {
            await refresh();
          }
        },
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.black,
        elevation: 2,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: "Home",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.refresh),
            label: "Reload",
          ),
        ],
      ),
      body: Builder(builder: (context) {
        return WebView(
          gestureNavigationEnabled: true,
          initialUrl: home,
          onWebViewCreated: ((controller) =>
              webController.complete(controller)),
          allowsInlineMediaPlayback: true,
          javascriptMode: JavascriptMode.unrestricted,
          javascriptChannels: <JavascriptChannel>{
            _toasterJavascriptChannel(context),
          },
          onProgress: (progress) {
            setState(() {
              loadingProgress = progress;
            });
          },
          onPageStarted: (c) {
            setState(() {
              isLoading = true;
            });
          },
          onPageFinished: (c) {
            setState(() {
              isLoading = false;
            });
          },
        );
      }),
    );
  }
}
