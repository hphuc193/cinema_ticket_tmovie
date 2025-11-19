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
        iconTheme: IconThemeData(color: Colors.black87),
        titleTextStyle: TextStyle(
          color: Colors.black87,
          fontSize: 17,
          fontWeight: FontWeight.w500,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: InputBorder.none,
        hintStyle: TextStyle(
          color: Colors.grey[400],
          fontSize: 17,
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
          icon: Icon(Icons.close, color: Colors.grey[600], size: 22),
          onPressed: () {
            query = '';
          },
        ),
      Container(
        margin: EdgeInsets.only(right: 8),
        child: IconButton(
          icon: Container(
            padding: EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: _showFilters
                  ? Theme.of(context).primaryColor.withOpacity(0.1)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.tune_rounded,
              color: _showFilters
                  ? Theme.of(context).primaryColor
                  : Colors.grey[600],
              size: 22,
            ),
          ),
          onPressed: () {
            _showFilters = !_showFilters;
            _filterNotifier.value++;
          },
        ),
      ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.arrow_back_ios_new_rounded, color: Colors.black87, size: 20),
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
        return Column(
          children: [
            if (_showFilters) _buildFiltersSection(context),
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
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Colors.grey[100]!, width: 1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Bộ lọc tìm kiếm',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              TextButton.icon(
                onPressed: () {
                  _selectedGenre = 'Tất cả';
                  _selectedStatus = 'Tất cả';
                  _minRating = 0.0;
                  _filterNotifier.value++;
                },
                icon: Icon(Icons.refresh_rounded, size: 18),
                label: Text('Đặt lại'),
                style: TextButton.styleFrom(
                  foregroundColor: Theme.of(context).primaryColor,
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
              ),
            ],
          ),

          SizedBox(height: 16),

          // Genre Filter
          _buildFilterLabel('Thể loại'),
          SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: ['Tất cả', ...allGenres].map((genre) {
                final isSelected = _selectedGenre == genre;
                return Container(
                  margin: EdgeInsets.only(right: 8),
                  child: InkWell(
                    onTap: () {
                      _selectedGenre = isSelected ? 'Tất cả' : genre;
                      _filterNotifier.value++;
                    },
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? Theme.of(context).primaryColor
                            : Colors.grey[100],
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isSelected
                              ? Theme.of(context).primaryColor
                              : Colors.transparent,
                          width: 1,
                        ),
                      ),
                      child: Text(
                        genre,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: isSelected ? Colors.white : Colors.black87,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

          SizedBox(height: 16),

          // Status Filter
          _buildFilterLabel('Trạng thái'),
          SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: ['Tất cả', 'Đang chiếu', 'Sắp chiếu'].map((status) {
                final isSelected = _selectedStatus == status;
                return Container(
                  margin: EdgeInsets.only(right: 8),
                  child: InkWell(
                    onTap: () {
                      _selectedStatus = isSelected ? 'Tất cả' : status;
                      _filterNotifier.value++;
                    },
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? Theme.of(context).primaryColor
                            : Colors.grey[100],
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isSelected
                              ? Theme.of(context).primaryColor
                              : Colors.transparent,
                          width: 1,
                        ),
                      ),
                      child: Text(
                        status,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: isSelected ? Colors.white : Colors.black87,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

          SizedBox(height: 16),

          // Rating Filter
          _buildFilterLabel('Đánh giá tối thiểu'),
          SizedBox(height: 4),
          Row(
            children: [
              Expanded(
                child: SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    activeTrackColor: Theme.of(context).primaryColor,
                    inactiveTrackColor: Colors.grey[200],
                    thumbColor: Theme.of(context).primaryColor,
                    overlayColor: Theme.of(context).primaryColor.withOpacity(0.2),
                    thumbShape: RoundSliderThumbShape(enabledThumbRadius: 10),
                    overlayShape: RoundSliderOverlayShape(overlayRadius: 20),
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
              Container(
                width: 60,
                alignment: Alignment.center,
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.star_rounded,
                      color: Theme.of(context).primaryColor,
                      size: 16,
                    ),
                    SizedBox(width: 4),
                    Text(
                      _minRating.toStringAsFixed(1),
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilterLabel(String label) {
    return Text(
      label,
      style: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: Colors.grey[700],
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
                  Text(
                    'Tìm kiếm gần đây',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      _searchHistory.clear();
                      _filterNotifier.value++;
                    },
                    child: Text(
                      'Xóa tất cả',
                      style: TextStyle(fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),
            ...(_searchHistory.take(5).map((historyQuery) => InkWell(
              onTap: () {
                query = historyQuery;
                showResults(context);
              },
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                child: Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.history_rounded,
                        color: Colors.grey[600],
                        size: 20,
                      ),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        historyQuery,
                        style: TextStyle(
                          fontSize: 15,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.close, color: Colors.grey[400], size: 20),
                      onPressed: () {
                        _searchHistory.remove(historyQuery);
                        _filterNotifier.value++;
                      },
                    ),
                  ],
                ),
              ),
            ))),
            SizedBox(height: 8),
          ],

          // Popular searches
          Padding(
            padding: EdgeInsets.fromLTRB(20, 20, 20, 12),
            child: Text(
              'Gợi ý tìm kiếm',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ),
          _buildPopularSearches(context),
          SizedBox(height: 20),
        ],
      ),
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
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: Wrap(
        spacing: 10,
        runSpacing: 10,
        children: popularSearches.map((search) => InkWell(
          onTap: () {
            query = search;
            showResults(context);
          },
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.grey[200]!, width: 1),
            ),
            child: Text(
              search,
              style: TextStyle(
                fontSize: 14,
                color: Colors.black87,
                fontWeight: FontWeight.w500,
              ),
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
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.search_off_rounded,
                  size: 64,
                  color: Colors.grey[400],
                ),
              ),
              SizedBox(height: 24),
              Text(
                'Không tìm thấy kết quả',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Thử thay đổi từ khóa hoặc bộ lọc',
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.grey[600],
                ),
              ),
              SizedBox(height: 24),
              if (_selectedGenre != 'Tất cả' || _selectedStatus != 'Tất cả' || _minRating > 0.0)
                Container(
                  padding: EdgeInsets.all(16),
                  margin: EdgeInsets.symmetric(horizontal: 32),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey[200]!),
                  ),
                  child: Column(
                    children: [
                      Text(
                        'Bộ lọc hiện tại:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: Colors.black87,
                        ),
                      ),
                      SizedBox(height: 8),
                      if (_selectedGenre != 'Tất cả')
                        _buildFilterChip('Thể loại: $_selectedGenre'),
                      if (_selectedStatus != 'Tất cả')
                        _buildFilterChip('Trạng thái: $_selectedStatus'),
                      if (_minRating > 0.0)
                        _buildFilterChip('Đánh giá: ≥ ${_minRating.toStringAsFixed(1)}'),
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
        Padding(
          padding: EdgeInsets.fromLTRB(20, 16, 20, 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${filteredMovies.length} kết quả',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              if (_selectedGenre != 'Tất cả' || _selectedStatus != 'Tất cả' || _minRating > 0.0)
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.filter_alt_rounded,
                        size: 14,
                        color: Theme.of(context).primaryColor,
                      ),
                      SizedBox(width: 4),
                      Text(
                        '${_getActiveFilterCount()}',
                        style: TextStyle(
                          fontSize: 13,
                          color: Theme.of(context).primaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
        Expanded(
          child: ListView.separated(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            itemCount: filteredMovies.length,
            separatorBuilder: (context, index) => SizedBox(height: 12),
            itemBuilder: (context, index) {
              final movie = filteredMovies[index];
              return _buildMovieCard(context, movie);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildFilterChip(String text) {
    return Container(
      margin: EdgeInsets.only(top: 4),
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: TextStyle(fontSize: 12, color: Colors.grey[700]),
      ),
    );
  }

  Widget _buildMovieCard(BuildContext context, Movie movie) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      elevation: 0,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          _addToSearchHistory(query);
          close(context, null);
          Navigator.pushNamed(
            context,
            '/movie-detail',
            arguments: movie.id,
          );
        },
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[200]!),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: EdgeInsets.all(12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Movie Poster
                Hero(
                  tag: 'movie_${movie.id}',
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: movie.posterUrl.isNotEmpty
                        ? Container(
                      width: 70,
                      height: 100,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: NetworkImage(movie.posterUrl),
                          fit: BoxFit.cover,
                        ),
                      ),
                    )
                        : Container(
                      width: 70,
                      height: 100,
                      color: Colors.grey[200],
                      child: Icon(Icons.movie_rounded, color: Colors.grey[400], size: 32),
                    ),
                  ),
                ),

                SizedBox(width: 12),

                // Movie Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              movie.title,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                                height: 1.3,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          SizedBox(width: 8),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: _getStatusColor(movie.status),
                              borderRadius: BorderRadius.circular(8),
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

                      SizedBox(height: 6),

                      if (movie.director.isNotEmpty)
                        Text(
                          movie.director,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[600],
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),

                      SizedBox(height: 8),

                      Row(
                        children: [
                          Icon(Icons.star_rounded, color: Colors.amber[700], size: 16),
                          SizedBox(width: 4),
                          Text(
                            movie.rating.toString(),
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          SizedBox(width: 12),
                          Icon(Icons.access_time_rounded, color: Colors.grey[500], size: 16),
                          SizedBox(width: 4),
                          Text(
                            '${movie.duration} phút',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),

                      if (movie.genres.isNotEmpty) ...[
                        SizedBox(height: 8),
                        Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: movie.genres.take(3).map((genre) => Container(
                            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Theme.of(context).primaryColor.withOpacity(0.08),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              genre,
                              style: TextStyle(
                                fontSize: 11,
                                color: Theme.of(context).primaryColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          )).toList(),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  int _getActiveFilterCount() {
    int count = 0;
    if (_selectedGenre != 'Tất cả') count++;
    if (_selectedStatus != 'Tất cả') count++;
    if (_minRating > 0.0) count++;
    return count;
  }

  List<Movie> _getFilteredMovies(List<Movie> movies) {
    var filtered = movies.where((movie) {
      bool matchesQuery = true;
      if (query.isNotEmpty) {
        final queryLower = query.toLowerCase();
        matchesQuery = movie.title.toLowerCase().contains(queryLower) ||
            movie.director.toLowerCase().contains(queryLower) ||
            movie.cast.any((actor) => actor.toLowerCase().contains(queryLower)) ||
            movie.genres.any((genre) => genre.toLowerCase().contains(queryLower));
      }

      bool matchesGenre = true;
      if (_selectedGenre != 'Tất cả') {
        matchesGenre = movie.genres.contains(_selectedGenre);
      }

      bool matchesStatus = true;
      if (_selectedStatus != 'Tất cả') {
        final movieStatusText = _getStatusText(movie.status);
        matchesStatus = movieStatusText == _selectedStatus;
      }

      bool matchesRating = movie.rating >= _minRating;

      return matchesQuery && matchesGenre && matchesStatus && matchesRating;
    }).toList();

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
        return Colors.green[600]!;
      case 'coming_soon':
        return Colors.orange[600]!;
      default:
        return Colors.grey[600]!;
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