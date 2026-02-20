import 'dart:convert';
import 'package:http/http.dart' as http;

class XenditService {
  XenditService(this.apiKey);

  final String apiKey;

  Map<String, String> _headers() {
    final basicAuth = base64Encode(utf8.encode('$apiKey:'));
    return {
      "Authorization": "Basic $basicAuth",
      "Content-Type": "application/json",
    };
  }

  Future<Map<String, dynamic>> createInvoice({
    required double amount,
    required String externalId,
    String description = "Order payment via Xendit",
  }) async {
    final url = Uri.parse("https://api.xendit.co/v2/invoices");

    final res = await http.post(
      url,
      headers: _headers(),
      body: jsonEncode({
        "external_id": externalId,
        "amount": amount,
        "description": description,
      }),
    );

    if (res.statusCode == 200 || res.statusCode == 201) {
      return jsonDecode(res.body) as Map<String, dynamic>;
    }
    throw Exception("Create invoice failed (${res.statusCode}): ${res.body}");
  }

  Future<Map<String, dynamic>> getInvoice(String invoiceId) async {
    final url = Uri.parse("https://api.xendit.co/v2/invoices/$invoiceId");

    final res = await http.get(url, headers: _headers());

    if (res.statusCode == 200) {
      return jsonDecode(res.body) as Map<String, dynamic>;
    }
    throw Exception("Get invoice failed (${res.statusCode}): ${res.body}");
  }
}