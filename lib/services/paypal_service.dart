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

  /// Debug method để kiểm tra credentials
  void debugCredentials() {
    print('=== PAYPAL DEBUG ===');
    print('Client ID: ${_clientId.isNotEmpty ? "${_clientId.substring(0, 8)}..." : "EMPTY"}');
    print('Client Secret: ${_clientSecret.isNotEmpty ? "${_clientSecret.substring(0, 8)}..." : "EMPTY"}');
    print('Token URL: $_tokenUrl');
    print('Payment URL: $_paymentUrl');
    print('==================');
  }

  /// Lấy access token từ PayPal với debug chi tiết
  Future<String?> getAccessToken() async {
    debugCredentials();

    try {
      if (_clientId.isEmpty || _clientSecret.isEmpty) {
        print('PayPal credentials missing in .env');
        print('- Client ID empty: ${_clientId.isEmpty}');
        print('- Client Secret empty: ${_clientSecret.isEmpty}');
        return null;
      }

      print('Getting access token...');
      final credentials = base64Encode(utf8.encode('$_clientId:$_clientSecret'));
      print('✓ Credentials encoded');

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

      print('Token request sent');
      print('Status code: ${response.statusCode}');
      print('Response headers: ${response.headers}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final token = data['access_token'];
        print('Access token obtained successfully');
        print('Token: ${token?.substring(0, 20)}...');
        return token;
      } else {
        print('Failed to get token');
        print('Status: ${response.statusCode}');
        print('Body: ${response.body}');

        // Parse error details
        try {
          final errorData = json.decode(response.body);
          print('Error name: ${errorData['error']}');
          print('Error description: ${errorData['error_description']}');
        } catch (e) {
          print('Could not parse error response: $e');
        }
        return null;
      }
    } catch (e, stackTrace) {
      print('Exception getting token: $e');
      print('Stack trace: $stackTrace');
      return null;
    }
  }

  /// Tạo một payment mới với debug chi tiết
  Future<Map<String, dynamic>?> createPayment({
    required double amount,
    required String currency,
    required String description,
    required String returnUrl,
    required String cancelUrl,
  }) async {
    print('Creating payment...');
    print('Amount: $amount $currency');
    print('Description: $description');
    print('Return URL: $returnUrl');
    print('Cancel URL: $cancelUrl');

    try {
      final accessToken = await getAccessToken();
      if (accessToken == null) {
        print('No access token - cannot create payment');
        throw Exception('No access token');
      }

      print('Access token obtained, creating payment...');

      // Validate amount
      if (amount <= 0) {
        print('Invalid amount: $amount');
        throw Exception('Amount must be greater than 0');
      }

      // Format amount to 2 decimal places
      final formattedAmount = amount.toStringAsFixed(2);
      print('Formatted amount: $formattedAmount');

      final paymentData = {
        'intent': 'sale',
        'payer': {'payment_method': 'paypal'},
        'transactions': [
          {
            'amount': {
              'total': formattedAmount,
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

      print('Payment data: ${json.encode(paymentData)}');

      final response = await http.post(
        Uri.parse(_paymentUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
        body: json.encode(paymentData),
      );

      print('Payment request sent');
      print('Status code: ${response.statusCode}');
      print('Response headers: ${response.headers}');
      print('Response body: ${response.body}');

      if (response.statusCode == 201) {
        final responseData = json.decode(response.body);
        print('Payment created successfully');
        print('Payment ID: ${responseData['id']}');
        print('Approval URL: ${getApprovalUrl(responseData)}');
        return responseData;
      } else {
        print('Failed to create payment');
        print('Status: ${response.statusCode}');
        print('Body: ${response.body}');

        // Parse error details
        try {
          final errorData = json.decode(response.body);
          print('Error name: ${errorData['name']}');
          print('Error message: ${errorData['message']}');
          print('Error details: ${errorData['details']}');
        } catch (e) {
          print('Could not parse error response: $e');
        }
        return null;
      }
    } catch (e, stackTrace) {
      print('Exception creating payment: $e');
      print('Stack trace: $stackTrace');
      return null;
    }
  }

  /// Thực thi thanh toán
  Future<Map<String, dynamic>?> executePayment({
    required String paymentId,
    required String payerId,
  }) async {
    print('⚡ Executing payment...');
    print('Payment ID: $paymentId');
    print('Payer ID: $payerId');

    try {
      final accessToken = await getAccessToken();
      if (accessToken == null) throw Exception('No access token');

      final executeUrl = '$_paymentUrl/$paymentId/execute';
      final executeData = {'payer_id': payerId};

      print('Execute URL: $executeUrl');
      print('Execute data: ${json.encode(executeData)}');

      final response = await http.post(
        Uri.parse(executeUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
        body: json.encode(executeData),
      );

      print('xecute request sent');
      print('Status code: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        print('Payment executed successfully');
        print('State: ${responseData['state']}');
        return responseData;
      } else {
        print('Failed to execute payment');
        print('Status: ${response.statusCode}');
        print('Body: ${response.body}');
        return null;
      }
    } catch (e, stackTrace) {
      print('Exception executing payment: $e');
      print('Stack trace: $stackTrace');
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
            final approvalUrl = link['href'];
            print('🔗 Approval URL found: $approvalUrl');
            return approvalUrl;
          }
        }
      }
      print('No approval URL found in payment response');
      return null;
    } catch (e) {
      print('Exception getting approval URL: $e');
      return null;
    }
  }

  /// Chuyển đổi tiền VND → USD với debug
  double convertVndToUsd(double vndAmount) {
    const double exchangeRate = 24300.0;
    final usdAmount = vndAmount / exchangeRate;
    final finalAmount = usdAmount < 0.01 ? 0.01 : double.parse(usdAmount.toStringAsFixed(2));

    print('💱 Currency conversion:');
    print('  VND: ${vndAmount.toStringAsFixed(0)}');
    print('  Rate: $exchangeRate');
    print('  USD (raw): ${usdAmount.toStringAsFixed(4)}');
    print('  USD (final): $finalAmount');

    return finalAmount;
  }

  /// Test method để kiểm tra kết nối PayPal
  Future<bool> testConnection() async {
    print('🔧 Testing PayPal connection...');
    try {
      final token = await getAccessToken();
      if (token != null) {
        print('PayPal connection test successful');
        return true;
      } else {
        print('PayPal connection test failed');
        return false;
      }
    } catch (e) {
      print('PayPal connection test error: $e');
      return false;
    }
  }
}