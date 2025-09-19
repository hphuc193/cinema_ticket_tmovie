// lib/screens/paypal_checkout_screen.dart - Fixed navigation
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../services/paypal_service.dart';

class PayPalCheckoutScreen extends StatefulWidget {
  final double totalAmount;
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

// Updated PayPalCheckoutScreen với better context handling

class _PayPalCheckoutScreenState extends State<PayPalCheckoutScreen> {
  final PayPalService _paypalService = PayPalService();

  WebViewController? _webViewController;
  bool isLoading = true;
  bool hasError = false;
  String? errorMessage;
  String? approvalUrl;
  String? paymentId;
  bool _showDebugInfo = false;
  bool _isCallbackProcessed = false; // Prevent multiple callbacks

  @override
  void initState() {
    super.initState();
    _initPaymentFlow();
  }

  Future<void> _initPaymentFlow() async {
    try {
      await _initWebView();
      await _testConnection();
      await _createPayment();
    } catch (e) {
      _setError(e.toString());
    }
  }

  Future<void> _testConnection() async {
    print('Testing PayPal connection...');
    final isConnected = await _paypalService.testConnection();
    if (!isConnected) {
      _setError("Không thể kết nối đến PayPal. Kiểm tra credentials.");
      return;
    }
    print('PayPal connection OK');
  }

  Future<void> _initWebView() async {
    _webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..enableZoom(false)
      ..setBackgroundColor(Colors.white)
      ..setNavigationDelegate(
        NavigationDelegate(
          onNavigationRequest: (request) => _handleNavigation(request.url),
          onWebResourceError: (error) => _setError("WebView error: ${error.description}"),
          onPageFinished: (url) {
            print('Page finished loading: $url');
          },
        ),
      );
  }

  Future<void> _createPayment() async {
    if (!mounted) return;

    setState(() {
      isLoading = true;
      hasError = false;
    });

    try {
      print('Creating PayPal payment...');

      final usdAmount = _paypalService.convertVndToUsd(widget.totalAmount);
      print('Amount: VND ${widget.totalAmount} -> USD $usdAmount');

      if (usdAmount < 0.01) {
        throw Exception("Số tiền tối thiểu là 0.01 USD");
      }

      final paymentData = await _paypalService.createPayment(
        amount: usdAmount,
        currency: "USD",
        description: widget.description,
        returnUrl: "https://your-app.com/paypal/success",
        cancelUrl: "https://your-app.com/paypal/cancel",
      );

      if (paymentData == null) {
        throw Exception("Không tạo được Payment");
      }

      paymentId = paymentData["id"];
      approvalUrl = _paypalService.getApprovalUrl(paymentData);

      print('Payment ID: $paymentId');
      print('Approval URL: $approvalUrl');

      if (approvalUrl == null) {
        throw Exception("Không lấy được Approval URL");
      }

      if (mounted) {
        await _webViewController?.loadRequest(Uri.parse(approvalUrl!));
        setState(() => isLoading = false);
      }
    } catch (e, stackTrace) {
      print('Error creating payment: $e');
      print('Stack trace: $stackTrace');
      _setError("Lỗi tạo thanh toán: $e");
    }
  }

  NavigationDecision _handleNavigation(String url) {
    print('Navigation to: $url');

    // Prevent multiple callback processing
    if (_isCallbackProcessed) {
      print('Callback already processed, ignoring');
      return NavigationDecision.prevent;
    }

    if (url.contains("paypal/success")) {
      _isCallbackProcessed = true;
      final uri = Uri.parse(url);
      final payerId = uri.queryParameters["PayerID"];

      print('Success URL detected, PayerID: $payerId');

      if (paymentId != null && payerId != null) {
        _executePayment(payerId);
      } else {
        print('Missing payment info');
        _triggerError("Thiếu thông tin thanh toán");
      }
      return NavigationDecision.prevent;
    }

    if (url.contains("paypal/cancel")) {
      if (!_isCallbackProcessed) {
        _isCallbackProcessed = true;
        print('Cancel URL detected');
        _triggerCancel();
      }
      return NavigationDecision.prevent;
    }

    return NavigationDecision.navigate;
  }

  Future<void> _executePayment(String payerId) async {
    if (!mounted) return;

    try {
      setState(() => isLoading = true);

      print('Executing payment...');

      final result = await _paypalService.executePayment(
        paymentId: paymentId!,
        payerId: payerId,
      );

      if (!mounted) return;

      if (result != null && result["state"] == "approved") {
        print('Payment execution successful');

        // Add small delay to ensure everything is processed
        await Future.delayed(Duration(milliseconds: 300));

        if (mounted) {
          widget.onSuccess(result);
        }
      } else {
        print('Payment execution failed');
        _triggerError("Thanh toán thất bại - trạng thái không hợp lệ");
      }
    } catch (e, stackTrace) {
      print('Error executing payment: $e');
      print('Stack trace: $stackTrace');
      if (mounted) {
        _triggerError("Lỗi khi xác nhận thanh toán: $e");
      }
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  void _triggerError(String error) {
    if (!mounted || _isCallbackProcessed) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        widget.onError(error);
      }
    });
  }

  void _triggerCancel() {
    if (!mounted || _isCallbackProcessed) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        widget.onCancel();
      }
    });
  }

  void _setError(String msg) {
    print('Setting error: $msg');
    if (mounted) {
      setState(() {
        isLoading = false;
        hasError = true;
        errorMessage = msg;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (!_isCallbackProcessed) {
          _isCallbackProcessed = true;
          widget.onCancel();
        }
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Thanh toán PayPal"),
          backgroundColor: Colors.blue[700],
          foregroundColor: Colors.white,
          leading: IconButton(
            icon: const Icon(Icons.close),
            onPressed: () {
              if (!_isCallbackProcessed) {
                _isCallbackProcessed = true;
                widget.onCancel();
              }
            },
          ),
          actions: [
            IconButton(
              icon: Icon(_showDebugInfo ? Icons.bug_report : Icons.bug_report_outlined),
              onPressed: () {
                if (mounted) {
                  setState(() {
                    _showDebugInfo = !_showDebugInfo;
                  });
                }
              },
            ),
          ],
        ),
        body: Stack(
          children: [
            // Debug info
            if (_showDebugInfo)
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: Container(
                  color: Colors.black87,
                  padding: EdgeInsets.all(8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('DEBUG INFO', style: TextStyle(color: Colors.yellow, fontWeight: FontWeight.bold)),
                      Text('Payment ID: $paymentId', style: TextStyle(color: Colors.white)),
                      Text('Is Loading: $isLoading', style: TextStyle(color: Colors.white)),
                      Text('Has Error: $hasError', style: TextStyle(color: Colors.white)),
                      Text('Callback Processed: $_isCallbackProcessed', style: TextStyle(color: Colors.white)),
                    ],
                  ),
                ),
              ),

            // WebView
            if (!isLoading && !hasError && _webViewController != null)
              Padding(
                padding: EdgeInsets.only(top: _showDebugInfo ? 120 : 0),
                child: WebViewWidget(controller: _webViewController!),
              ),

            // Loading
            if (isLoading)
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('Đang xử lý thanh toán PayPal...'),
                  ],
                ),
              ),

            // Error
            if (hasError)
              Center(
                child: Container(
                  margin: EdgeInsets.all(16),
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.red[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.red[200]!),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.error, color: Colors.red, size: 50),
                      SizedBox(height: 16),
                      Text('Lỗi PayPal', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.red[800])),
                      SizedBox(height: 8),
                      Text(errorMessage ?? "Đã xảy ra lỗi", style: TextStyle(color: Colors.red[700]), textAlign: TextAlign.center),
                      SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ElevatedButton(
                            onPressed: () {
                              setState(() {
                                _isCallbackProcessed = false;
                              });
                              _initPaymentFlow();
                            },
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, foregroundColor: Colors.white),
                            child: Text("Thử lại"),
                          ),
                          TextButton(
                            onPressed: () {
                              if (!_isCallbackProcessed) {
                                _isCallbackProcessed = true;
                                widget.onCancel();
                              }
                            },
                            child: Text("Hủy"),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}