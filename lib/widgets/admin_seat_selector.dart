// lib/widgets/admin_seat_selector.dart
import 'package:flutter/material.dart';

class AdminSeatSelector extends StatefulWidget {
  final Function(List<String>) onSeatsChanged;
  final List<String>? initialAvailableSeats;

  const AdminSeatSelector({
    Key? key,
    required this.onSeatsChanged,
    this.initialAvailableSeats,
  }) : super(key: key);

  @override
  _AdminSeatSelectorState createState() => _AdminSeatSelectorState();
}

class _AdminSeatSelectorState extends State<AdminSeatSelector> {
  late List<List<String>> seatLayout;
  Set<String> unavailableSeats = {}; // Ghế không khả dụng (được chọn để disable)
  Set<String> allSeats = {}; // Tất cả ghế trong layout
  bool _isDisposed = false;

  @override
  void initState() {
    super.initState();
    _initializeSeatLayout();
    _loadInitialUnavailableSeats();
  }

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }

  void _initializeSeatLayout() {
    seatLayout = [];
    allSeats = {};
    const rows = ['A', 'B', 'C', 'D', 'E', 'F', 'G', 'H'];

    for (String row in rows) {
      List<String> seatRow = [];
      for (int i = 1; i <= 12; i++) {
        String seatId = '$row$i';
        seatRow.add(seatId);
        allSeats.add(seatId);
      }
      seatLayout.add(seatRow);
    }
  }

  void _loadInitialUnavailableSeats() {
    if (widget.initialAvailableSeats != null) {
      final initialAvailable = widget.initialAvailableSeats!.toSet();
      unavailableSeats = allSeats.difference(initialAvailable);
    }

    // Delay notification để tránh lỗi setState trong build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_isDisposed) {
        _notifySeatsChanged();
      }
    });
  }

  void _safeSetState(VoidCallback fn) {
    if (!_isDisposed && mounted) {
      setState(fn);
    }
  }

  void _notifySeatsChanged() {
    if (_isDisposed || !mounted) return;

    final availableSeats = allSeats.difference(unavailableSeats).toList();
    availableSeats.sort(); // Sắp xếp A1, A2, A3, ... A12, B1, B2, ...

    try {
      widget.onSeatsChanged(availableSeats);
    } catch (e) {
      print('Error in onSeatsChanged callback: $e');
    }
  }

  void _toggleSeat(String seatId) {
    if (_isDisposed || !mounted) return;

    _safeSetState(() {
      if (unavailableSeats.contains(seatId)) {
        unavailableSeats.remove(seatId); // Làm cho ghế available
      } else {
        unavailableSeats.add(seatId); // Làm cho ghế unavailable
      }
    });

    // Delay notification to avoid build conflicts
    Future.microtask(() {
      if (!_isDisposed && mounted) {
        _notifySeatsChanged();
      }
    });
  }

  void _performQuickAction(VoidCallback action) {
    if (_isDisposed || !mounted) return;

    _safeSetState(action);

    Future.microtask(() {
      if (!_isDisposed && mounted) {
        _notifySeatsChanged();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isDisposed) {
      return Container();
    }

    final availableCount = allSeats.length - unavailableSeats.length;
    final unavailableCount = unavailableSeats.length;

    return Container(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header thông tin
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.blue[200]!),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.blue[700]),
                    SizedBox(width: 8),
                    Text(
                      'Cấu hình ghế ngồi',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.blue[800],
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8),
                Text(
                  'Nhấn vào ghế để chuyển đổi trạng thái khả dụng/không khả dụng',
                  style: TextStyle(color: Colors.blue[700], fontSize: 14),
                ),
                SizedBox(height: 8),
                Row(
                  children: [
                    Text('Ghế khả dụng: ', style: TextStyle(fontWeight: FontWeight.w500)),
                    Text('$availableCount', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                    SizedBox(width: 20),
                    Text('Không khả dụng: ', style: TextStyle(fontWeight: FontWeight.w500)),
                    Text('$unavailableCount', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                  ],
                ),
              ],
            ),
          ),

          SizedBox(height: 20),

          // Seat legend
          _buildSeatLegend(),

          SizedBox(height: 20),

          // Screen
          Container(
            width: double.infinity,
            height: 30,
            margin: EdgeInsets.only(bottom: 24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.grey[400]!, Colors.grey[200]!],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Center(
              child: Text(
                'MÀN HÌNH',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[700],
                ),
              ),
            ),
          ),

          // Seat layout
          Container(
            constraints: BoxConstraints(
              maxHeight: 400,
            ),
            child: SingleChildScrollView(
              child: _buildSeatLayout(),
            ),
          ),

          SizedBox(height: 20),

          // Quick actions
          _buildQuickActions(),
        ],
      ),
    );
  }

  Widget _buildSeatLegend() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildLegendItem(Colors.green, 'Khả dụng', Icons.event_seat),
          _buildLegendItem(Colors.red, 'Không khả dụng', Icons.event_seat),
        ],
      ),
    );
  }

  Widget _buildLegendItem(Color color, String label, IconData icon) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color, size: 20),
        SizedBox(width: 4),
        Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
      ],
    );
  }

  Widget _buildSeatLayout() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      padding: EdgeInsets.all(16),
      child: Column(
        children: seatLayout.asMap().entries.map((entry) {
          int rowIndex = entry.key;
          List<String> seats = entry.value;
          String rowLabel = String.fromCharCode(65 + rowIndex); // A, B, C, ...

          return Container(
            margin: EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                // Row label (left)
                Container(
                  width: 30,
                  child: Text(
                    rowLabel,
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    textAlign: TextAlign.center,
                  ),
                ),
                // Seats
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: seats.asMap().entries.map((seatEntry) {
                        int seatIndex = seatEntry.key;
                        String seatId = seatEntry.value;

                        Widget seatWidget = _buildSeat(seatId);

                        // Add aisle space after seat 6
                        if (seatIndex == 5) {
                          return Row(children: [seatWidget, SizedBox(width: 16)]);
                        } else if (seatIndex == seats.length - 1) {
                          return seatWidget;
                        } else {
                          return Row(children: [seatWidget, SizedBox(width: 4)]);
                        }
                      }).toList(),
                    ),
                  ),
                ),
                // Row label (right)
                Container(
                  width: 30,
                  child: Text(
                    rowLabel,
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSeat(String seatId) {
    final isUnavailable = unavailableSeats.contains(seatId);
    final isAvailable = !isUnavailable;

    Color seatColor = isAvailable ? Colors.green : Colors.red;

    return GestureDetector(
      onTap: () => _toggleSeat(seatId),
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: seatColor,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: Colors.white, width: 1),
          boxShadow: [
            BoxShadow(
              color: seatColor.withOpacity(0.3),
              spreadRadius: 1,
              blurRadius: 2,
            ),
          ],
        ),
        child: Center(
          child: isUnavailable
              ? Icon(Icons.close, color: Colors.white, size: 14)
              : Text(
            seatId.substring(1), // Show seat number (1, 2, 3, ...)
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQuickActions() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.flash_on, color: Colors.blue[700], size: 20),
              SizedBox(width: 8),
              Text(
                'Thao tác nhanh:',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.blue[700],
                ),
              ),
            ],
          ),
          SizedBox(height: 16),

          // Hàng đầu tiên - 2 nút chính
          Row(
            children: [
              Expanded(
                child: _buildQuickActionButton(
                  icon: Icons.select_all,
                  label: 'Tất cả khả dụng',
                  color: Colors.green,
                  onPressed: () {
                    _performQuickAction(() {
                      unavailableSeats.clear();
                    });
                  },
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: _buildQuickActionButton(
                  icon: Icons.block,
                  label: 'Tất cả không khả dụng',
                  color: Colors.red,
                  onPressed: () {
                    _performQuickAction(() {
                      unavailableSeats = Set.from(allSeats);
                    });
                  },
                ),
              ),
            ],
          ),

          SizedBox(height: 12),

          // Hàng thứ hai - 2 nút phụ
          Row(
            children: [
              Expanded(
                child: _buildQuickActionButton(
                  icon: Icons.horizontal_rule,
                  label: 'Disable hàng đầu/cuối',
                  color: Colors.orange,
                  onPressed: () {
                    _performQuickAction(() {
                      unavailableSeats.clear();
                      for (int i = 1; i <= 12; i++) {
                        unavailableSeats.add('A$i');
                        unavailableSeats.add('H$i');
                      }
                    });
                  },
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: _buildQuickActionButton(
                  icon: Icons.refresh,
                  label: 'Reset',
                  color: Colors.grey[600]!,
                  onPressed: () {
                    _performQuickAction(() {
                      unavailableSeats.clear();
                    });
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return Container(
      height: 48,
      child: ElevatedButton(
        onPressed: _isDisposed || !mounted ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          elevation: 2,
          shadowColor: color.withOpacity(0.3),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 18),
            SizedBox(width: 6),
            Flexible(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}