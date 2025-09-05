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

  // FIX: Thêm ValueNotifier để trigger rebuild
  final ValueNotifier<int> _filterNotifier = ValueNotifier<int>(0);

  @override
  String get searchFieldLabel => 'Tìm kiếm phim, diễn viên, đạo diễn...';

  @override
  ThemeData appBarTheme(BuildContext context) {
    return Theme.of(context).copyWith(
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.grey[800]),
        titleTextStyle: TextStyle(
          color: Colors.grey[800],
          fontSize: 18,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: InputBorder.none,
        hintStyle: TextStyle(color: Colors.grey[400]),
      ),
    );
  }

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      if (query.isNotEmpty)
        IconButton(
          icon: Icon(Icons.clear, color: Colors.grey[600]),
          onPressed: () {
            query = '';
          },
        ),
      IconButton(
        icon: Icon(
          _showFilters ? Icons.filter_list : Icons.filter_list_outlined,
          color: _showFilters ? Theme.of(context).primaryColor : Colors.grey[600],
        ),
        onPressed: () {
          _showFilters = !_showFilters;
          _filterNotifier.value++;
        },
      ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.arrow_back, color: Colors.grey[800]),
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

    // FIX: Sử dụng ValueListenableBuilder để lắng nghe thay đổi filter
    return ValueListenableBuilder<int>(
      valueListenable: _filterNotifier,
      builder: (context, value, child) {
        return Column(
          children: [
            // Filters Section
            if (_showFilters) _buildFiltersSection(context),

            // Search Results
            Expanded(
              child: query.isEmpty && showSuggestions
                  ? _buildSearchHistory(context)
                  : _buildMovieResults(context, movieProvider),
            ),
          ],
        );
      },
    );
  }

  Widget _buildFiltersSection(BuildContext context) {
    final movieProvider = Provider.of<MovieProvider>(context);
    final allGenres = _getAllGenres(movieProvider.movies);

    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        border: Border(bottom: BorderSide(color: Colors.grey[200]!)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Bộ lọc',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          SizedBox(height: 12),

          // Genre Filter
          Row(
            children: [
              Text('Thể loại: ', style: TextStyle(fontWeight: FontWeight.w500)),
              SizedBox(width: 8),
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: ['Tất cả', ...allGenres].map((genre) {
                      final isSelected = _selectedGenre == genre;
                      return Container(
                        margin: EdgeInsets.only(right: 8),
                        child: FilterChip(
                          label: Text(genre),
                          selected: isSelected,
                          onSelected: (selected) {
                            // FIX: Cập nhật state và trigger rebuild
                            _selectedGenre = selected ? genre : 'Tất cả';
                            _filterNotifier.value++;
                          },
                          backgroundColor: Colors.white,
                          selectedColor: Theme.of(context).primaryColor.withOpacity(0.2),
                          checkmarkColor: Theme.of(context).primaryColor,
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: 8),

          // Status Filter
          Row(
            children: [
              Text('Trạng thái: ', style: TextStyle(fontWeight: FontWeight.w500)),
              SizedBox(width: 8),
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: ['Tất cả', 'Đang chiếu', 'Sắp chiếu'].map((status) {
                      final isSelected = _selectedStatus == status;
                      return Container(
                        margin: EdgeInsets.only(right: 8),
                        child: FilterChip(
                          label: Text(status),
                          selected: isSelected,
                          onSelected: (selected) {
                            // FIX: Cập nhật state và trigger rebuild
                            _selectedStatus = selected ? status : 'Tất cả';
                            _filterNotifier.value++;
                          },
                          backgroundColor: Colors.white,
                          selectedColor: Theme.of(context).primaryColor.withOpacity(0.2),
                          checkmarkColor: Theme.of(context).primaryColor,
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: 8),

          // Rating Filter
          Row(
            children: [
              Text('Đánh giá tối thiểu: ', style: TextStyle(fontWeight: FontWeight.w500)),
              Text(
                _minRating.toStringAsFixed(1),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).primaryColor,
                ),
              ),
              Expanded(
                child: Slider(
                  value: _minRating,
                  min: 0.0,
                  max: 10.0,
                  divisions: 20,
                  onChanged: (value) {
                    // FIX: Cập nhật state và trigger rebuild
                    _minRating = value;
                    _filterNotifier.value++;
                  },
                ),
              ),
            ],
          ),

          // Reset filter button
          SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton.icon(
                onPressed: () {
                  _selectedGenre = 'Tất cả';
                  _selectedStatus = 'Tất cả';
                  _minRating = 0.0;
                  _filterNotifier.value++;
                },
                icon: Icon(Icons.refresh),
                label: Text('Đặt lại bộ lọc'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSearchHistory(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_searchHistory.isNotEmpty) ...[
          Padding(
            padding: EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Tìm kiếm gần đây',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
                TextButton(
                  onPressed: () {
                    _searchHistory.clear();
                    _filterNotifier.value++;
                  },
                  child: Text('Xóa tất cả'),
                ),
              ],
            ),
          ),
          ...(_searchHistory.take(5).map((historyQuery) => ListTile(
            leading: Icon(Icons.history, color: Colors.grey[400]),
            title: Text(historyQuery),
            trailing: IconButton(
              icon: Icon(Icons.close, color: Colors.grey[400]),
              onPressed: () {
                _searchHistory.remove(historyQuery);
                _filterNotifier.value++;
              },
            ),
            onTap: () {
              query = historyQuery;
              showResults(context);
            },
          ))),
        ],

        // Popular searches or trending movies
        Padding(
          padding: EdgeInsets.all(16),
          child: Text(
            'Gợi ý tìm kiếm',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
        ),
        _buildPopularSearches(context),
      ],
    );
  }

  Widget _buildPopularSearches(BuildContext context) {
    final popularSearches = [
      'Phim hành động',
      'Phim kinh dị',
      'Phim lãng mạn',
      'Phim hoạt hình',
      'Marvel',
      'DC Comics',
    ];

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Wrap(
        spacing: 8,
        runSpacing: 4,
        children: popularSearches.map((search) => ActionChip(
          label: Text(search),
          onPressed: () {
            query = search;
            showResults(context);
          },
          backgroundColor: Colors.grey[100],
        )).toList(),
      ),
    );
  }

  Widget _buildMovieResults(BuildContext context, MovieProvider movieProvider) {
    final filteredMovies = _getFilteredMovies(movieProvider.movies);

    if (filteredMovies.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 64,
              color: Colors.grey[400],
            ),
            SizedBox(height: 16),
            Text(
              'Không tìm thấy kết quả',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Thử thay đổi từ khóa hoặc bộ lọc',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
            ),
            SizedBox(height: 16),
            // Show current filter status
            if (_selectedGenre != 'Tất cả' || _selectedStatus != 'Tất cả' || _minRating > 0.0)
              Container(
                padding: EdgeInsets.all(12),
                margin: EdgeInsets.symmetric(horizontal: 32),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    Text('Bộ lọc hiện tại:', style: TextStyle(fontWeight: FontWeight.bold)),
                    SizedBox(height: 4),
                    if (_selectedGenre != 'Tất cả')
                      Text('Thể loại: $_selectedGenre'),
                    if (_selectedStatus != 'Tất cả')
                      Text('Trạng thái: $_selectedStatus'),
                    if (_minRating > 0.0)
                      Text('Đánh giá: ≥ ${_minRating.toStringAsFixed(1)}'),
                  ],
                ),
              ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Tìm thấy ${filteredMovies.length} kết quả',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
              // Show active filters count
              if (_selectedGenre != 'Tất cả' || _selectedStatus != 'Tất cả' || _minRating > 0.0)
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${_getActiveFilterCount()} bộ lọc',
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context).primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
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