// lib/screens/admin/add_showtime_screen.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tmovie/models/movie_model.dart';

class AddShowtimeScreen extends StatefulWidget {
  final String movieId;
  final List<String> availableCinemas;

  const AddShowtimeScreen({
    required this.movieId,
    this.availableCinemas = const [], required Movie movie,
  });

  @override
  State<AddShowtimeScreen> createState() => _AddShowtimeScreenState();
}

class _AddShowtimeScreenState extends State<AddShowtimeScreen> {
  final _formKey = GlobalKey<FormState>();
  DateTime _selectedDateTime = DateTime.now().add(Duration(hours: 1));
  final _priceController = TextEditingController(text: '60000');
  final _roomIdController = TextEditingController(text: 'Room 1');
  final _availableSeatsController = TextEditingController(
      text: 'A1,A2,A3,A4,A5,A6,A7,A8,B1,B2,B3,B4,B5,B6,B7,B8,C1,C2,C3,C4,C5,C6,C7,C8'
  );

  String? _selectedCinema;
  List<String> _cinemaOptions = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadCinemaOptions();
  }

  Future<void> _loadCinemaOptions() async {
    try {
      // Tải danh sách rạp từ movie_cinemas collection
      final doc = await FirebaseFirestore.instance
          .collection('movie_cinemas')
          .doc(widget.movieId)
          .get();

      if (doc.exists) {
        final cinemas = List<String>.from(doc.data()?['cinemas'] ?? []);
        setState(() {
          _cinemaOptions = cinemas;
          if (_cinemaOptions.isNotEmpty) {
            _selectedCinema = _cinemaOptions.first;
          }
        });
      } else if (widget.availableCinemas.isNotEmpty) {
        // Fallback: sử dụng danh sách từ parameter
        setState(() {
          _cinemaOptions = widget.availableCinemas;
          _selectedCinema = _cinemaOptions.first;
        });
      }
    } catch (e) {
      print('Error loading cinema options: $e');
      // Fallback: sử dụng danh sách mặc định
      setState(() {
        _cinemaOptions = ['CGV Cinemas', 'Lotte Cinema', 'Galaxy Cinema'];
        _selectedCinema = _cinemaOptions.first;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Thêm suất chiếu'),
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _saveShowtime,
            child: Text(
              'Lưu',
              style: TextStyle(
                color: _isLoading ? Colors.grey : Colors.blue,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: EdgeInsets.all(16),
          children: [
            // Chọn rạp phim
            if (_cinemaOptions.isNotEmpty) ...[
              DropdownButtonFormField<String>(
                value: _selectedCinema,
                decoration: InputDecoration(
                  labelText: 'Chọn rạp phim',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.local_movies),
                ),
                items: _cinemaOptions.map((cinema) => DropdownMenuItem(
                  value: cinema,
                  child: Text(cinema),
                )).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedCinema = value;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Vui lòng chọn rạp phim';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
            ] else ...[
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  border: Border.all(color: Colors.orange),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.warning, color: Colors.orange),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Không tìm thấy danh sách rạp phim cho phim này.',
                        style: TextStyle(color: Colors.orange.shade800),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16),
            ],

            // Phòng chiếu
            TextFormField(
              controller: _roomIdController,
              decoration: InputDecoration(
                labelText: 'Phòng chiếu',
                border: OutlineInputBorder(),
                hintText: 'VD: Room 1, Phòng A, P1, etc.',
                prefixIcon: Icon(Icons.meeting_room),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Vui lòng nhập tên phòng chiếu';
                }
                return null;
              },
            ),

            SizedBox(height: 16),

            // Thời gian chiếu
            Card(
              child: ListTile(
                leading: Icon(Icons.access_time),
                title: Text('Thời gian chiếu'),
                subtitle: Text(
                    '${_selectedDateTime.day}/${_selectedDateTime.month}/${_selectedDateTime.year} '
                        '${_selectedDateTime.hour}:${_selectedDateTime.minute.toString().padLeft(2, '0')}'
                ),
                trailing: Icon(Icons.edit),
                onTap: () async {
                  final pickedDate = await showDatePicker(
                    context: context,
                    initialDate: _selectedDateTime,
                    firstDate: DateTime.now(),
                    lastDate: DateTime(2030),
                  );
                  if (pickedDate != null) {
                    final pickedTime = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.fromDateTime(_selectedDateTime),
                    );
                    if (pickedTime != null) {
                      setState(() {
                        _selectedDateTime = DateTime(
                          pickedDate.year,
                          pickedDate.month,
                          pickedDate.day,
                          pickedTime.hour,
                          pickedTime.minute,
                        );
                      });
                    }
                  }
                },
              ),
            ),

            SizedBox(height: 16),

            // Giá vé
            TextFormField(
              controller: _priceController,
              decoration: InputDecoration(
                labelText: 'Giá vé (VND)',
                border: OutlineInputBorder(),
                prefixText: '₫ ',
                prefixIcon: Icon(Icons.attach_money),
                suffixText: 'VND',
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Vui lòng nhập giá vé';
                }
                final price = double.tryParse(value);
                if (price == null) {
                  return 'Giá vé không hợp lệ';
                }
                if (price <= 0) {
                  return 'Giá vé phải lớn hơn 0';
                }
                return null;
              },
            ),

            SizedBox(height: 16),

            // Danh sách ghế
            TextFormField(
              controller: _availableSeatsController,
              decoration: InputDecoration(
                labelText: 'Danh sách ghế có sẵn',
                border: OutlineInputBorder(),
                hintText: 'A1,A2,A3,B1,B2,B3,C1,C2,C3',
                helperText: 'Các ghế cách nhau bởi dấu phẩy',
                prefixIcon: Icon(Icons.event_seat),
              ),
              maxLines: 3,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Vui lòng nhập danh sách ghế';
                }
                final seats = value.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
                if (seats.isEmpty) {
                  return 'Danh sách ghế không hợp lệ';
                }
                return null;
              },
            ),

            SizedBox(height: 16),

            // Hiển thị thông tin tóm tắt
            Card(
              elevation: 2,
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.info_outline, color: Colors.blue),
                        SizedBox(width: 8),
                        Text(
                          'Thông tin suất chiếu',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 12),
                    if (_selectedCinema != null) ...[
                      _buildInfoRow(Icons.local_movies, 'Rạp:', _selectedCinema!),
                      SizedBox(height: 8),
                    ],
                    _buildInfoRow(
                        Icons.meeting_room,
                        'Phòng:',
                        _roomIdController.text.isEmpty ? "Chưa nhập" : _roomIdController.text
                    ),
                    SizedBox(height: 8),
                    _buildInfoRow(
                        Icons.access_time,
                        'Thời gian:',
                        '${_selectedDateTime.day}/${_selectedDateTime.month}/${_selectedDateTime.year} ${_selectedDateTime.hour}:${_selectedDateTime.minute.toString().padLeft(2, '0')}'
                    ),
                    SizedBox(height: 8),
                    _buildInfoRow(
                        Icons.attach_money,
                        'Giá vé:',
                        '${_priceController.text.isEmpty ? "0" : _priceController.text} VND'
                    ),
                    SizedBox(height: 8),
                    _buildInfoRow(
                        Icons.event_seat,
                        'Số ghế:',
                        '${_availableSeatsController.text.split(',').where((s) => s.trim().isNotEmpty).length} ghế'
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: 24),

            // Nút lưu
            Container(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _saveShowtime,
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Colors.blue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: _isLoading
                    ? Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(width: 12),
                    Text(
                      'Đang lưu...',
                      style: TextStyle(color: Colors.white),
                    ),
                  ],
                )
                    : Text(
                  'Thêm suất chiếu',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: Colors.grey[600]),
        SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.w500,
            color: Colors.grey[700],
          ),
        ),
        SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              color: Colors.black87,
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _saveShowtime() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedCinema == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Vui lòng chọn rạp phim'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final availableSeats = _availableSeatsController.text
          .split(',')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();

      if (availableSeats.isEmpty) {
        throw Exception('Danh sách ghế không được để trống');
      }

      // Tạo cinema ID từ tên rạp
      final cinemaId = _selectedCinema!
          .toLowerCase()
          .replaceAll(' ', '_')
          .replaceAll(RegExp(r'[^a-z0-9_]'), '');

      final showtimeData = {
        'movieId': widget.movieId,
        'cinemaId': cinemaId,
        'cinemaName': _selectedCinema,
        'roomId': _roomIdController.text.trim(),
        'startTime': Timestamp.fromDate(_selectedDateTime),
        'availableSeats': availableSeats,
        'bookedSeats': <String>[], // Khởi tạo rỗng
        'price': double.parse(_priceController.text),
        'createdAt': Timestamp.now(),
      };

      print('Saving showtime: $showtimeData');

      // Lưu suất chiếu
      final docRef = await FirebaseFirestore.instance
          .collection('showtimes')
          .add(showtimeData);

      print('Showtime saved with ID: ${docRef.id}');

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: 8),
              Text('Thêm suất chiếu thành công'),
            ],
          ),
          backgroundColor: Colors.green,
        ),
      );

      // Hỏi người dùng có muốn thêm suất chiếu khác không
      final shouldAddMore = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.green),
              SizedBox(width: 8),
              Text('Thành công'),
            ],
          ),
          content: Text('Suất chiếu đã được thêm thành công.\nBạn có muốn thêm suất chiếu khác không?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text('Không'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text('Có'),
            ),
          ],
        ),
      );

      if (shouldAddMore == true) {
        // Reset form để thêm suất chiếu mới
        setState(() {
          _selectedDateTime = DateTime.now().add(Duration(hours: 2));
          _roomIdController.text = 'Room 1';
        });
      } else {
        // Quay về màn hình trước
        Navigator.pop(context);
      }

    } catch (e) {
      print('Lỗi khi thêm suất chiếu: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.error, color: Colors.white),
              SizedBox(width: 8),
              Expanded(child: Text('Thêm thất bại: ${e.toString()}')),
            ],
          ),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _priceController.dispose();
    _roomIdController.dispose();
    _availableSeatsController.dispose();
    super.dispose();
  }
}