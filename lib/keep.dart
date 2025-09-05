// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
//
// void main() {
//   runApp(CinemaApp());
// }
//
// class CinemaApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Cinema Ticket App',
//       theme: ThemeData(
//         primarySwatch: Colors.red,
//         primaryColor: Color(0xFFE50914),
//         scaffoldBackgroundColor: Color(0xFF1a1a1a),
//         appBarTheme: AppBarTheme(
//           backgroundColor: Color(0xFF1a1a1a),
//           elevation: 0,
//           titleTextStyle: TextStyle(
//             color: Colors.white,
//             fontSize: 20,
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//       ),
//       home: HomeScreen(),
//       routes: {
//         '/login': (context) => LoginScreen(),
//         '/movie-detail': (context) => MovieDetailScreen(),
//         '/booking': (context) => BookingScreen(),
//         '/admin': (context) => AdminDashboard(),
//       },
//     );
//   }
// }
//
// // Model classes
// class Movie {
//   final String id;
//   final String title;
//   final String description;
//   final int duration;
//   final double rating;
//   final String posterUrl;
//   final String trailerUrl;
//   final DateTime releaseDate;
//   final String status;
//
//   Movie({
//     required this.id,
//     required this.title,
//     required this.description,
//     required this.duration,
//     required this.rating,
//     required this.posterUrl,
//     required this.trailerUrl,
//     required this.releaseDate,
//     required this.status,
//   });
// }
//
// class Cinema {
//   final String id;
//   final String name;
//   final String location;
//
//   Cinema({required this.id, required this.name, required this.location});
// }
//
// class Showtime {
//   final String id;
//   final String movieId;
//   final String cinemaId;
//   final DateTime startTime;
//   final List<String> availableSeats;
//   final List<String> bookedSeats;
//
//   Showtime({
//     required this.id,
//     required this.movieId,
//     required this.cinemaId,
//     required this.startTime,
//     required this.availableSeats,
//     required this.bookedSeats,
//   });
// }
//
// // Demo data
// class DemoData {
//   static List<Movie> movies = [
//     Movie(
//       id: '1',
//       title: 'Avengers: Endgame',
//       description: 'Sau sự kiện của Infinity War, vũ trụ bị tàn phá. Với sự giúp đỡ của các đồng minh còn lại, các Avengers phải tập hợp một lần nữa để đảo ngược hành động của Thanos.',
//       duration: 181,
//       rating: 8.4,
//       posterUrl: 'https://image.tmdb.org/t/p/w500/or06FN3Dka5tukK1e9sl16pB3iy.jpg',
//       trailerUrl: 'https://www.youtube.com/watch?v=TcMBFSGVi1c',
//       releaseDate: DateTime.now().subtract(Duration(days: 30)),
//       status: 'now_showing',
//     ),
//     Movie(
//       id: '2',
//       title: 'Spider-Man: No Way Home',
//       description: 'Lần đầu tiên trong lịch sử điện ảnh của Spider-Man, thân phận của Người Nhện thân thiện được bóc trần, khiến anh không còn tách biệt được trách nhiệm của siêu anh hùng với cuộc sống bình thường.',
//       duration: 148,
//       rating: 8.7,
//       posterUrl: 'https://image.tmdb.org/t/p/w500/1g0dhYtq4irTY1GPXvft6k4YLjm.jpg',
//       trailerUrl: 'https://www.youtube.com/watch?v=JfVOs4VSpmA',
//       releaseDate: DateTime.now().subtract(Duration(days: 15)),
//       status: 'now_showing',
//     ),
//     Movie(
//       id: '3',
//       title: 'Fast & Furious 9',
//       description: 'Dom Toretto đang sống cuộc sống yên tĩnh cùng Letty và con trai mình, nhưng họ biết rằng sự nguy hiểm luôn rình rập.',
//       duration: 143,
//       rating: 5.2,
//       posterUrl: 'https://image.tmdb.org/t/p/w500/bOFaAXmWWXC3Rbv4u4uM9ZSzRXP.jpg',
//       trailerUrl: 'https://www.youtube.com/watch?v=FUK2kdWy6hs',
//       releaseDate: DateTime.now().subtract(Duration(days: 45)),
//       status: 'now_showing',
//     ),
//     Movie(
//       id: '4',
//       title: 'Black Widow',
//       description: 'Natasha Romanoff phải đối mặt với những điều tối tăm trong quá khứ khi một âm mưu nguy hiểm liên quan đến cuộc sống cũ của cô được tiết lộ.',
//       duration: 134,
//       rating: 6.7,
//       posterUrl: 'https://image.tmdb.org/t/p/w500/qAZ0pzat24kLdO3o8ejmbLxyOac.jpg',
//       trailerUrl: 'https://www.youtube.com/watch?v=ybji16u608U',
//       releaseDate: DateTime.now().add(Duration(days: 7)),
//       status: 'coming_soon',
//     ),
//     Movie(
//       id: '5',
//       title: 'The Matrix Resurrections',
//       description: 'Neo sống một cuộc sống bình thường tại San Francisco, nơi therapist của anh ta cho anh ta những viên thuốc màu xanh.',
//       duration: 148,
//       rating: 5.7,
//       posterUrl: 'https://image.tmdb.org/t/p/w500/8c4a8kE7PizaGQQnditMmI1xbRp.jpg',
//       trailerUrl: 'https://www.youtube.com/watch?v=9ix7TUGVYIo',
//       releaseDate: DateTime.now().add(Duration(days: 14)),
//       status: 'coming_soon',
//     ),
//     Movie(
//       id: '6',
//       title: 'Dune',
//       description: 'Một câu chuyện thần thoại và cảm xúc về hành trình của Paul Atreides, một chàng trai tài năng và tài giỏi được sinh ra để làm những việc vĩ đại.',
//       duration: 155,
//       rating: 8.0,
//       posterUrl: 'https://image.tmdb.org/t/p/w500/d5NXSklXo0qyIYkgV94XAgMIckC.jpg',
//       trailerUrl: 'https://www.youtube.com/watch?v=n9xhJrPXop4',
//       releaseDate: DateTime.now().subtract(Duration(days: 20)),
//       status: 'now_showing',
//     ),
//   ];
//
//   static List<Cinema> cinemas = [
//     Cinema(id: '1', name: 'CGV Aeon Mall', location: 'Tân Phú, TP.HCM'),
//     Cinema(id: '2', name: 'Lotte Cinema', location: 'Quận 1, TP.HCM'),
//     Cinema(id: '3', name: 'Galaxy Cinema', location: 'Quận 7, TP.HCM'),
//   ];
//
//   static List<Showtime> showtimes = [
//     Showtime(
//       id: '1',
//       movieId: '1',
//       cinemaId: '1',
//       startTime: DateTime.now().add(Duration(hours: 2)),
//       availableSeats: ['A1', 'A2', 'B1', 'B2', 'C1', 'C2'],
//       bookedSeats: ['A3', 'B3'],
//     ),
//     Showtime(
//       id: '2',
//       movieId: '1',
//       cinemaId: '1',
//       startTime: DateTime.now().add(Duration(hours: 5)),
//       availableSeats: ['A1', 'A3', 'B1', 'B3', 'C1', 'C3'],
//       bookedSeats: ['A2', 'B2'],
//     ),
//   ];
// }
//
// // Home Screen
// class HomeScreen extends StatefulWidget {
//   @override
//   _HomeScreenState createState() => _HomeScreenState();
// }
//
// class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
//   late TabController _tabController;
//   List<Movie> nowShowingMovies = [];
//   List<Movie> comingSoonMovies = [];
//
//   @override
//   void initState() {
//     super.initState();
//     _tabController = TabController(length: 2, vsync: this);
//     _loadMovies();
//   }
//
//   void _loadMovies() {
//     nowShowingMovies = DemoData.movies.where((movie) => movie.status == 'now_showing').toList();
//     comingSoonMovies = DemoData.movies.where((movie) => movie.status == 'coming_soon').toList();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Cinema Ticket'),
//         actions: [
//           IconButton(
//             icon: Icon(Icons.search, color: Colors.white),
//             onPressed: () {},
//           ),
//           IconButton(
//             icon: Icon(Icons.person, color: Colors.white),
//             onPressed: () => Navigator.pushNamed(context, '/login'),
//           ),
//         ],
//         bottom: TabBar(
//           controller: _tabController,
//           tabs: [
//             Tab(text: 'Đang chiếu'),
//             Tab(text: 'Sắp chiếu'),
//           ],
//           indicatorColor: Color(0xFFE50914),
//           labelColor: Colors.white,
//           unselectedLabelColor: Colors.grey,
//         ),
//       ),
//       body: TabBarView(
//         controller: _tabController,
//         children: [
//           _buildMovieGrid(nowShowingMovies),
//           _buildMovieGrid(comingSoonMovies),
//         ],
//       ),
//       bottomNavigationBar: BottomNavigationBar(
//         backgroundColor: Color(0xFF1a1a1a),
//         selectedItemColor: Color(0xFFE50914),
//         unselectedItemColor: Colors.grey,
//         items: [
//           BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Trang chủ'),
//           BottomNavigationBarItem(icon: Icon(Icons.history), label: 'Lịch sử'),
//           BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Tài khoản'),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildMovieGrid(List<Movie> movies) {
//     return Container(
//       padding: EdgeInsets.all(16),
//       child: GridView.builder(
//         gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//           crossAxisCount: 2,
//           childAspectRatio: 0.7,
//           crossAxisSpacing: 16,
//           mainAxisSpacing: 16,
//         ),
//         itemCount: movies.length,
//         itemBuilder: (context, index) {
//           return MovieCard(movie: movies[index]);
//         },
//       ),
//     );
//   }
// }
//
// // Movie Card Widget
// class MovieCard extends StatelessWidget {
//   final Movie movie;
//
//   const MovieCard({Key? key, required this.movie}) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: () {
//         Navigator.pushNamed(context, '/movie-detail', arguments: movie);
//       },
//       child: Container(
//         decoration: BoxDecoration(
//           borderRadius: BorderRadius.circular(12),
//           color: Color(0xFF2a2a2a),
//         ),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Expanded(
//               child: Container(
//                 decoration: BoxDecoration(
//                   borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
//                   image: DecorationImage(
//                     image: NetworkImage(movie.posterUrl),
//                     fit: BoxFit.cover,
//                   ),
//                 ),
//                 child: Stack(
//                   children: [
//                     if (movie.status == 'coming_soon')
//                       Positioned(
//                         top: 8,
//                         right: 8,
//                         child: Container(
//                           padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//                           decoration: BoxDecoration(
//                             color: Color(0xFFE50914),
//                             borderRadius: BorderRadius.circular(4),
//                           ),
//                           child: Text(
//                             'Sắp chiếu',
//                             style: TextStyle(color: Colors.white, fontSize: 10),
//                           ),
//                         ),
//                       ),
//                     Positioned(
//                       bottom: 8,
//                       left: 8,
//                       child: Row(
//                         children: [
//                           Icon(Icons.star, color: Colors.amber, size: 16),
//                           SizedBox(width: 4),
//                           Text(
//                             movie.rating.toString(),
//                             style: TextStyle(color: Colors.white, fontSize: 12),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//             Padding(
//               padding: EdgeInsets.all(8),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     movie.title,
//                     style: TextStyle(
//                       color: Colors.white,
//                       fontSize: 14,
//                       fontWeight: FontWeight.bold,
//                     ),
//                     maxLines: 2,
//                     overflow: TextOverflow.ellipsis,
//                   ),
//                   SizedBox(height: 4),
//                   Text(
//                     '${movie.duration} phút',
//                     style: TextStyle(color: Colors.grey, fontSize: 12),
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
//
// // Movie Detail Screen
// class MovieDetailScreen extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     final Movie movie = ModalRoute.of(context)!.settings.arguments as Movie;
//
//     return Scaffold(
//       body: CustomScrollView(
//         slivers: [
//           SliverAppBar(
//             expandedHeight: 300,
//             pinned: true,
//             flexibleSpace: FlexibleSpaceBar(
//               background: Stack(
//                 fit: StackFit.expand,
//                 children: [
//                   Image.network(
//                     movie.posterUrl,
//                     fit: BoxFit.cover,
//                   ),
//                   Container(
//                     decoration: BoxDecoration(
//                       gradient: LinearGradient(
//                         begin: Alignment.topCenter,
//                         end: Alignment.bottomCenter,
//                         colors: [
//                           Colors.transparent,
//                           Color(0xFF1a1a1a).withOpacity(0.8),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             leading: IconButton(
//               icon: Icon(Icons.arrow_back, color: Colors.white),
//               onPressed: () => Navigator.pop(context),
//             ),
//           ),
//           SliverList(
//             delegate: SliverChildListDelegate([
//               Padding(
//                 padding: EdgeInsets.all(16),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       movie.title,
//                       style: TextStyle(
//                         color: Colors.white,
//                         fontSize: 24,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                     SizedBox(height: 8),
//                     Row(
//                       children: [
//                         Icon(Icons.star, color: Colors.amber, size: 20),
//                         SizedBox(width: 4),
//                         Text(
//                           movie.rating.toString(),
//                           style: TextStyle(color: Colors.white, fontSize: 16),
//                         ),
//                         SizedBox(width: 16),
//                         Icon(Icons.access_time, color: Colors.grey, size: 20),
//                         SizedBox(width: 4),
//                         Text(
//                           '${movie.duration} phút',
//                           style: TextStyle(color: Colors.grey, fontSize: 16),
//                         ),
//                       ],
//                     ),
//                     SizedBox(height: 16),
//                     Text(
//                       'Mô tả',
//                       style: TextStyle(
//                         color: Colors.white,
//                         fontSize: 18,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                     SizedBox(height: 8),
//                     Text(
//                       movie.description,
//                       style: TextStyle(color: Colors.grey, fontSize: 14),
//                     ),
//                     SizedBox(height: 24),
//                     if (movie.status == 'now_showing')
//                       SizedBox(
//                         width: double.infinity,
//                         height: 50,
//                         child: ElevatedButton(
//                           onPressed: () {
//                             Navigator.pushNamed(context, '/booking', arguments: movie);
//                           },
//                           child: Text('Đặt vé ngay'),
//                           style: ElevatedButton.styleFrom(
//                             backgroundColor: Color(0xFFE50914),
//                             foregroundColor: Colors.white,
//                           ),
//                         ),
//                       ),
//                   ],
//                 ),
//               ),
//             ]),
//           ),
//         ],
//       ),
//     );
//   }
// }
//
// // Booking Screen
// class BookingScreen extends StatefulWidget {
//   @override
//   _BookingScreenState createState() => _BookingScreenState();
// }
//
// class _BookingScreenState extends State<BookingScreen> {
//   Cinema? selectedCinema;
//   Showtime? selectedShowtime;
//   List<String> selectedSeats = [];
//
//   @override
//   Widget build(BuildContext context) {
//     final Movie movie = ModalRoute.of(context)!.settings.arguments as Movie;
//
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Đặt vé'),
//         leading: IconButton(
//           icon: Icon(Icons.arrow_back, color: Colors.white),
//           onPressed: () => Navigator.pop(context),
//         ),
//       ),
//       body: SingleChildScrollView(
//         padding: EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // Movie info
//             Row(
//               children: [
//                 Container(
//                   width: 80,
//                   height: 120,
//                   decoration: BoxDecoration(
//                     borderRadius: BorderRadius.circular(8),
//                     image: DecorationImage(
//                       image: NetworkImage(movie.posterUrl),
//                       fit: BoxFit.cover,
//                     ),
//                   ),
//                 ),
//                 SizedBox(width: 16),
//                 Expanded(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         movie.title,
//                         style: TextStyle(
//                           color: Colors.white,
//                           fontSize: 18,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                       SizedBox(height: 8),
//                       Text(
//                         '${movie.duration} phút',
//                         style: TextStyle(color: Colors.grey),
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//             SizedBox(height: 24),
//
//             // Cinema selection
//             Text(
//               'Chọn rạp phim',
//               style: TextStyle(
//                 color: Colors.white,
//                 fontSize: 16,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//             SizedBox(height: 8),
//             ...DemoData.cinemas.map((cinema) => RadioListTile<Cinema>(
//               title: Text(cinema.name, style: TextStyle(color: Colors.white)),
//               subtitle: Text(cinema.location, style: TextStyle(color: Colors.grey)),
//               value: cinema,
//               groupValue: selectedCinema,
//               onChanged: (Cinema? value) {
//                 setState(() {
//                   selectedCinema = value;
//                 });
//               },
//               activeColor: Color(0xFFE50914),
//             )),
//
//             SizedBox(height: 24),
//
//             // Showtime selection
//             if (selectedCinema != null) ...[
//               Text(
//                 'Chọn suất chiếu',
//                 style: TextStyle(
//                   color: Colors.white,
//                   fontSize: 16,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//               SizedBox(height: 8),
//               Wrap(
//                 spacing: 8,
//                 children: DemoData.showtimes.map((showtime) => ChoiceChip(
//                   label: Text(
//                     '${showtime.startTime.hour.toString().padLeft(2, '0')}:${showtime.startTime.minute.toString().padLeft(2, '0')}',
//                   ),
//                   selected: selectedShowtime == showtime,
//                   onSelected: (bool selected) {
//                     setState(() {
//                       selectedShowtime = selected ? showtime : null;
//                     });
//                   },
//                   selectedColor: Color(0xFFE50914),
//                   labelStyle: TextStyle(
//                     color: selectedShowtime == showtime ? Colors.white : Colors.grey,
//                   ),
//                 )).toList(),
//               ),
//               SizedBox(height: 24),
//             ],
//
//             // Seat selection
//             if (selectedShowtime != null) ...[
//               Text(
//                 'Chọn ghế',
//                 style: TextStyle(
//                   color: Colors.white,
//                   fontSize: 16,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//               SizedBox(height: 8),
//               _buildSeatMap(),
//               SizedBox(height: 24),
//             ],
//
//             // Booking button
//             if (selectedSeats.isNotEmpty) ...[
//               Container(
//                 width: double.infinity,
//                 height: 50,
//                 child: ElevatedButton(
//                   onPressed: () {
//                     _showPaymentDialog(context, movie);
//                   },
//                   child: Text('Đặt vé - ${selectedSeats.length * 90000}đ'),
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: Color(0xFFE50914),
//                     foregroundColor: Colors.white,
//                   ),
//                 ),
//               ),
//             ],
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildSeatMap() {
//     return Container(
//       padding: EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: Color(0xFF2a2a2a),
//         borderRadius: BorderRadius.circular(12),
//       ),
//       child: Column(
//         children: [
//           // Screen
//           Container(
//             width: double.infinity,
//             height: 4,
//             decoration: BoxDecoration(
//               color: Colors.white,
//               borderRadius: BorderRadius.circular(2),
//             ),
//           ),
//           SizedBox(height: 8),
//           Text('Màn hình', style: TextStyle(color: Colors.grey, fontSize: 12)),
//           SizedBox(height: 16),
//
//           // Seats
//           ...['A', 'B', 'C', 'D'].map((row) => Padding(
//             padding: EdgeInsets.symmetric(vertical: 4),
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 Text(row, style: TextStyle(color: Colors.white)),
//                 SizedBox(width: 8),
//                 ...List.generate(8, (index) {
//                   String seatId = '$row${index + 1}';
//                   bool isBooked = selectedShowtime!.bookedSeats.contains(seatId);
//                   bool isSelected = selectedSeats.contains(seatId);
//
//                   return GestureDetector(
//                     onTap: isBooked ? null : () {
//                       setState(() {
//                         if (isSelected) {
//                           selectedSeats.remove(seatId);
//                         } else {
//                           selectedSeats.add(seatId);
//                         }
//                       });
//                     },
//                     child: Container(
//                       width: 30,
//                       height: 30,
//                       margin: EdgeInsets.all(2),
//                       decoration: BoxDecoration(
//                         color: isBooked
//                             ? Colors.red
//                             : isSelected
//                             ? Color(0xFFE50914)
//                             : Colors.grey,
//                         borderRadius: BorderRadius.circular(6),
//                       ),
//                       child: Center(
//                         child: Text(
//                           '${index + 1}',
//                           style: TextStyle(
//                             color: Colors.white,
//                             fontSize: 10,
//                           ),
//                         ),
//                       ),
//                     ),
//                   );
//                 }),
//               ],
//             ),
//           )),
//
//           SizedBox(height: 16),
//
//           // Legend
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//             children: [
//               _buildLegendItem(Colors.grey, 'Trống'),
//               _buildLegendItem(Color(0xFFE50914), 'Đã chọn'),
//               _buildLegendItem(Colors.red, 'Đã đặt'),
//             ],
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildLegendItem(Color color, String label) {
//     return Row(
//       children: [
//         Container(
//           width: 16,
//           height: 16,
//           decoration: BoxDecoration(
//             color: color,
//             borderRadius: BorderRadius.circular(4),
//           ),
//         ),
//         SizedBox(width: 4),
//         Text(label, style: TextStyle(color: Colors.white, fontSize: 12)),
//       ],
//     );
//   }
//
//   void _showPaymentDialog(BuildContext context, Movie movie) {
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           backgroundColor: Color(0xFF2a2a2a),
//           title: Text('Chọn phương thức thanh toán', style: TextStyle(color: Colors.white)),
//           content: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               ListTile(
//                 leading: Icon(Icons.payment, color: Colors.white),
//                 title: Text('MoMo', style: TextStyle(color: Colors.white)),
//                 onTap: () {
//                   Navigator.pop(context);
//                   _processPayment('momo');
//                 },
//               ),
//               ListTile(
//                 leading: Icon(Icons.money, color: Colors.white),
//                 title: Text('Tiền mặt', style: TextStyle(color: Colors.white)),
//                 onTap: () {
//                   Navigator.pop(context);
//                   _processPayment('cash');
//                 },
//               ),
//               ListTile(
//                 leading: Icon(Icons.credit_card, color: Colors.white),
//                 title: Text('Thẻ tín dụng', style: TextStyle(color: Colors.white)),
//                 onTap: () {
//                   Navigator.pop(context);
//                   _processPayment('card');
//                 },
//               ),
//             ],
//           ),
//         );
//       },
//     );
//   }
//
//   void _processPayment(String method) {
//     // Show success dialog
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           backgroundColor: Color(0xFF2a2a2a),
//           title: Text('Đặt vé thành công!', style: TextStyle(color: Colors.white)),
//           content: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               Icon(Icons.check_circle, color: Colors.green, size: 64),
//               SizedBox(height: 16),
//               Text('Vé của bạn đã được đặt thành công', style: TextStyle(color: Colors.white)),
//               SizedBox(height: 8),
//               Text('Phương thức: ${method.toUpperCase()}', style: TextStyle(color: Colors.grey)),
//             ],
//           ),
//           actions: [
//             TextButton(
//               onPressed: () {
//                 Navigator.pop(context);
//                 Navigator.pop(context);
//                 Navigator.pop(context);
//               },
//               child: Text('OK', style: TextStyle(color: Color(0xFFE50914))),
//             ),
//           ],
//         );
//       },
//     );
//   }
// }
//
// // Login Screen
// class LoginScreen extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Đăng nhập'),
//         leading: IconButton(
//           icon: Icon(Icons.arrow_back, color: Colors.white),
//           onPressed: () => Navigator.pop(context),
//         ),
//       ),
//       body: Padding(
//         padding: EdgeInsets.all(16),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Icon(
//               Icons.local_movies,
//               size: 80,
//               color: Color(0xFFE50914),
//             ),
//             SizedBox(height: 24),
//             Text(
//               'Cinema Ticket',
//               style: TextStyle(
//                 color: Colors.white,
//                 fontSize: 24,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//             SizedBox(height: 32),
//             TextField(
//               style: TextStyle(color: Colors.white),
//               decoration: InputDecoration(
//                 hintText: 'Email',
//                 hintStyle: TextStyle(color: Colors.grey),
//                 filled: true,
//                 fillColor: Color(0xFF2a2a2a),
//                 border: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(8),
//                   borderSide: BorderSide.none,
//                 ),
//               ),
//             ),
//             SizedBox(height: 16),
//             TextField(
//               style: TextStyle(color: Colors.white),
//               obscureText: true,
//               decoration: InputDecoration(
//                 hintText: 'Mật khẩu',
//                 hintStyle: TextStyle(color: Colors.grey),
//                 filled: true,
//                 fillColor: Color(0xFF2a2a2a),
//                 border: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(8),
//                   borderSide: BorderSide.none,
//                 ),
//               ),
//             ),
//             SizedBox(height: 24),
//             SizedBox(
//               width: double.infinity,
//               height: 50,
//               child: ElevatedButton(
//                 onPressed: () {
//                   Navigator.pop(context);
//                   _showLoginSuccess(context);
//                 },
//                 child: Text('Đăng nhập'),
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: Color(0xFFE50914),
//                   foregroundColor: Colors.white,
//                 ),
//               ),
//             ),
//             SizedBox(height: 16),
//             TextButton(
//               onPressed: () {
//                 Navigator.pushNamed(context, '/admin');
//               },
//               child: Text(
//                 'Đăng nhập Admin',
//                 style: TextStyle(color: Color(0xFFE50914)),
//               ),
//             ),
//             SizedBox(height: 16),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 Text(
//                   'Chưa có tài khoản? ',
//                   style: TextStyle(color: Colors.grey),
//                 ),
//                 TextButton(
//                   onPressed: () {},
//                   child: Text(
//                     'Đăng ký ngay',
//                     style: TextStyle(color: Color(0xFFE50914)),
//                   ),
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   void _showLoginSuccess(BuildContext context) {
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           backgroundColor: Color(0xFF2a2a2a),
//           title: Text('Đăng nhập thành công!', style: TextStyle(color: Colors.white)),
//           content: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               Icon(Icons.check_circle, color: Colors.green, size: 64),
//               SizedBox(height: 16),
//               Text('Chào mừng bạn đến với Cinema Ticket!', style: TextStyle(color: Colors.white)),
//             ],
//           ),
//           actions: [
//             TextButton(
//               onPressed: () {
//                 Navigator.pop(context);
//               },
//               child: Text('OK', style: TextStyle(color: Color(0xFFE50914))),
//             ),
//           ],
//         );
//       },
//     );
//   }
// }
//
// // Admin Dashboard
// class AdminDashboard extends StatefulWidget {
//   @override
//   _AdminDashboardState createState() => _AdminDashboardState();
// }
//
// class _AdminDashboardState extends State<AdminDashboard> {
//   int _selectedIndex = 0;
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Admin Dashboard'),
//         actions: [
//           IconButton(
//             icon: Icon(Icons.logout, color: Colors.white),
//             onPressed: () {
//               Navigator.pop(context);
//             },
//           ),
//         ],
//       ),
//       body: IndexedStack(
//         index: _selectedIndex,
//         children: [
//           _buildDashboardStats(),
//           _buildMovieManagement(),
//           _buildShowtimeManagement(),
//           _buildUserManagement(),
//         ],
//       ),
//       bottomNavigationBar: BottomNavigationBar(
//         type: BottomNavigationBarType.fixed,
//         backgroundColor: Color(0xFF1a1a1a),
//         selectedItemColor: Color(0xFFE50914),
//         unselectedItemColor: Colors.grey,
//         currentIndex: _selectedIndex,
//         onTap: (index) {
//           setState(() {
//             _selectedIndex = index;
//           });
//         },
//         items: [
//           BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'Thống kê'),
//           BottomNavigationBarItem(icon: Icon(Icons.movie), label: 'Phim'),
//           BottomNavigationBarItem(icon: Icon(Icons.schedule), label: 'Suất chiếu'),
//           BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Người dùng'),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildDashboardStats() {
//     return Padding(
//       padding: EdgeInsets.all(16),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             'Thống kê tổng quan',
//             style: TextStyle(
//               color: Colors.white,
//               fontSize: 20,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//           SizedBox(height: 16),
//           GridView.count(
//             crossAxisCount: 2,
//             shrinkWrap: true,
//             physics: NeverScrollableScrollPhysics(),
//             childAspectRatio: 1.5,
//             crossAxisSpacing: 16,
//             mainAxisSpacing: 16,
//             children: [
//               _buildStatCard('Tổng phim', '12', Icons.movie, Colors.blue),
//               _buildStatCard('Vé đã bán', '1,234', Icons.confirmation_number, Colors.green),
//               _buildStatCard('Doanh thu', '234M đ', Icons.attach_money, Colors.orange),
//               _buildStatCard('Người dùng', '567', Icons.people, Colors.purple),
//             ],
//           ),
//           SizedBox(height: 24),
//           Container(
//             padding: EdgeInsets.all(16),
//             decoration: BoxDecoration(
//               color: Color(0xFF2a2a2a),
//               borderRadius: BorderRadius.circular(12),
//             ),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   'Phim bán chạy nhất',
//                   style: TextStyle(
//                     color: Colors.white,
//                     fontSize: 16,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//                 SizedBox(height: 12),
//                 ...DemoData.movies.take(3).map((movie) => ListTile(
//                   leading: Container(
//                     width: 40,
//                     height: 60,
//                     decoration: BoxDecoration(
//                       borderRadius: BorderRadius.circular(4),
//                       image: DecorationImage(
//                         image: NetworkImage(movie.posterUrl),
//                         fit: BoxFit.cover,
//                       ),
//                     ),
//                   ),
//                   title: Text(
//                     movie.title,
//                     style: TextStyle(color: Colors.white),
//                   ),
//                   subtitle: Text(
//                     'Đã bán: ${(movie.rating * 100).toInt()} vé',
//                     style: TextStyle(color: Colors.grey),
//                   ),
//                   trailing: Text(
//                     '${(movie.rating * 20).toInt()}M đ',
//                     style: TextStyle(color: Colors.green),
//                   ),
//                 )),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildStatCard(String title, String value, IconData icon, Color color) {
//     return Container(
//       padding: EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: Color(0xFF2a2a2a),
//         borderRadius: BorderRadius.circular(12),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Icon(icon, color: color, size: 24),
//               Text(
//                 value,
//                 style: TextStyle(
//                   color: Colors.white,
//                   fontSize: 20,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//             ],
//           ),
//           SizedBox(height: 8),
//           Text(
//             title,
//             style: TextStyle(color: Colors.grey, fontSize: 14),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildMovieManagement() {
//     return Padding(
//       padding: EdgeInsets.all(16),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Text(
//                 'Quản lý phim',
//                 style: TextStyle(
//                   color: Colors.white,
//                   fontSize: 20,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//               ElevatedButton(
//                 onPressed: () {
//                   _showAddMovieDialog();
//                 },
//                 child: Text('Thêm phim'),
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: Color(0xFFE50914),
//                   foregroundColor: Colors.white,
//                 ),
//               ),
//             ],
//           ),
//           SizedBox(height: 16),
//           Expanded(
//             child: ListView.builder(
//               itemCount: DemoData.movies.length,
//               itemBuilder: (context, index) {
//                 final movie = DemoData.movies[index];
//                 return Card(
//                   color: Color(0xFF2a2a2a),
//                   child: ListTile(
//                     leading: Container(
//                       width: 40,
//                       height: 60,
//                       decoration: BoxDecoration(
//                         borderRadius: BorderRadius.circular(4),
//                         image: DecorationImage(
//                           image: NetworkImage(movie.posterUrl),
//                           fit: BoxFit.cover,
//                         ),
//                       ),
//                     ),
//                     title: Text(
//                       movie.title,
//                       style: TextStyle(color: Colors.white),
//                     ),
//                     subtitle: Text(
//                       '${movie.duration} phút - ${movie.status}',
//                       style: TextStyle(color: Colors.grey),
//                     ),
//                     trailing: Row(
//                       mainAxisSize: MainAxisSize.min,
//                       children: [
//                         IconButton(
//                           icon: Icon(Icons.edit, color: Colors.blue),
//                           onPressed: () {
//                             _showEditMovieDialog(movie);
//                           },
//                         ),
//                         IconButton(
//                           icon: Icon(Icons.delete, color: Colors.red),
//                           onPressed: () {
//                             _showDeleteConfirmation(movie);
//                           },
//                         ),
//                       ],
//                     ),
//                   ),
//                 );
//               },
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildShowtimeManagement() {
//     return Padding(
//       padding: EdgeInsets.all(16),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Text(
//                 'Quản lý suất chiếu',
//                 style: TextStyle(
//                   color: Colors.white,
//                   fontSize: 20,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//               ElevatedButton(
//                 onPressed: () {
//                   _showAddShowtimeDialog();
//                 },
//                 child: Text('Thêm suất chiếu'),
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: Color(0xFFE50914),
//                   foregroundColor: Colors.white,
//                 ),
//               ),
//             ],
//           ),
//           SizedBox(height: 16),
//           Expanded(
//             child: ListView.builder(
//               itemCount: DemoData.showtimes.length,
//               itemBuilder: (context, index) {
//                 final showtime = DemoData.showtimes[index];
//                 final movie = DemoData.movies.firstWhere(
//                       (m) => m.id == showtime.movieId,
//                 );
//                 final cinema = DemoData.cinemas.firstWhere(
//                       (c) => c.id == showtime.cinemaId,
//                 );
//
//                 return Card(
//                   color: Color(0xFF2a2a2a),
//                   child: ListTile(
//                     title: Text(
//                       movie.title,
//                       style: TextStyle(color: Colors.white),
//                     ),
//                     subtitle: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(
//                           cinema.name,
//                           style: TextStyle(color: Colors.grey),
//                         ),
//                         Text(
//                           '${showtime.startTime.hour.toString().padLeft(2, '0')}:${showtime.startTime.minute.toString().padLeft(2, '0')}',
//                           style: TextStyle(color: Colors.grey),
//                         ),
//                       ],
//                     ),
//                     trailing: Row(
//                       mainAxisSize: MainAxisSize.min,
//                       children: [
//                         Text(
//                           '${showtime.availableSeats.length}/${showtime.availableSeats.length + showtime.bookedSeats.length}',
//                           style: TextStyle(color: Colors.green),
//                         ),
//                         SizedBox(width: 8),
//                         IconButton(
//                           icon: Icon(Icons.delete, color: Colors.red),
//                           onPressed: () {
//                             _showDeleteShowtimeConfirmation(showtime);
//                           },
//                         ),
//                       ],
//                     ),
//                   ),
//                 );
//               },
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildUserManagement() {
//     return Padding(
//       padding: EdgeInsets.all(16),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             'Quản lý người dùng',
//             style: TextStyle(
//               color: Colors.white,
//               fontSize: 20,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//           SizedBox(height: 16),
//           Expanded(
//             child: ListView.builder(
//               itemCount: 10, // Demo data
//               itemBuilder: (context, index) {
//                 return Card(
//                   color: Color(0xFF2a2a2a),
//                   child: ListTile(
//                     leading: CircleAvatar(
//                       backgroundColor: Color(0xFFE50914),
//                       child: Text(
//                         'U${index + 1}',
//                         style: TextStyle(color: Colors.white),
//                       ),
//                     ),
//                     title: Text(
//                       'User ${index + 1}',
//                       style: TextStyle(color: Colors.white),
//                     ),
//                     subtitle: Text(
//                       'user${index + 1}@example.com',
//                       style: TextStyle(color: Colors.grey),
//                     ),
//                     trailing: Text(
//                       'Active',
//                       style: TextStyle(color: Colors.green),
//                     ),
//                   ),
//                 );
//               },
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   void _showAddMovieDialog() {
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           backgroundColor: Color(0xFF2a2a2a),
//           title: Text('Thêm phim mới', style: TextStyle(color: Colors.white)),
//           content: SingleChildScrollView(
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 TextField(
//                   style: TextStyle(color: Colors.white),
//                   decoration: InputDecoration(
//                     hintText: 'Tên phim',
//                     hintStyle: TextStyle(color: Colors.grey),
//                     filled: true,
//                     fillColor: Color(0xFF1a1a1a),
//                     border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
//                   ),
//                 ),
//                 SizedBox(height: 16),
//                 TextField(
//                   style: TextStyle(color: Colors.white),
//                   maxLines: 3,
//                   decoration: InputDecoration(
//                     hintText: 'Mô tả',
//                     hintStyle: TextStyle(color: Colors.grey),
//                     filled: true,
//                     fillColor: Color(0xFF1a1a1a),
//                     border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
//                   ),
//                 ),
//                 SizedBox(height: 16),
//                 TextField(
//                   style: TextStyle(color: Colors.white),
//                   keyboardType: TextInputType.number,
//                   decoration: InputDecoration(
//                     hintText: 'Thời lượng (phút)',
//                     hintStyle: TextStyle(color: Colors.grey),
//                     filled: true,
//                     fillColor: Color(0xFF1a1a1a),
//                     border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           actions: [
//             TextButton(
//               onPressed: () => Navigator.pop(context),
//               child: Text('Hủy', style: TextStyle(color: Colors.grey)),
//             ),
//             TextButton(
//               onPressed: () {
//                 Navigator.pop(context);
//                 _showSuccessMessage('Thêm phim thành công!');
//               },
//               child: Text('Thêm', style: TextStyle(color: Color(0xFFE50914))),
//             ),
//           ],
//         );
//       },
//     );
//   }
//
//   void _showEditMovieDialog(Movie movie) {
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           backgroundColor: Color(0xFF2a2a2a),
//           title: Text('Chỉnh sửa phim', style: TextStyle(color: Colors.white)),
//           content: SingleChildScrollView(
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 TextField(
//                   style: TextStyle(color: Colors.white),
//                   decoration: InputDecoration(
//                     hintText: movie.title,
//                     hintStyle: TextStyle(color: Colors.grey),
//                     filled: true,
//                     fillColor: Color(0xFF1a1a1a),
//                     border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
//                   ),
//                 ),
//                 SizedBox(height: 16),
//                 TextField(
//                   style: TextStyle(color: Colors.white),
//                   maxLines: 3,
//                   decoration: InputDecoration(
//                     hintText: movie.description,
//                     hintStyle: TextStyle(color: Colors.grey),
//                     filled: true,
//                     fillColor: Color(0xFF1a1a1a),
//                     border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           actions: [
//             TextButton(
//               onPressed: () => Navigator.pop(context),
//               child: Text('Hủy', style: TextStyle(color: Colors.grey)),
//             ),
//             TextButton(
//               onPressed: () {
//                 Navigator.pop(context);
//                 _showSuccessMessage('Cập nhật phim thành công!');
//               },
//               child: Text('Cập nhật', style: TextStyle(color: Color(0xFFE50914))),
//             ),
//           ],
//         );
//       },
//     );
//   }
//
//   void _showDeleteConfirmation(Movie movie) {
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           backgroundColor: Color(0xFF2a2a2a),
//           title: Text('Xóa phim', style: TextStyle(color: Colors.white)),
//           content: Text(
//             'Bạn có chắc chắn muốn xóa phim "${movie.title}"?',
//             style: TextStyle(color: Colors.white),
//           ),
//           actions: [
//             TextButton(
//               onPressed: () => Navigator.pop(context),
//               child: Text('Hủy', style: TextStyle(color: Colors.grey)),
//             ),
//             TextButton(
//               onPressed: () {
//                 Navigator.pop(context);
//                 _showSuccessMessage('Xóa phim thành công!');
//               },
//               child: Text('Xóa', style: TextStyle(color: Colors.red)),
//             ),
//           ],
//         );
//       },
//     );
//   }
//
//   void _showAddShowtimeDialog() {
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           backgroundColor: Color(0xFF2a2a2a),
//           title: Text('Thêm suất chiếu', style: TextStyle(color: Colors.white)),
//           content: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               DropdownButtonFormField<String>(
//                 style: TextStyle(color: Colors.white),
//                 dropdownColor: Color(0xFF2a2a2a),
//                 decoration: InputDecoration(
//                   hintText: 'Chọn phim',
//                   hintStyle: TextStyle(color: Colors.grey),
//                   filled: true,
//                   fillColor: Color(0xFF1a1a1a),
//                   border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
//                 ),
//                 items: DemoData.movies.map((movie) {
//                   return DropdownMenuItem<String>(
//                     value: movie.id,
//                     child: Text(movie.title),
//                   );
//                 }).toList(),
//                 onChanged: (value) {},
//               ),
//               SizedBox(height: 16),
//               DropdownButtonFormField<String>(
//                 style: TextStyle(color: Colors.white),
//                 dropdownColor: Color(0xFF2a2a2a),
//                 decoration: InputDecoration(
//                   hintText: 'Chọn rạp',
//                   hintStyle: TextStyle(color: Colors.grey),
//                   filled: true,
//                   fillColor: Color(0xFF1a1a1a),
//                   border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
//                 ),
//                 items: DemoData.cinemas.map((cinema) {
//                   return DropdownMenuItem<String>(
//                     value: cinema.id,
//                     child: Text(cinema.name),
//                   );
//                 }).toList(),
//                 onChanged: (value) {},
//               ),
//             ],
//           ),
//           actions: [
//             TextButton(
//               onPressed: () => Navigator.pop(context),
//               child: Text('Hủy', style: TextStyle(color: Colors.grey)),
//             ),
//             TextButton(
//               onPressed: () {
//                 Navigator.pop(context);
//                 _showSuccessMessage('Thêm suất chiếu thành công!');
//               },
//               child: Text('Thêm', style: TextStyle(color: Color(0xFFE50914))),
//             ),
//           ],
//         );
//       },
//     );
//   }
//
//   void _showDeleteShowtimeConfirmation(Showtime showtime) {
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           backgroundColor: Color(0xFF2a2a2a),
//           title: Text('Xóa suất chiếu', style: TextStyle(color: Colors.white)),
//           content: Text(
//             'Bạn có chắc chắn muốn xóa suất chiếu này?',
//             style: TextStyle(color: Colors.white),
//           ),
//           actions: [
//             TextButton(
//               onPressed: () => Navigator.pop(context),
//               child: Text('Hủy', style: TextStyle(color: Colors.grey)),
//             ),
//             TextButton(
//               onPressed: () {
//                 Navigator.pop(context);
//                 _showSuccessMessage('Xóa suất chiếu thành công!');
//               },
//               child: Text('Xóa', style: TextStyle(color: Colors.red)),
//             ),
//           ],
//         );
//       },
//     );
//   }
//
//   void _showSuccessMessage(String message) {
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           backgroundColor: Color(0xFF2a2a2a),
//           title: Text('Thành công', style: TextStyle(color: Colors.white)),
//           content: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               Icon(Icons.check_circle, color: Colors.green, size: 48),
//               SizedBox(height: 16),
//               Text(message, style: TextStyle(color: Colors.white)),
//             ],
//           ),
//           actions: [
//             TextButton(
//               onPressed: () => Navigator.pop(context),
//               child: Text('OK', style: TextStyle(color: Color(0xFFE50914))),
//             ),
//           ],
//         );
//       },
//     );
//   }
// }