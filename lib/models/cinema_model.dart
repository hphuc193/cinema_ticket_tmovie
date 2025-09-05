// lib/models/cinema_model.dart - Improved version for movie_cinemas structure

class Cinema {
  final String id;
  final String name;
  final String location;
  final List<Room> rooms;
  final String? movieId; // Optional movieId field

  Cinema({
    required this.id,
    required this.name,
    required this.location,
    required this.rooms,
    this.movieId,
  });

  factory Cinema.fromJson(Map<String, dynamic> json) {
    try {
      return Cinema(
        id: json['id']?.toString() ?? '',
        name: json['name']?.toString() ?? 'Unknown Cinema',
        location: json['location']?.toString() ?? 'Unknown Location',
        rooms: _parseRooms(json['rooms']),
        movieId: json['movieId']?.toString(),
      );
    } catch (e) {
      print('Error parsing Cinema from JSON: $e');
      print('JSON data: $json');
      // Trả về cinema với dữ liệu mặc định thay vì throw exception
      return Cinema(
        id: json['id']?.toString() ?? '',
        name: json['name']?.toString() ?? 'Unknown Cinema',
        location: json['location']?.toString() ?? 'Unknown Location',
        rooms: [],
        movieId: json['movieId']?.toString(),
      );
    }
  }

  static List<Room> _parseRooms(dynamic roomsData) {
    if (roomsData == null) return [];

    try {
      if (roomsData is List) {
        final rooms = <Room>[];
        for (var roomData in roomsData) {
          try {
            if (roomData is Map<String, dynamic>) {
              rooms.add(Room.fromJson(roomData));
            } else if (roomData is String) {
              // Nếu chỉ là tên room đơn giản
              rooms.add(Room(
                roomId: roomData,
                name: roomData,
                seatMap: _generateDefaultSeatMap(),
              ));
            }
          } catch (e) {
            print('Error parsing individual room: $e');
            // Skip invalid room data
            continue;
          }
        }
        return rooms;
      } else if (roomsData is Map<String, dynamic>) {
        // Nếu rooms là một object thay vì array
        return [Room.fromJson(roomsData)];
      }
    } catch (e) {
      print('Error parsing rooms data: $e');
    }

    return [];
  }

  // Generate default seat map if none provided
  static List<List<String>> _generateDefaultSeatMap() {
    final seatMap = <List<String>>[];
    const rows = ['A', 'B', 'C', 'D', 'E', 'F'];

    for (String row in rows) {
      final seatRow = <String>[];
      for (int i = 1; i <= 10; i++) {
        seatRow.add('$row$i');
      }
      seatMap.add(seatRow);
    }

    return seatMap;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'location': location,
      'rooms': rooms.map((room) => room.toJson()).toList(),
      if (movieId != null) 'movieId': movieId,
    };
  }

  @override
  String toString() {
    return 'Cinema(id: $id, name: $name, location: $location, rooms: ${rooms.length}, movieId: $movieId)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Cinema && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

class Room {
  final String roomId;
  final String name;
  final List<List<String>> seatMap;
  final int? capacity;

  Room({
    required this.roomId,
    required this.name,
    required this.seatMap,
    this.capacity,
  });

  factory Room.fromJson(Map<String, dynamic> json) {
    try {
      return Room(
        roomId: json['roomId']?.toString() ?? json['id']?.toString() ?? '',
        name: json['name']?.toString() ?? json['roomId']?.toString() ?? 'Unknown Room',
        seatMap: _parseSeatMap(json['seatMap'] ?? json['seats']),
        capacity: json['capacity'] as int?,
      );
    } catch (e) {
      print('Error parsing Room from JSON: $e');
      // Trả về room với dữ liệu mặc định
      return Room(
        roomId: json['roomId']?.toString() ?? json['id']?.toString() ?? '',
        name: json['name']?.toString() ?? 'Unknown Room',
        seatMap: _generateDefaultSeatMap(),
      );
    }
  }

  static List<List<String>> _parseSeatMap(dynamic seatMapData) {
    if (seatMapData == null) return _generateDefaultSeatMap();

    try {
      if (seatMapData is List) {
        final seatMap = <List<String>>[];
        for (var row in seatMapData) {
          if (row is List) {
            seatMap.add(List<String>.from(row.map((seat) => seat.toString())));
          } else if (row is String) {
            // Nếu mỗi row chỉ là một string, split nó
            seatMap.add(row.split(',').map((s) => s.trim()).toList());
          }
        }
        return seatMap.isNotEmpty ? seatMap : _generateDefaultSeatMap();
      } else if (seatMapData is Map) {
        // Handle seat map as object format
        final seatMap = <List<String>>[];
        seatMapData.forEach((key, value) {
          if (value is List) {
            seatMap.add(List<String>.from(value));
          }
        });
        return seatMap.isNotEmpty ? seatMap : _generateDefaultSeatMap();
      }
    } catch (e) {
      print('Error parsing seat map: $e');
    }

    return _generateDefaultSeatMap();
  }

  // Generate default seat map
  static List<List<String>> _generateDefaultSeatMap() {
    final seatMap = <List<String>>[];
    const rows = ['A', 'B', 'C', 'D', 'E', 'F'];

    for (String row in rows) {
      final seatRow = <String>[];
      for (int i = 1; i <= 10; i++) {
        seatRow.add('$row$i');
      }
      seatMap.add(seatRow);
    }

    return seatMap;
  }

  // Get total seats count
  int get totalSeats {
    return seatMap.fold(0, (sum, row) => sum + row.length);
  }

  // Get all seat IDs as flat list
  List<String> get allSeatIds {
    final seats = <String>[];
    for (var row in seatMap) {
      seats.addAll(row);
    }
    return seats;
  }

  Map<String, dynamic> toJson() {
    return {
      'roomId': roomId,
      'name': name,
      'seatMap': seatMap,
      if (capacity != null) 'capacity': capacity,
    };
  }

  @override
  String toString() {
    return 'Room(roomId: $roomId, name: $name, totalSeats: $totalSeats)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Room && other.roomId == roomId;
  }

  @override
  int get hashCode => roomId.hashCode;
}