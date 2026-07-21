class Trip {
  final String id;
  final String company;
  final String from;
  final String to;
  final DateTime dateTime;
  final double price;
  final int availableSeats;
  final String busType;
  final double duration;

  Trip({
    required this.id,
    required this.company,
    required this.from,
    required this.to,
    required this.dateTime,
    required this.price,
    required this.availableSeats,
    required this.busType,
    required this.duration,
  });
}
