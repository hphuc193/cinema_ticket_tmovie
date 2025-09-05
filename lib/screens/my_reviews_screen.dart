// import 'package:flutter/material.dart';
//
// class MyReviewsScreen extends StatelessWidget {
//   // Bạn có thể truyền list từ provider thực tế nếu có.
//   final _reviews = const [
//     {
//       'movie': 'Avengers: Endgame',
//       'rating': 5,
//       'comment': 'Cực kỳ hoành tráng và cảm động!',
//       'date': '2023-10-15',
//     },
//     {
//       'movie': 'Spider-Man: No Way Home',
//       'rating': 4,
//       'comment': 'Rất mãn nhãn, diễn xuất tuyệt vời!',
//       'date': '2024-01-22',
//     },
//   ];
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Đánh giá của tôi'),
//       ),
//       body: ListView.separated(
//         padding: EdgeInsets.all(16),
//         itemCount: _reviews.length,
//         separatorBuilder: (context, index) => Divider(),
//         itemBuilder: (context, index) {
//           final review = _reviews[index];
//           return ListTile(
//             leading: Icon(Icons.movie),
//             title: Text(review['movie'] ?? ''),
//             subtitle: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Row(
//                   children: List.generate(
//                     review['rating'] as int,
//                         (i) => Icon(Icons.star, color: Colors.amber, size: 18),
//                   ),
//                 ),
//                 SizedBox(height: 4),
//                 Text(review['comment'] ?? ''),
//                 SizedBox(height: 4),
//                 Text(
//                   review['date'] ?? '',
//                   style: TextStyle(fontSize: 12, color: Colors.grey),
//                 ),
//               ],
//             ),
//           );
//         },
//       ),
//     );
//   }
// }
