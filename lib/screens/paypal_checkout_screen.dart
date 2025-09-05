// lib/screens/paypal_checkout_screen.dart
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../services/paypal_service.dart';

class PayPalCheckoutScreen extends StatefulWidget {
  final double totalAmount; // số tiền VND
  final String description;
  final Function(Map<String, dynamic>) onSuccess;
  final Function(String) onError;
  final Function() onCancel;

  const PayPalCheckoutScreen({
    Key? key,
    required this.totalAmount,
    required this.description,
    required this.onSuccess,
    required this.onError,
    required this.onCancel,
  }) : super(key: key);

  @override
  State<PayPalCheckoutScreen> createState() => _PayPalCheckoutScreenState();
}

class _PayPalCheckoutScreenState extends State<PayPalCheckoutScreen> {
  final PayPalService _paypalService = PayPalService();

  WebViewController? _webViewController;
  bool isLoading = true;
  bool hasError = false;
  String? errorMessage;
  String? approvalUrl;
  String? paymentId;

  @override
  void initState() {
    super.initState();
    _initPaymentFlow();
  }

  /// Khởi tạo flow thanh toán
  Future<void> _initPaymentFlow() async {
    try {
      await _initWebView();
      await _createPayment();
    } catch (e) {
      _setError(e.toString());
    }
  }

  /// Chuẩn bị WebView
  Future<void> _initWebView() async {
    _webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..enableZoom(false)
      ..setBackgroundColor(Colors.white)
      ..setNavigationDelegate(
        NavigationDelegate(
          onNavigationRequest: (request) => _handleNavigation(request.url),
          onWebResourceError: (error) =>
              _setError("WebView error: ${error.description}"),
        ),
      );
  }

  /// Tạo payment trên PayPal
  Future<void> _createPayment() async {
    setState(() {
      isLoading = true;
      hasError = false;
    });

    try {
      final usdAmount = _paypalService.convertVndToUsd(widget.totalAmount);
      final paymentData = await _paypalService.createPayment(
        amount: usdAmount,
        currency: "USD",
        description: widget.description,
        returnUrl: "https://your-app.com/paypal/success",
        cancelUrl: "https://your-app.com/paypal/cancel",
      );

      if (paymentData == null) throw Exception("Không tạo được Payment");

      paymentId = paymentData["id"];
      approvalUrl = _paypalService.getApprovalUrl(paymentData);

      if (approvalUrl == null) {
        throw Exception("Không lấy được Approval URL");
      }

      await _webViewController?.loadRequest(Uri.parse(approvalUrl!));

      setState(() => isLoading = false);
    } catch (e) {
      _setError("Lỗi tạo thanh toán: $e");
    }
  }

  /// Xử lý khi điều hướng trong WebView
  NavigationDecision _handleNavigation(String url) {
    if (url.contains("paypal/success")) {
      final uri = Uri.parse(url);
      final payerId = uri.queryParameters["PayerID"];

      if (paymentId != null && payerId != null) {
        _executePayment(payerId);
      } else {
        widget.onError("Thiếu thông tin thanh toán");
      }
      return NavigationDecision.prevent;
    }

    if (url.contains("paypal/cancel")) {
      widget.onCancel();
      return NavigationDecision.prevent;
    }

    return NavigationDecision.navigate;
  }

  /// Thực hiện thanh toán
  /// Thực hiện thanh toán
  Future<void> _executePayment(String payerId) async {
    try {
      setState(() => isLoading = true);

      final result = await _paypalService.executePayment(
        paymentId: paymentId!,
        payerId: payerId,
      );

      if (result != null && result["state"] == "approved") {
        widget.onSuccess(result);
      } else {
        widget.onError("Thanh toán thất bại");
      }
    } catch (e) {
      widget.onError("Lỗi khi xác nhận thanh toán: $e");
    } finally {
      setState(() => isLoading = false);
    }
  }

  void _setError(String msg) {
    setState(() {
      isLoading = false;
      hasError = true;
      errorMessage = msg;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Thanh toán PayPal"),
        backgroundColor: Colors.blue[700],
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: widget.onCancel,
        ),
      ),
      body: Stack(
        children: [
          if (!isLoading && !hasError && _webViewController != null)
            WebViewWidget(controller: _webViewController!),

          if (isLoading)
            const Center(child: CircularProgressIndicator()),

          if (hasError)
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error, color: Colors.red, size: 50),
                  const SizedBox(height: 16),
                  Text(errorMessage ?? "Đã xảy ra lỗi"),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _initPaymentFlow,
                    child: const Text("Thử lại"),
                  ),
                  TextButton(
                    onPressed: widget.onCancel,
                    child: const Text("Hủy"),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
