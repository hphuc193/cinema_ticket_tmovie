// lib/screens/home_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/movie_provider.dart';
import '../providers/auth_provider.dart';
import '../providers/theme_provider.dart';
import '../widgets/movie_card.dart';
import '../widgets/movie_carousel.dart';
import '../widgets/bottom_nav_bar.dart';
import '../models/movie_model.dart';
import '../widgets/movie_search_delegate.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  int _currentIndex = 0;
  String _selectedCategory = 'now_showing';
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: Duration(milliseconds: 500),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<MovieProvider>(context, listen: false).fetchMovies();
      _animationController.forward();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final movieProvider = Provider.of<MovieProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.isDarkMode;

    return Scaffold(
      backgroundColor: isDarkMode ? Color(0xFF0A0A0A) : Color(0xFFF5F5F5),
      body: CustomScrollView(
        slivers: [
          _buildModernAppBar(context, isDarkMode),
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 20),
                _buildFeaturedSection(movieProvider, isDarkMode),
                SizedBox(height: 30),
                _buildCategoryTabs(isDarkMode),
                SizedBox(height: 20),
                _buildMoviesByCategory(movieProvider, isDarkMode, 'Phim Hành Động', 'action'),
                SizedBox(height: 30),
                _buildMoviesByCategory(movieProvider, isDarkMode, 'Phim Kinh Dị', 'horror'),
                SizedBox(height: 30),
                _buildMoviesByCategory(movieProvider, isDarkMode, 'Phim Hài', 'comedy'),
                SizedBox(height: 30),
                _buildAllMoviesGrid(movieProvider, isDarkMode),
                SizedBox(height: 100),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
          _handleNavigation(index);
        },
      ),
    );
  }

  Widget _buildModernAppBar(BuildContext context, bool isDarkMode) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return SliverAppBar(
      expandedHeight: 0,
      floating: true,
      pinned: true,
      backgroundColor: isDarkMode ? Color(0xFF0A0A0A) : Colors.white,
      elevation: 0,
      automaticallyImplyLeading: false,
      title: Row(
        children: [
          // Logo/Title
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Theme.of(context).primaryColor,
                  Theme.of(context).primaryColor.withOpacity(0.7),
                ],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              'CINEMA',
              style: TextStyle(
                fontWeight: FontWeight.w900,
                color: Colors.white,
                fontSize: 18,
                letterSpacing: 1.5,
              ),
            ),
          ),
          Spacer(),
          // Search button
          _buildIconButton(
            Icons.search_rounded,
            isDarkMode,
                () {
              showSearch(context: context, delegate: EnhancedMovieSearchDelegate());
            },
          ),
          SizedBox(width: 8),
          // Theme toggle
          _buildIconButton(
            isDarkMode ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
            isDarkMode,
                () {
              themeProvider.toggleTheme();
            },
          ),
          SizedBox(width: 8),
          // Profile button
          _buildIconButton(
            Icons.person_rounded,
            isDarkMode,
                () {
              Navigator.pushNamed(context, '/profile');
            },
          ),
        ],
      ),
    );
  }

  Widget _buildIconButton(IconData icon, bool isDarkMode, VoidCallback onPressed) {
    return Container(
      decoration: BoxDecoration(
        color: isDarkMode ? Color(0xFF1A1A1A) : Color(0xFFF0F0F0),
        borderRadius: BorderRadius.circular(12),
      ),
      child: IconButton(
        icon: Icon(icon, size: 22),
        color: isDarkMode ? Colors.white : Colors.grey[800],
        onPressed: onPressed,
        padding: EdgeInsets.all(8),
        constraints: BoxConstraints(),
      ),
    );
  }

  Widget _buildFeaturedSection(MovieProvider movieProvider, bool isDarkMode) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            'Nổi Bật',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: isDarkMode ? Colors.white : Colors.grey[900],
              letterSpacing: -0.5,
            ),
          ),
        ),
        SizedBox(height: 15),
        Container(
          height: 250,
          child: movieProvider.featuredMovies.isEmpty
              ? Center(child: CircularProgressIndicator())
              : PageView.builder(
            controller: PageController(viewportFraction: 1.0),
            itemCount: movieProvider.featuredMovies.take(5).length,
            itemBuilder: (context, index) {
              final movie = movieProvider.featuredMovies[index];
              return _buildFeaturedCard(movie, isDarkMode);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildFeaturedCard(Movie movie, bool isDarkMode) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 8),
      child: GestureDetector(
        onTap: () {
          Navigator.pushNamed(
            context,
            '/movie-detail',
            arguments: movie.id,
          );
        },
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Movie poster
              Image.network(
                movie.posterUrl,
                fit: BoxFit.cover,
              ),
              // Gradient overlay
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.3),
                      Colors.black.withOpacity(0.9),
                    ],
                    stops: [0.3, 0.6, 1.0],
                  ),
                ),
              ),
              // Movie info
              Positioned(
                left: 20,
                right: 20,
                bottom: 20,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Rating badge
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.amber,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.star, color: Colors.white, size: 16),
                          SizedBox(width: 4),
                          Text(
                            movie.rating.toString(),
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 12),
                    // Title
                    Text(
                      movie.title,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 8),
                    // Info row
                    Row(
                      children: [
                        _buildInfoChip(Icons.access_time, '${movie.duration}m'),
                        SizedBox(width: 8),
                        _buildInfoChip(Icons.calendar_today, _formatYear(movie.releaseDate)),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String text) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 14),
          SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryTabs(bool isDarkMode) {
    return Container(
      height: 50,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 20),
        children: [
          _buildCategoryChip('Đang Chiếu', 'now_showing', isDarkMode),
          SizedBox(width: 12),
          _buildCategoryChip('Sắp Chiếu', 'coming_soon', isDarkMode),
        ],
      ),
    );
  }

  Widget _buildCategoryChip(String title, String category, bool isDarkMode) {
    final isSelected = _selectedCategory == category;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedCategory = category;
        });
      },
      child: AnimatedContainer(
        duration: Duration(milliseconds: 300),
        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          gradient: isSelected
              ? LinearGradient(
            colors: [
              Theme.of(context).primaryColor,
              Theme.of(context).primaryColor.withOpacity(0.8),
            ],
          )
              : null,
          color: isSelected ? null : (isDarkMode ? Color(0xFF1A1A1A) : Colors.white),
          borderRadius: BorderRadius.circular(25),
          boxShadow: isSelected
              ? [
            BoxShadow(
              color: Theme.of(context).primaryColor.withOpacity(0.3),
              blurRadius: 8,
              offset: Offset(0, 4),
            ),
          ]
              : [],
        ),
        child: Text(
          title,
          style: TextStyle(
            color: isSelected ? Colors.white : (isDarkMode ? Colors.grey[400] : Colors.grey[700]),
            fontWeight: FontWeight.w700,
            fontSize: 15,
          ),
        ),
      ),
    );
  }

  Widget _buildMoviesByCategory(MovieProvider movieProvider, bool isDarkMode, String title, String category) {
    final movies = movieProvider.getMoviesByStatus(_selectedCategory).take(10).toList();

    if (movies.isEmpty) return SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: isDarkMode ? Colors.white : Colors.grey[900],
                ),
              ),
              TextButton(
                onPressed: () {},
                child: Text(
                  'Xem tất cả',
                  style: TextStyle(
                    color: Theme.of(context).primaryColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 12),
        Container(
          height: 280,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: 20),
            itemCount: movies.length,
            itemBuilder: (context, index) {
              final movie = movies[index];
              return _buildHorizontalMovieCard(movie, isDarkMode);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildHorizontalMovieCard(Movie movie, bool isDarkMode) {
    return Container(
      width: 160,
      margin: EdgeInsets.only(right: 16),
      child: GestureDetector(
        onTap: () {
          Navigator.pushNamed(
            context,
            '/movie-detail',
            arguments: movie.id,
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Poster
            Container(
              height: 220,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 8,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.network(
                      movie.posterUrl,
                      fit: BoxFit.cover,
                    ),
                    // Rating badge
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.7),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.star, color: Colors.amber, size: 12),
                            SizedBox(width: 2),
                            Text(
                              movie.rating.toString(),
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 8),
            // Title
            Text(
              movie.title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: isDarkMode ? Colors.white : Colors.grey[900],
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAllMoviesGrid(MovieProvider movieProvider, bool isDarkMode) {
    if (movieProvider.isLoading) {
      return Container(
        height: 200,
        child: Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor),
          ),
        ),
      );
    }

    final movies = movieProvider.getMoviesByStatus(_selectedCategory);

    if (movies.isEmpty) {
      return Container(
        height: 200,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.movie_outlined,
                size: 64,
                color: isDarkMode ? Colors.grey[700] : Colors.grey[400],
              ),
              SizedBox(height: 16),
              Text(
                'Không có phim nào',
                style: TextStyle(
                  fontSize: 18,
                  color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                  fontWeight: FontWeight.w600,
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
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            'Tất Cả Phim',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: isDarkMode ? Colors.white : Colors.grey[900],
            ),
          ),
        ),
        SizedBox(height: 12),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: GridView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              childAspectRatio: 0.55,
              crossAxisSpacing: 12,
              mainAxisSpacing: 16,
            ),
            itemCount: movies.length,
            itemBuilder: (context, index) {
              final movie = movies[index];
              return _buildCompactMovieCard(movie, isDarkMode);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCompactMovieCard(Movie movie, bool isDarkMode) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(
          context,
          '/movie-detail',
          arguments: movie.id,
        );
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 6,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.network(
                      movie.posterUrl,
                      fit: BoxFit.cover,
                    ),
                    Positioned(
                      top: 6,
                      right: 6,
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.7),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.star, color: Colors.amber, size: 10),
                            SizedBox(width: 2),
                            Text(
                              movie.rating.toString(),
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SizedBox(height: 6),
          Text(
            movie.title,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: isDarkMode ? Colors.white : Colors.grey[900],
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  String _formatYear(DateTime date) {
    return date.year.toString();
  }

  String _formatReleaseDate(DateTime date) {
    final months = [
      'T1', 'T2', 'T3', 'T4', 'T5', 'T6',
      'T7', 'T8', 'T9', 'T10', 'T11', 'T12'
    ];
    return '${date.day}/${months[date.month - 1]}/${date.year}';
  }

  void _handleNavigation(int index) {
    switch (index) {
      case 0:
        break;
      case 1:
        Navigator.pushNamed(context, '/tickets');
        break;
      case 2:
        Navigator.pushNamed(context, '/profile');
        break;
    }
  }
}