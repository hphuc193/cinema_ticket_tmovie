import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/movie_provider.dart';
import '../models/movie_model.dart';

class EnhancedMovieSearchDelegate extends SearchDelegate {
  List<String> _searchHistory = [];
  String _selectedGenre = 'Tất cả';
  String _selectedStatus = 'Tất cả';
  double _minRating = 0.0;
  bool _showFilters = false;

  final ValueNotifier<int> _filterNotifier = ValueNotifier<int>(0);

  @override
  String get searchFieldLabel => 'Tìm kiếm phim, diễn viên, đạo diễn...';

  @override
  ThemeData appBarTheme(BuildContext context) {
    return Theme.of(context).copyWith(
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: Color(0xFF1a1a2e)),
        titleTextStyle: TextStyle(
          color: Color(0xFF1a1a2e),
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: InputBorder.none,
        hintStyle: TextStyle(
          color: Colors.grey[400],
          fontSize: 16,
          fontWeight: FontWeight.w400,
        ),
      ),
    );
  }

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      if (query.isNotEmpty)
        IconButton(
          icon: Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.clear, color: Colors.grey[700], size: 20),
          ),
          onPressed: () {
            query = '';
          },
        ),
      IconButton(
        icon: Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            gradient: _showFilters
                ? LinearGradient(
              colors: [Color(0xFF6366f1), Color(0xFF8b5cf6)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            )
                : null,
            color: _showFilters ? null : Colors.grey[100],
            shape: BoxShape.circle,
          ),
          child: Icon(
            _showFilters ? Icons.tune : Icons.tune,
            color: _showFilters ? Colors.white : Colors.grey[700],
            size: 20,
          ),
        ),
        onPressed: () {
          _showFilters = !_showFilters;
          _filterNotifier.value++;
        },
      ),
      SizedBox(width: 8),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: Container(
        padding: EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          shape: BoxShape.circle,
        ),
        child: Icon(Icons.arrow_back_ios_new, color: Color(0xFF1a1a2e), size: 18),
      ),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return _buildSearchContent(context, showSuggestions: false);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return _buildSearchContent(context, showSuggestions: true);
  }

  Widget _buildSearchContent(BuildContext context, {required bool showSuggestions}) {
    final movieProvider = Provider.of<MovieProvider>(context);

    return ValueListenableBuilder<int>(
      valueListenable: _filterNotifier,
      builder: (context, value, child) {
        return Container(
          color: Color(0xFFFAFAFC),
          child: Column(
            children: [
              if (_showFilters) _buildFiltersSection(context),
              Expanded(
                child: query.isEmpty && showSuggestions
                    ? _buildSearchHistory(context)
                    : _buildMovieResults(context, movieProvider),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFiltersSection(BuildContext context) {
    final movieProvider = Provider.of<MovieProvider>(context);
    final allGenres = _getAllGenres(movieProvider.movies);

    return Container(
      margin: EdgeInsets.all(16),
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Color(0xFF6366f1).withOpacity(0.08),
            blurRadius: 20,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF6366f1), Color(0xFF8b5cf6)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.filter_list, color: Colors.white, size: 20),
              ),
              SizedBox(width: 12),
              Text(
                'Bộ lọc nâng cao',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1a1a2e),
                ),
              ),
            ],
          ),
          SizedBox(height: 20),

          // Genre Filter
          Text(
            'Thể loại',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Color(0xFF64748b),
              letterSpacing: 0.5,
            ),
          ),
          SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: ['Tất cả', ...allGenres].map((genre) {
                final isSelected = _selectedGenre == genre;
                return Container(
                  margin: EdgeInsets.only(right: 8),
                  child: AnimatedContainer(
                    duration: Duration(milliseconds: 200),
                    child: InkWell(
                      onTap: () {
                        _selectedGenre = genre;
                        _filterNotifier.value++;
                      },
                      borderRadius: BorderRadius.circular(30),
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        decoration: BoxDecoration(
                          gradient: isSelected
                              ? LinearGradient(
                            colors: [Color(0xFF6366f1), Color(0xFF8b5cf6)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          )
                              : null,
                          color: isSelected ? null : Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(30),
                          border: Border.all(
                            color: isSelected ? Colors.transparent : Color(0xFFE2E8F0),
                            width: 1.5,
                          ),
                        ),
                        child: Text(
                          genre,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: isSelected ? Colors.white : Color(0xFF475569),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

          SizedBox(height: 20),

          // Status Filter
          Text(
            'Trạng thái',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Color(0xFF64748b),
              letterSpacing: 0.5,
            ),
          ),
          SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: ['Tất cả', 'Đang chiếu', 'Sắp chiếu'].map((status) {
                final isSelected = _selectedStatus == status;
                return Container(
                  margin: EdgeInsets.only(right: 8),
                  child: AnimatedContainer(
                    duration: Duration(milliseconds: 200),
                    child: InkWell(
                      onTap: () {
                        _selectedStatus = status;
                        _filterNotifier.value++;
                      },
                      borderRadius: BorderRadius.circular(30),
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        decoration: BoxDecoration(
                          gradient: isSelected
                              ? LinearGradient(
                            colors: [Color(0xFF6366f1), Color(0xFF8b5cf6)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          )
                              : null,
                          color: isSelected ? null : Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(30),
                          border: Border.all(
                            color: isSelected ? Colors.transparent : Color(0xFFE2E8F0),
                            width: 1.5,
                          ),
                        ),
                        child: Text(
                          status,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: isSelected ? Colors.white : Color(0xFF475569),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

          SizedBox(height: 20),

          // Rating Filter
          Text(
            'Đánh giá tối thiểu',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Color(0xFF64748b),
              letterSpacing: 0.5,
            ),
          ),
          SizedBox(height: 8),
          Row(
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF6366f1), Color(0xFF8b5cf6)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.star, color: Colors.white, size: 16),
                    SizedBox(width: 6),
                    Text(
                      _minRating.toStringAsFixed(1),
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: SliderTheme(
                  data: SliderThemeData(
                    activeTrackColor: Color(0xFF6366f1),
                    inactiveTrackColor: Color(0xFFE2E8F0),
                    thumbColor: Color(0xFF6366f1),
                    overlayColor: Color(0xFF6366f1).withOpacity(0.2),
                    trackHeight: 4,
                    thumbShape: RoundSliderThumbShape(enabledThumbRadius: 8),
                  ),
                  child: Slider(
                    value: _minRating,
                    min: 0.0,
                    max: 10.0,
                    divisions: 20,
                    onChanged: (value) {
                      _minRating = value;
                      _filterNotifier.value++;
                    },
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: 16),

          // Reset button
          Center(
            child: TextButton.icon(
              onPressed: () {
                _selectedGenre = 'Tất cả';
                _selectedStatus = 'Tất cả';
                _minRating = 0.0;
                _filterNotifier.value++;
              },
              style: TextButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                backgroundColor: Color(0xFFF1F5F9),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: Icon(Icons.refresh, color: Color(0xFF6366f1), size: 18),
              label: Text(
                'Đặt lại bộ lọc',
                style: TextStyle(
                  color: Color(0xFF6366f1),
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchHistory(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_searchHistory.isNotEmpty) ...[
            Padding(
              padding: EdgeInsets.fromLTRB(20, 20, 20, 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(Icons.history, color: Color(0xFF6366f1), size: 20),
                      SizedBox(width: 8),
                      Text(
                        'Tìm kiếm gần đây',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1a1a2e),
                        ),
                      ),
                    ],
                  ),
                  TextButton(
                    onPressed: () {
                      _searchHistory.clear();
                      _filterNotifier.value++;
                    },
                    child: Text(
                      'Xóa tất cả',
                      style: TextStyle(
                        color: Color(0xFF6366f1),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            ...(_searchHistory.take(5).map((historyQuery) => Container(
              margin: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 8,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: ListTile(
                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                leading: Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(Icons.history, color: Color(0xFF6366f1), size: 20),
                ),
                title: Text(
                  historyQuery,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF1a1a2e),
                  ),
                ),
                trailing: IconButton(
                  icon: Icon(Icons.close, color: Colors.grey[400], size: 20),
                  onPressed: () {
                    _searchHistory.remove(historyQuery);
                    _filterNotifier.value++;
                  },
                ),
                onTap: () {
                  query = historyQuery;
                  showResults(context);
                },
              ),
            ))),
            SizedBox(height: 16),
          ],

          Padding(
            padding: EdgeInsets.fromLTRB(20, 20, 20, 12),
            child: Row(
              children: [
                Icon(Icons.explore, color: Color(0xFF6366f1), size: 20),
                SizedBox(width: 8),
                Text(
                  'Gợi ý tìm kiếm',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1a1a2e),
                  ),
                ),
              ],
            ),
          ),
          _buildPopularSearches(context),
        ],
      ),
    );
  }

  Widget _buildPopularSearches(BuildContext context) {
    final popularSearches = [
      {'text': 'Phim hành động', 'icon': Icons.local_fire_department, 'color': Color(0xFFef4444)},
      {'text': 'Phim kinh dị', 'icon': Icons.sentiment_very_dissatisfied, 'color': Color(0xFF8b5cf6)},
      {'text': 'Phim lãng mạn', 'icon': Icons.favorite, 'color': Color(0xFFec4899)},
      {'text': 'Phim hoạt hình', 'icon': Icons.animation, 'color': Color(0xFF06b6d4)},
      {'text': 'Marvel', 'icon': Icons.support_sharp, 'color': Color(0xFFf59e0b)},
      {'text': 'DC Comics', 'icon': Icons.flash_on, 'color': Color(0xFF3b82f6)},
    ];

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Wrap(
        spacing: 10,
        runSpacing: 10,
        children: popularSearches.map((search) => InkWell(
          onTap: () {
            query = search['text'] as String;
            showResults(context);
          },
          borderRadius: BorderRadius.circular(30),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(30),
              border: Border.all(color: Color(0xFFE2E8F0), width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 8,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  search['icon'] as IconData,
                  color: search['color'] as Color,
                  size: 18,
                ),
                SizedBox(width: 8),
                Text(
                  search['text'] as String,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF475569),
                  ),
                ),
              ],
            ),
          ),
        )).toList(),
      ),
    );
  }

  Widget _buildMovieResults(BuildContext context, MovieProvider movieProvider) {
    final filteredMovies = _getFilteredMovies(movieProvider.movies);

    if (filteredMovies.isEmpty) {
      return Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color(0xFF6366f1).withOpacity(0.1),
                      Color(0xFF8b5cf6).withOpacity(0.1)
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.search_off,
                  size: 64,
                  color: Color(0xFF6366f1),
                ),
              ),
              SizedBox(height: 24),
              Text(
                'Không tìm thấy kết quả',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1a1a2e),
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Thử thay đổi từ khóa hoặc bộ lọc',
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF64748b),
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 24),
              if (_selectedGenre != 'Tất cả' || _selectedStatus != 'Tất cả' || _minRating > 0.0)
                Container(
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Color(0xFFE2E8F0), width: 1.5),
                  ),
                  child: Column(
                    children: [
                      Text(
                        'Bộ lọc hiện tại:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1a1a2e),
                          fontSize: 14,
                        ),
                      ),
                      SizedBox(height: 12),
                      if (_selectedGenre != 'Tất cả')
                        _buildFilterChip('Thể loại: $_selectedGenre', Icons.category),
                      if (_selectedStatus != 'Tất cả')
                        _buildFilterChip('Trạng thái: $_selectedStatus', Icons.play_circle),
                      if (_minRating > 0.0)
                        _buildFilterChip('Đánh giá: ≥ ${_minRating.toStringAsFixed(1)}', Icons.star),
                    ],
                  ),
                ),
            ],
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: EdgeInsets.all(16),
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 8,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.movie_filter, color: Color(0xFF6366f1), size: 18),
                  SizedBox(width: 8),
                  Text(
                    'Tìm thấy ${filteredMovies.length} kết quả',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF475569),
                    ),
                  ),
                ],
              ),
              if (_selectedGenre != 'Tất cả' || _selectedStatus != 'Tất cả' || _minRating > 0.0)
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF6366f1), Color(0xFF8b5cf6)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${_getActiveFilterCount()} bộ lọc',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: EdgeInsets.symmetric(horizontal: 16),
            itemCount: filteredMovies.length,
            itemBuilder: (context, index) {
              final movie = filteredMovies[index];
              return _buildMovieCard(context, movie);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildFilterChip(String text, IconData icon) {
    return Container(
      margin: EdgeInsets.only(bottom: 8),
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Color(0xFF6366f1)),
          SizedBox(width: 6),
          Text(
            text,
            style: TextStyle(
              fontSize: 12,
              color: Color(0xFF475569),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMovieCard(BuildContext context, Movie movie) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          _addToSearchHistory(query);
          close(context, null);
          Navigator.pushNamed(
            context,
            '/movie-detail',
            arguments: movie.id,
          );
        },
        child: Padding(
          padding: EdgeInsets.all(12),
          child: Row(
            children: [
              // Movie Poster
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: movie.posterUrl.isNotEmpty
                    ? Container(
                  width: 60,
                  height: 90,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: NetworkImage(movie.posterUrl),
                      fit: BoxFit.cover,
                    ),
                  ),
                )
                    : Container(
                  width: 60,
                  height: 90,
                  color: Colors.grey[300],
                  child: Icon(Icons.movie, color: Colors.grey[600]),
                ),
              ),

              SizedBox(width: 12),

              // Movie Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      movie.title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),

                    SizedBox(height: 4),

                    if (movie.director.isNotEmpty)
                      Text(
                        'Đạo diễn: ${movie.director}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),

                    SizedBox(height: 4),

                    Row(
                      children: [
                        Icon(Icons.star, color: Colors.amber, size: 16),
                        SizedBox(width: 4),
                        Text(
                          movie.rating.toString(),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[700],
                          ),
                        ),
                        SizedBox(width: 12),
                        Icon(Icons.access_time, color: Colors.grey[500], size: 16),
                        SizedBox(width: 4),
                        Text(
                          '${movie.duration} phút',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 4),

                    if (movie.genres.isNotEmpty)
                      Wrap(
                        children: movie.genres.take(3).map((genre) => Container(
                          margin: EdgeInsets.only(right: 4, top: 2),
                          padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Theme.of(context).primaryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            genre,
                            style: TextStyle(
                              fontSize: 10,
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                        )).toList(),
                      ),
                  ],
                ),
              ),

              // Status badge
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _getStatusColor(movie.status),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _getStatusText(movie.status),
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper method to count active filters
  int _getActiveFilterCount() {
    int count = 0;
    if (_selectedGenre != 'Tất cả') count++;
    if (_selectedStatus != 'Tất cả') count++;
    if (_minRating > 0.0) count++;
    return count;
  }

  List<Movie> _getFilteredMovies(List<Movie> movies) {
    var filtered = movies.where((movie) {
      // Text search
      bool matchesQuery = true;
      if (query.isNotEmpty) {
        final queryLower = query.toLowerCase();
        matchesQuery = movie.title.toLowerCase().contains(queryLower) ||
            movie.director.toLowerCase().contains(queryLower) ||
            movie.cast.any((actor) => actor.toLowerCase().contains(queryLower)) ||
            movie.genres.any((genre) => genre.toLowerCase().contains(queryLower));
      }

      // Genre filter
      bool matchesGenre = true;
      if (_selectedGenre != 'Tất cả') {
        matchesGenre = movie.genres.contains(_selectedGenre);
      }

      // Status filter
      bool matchesStatus = true;
      if (_selectedStatus != 'Tất cả') {
        final movieStatusText = _getStatusText(movie.status);
        matchesStatus = movieStatusText == _selectedStatus;
      }

      // Rating filter
      bool matchesRating = movie.rating >= _minRating;

      return matchesQuery && matchesGenre && matchesStatus && matchesRating;
    }).toList();

    // Sort by relevance
    filtered.sort((a, b) {
      if (query.isNotEmpty) {
        final queryLower = query.toLowerCase();
        final aExactMatch = a.title.toLowerCase() == queryLower;
        final bExactMatch = b.title.toLowerCase() == queryLower;

        if (aExactMatch && !bExactMatch) return -1;
        if (!aExactMatch && bExactMatch) return 1;

        final aTitleStartsWith = a.title.toLowerCase().startsWith(queryLower);
        final bTitleStartsWith = b.title.toLowerCase().startsWith(queryLower);

        if (aTitleStartsWith && !bTitleStartsWith) return -1;
        if (!aTitleStartsWith && bTitleStartsWith) return 1;
      }

      return b.rating.compareTo(a.rating);
    });

    return filtered;
  }

  List<String> _getAllGenres(List<Movie> movies) {
    final allGenres = <String>{};
    for (final movie in movies) {
      allGenres.addAll(movie.genres);
    }
    return allGenres.toList()..sort();
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'now_showing':
        return Colors.green;
      case 'coming_soon':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'now_showing':
        return 'Đang chiếu';
      case 'coming_soon':
        return 'Sắp chiếu';
      default:
        return 'Đã chiếu';
    }
  }

  void _addToSearchHistory(String searchQuery) {
    if (searchQuery.isNotEmpty && !_searchHistory.contains(searchQuery)) {
      _searchHistory.insert(0, searchQuery);
      if (_searchHistory.length > 10) {
        _searchHistory.removeLast();
      }
    }
  }

  @override
  void dispose() {
    _filterNotifier.dispose();
    super.dispose();
  }
}