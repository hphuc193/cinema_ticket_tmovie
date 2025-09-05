import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class PayPalService {
  // Lấy credentials từ .env
  static String get _clientId => dotenv.env['PAYPAL_CLIENT_ID'] ?? '';
  static String get _clientSecret => dotenv.env['PAYPAL_CLIENT_SECRET'] ?? '';

  // Sandbox URLs
  static const String _baseUrl = 'https://api-m.sandbox.paypal.com';
  static String get _tokenUrl => '$_baseUrl/v1/oauth2/token';
  static String get _paymentUrl => '$_baseUrl/v1/payments/payment';

  /// Lấy access token từ PayPal
  Future<String?> getAccessToken() async {
    try {
      if (_clientId.isEmpty || _clientSecret.isEmpty) {
        debugPrint('❌ PayPal credentials missing in .env');
        return null;
      }

      final credentials = base64Encode(utf8.encode('$_clientId:$_clientSecret'));

      final response = await http.post(
        Uri.parse(_tokenUrl),
        headers: {
          'Accept': 'application/json',
          'Accept-Language': 'en_US',
          'Authorization': 'Basic $credentials',
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: 'grant_type=client_credentials',
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['access_token'];
      } else {
        debugPrint('❌ Failed to get token: ${response.body}');
        return null;
      }
    } catch (e) {
      debugPrint('❌ Exception getting token: $e');
      return null;
    }
  }

  /// Tạo một payment mới
  Future<Map<String, dynamic>?> createPayment({
    required double amount,
    required String currency,
    required String description,
    required String returnUrl,
    required String cancelUrl,
  }) async {
    try {
      final accessToken = await getAccessToken();
      if (accessToken == null) throw Exception('No access token');

      final paymentData = {
        'intent': 'sale',
        'payer': {'payment_method': 'paypal'},
        'transactions': [
          {
            'amount': {
              'total': amount.toStringAsFixed(2),
              'currency': currency,
            },
            'description': description,
          }
        ],
        'redirect_urls': {
          'return_url': returnUrl,
          'cancel_url': cancelUrl,
        },
      };

      final response = await http.post(
        Uri.parse(_paymentUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
        body: json.encode(paymentData),
      );

      if (response.statusCode == 201) {
        return json.decode(response.body);
      } else {
        debugPrint('❌ Failed to create payment: ${response.body}');
        return null;
      }
    } catch (e) {
      debugPrint('❌ Exception creating payment: $e');
      return null;
    }
  }

  /// Thực thi thanh toán
  Future<Map<String, dynamic>?> executePayment({
    required String paymentId,
    required String payerId,
  }) async {
    try {
      final accessToken = await getAccessToken();
      if (accessToken == null) throw Exception('No access token');

      final executeUrl = '$_paymentUrl/$paymentId/execute';
      final executeData = {'payer_id': payerId};

      final response = await http.post(
        Uri.parse(executeUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
        body: json.encode(executeData),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        debugPrint('❌ Failed to execute payment: ${response.body}');
        return null;
      }
    } catch (e) {
      debugPrint('❌ Exception executing payment: $e');
      return null;
    }
  }

  /// Lấy URL duyệt thanh toán
  String? getApprovalUrl(Map<String, dynamic> paymentData) {
    try {
      final links = paymentData['links'] as List<dynamic>?;
      if (links != null) {
        for (var link in links) {
          if (link['rel'] == 'approval_url') {
            return link['href'];
          }
        }
      }
      return null;
    } catch (e) {
      debugPrint('❌ Exception getting approval URL: $e');
      return null;
    }
  }

  /// Chuyển đổi tiền VND → USD
  double convertVndToUsd(double vndAmount) {
    const double exchangeRate = 24300.0;
    final usdAmount = vndAmount / exchangeRate;
    return usdAmount < 0.01 ? 0.01 : double.parse(usdAmount.toStringAsFixed(2));
  }
}
