import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class CreateAccountResponse {
  late String url;
  late bool success;
  late String id;

  CreateAccountResponse(String url, bool success, String id) {
    this.url = url;
    this.success = success;
    this.id = id;
  }
}

class CheckoutSessionResponse {
  late Map<String, dynamic> session;

  CheckoutSessionResponse(Map<String, dynamic> session) {
    this.session = session;
  }
}

class StripeBackendService {
  static String apiBase = 'https://petwatch-stripe-api.netlify.app/api/stripe';
  static String createAccountUrl =
      '${StripeBackendService.apiBase}/account?mobile=true';
  static Map<String, String> headers = {'Content-Type': 'application/json'};

  static Future<CreateAccountResponse> createSellerAccount() async {
    var url = Uri.parse(StripeBackendService.createAccountUrl);
    var response = await http.get(url, headers: StripeBackendService.headers);
    Map<String, dynamic> body = jsonDecode(response.body);
    return new CreateAccountResponse(body['url'], true, body["id"]);
  }
}

class GetConnectedDashboard {
  static String apiBase = 'https://petwatch-stripe-api.netlify.app/api/stripe';
  static Future<Map<String, dynamic>> getDashboard(
      String stripeExpressId) async {
    String url =
        "${GetConnectedDashboard.apiBase}/connect-dashboard?connectedStripeId=$stripeExpressId";
    var response = await http.get(Uri.parse(url));
    debugPrint(response.body.toString());
    Map<String, dynamic> body = jsonDecode(response.body);
    return body;
  }
}

class CreatePaymentSheet {
  static String apiBase = "https://petwatch-stripe-api.netlify.app/api/stripe";
  static Future<Map<String, dynamic>> getPaymentIntent(
      String expressId, int amount, String path, String email) async {
    bool hasAccount = false;
    String url =
        '${CreatePaymentSheet.apiBase}/payment-intent?account_id=$expressId&amount=$amount&email=$email';
    await FirebaseFirestore.instance.doc(path).get().then((value) {
      if (value.data()!['stripeCustomerId'] != null) {
        url += "&customer=${value.data()!['stripeCustomerId']}";
        debugPrint(url);
        hasAccount = true;
      }
    });
    var response = await http.get(Uri.parse(url));

    Map<String, dynamic> params = json.decode(response.body);
    if (!hasAccount) {
      FirebaseFirestore.instance
          .doc(path)
          .update({"stripeCustomerId": params['customer']});
    }

    return params;
  }
}
