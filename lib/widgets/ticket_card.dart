// lib/widgets/ticket_card.dart
import 'package:flutter/material.dart';
import '../models/ticket_model.dart';
import 'package:intl/intl.dart';

class TicketCard extends StatelessWidget {
  final Ticket ticket;
  final VoidCallback? onTap;
  final VoidCallback? onCancel;

  const TicketCard({
    Key? key,
    required this.ticket,
    this.onTap,
    this.onCancel,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.only(bottom: 16),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header với tên phim và trạng thái
              Row(
                children: [
                  Expanded(
                    child: Text(
                      ticket.movie?.title ?? 'Phim không xác định',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  SizedBox(width: 8),
                  _buildStatusChip(ticket.paymentStatus),
                ],
              ),

              SizedBox(height: 12),

              // Thông tin rạp và ghế
              Row(
                children: [
                  Icon(Icons.location_on, size: 16, color: Colors.grey[600]),
                  SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      ticket.cinema?.name ?? 'Rạp không xác định',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),

              SizedBox(height: 8),

              Row(
                children: [
                  Icon(Icons.event_seat, size: 16, color: Colors.grey[600]),
                  SizedBox(width: 4),
                  Text(
                    'Ghế: ${ticket.seats.join(', ')}',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                ],
              ),

              SizedBox(height: 8),

              // Giá và ngày đặt
              Row(
                children: [
                  Icon(Icons.monetization_on, size: 16, color: Colors.grey[600]),
                  SizedBox(width: 4),
                  Text(
                    '${NumberFormat('#,###').format(ticket.totalPrice)} VND',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),

              SizedBox(height: 8),

              Row(
                children: [
                  Icon(Icons.access_time, size: 16, color: Colors.grey[600]),
                  SizedBox(width: 4),
                  Text(
                    DateFormat('dd/MM/yyyy HH:mm').format(ticket.createdAt),
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                ],
              ),

              // 🔄 QUAN TRỌNG: Cập nhật điều kiện hiển thị nút hủy vé
              // Hiển thị nút hủy cho cả vé pending và completed (chỉ ẩn với cancelled)
              if (onCancel != null) ...[
                SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.red[50],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: Colors.red[200]!,
                          width: 1,
                        ),
                      ),
                      child: TextButton.icon(
                        onPressed: onCancel,
                        icon: Icon(
                          Icons.cancel_outlined,
                          size: 16,
                          color: Colors.red[600],
                        ),
                        label: Text(
                          'Hủy vé',
                          style: TextStyle(
                            color: Colors.red[600],
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          minimumSize: Size(0, 0),
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color backgroundColor;
    Color textColor;
    String text;

    switch (status) {
      case 'completed':
        backgroundColor = Colors.green;
        textColor = Colors.white;
        text = 'Đã thanh toán';
        break;
      case 'pending':
        backgroundColor = Colors.orange;
        textColor = Colors.white;
        text = 'Chờ thanh toán';
        break;
      case 'cancelled':
        backgroundColor = Colors.red;
        textColor = Colors.white;
        text = 'Đã hủy';
        break;
      default:
        backgroundColor = Colors.grey;
        textColor = Colors.white;
        text = 'Không xác định';
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: textColor,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}