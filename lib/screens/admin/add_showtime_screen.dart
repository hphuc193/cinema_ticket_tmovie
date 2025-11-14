// lib/screens/admin/add_showtime_screen.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tmovie/models/movie_model.dart';
import '../../widgets/admin_seat_selector.dart';

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
  List<String> _availableSeats = [];

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

            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Icon(Icons.event_seat, color: Theme.of(context).primaryColor),
                        SizedBox(width: 8),
                        Text(
                          'Cấu hình ghế ngồi',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  AdminSeatSelector(
                    onSeatsChanged: (seats) {
                      setState(() {
                        _availableSeats = seats;
                      });
                    },
                    initialAvailableSeats: _availableSeats.isEmpty ? null : _availableSeats,
                  ),
                ],
              ),
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
                        '${_availableSeats.length} ghế khả dụng'
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
      print('=== STARTING SHOWTIME SAVE PROCESS ===');

      final availableSeats = _availableSeats;

      if (availableSeats.isEmpty) {
        throw Exception('Vui lòng cấu hình ít nhất 1 ghế khả dụng');
      }

      final cinemaId = _selectedCinema!;
      print('Using cinema ID: $cinemaId');

      final showtimeData = {
        'movieId': widget.movieId,
        'cinemaId': cinemaId,
        'cinemaName': _selectedCinema,
        'roomId': _roomIdController.text.trim(),
        'startTime': Timestamp.fromDate(_selectedDateTime),
        'availableSeats': availableSeats,
        'bookedSeats': <String>[],
        'price': double.parse(_priceController.text),
        'createdAt': Timestamp.now(),
      };

      print('Showtime data to save: $showtimeData');

      // Lưu suất chiếu
      print('Saving showtime to Firestore...');
      final docRef = await FirebaseFirestore.instance
          .collection('showtimes')
          .add(showtimeData);

      print('Showtime saved with ID: ${docRef.id}');

      //Cập nhật movie_cinemas NGAY SAU KHI LƯU SHOWTIME THÀNH CÔNG
      print('Now updating movie_cinemas...');
      await _updateMovieCinemas();

      print('=== SHOWTIME SAVE PROCESS COMPLETED ===');

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
        setState(() {
          _selectedDateTime = DateTime.now().add(Duration(hours: 2));
          _roomIdController.text = 'Room 1';
        });
      } else {
        Navigator.pop(context);
      }

    } catch (e, stackTrace) {
      print('=== ERROR IN SHOWTIME SAVE PROCESS ===');
      print('Error: $e');
      print('Stack trace: $stackTrace');

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

  // Thêm method để cập nhật movie_cinemas
  Future<void> _updateMovieCinemas() async {
    try {
      print('=== STARTING _updateMovieCinemas ===');
      print('Movie ID: ${widget.movieId}');
      print('Selected Cinema: $_selectedCinema');

      final movieCinemasRef = FirebaseFirestore.instance
          .collection('movie_cinemas')
          .doc(widget.movieId);

      print('Checking if document exists...');
      final doc = await movieCinemasRef.get();

      if (doc.exists) {
        print('Document EXISTS - updating...');
        final data = doc.data()!;
        print('Current document data: $data');

        final currentCinemas = List<String>.from(data['cinemas'] ?? []);
        print('Current cinemas list: $currentCinemas');

        if (!currentCinemas.contains(_selectedCinema)) {
          print('Cinema NOT found in list, adding...');
          currentCinemas.add(_selectedCinema!);
          print('New cinemas list: $currentCinemas');

          await movieCinemasRef.update({
            'cinemas': currentCinemas,
            'updatedAt': Timestamp.now(),
          });
          print('Document UPDATED successfully');
        } else {
          print('Cinema ALREADY exists in list, no update needed');
        }
      } else {
        print('Document DOES NOT exist - creating new...');
        final newData = {
          'movieId': widget.movieId,
          'cinemas': [_selectedCinema],
          'updatedAt': Timestamp.now(),
          'createdAt': Timestamp.now(),
        };
        print('Creating document with data: $newData');

        await movieCinemasRef.set(newData);
        print('New document CREATED successfully');
      }

      print('=== _updateMovieCinemas COMPLETED SUCCESSFULLY ===');
    } catch (e, stackTrace) {
      print('=== ERROR in _updateMovieCinemas ===');
      print('Error: $e');
      print('Stack trace: $stackTrace');
      // Không throw lại để không làm gián đoạn việc tạo showtime
    }
  }

  @override
  void dispose() {
    _priceController.dispose();
    _roomIdController.dispose();
    super.dispose();
  }

}
