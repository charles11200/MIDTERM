import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'xendit_service.dart';

class XenditInvoicePage extends StatefulWidget {
  const XenditInvoicePage({
    super.key,
    required this.apiKey,
    required this.invoiceId,
    required this.invoiceUrl,
  });

  final String apiKey;
  final String invoiceId;
  final String invoiceUrl;

  @override
  State<XenditInvoicePage> createState() => _XenditInvoicePageState();
}

class _XenditInvoicePageState extends State<XenditInvoicePage> {
  late final WebViewController _web;
  Timer? _pollTimer;

  String _status = "PENDING";

  @override
  void initState() {
    super.initState();

    _web = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..loadRequest(Uri.parse(widget.invoiceUrl));

    _startPolling();
  }

  void _startPolling() {
    _pollTimer?.cancel();
    _pollTimer = Timer.periodic(const Duration(seconds: 3), (_) async {
      if (!mounted) return;
      try {
        final invoice = await XenditService(widget.apiKey).getInvoice(widget.invoiceId);
        final status = (invoice["status"] ?? "PENDING").toString().toUpperCase();
        if (!mounted) return;

        setState(() => _status = status);

        if (status == "PAID" || status == "SETTLED") {
          _pollTimer?.cancel();
          // return paid=true to previous page
          Navigator.of(context).pop(true);
        }
      } catch (_) {
        // ignore temporary network errors
      }
    });
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text("Xendit ($_status)"),
        leading: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: () => Navigator.pop(context, false),
          child: const Icon(CupertinoIcons.back),
        ),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: () => Navigator.pop(context, false),
          child: const Icon(CupertinoIcons.xmark, color: CupertinoColors.systemRed),
        ),
      ),
      child: SafeArea(
        child: WebViewWidget(controller: _web),
      ),
    );
  }
}