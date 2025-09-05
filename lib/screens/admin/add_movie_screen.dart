// lib/screens/admin/add_movie_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import '../../providers/movie_provider.dart';
import '../../models/movie_model.dart';
import 'add_showtime_screen.dart';

class AddMovieScreen extends StatefulWidget {
  final Movie? movie;

  AddMovieScreen({this.movie});

  @override
  _AddMovieScreenState createState() => _AddMovieScreenState();
}

class _AddMovieScreenState extends State<AddMovieScreen> with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _durationController = TextEditingController();
  final _ratingController = TextEditingController();
  final _posterUrlController = TextEditingController();
  final _trailerUrlController = TextEditingController();
  final _directorController = TextEditingController();
  final _castController = TextEditingController();
  final _genresController = TextEditingController();
  final _customCinemaController = TextEditingController();

  String _selectedStatus = 'now_showing';
  DateTime _selectedDate = DateTime.now();
  bool _isLoading = false;

  // File upload related variables
  File? _selectedPosterFile;
  File? _selectedTrailerFile;
  String? _uploadedPosterUrl;
  String? _uploadedTrailerUrl;
  bool _isUploadingPoster = false;
  bool _isUploadingTrailer = false;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  // Danh sách rạp phim có sẵn
  final List<String> _availableCinemas = [
    'CGV Cinemas',
    'Lotte Cinema',
    'Galaxy Cinema',
    'BHD Star Cineplex',
    'Cinestar',
    'Mega GS Cinemas',
    'Beta Cinemas',
    'Cinebox',
  ];

  List<String> _selectedCinemas = [];
  bool _showCustomCinemaField = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    if (widget.movie != null) {
      _titleController.text = widget.movie!.title;
      _descriptionController.text = widget.movie!.description;
      _durationController.text = widget.movie!.duration.toString();
      _ratingController.text = widget.movie!.rating.toString();
      _posterUrlController.text = widget.movie!.posterUrl;
      _trailerUrlController.text = widget.movie!.trailerUrl;
      _directorController.text = widget.movie!.director;
      _castController.text = widget.movie!.cast.join(', ');
      _genresController.text = widget.movie!.genres.join(', ');
      _selectedStatus = widget.movie!.status;
      _selectedDate = widget.movie!.releaseDate;

      _loadSelectedCinemas();
    }

    _animationController.forward();
  }

  Future<void> _loadSelectedCinemas() async {
    if (widget.movie != null) {
      try {
        final doc = await FirebaseFirestore.instance
            .collection('movie_cinemas')
            .doc(widget.movie!.id)
            .get();

        if (doc.exists) {
          setState(() {
            _selectedCinemas = List<String>.from(doc.data()?['cinemas'] ?? []);
          });
        }
      } catch (e) {
        print('Error loading selected cinemas: $e');
      }
    }
  }

  // Upload poster image to Firebase Storage
  Future<void> _pickAndUploadPoster() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 80,
      );

      if (image != null) {
        setState(() {
          _selectedPosterFile = File(image.path);
          _isUploadingPoster = true;
        });

        // Upload to Firebase Storage
        final String fileName = 'posters/${DateTime.now().millisecondsSinceEpoch}_${image.name}';
        final Reference storageRef = FirebaseStorage.instance.ref().child(fileName);

        final UploadTask uploadTask = storageRef.putFile(_selectedPosterFile!);
        final TaskSnapshot snapshot = await uploadTask;
        final String downloadUrl = await snapshot.ref.getDownloadURL();

        setState(() {
          _uploadedPosterUrl = downloadUrl;
          _posterUrlController.text = downloadUrl;
          _isUploadingPoster = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Tải poster thành công!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isUploadingPoster = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lỗi tải poster: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Upload trailer video to Firebase Storage
  Future<void> _pickAndUploadTrailer() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.video,
        allowMultiple: false,
      );

      if (result != null) {
        setState(() {
          _selectedTrailerFile = File(result.files.single.path!);
          _isUploadingTrailer = true;
        });

        // Upload to Firebase Storage
        final String fileName = 'trailers/${DateTime.now().millisecondsSinceEpoch}_${result.files.single.name}';
        final Reference storageRef = FirebaseStorage.instance.ref().child(fileName);

        final UploadTask uploadTask = storageRef.putFile(_selectedTrailerFile!);
        final TaskSnapshot snapshot = await uploadTask;
        final String downloadUrl = await snapshot.ref.getDownloadURL();

        setState(() {
          _uploadedTrailerUrl = downloadUrl;
          _trailerUrlController.text = downloadUrl;
          _isUploadingTrailer = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Tải trailer thành công!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isUploadingTrailer = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lỗi tải trailer: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF8F9FA),
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(),
          SliverToBoxAdapter(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Form(
                key: _formKey,
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildBasicInfoSection(),
                      SizedBox(height: 24),
                      _buildMediaSection(),
                      SizedBox(height: 24),
                      _buildDetailsSection(),
                      SizedBox(height: 24),
                      _buildCinemaSection(),
                      SizedBox(height: 32),
                      _buildSaveButton(),
                      SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 120,
      floating: false,
      pinned: true,
      backgroundColor: Colors.transparent,
      elevation: 0,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Theme.of(context).primaryColor,
                Theme.of(context).primaryColor.withOpacity(0.8),
              ],
            ),
          ),
        ),
      ),
      title: Text(
        widget.movie == null ? 'Thêm phim mới' : 'Chỉnh sửa phim',
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      leading: IconButton(
        icon: Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () => Navigator.pop(context),
      ),
      actions: [
        Container(
          margin: EdgeInsets.only(right: 16),
          child: TextButton.icon(
            onPressed: _isLoading ? null : _saveMovie,
            icon: Icon(Icons.save, color: Colors.white),
            label: Text('Lưu', style: TextStyle(color: Colors.white)),
            style: TextButton.styleFrom(
              backgroundColor: Colors.white.withOpacity(0.2),
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBasicInfoSection() {
    return _buildSection(
      title: 'Thông tin cơ bản',
      icon: Icons.info_outline,
      child: Column(
        children: [
          _buildTextField(
            controller: _titleController,
            label: 'Tên phim',
            icon: Icons.movie,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Vui lòng nhập tên phim';
              }
              return null;
            },
          ),
          SizedBox(height: 16),
          _buildTextField(
            controller: _descriptionController,
            label: 'Mô tả',
            icon: Icons.description,
            maxLines: 3,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Vui lòng nhập mô tả';
              }
              return null;
            },
          ),
          SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildTextField(
                  controller: _durationController,
                  label: 'Thời lượng (phút)',
                  icon: Icons.access_time,
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Vui lòng nhập thời lượng';
                    }
                    return null;
                  },
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: _buildTextField(
                  controller: _ratingController,
                  label: 'Đánh giá (0-10)',
                  icon: Icons.star,
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Vui lòng nhập đánh giá';
                    }
                    final rating = double.tryParse(value);
                    if (rating == null || rating < 0 || rating > 10) {
                      return 'Đánh giá phải từ 0-10';
                    }
                    return null;
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMediaSection() {
    return _buildSection(
      title: 'Media & Hình ảnh',
      icon: Icons.perm_media,
      child: Column(
        children: [
          // Poster upload section
          Container(
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade300),
            ),
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.image, color: Theme.of(context).primaryColor),
                    SizedBox(width: 8),
                    Text(
                      'Poster phim',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12),
                if (_selectedPosterFile != null) ...[
                  Container(
                    height: 200,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      image: DecorationImage(
                        image: FileImage(_selectedPosterFile!),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  SizedBox(height: 12),
                ],
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _isUploadingPoster ? null : _pickAndUploadPoster,
                        icon: _isUploadingPoster
                            ? SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                            : Icon(Icons.upload),
                        label: Text(_isUploadingPoster ? 'Đang tải...' : 'Chọn poster'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).primaryColor,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12),
                Text('Hoặc nhập URL poster:', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                SizedBox(height: 8),
                _buildTextField(
                  controller: _posterUrlController,
                  label: 'URL poster',
                  icon: Icons.link,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Vui lòng chọn poster hoặc nhập URL';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),

          SizedBox(height: 16),

          // Trailer upload section
          Container(
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade300),
            ),
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.video_library, color: Theme.of(context).primaryColor),
                    SizedBox(width: 8),
                    Text(
                      'Trailer phim',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12),
                if (_selectedTrailerFile != null) ...[
                  Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.video_file, color: Colors.blue),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _selectedTrailerFile!.path.split('/').last,
                            style: TextStyle(fontWeight: FontWeight.w500),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 12),
                ],
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _isUploadingTrailer ? null : _pickAndUploadTrailer,
                        icon: _isUploadingTrailer
                            ? SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                            : Icon(Icons.upload),
                        label: Text(_isUploadingTrailer ? 'Đang tải...' : 'Chọn trailer'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12),
                Text('Hoặc nhập URL trailer:', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                SizedBox(height: 8),
                _buildTextField(
                  controller: _trailerUrlController,
                  label: 'URL trailer',
                  icon: Icons.link,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailsSection() {
    return _buildSection(
      title: 'Chi tiết phim',
      icon: Icons.details,
      child: Column(
        children: [
          _buildTextField(
            controller: _directorController,
            label: 'Đạo diễn',
            icon: Icons.person,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Vui lòng nhập tên đạo diễn';
              }
              return null;
            },
          ),
          SizedBox(height: 16),
          _buildTextField(
            controller: _castController,
            label: 'Diễn viên (cách nhau bởi dấu phẩy)',
            icon: Icons.people,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Vui lòng nhập danh sách diễn viên';
              }
              return null;
            },
          ),
          SizedBox(height: 16),
          _buildTextField(
            controller: _genresController,
            label: 'Thể loại (cách nhau bởi dấu phẩy)',
            icon: Icons.category,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Vui lòng nhập thể loại';
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
            child: DropdownButtonFormField<String>(
              value: _selectedStatus,
              decoration: InputDecoration(
                labelText: 'Trạng thái',
                prefixIcon: Icon(Icons.movie_filter),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              items: [
                DropdownMenuItem(value: 'now_showing', child: Text('Đang chiếu')),
                DropdownMenuItem(value: 'coming_soon', child: Text('Sắp chiếu')),
                if (widget.movie != null)
                  DropdownMenuItem(value: 'ended', child: Text('Đã chiếu')),
              ],
              onChanged: (value) {
                setState(() {
                  _selectedStatus = value!;
                });
              },
            ),
          ),
          SizedBox(height: 16),
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListTile(
              leading: Icon(Icons.calendar_today),
              title: Text('Ngày phát hành'),
              subtitle: Text('${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}'),
              trailing: Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: _selectedDate,
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2030),
                );
                if (date != null) {
                  setState(() {
                    _selectedDate = date;
                  });
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCinemaSection() {
    return _buildSection(
      title: 'Rạp chiếu phim',
      icon: Icons.local_movies,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                ..._availableCinemas.map((cinema) => Container(
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(color: Colors.grey.shade200, width: 0.5),
                    ),
                  ),
                  child: CheckboxListTile(
                    title: Text(cinema),
                    value: _selectedCinemas.contains(cinema),
                    onChanged: (bool? value) {
                      setState(() {
                        if (value == true) {
                          _selectedCinemas.add(cinema);
                        } else {
                          _selectedCinemas.remove(cinema);
                        }
                      });
                    },
                  ),
                )),
                CheckboxListTile(
                  title: Text('Rạp phim khác'),
                  value: _showCustomCinemaField,
                  onChanged: (bool? value) {
                    setState(() {
                      _showCustomCinemaField = value ?? false;
                      if (!_showCustomCinemaField) {
                        _customCinemaController.clear();
                      }
                    });
                  },
                ),
              ],
            ),
          ),

          if (_showCustomCinemaField) ...[
            SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildTextField(
                    controller: _customCinemaController,
                    label: 'Tên rạp phim khác',
                    icon: Icons.add_business,
                  ),
                ),
                SizedBox(width: 12),
                ElevatedButton(
                  onPressed: () {
                    if (_customCinemaController.text.trim().isNotEmpty) {
                      final customCinema = _customCinemaController.text.trim();
                      if (!_selectedCinemas.contains(customCinema)) {
                        setState(() {
                          _selectedCinemas.add(customCinema);
                          _customCinemaController.clear();
                        });
                      }
                    }
                  },
                  child: Text('Thêm'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ],
            ),
          ],

          if (_selectedCinemas.isNotEmpty) ...[
            SizedBox(height: 16),
            Text(
              'Rạp đã chọn:',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _selectedCinemas.map((cinema) => Chip(
                label: Text(cinema),
                deleteIcon: Icon(Icons.close, size: 18),
                onDeleted: () {
                  setState(() {
                    _selectedCinemas.remove(cinema);
                  });
                },
                backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
                labelStyle: TextStyle(color: Theme.of(context).primaryColor),
              )).toList(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      padding: EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: Theme.of(context).primaryColor,
                  size: 20,
                ),
              ),
              SizedBox(width: 12),
              Text(
                title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    int maxLines = 1,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: keyboardType,
        validator: validator,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
    );
  }

  Widget _buildSaveButton() {
    return Container(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _saveMovie,
        style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context).primaryColor,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),
          elevation: 8,
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
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
            SizedBox(width: 12),
            Text('Đang xử lý...', style: TextStyle(fontSize: 16)),
          ],
        )
            : Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(widget.movie == null ? Icons.add : Icons.update, size: 20),
            SizedBox(width: 8),
            Text(
              widget.movie == null ? 'Thêm phim' : 'Cập nhật phim',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _saveMovie() async {
    if (_formKey.currentState!.validate()) {
      if (_selectedCinemas.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Vui lòng chọn ít nhất một rạp phim'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      setState(() {
        _isLoading = true;
      });

      final movie = Movie(
          id: widget.movie?.id ?? '',
          title: _titleController.text,
          description:_descriptionController.text,
        duration: int.parse(_durationController.text),
        rating: double.parse(_ratingController.text),
        posterUrl: _posterUrlController.text,
        trailerUrl: _trailerUrlController.text,
        director: _directorController.text,
        cast: _castController.text.split(',').map((e) => e.trim()).toList(),
        genres: _genresController.text.split(',').map((e) => e.trim()).toList(),
        status: _selectedStatus,
        releaseDate: _selectedDate,
      );

      try {
        final movieProvider = Provider.of<MovieProvider>(context, listen: false);

        if (widget.movie == null) {
          // Thêm phim mới
          await movieProvider.addMovie(movie);
          await _saveCinemaMapping(movie.id);

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.white),
                  SizedBox(width: 8),
                  Text('Thêm phim thành công!'),
                ],
              ),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 3),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          );

          // Điều hướng đến màn hình thêm suất chiếu
          final shouldAddShowtime = await showDialog<bool>(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                title: Row(
                  children: [
                    Icon(Icons.movie_creation, color: Theme.of(context).primaryColor),
                    SizedBox(width: 8),
                    Text('Phim đã được thêm!'),
                  ],
                ),
                content: Text('Bạn có muốn thêm suất chiếu cho phim này không?'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: Text('Không', style: TextStyle(color: Colors.grey)),
                  ),
                  ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text('Có', style: TextStyle(color: Colors.white)),
                  ),
                ],
              );
            },
          );

          if (shouldAddShowtime == true) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => AddShowtimeScreen(movie: movie, movieId: '',),
              ),
            );
          } else {
            Navigator.pop(context);
          }
        } else {
          // Cập nhật phim
          await movieProvider.updateMovie(movie);
          await _saveCinemaMapping(movie.id);

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  Icon(Icons.update, color: Colors.white),
                  SizedBox(width: 8),
                  Text('Cập nhật phim thành công!'),
                ],
              ),
              backgroundColor: Colors.blue,
              duration: Duration(seconds: 3),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          );
          Navigator.pop(context);
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.error, color: Colors.white),
                SizedBox(width: 8),
                Expanded(child: Text('Lỗi: ${e.toString()}')),
              ],
            ),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 5),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _saveCinemaMapping(String movieId) async {
    if (_selectedCinemas.isNotEmpty) {
      try {
        await FirebaseFirestore.instance
            .collection('movie_cinemas')
            .doc(movieId)
            .set({
          'movieId': movieId,
          'cinemas': _selectedCinemas,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      } catch (e) {
        print('Error saving cinema mapping: $e');
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _titleController.dispose();
    _descriptionController.dispose();
    _durationController.dispose();
    _ratingController.dispose();
    _posterUrlController.dispose();
    _trailerUrlController.dispose();
    _directorController.dispose();
    _castController.dispose();
    _genresController.dispose();
    _customCinemaController.dispose();
    super.dispose();
  }
}