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
      backgroundColor: isDarkMode ? Color(0xFF121212) : Color(0xFFF8F9FA),
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(context, isDarkMode),
          SliverList(
            delegate: SliverChildListDelegate([
              _buildWelcomeSection(isDarkMode),
              _buildMovieCarousel(movieProvider),
              _buildCategorySection(isDarkMode),
              _buildMoviesGrid(movieProvider, isDarkMode),
              SizedBox(height: 80), // Space for bottom nav
            ]),
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

  Widget _buildSliverAppBar(BuildContext context, bool isDarkMode) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return SliverAppBar(
      expandedHeight: 120,
      floating: false,
      pinned: true,
      backgroundColor: Colors.transparent,
      elevation: 0,
      automaticallyImplyLeading: false,
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
      title: Row(
        children: [
          Expanded(
            child: Center(
              child: Text(
                'Cinema Ticket',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  fontSize: 22,
                ),
              ),
            ),
          ),
          Container(
            margin: EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(25),
            ),
            child: IconButton(
              icon: Icon(Icons.search, color: Colors.white),
              onPressed: () {
                showSearch(context: context, delegate: EnhancedMovieSearchDelegate());
              },
            ),
          ),
          Container(
            margin: EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(25),
            ),
            child: IconButton(
              icon: Icon(
                isDarkMode ? Icons.light_mode : Icons.dark_mode,
                color: Colors.white,
              ),
              onPressed: () {
                themeProvider.toggleTheme();
              },
            ),
          ),
          Container(
            margin: EdgeInsets.only(right: 16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(25),
            ),
            child: IconButton(
              icon: Icon(Icons.person, color: Colors.white),
              onPressed: () {
                Navigator.pushNamed(context, '/profile');
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWelcomeSection(bool isDarkMode) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Container(
        margin: EdgeInsets.all(20),
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDarkMode
                ? [
              Colors.grey.shade800,
              Colors.grey.shade700,
            ]
                : [
              Colors.blue.shade50,
              Colors.purple.shade50,
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDarkMode ? 0.3 : 0.1),
              blurRadius: 10,
              offset: Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Chào mừng đến với',
                    style: TextStyle(
                      fontSize: 16,
                      color: isDarkMode ? Colors.grey[300] : Colors.grey[600],
                    ),
                  ),
                  Text(
                    'Cinema World',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: isDarkMode ? Colors.white : Colors.grey[800],
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Trải nghiệm điện ảnh tuyệt vời',
                    style: TextStyle(
                      fontSize: 14,
                      color: isDarkMode ? Colors.grey[300] : Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Icon(
                Icons.movie,
                size: 40,
                color: Theme.of(context).primaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMovieCarousel(MovieProvider movieProvider) {
    final isDarkMode = Provider.of<ThemeProvider>(context).isDarkMode;

    return Container(
      margin: EdgeInsets.symmetric(vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              'Phim nổi bật',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: isDarkMode ? Colors.white : Colors.grey[800],
              ),
            ),
          ),
          SizedBox(height: 15),
          Container(
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(isDarkMode ? 0.3 : 0.1),
                  blurRadius: 15,
                  offset: Offset(0, 5),
                ),
              ],
            ),
            child: MovieCarousel(
              movies: movieProvider.featuredMovies,
              onMovieTap: (movie) {
                Navigator.pushNamed(
                  context,
                  '/movie-detail',
                  arguments: movie.id,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategorySection(bool isDarkMode) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Danh mục phim',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: isDarkMode ? Colors.white : Colors.grey[800],
            ),
          ),
          SizedBox(height: 15),
          Row(
            children: [
              Expanded(
                child: _buildEnhancedCategoryButton(
                  'Đang chiếu',
                  'now_showing',
                  _selectedCategory == 'now_showing',
                  Icons.play_circle_filled,
                  isDarkMode,
                ),
              ),
              SizedBox(width: 15),
              Expanded(
                child: _buildEnhancedCategoryButton(
                  'Sắp chiếu',
                  'coming_soon',
                  _selectedCategory == 'coming_soon',
                  Icons.schedule,
                  isDarkMode,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEnhancedCategoryButton(String title, String category, bool isSelected, IconData icon, bool isDarkMode) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 300),
      child: Material(
        elevation: isSelected ? 8 : 2,
        borderRadius: BorderRadius.circular(25),
        color: isSelected ? Theme.of(context).primaryColor : (isDarkMode ? Color(0xFF1E1E1E) : Colors.white),
        child: InkWell(
          onTap: () {
            setState(() {
              _selectedCategory = category;
            });
          },
          borderRadius: BorderRadius.circular(25),
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 15, horizontal: 20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(25),
              gradient: isSelected ? LinearGradient(
                colors: [
                  Theme.of(context).primaryColor,
                  Theme.of(context).primaryColor.withOpacity(0.8),
                ],
              ) : null,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  color: isSelected ? Colors.white : Theme.of(context).primaryColor,
                  size: 20,
                ),
                SizedBox(width: 8),
                Text(
                  title,
                  style: TextStyle(
                    color: isSelected ? Colors.white : Theme.of(context).primaryColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMoviesGrid(MovieProvider movieProvider, bool isDarkMode) {
    if (movieProvider.isLoading) {
      return Container(
        height: 200,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor),
              ),
              SizedBox(height: 16),
              Text(
                'Đang tải phim...',
                style: TextStyle(
                  color: isDarkMode ? Colors.grey[300] : Colors.grey[600],
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (movieProvider.movies.isEmpty) {
      return Container(
        height: 200,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.movie_outlined,
                size: 64,
                color: isDarkMode ? Colors.grey[600] : Colors.grey[400],
              ),
              SizedBox(height: 16),
              Text(
                'Không có phim nào',
                style: TextStyle(
                  fontSize: 18,
                  color: isDarkMode ? Colors.grey[300] : Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: GridView.builder(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.58,
          crossAxisSpacing: 15,
          mainAxisSpacing: 15,
        ),
        itemCount: movieProvider.getMoviesByStatus(_selectedCategory).length,
        itemBuilder: (context, index) {
          final movie = movieProvider.getMoviesByStatus(_selectedCategory)[index];
          return _buildEnhancedMovieCard(movie, index, isDarkMode);
        },
      ),
    );
  }

  Widget _buildEnhancedMovieCard(Movie movie, int index, bool isDarkMode) {
    return TweenAnimationBuilder(
      duration: Duration(milliseconds: 600 + (index * 100)),
      tween: Tween<double>(begin: 0.0, end: 1.0),
      builder: (context, double value, child) {
        return Transform.translate(
          offset: Offset(0, 30 * (1 - value)),
          child: Opacity(
            opacity: value,
            child: child,
          ),
        );
      },
      child: Hero(
        tag: 'movie-${movie.id}',
        child: Material(
          elevation: 8,
          borderRadius: BorderRadius.circular(20),
          color: isDarkMode ? Color(0xFF1E1E1E) : Colors.white,
          child: InkWell(
            onTap: () {
              Navigator.pushNamed(
                context,
                '/movie-detail',
                arguments: movie.id,
              );
            },
            borderRadius: BorderRadius.circular(20),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: isDarkMode
                      ? [Color(0xFF1E1E1E), Colors.grey.shade900]
                      : [Colors.white, Colors.grey.shade50],
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Poster image with enhanced styling
                  Expanded(
                    flex: 4,
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(isDarkMode ? 0.4 : 0.2),
                            blurRadius: 10,
                            offset: Offset(0, 5),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                        child: Stack(
                          children: [
                            Container(
                              width: double.infinity,
                              height: double.infinity,
                              decoration: BoxDecoration(
                                image: DecorationImage(
                                  image: NetworkImage(movie.posterUrl),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            // Gradient overlay
                            Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Colors.transparent,
                                    Colors.black.withOpacity(0.4),
                                  ],
                                ),
                              ),
                            ),
                            // Rating badge
                            Positioned(
                              top: 12,
                              right: 12,
                              child: Container(
                                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                decoration: BoxDecoration(
                                  color: Colors.amber,
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.amber.withOpacity(0.3),
                                      blurRadius: 8,
                                      offset: Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.star,
                                      color: Colors.white,
                                      size: 16,
                                    ),
                                    SizedBox(width: 4),
                                    Text(
                                      movie.rating.toString(),
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 13,
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
                  // Movie info with enhanced styling
                  Expanded(
                    flex: 2,
                    child: Padding(
                      padding: EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            movie.title,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: isDarkMode ? Colors.white : Colors.grey[800],
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: 8),
                          _buildInfoRow(Icons.access_time, '${movie.duration} phút', Colors.blue, isDarkMode),
                          SizedBox(height: 4),
                          _buildInfoRow(Icons.calendar_today, _formatReleaseDate(movie.releaseDate), Colors.green, isDarkMode),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text, Color color, bool isDarkMode) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Icon(
            icon,
            size: 14,
            color: color,
          ),
        ),
        SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 12,
              color: isDarkMode ? Colors.grey[300] : Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
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
      // Already on home
        break;
      case 1:
      // Navigate to tickets
        Navigator.pushNamed(context, '/tickets');
        break;
      case 2:
      // Navigate to profile
        Navigator.pushNamed(context, '/profile');
        break;
    }
  }
}