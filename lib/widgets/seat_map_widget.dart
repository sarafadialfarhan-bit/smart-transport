import 'package:flutter/material.dart';
import '../constants.dart';

class SeatMapWidget extends StatelessWidget {
  final Map<String, dynamic> seats; // { "1": "available", "2": "occupied", ... }
  final String busType; // standard, vip
  final String? selectedSeat;
  final Function(String) onSeatSelected;

  const SeatMapWidget({
    super.key,
    required this.seats,
    required this.busType,
    required this.selectedSeat,
    required this.onSeatSelected,
  });

  @override
  Widget build(BuildContext context) {
    int cols = busType == 'vip' ? 3 : 4;
    int totalSeats = seats.length;
    int rows = (totalSeats / cols).ceil();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        children: [
          // Bus Front / Driver
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Icon(Icons.steering_wheel, size: 40, color: kGreyColor),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                decoration: BoxDecoration(color: kSecondaryColor, borderRadius: BorderRadius.circular(10)),
                child: const Text("FRONT", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 10)),
              ),
              const SizedBox(width: 40),
            ],
          ),
          const SizedBox(height: 30),
          
          // Seats Grid
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: totalSeats,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: cols,
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              childAspectRatio: 1,
            ),
            itemBuilder: (context, index) {
              String seatNum = (index + 1).toString();
              String status = seats[seatNum] ?? 'available';
              bool isSelected = selectedSeat == seatNum;

              return GestureDetector(
                onTap: status == 'available' ? () => onSeatSelected(seatNum) : null,
                child: Container(
                  decoration: BoxDecoration(
                    color: _getSeatColor(status, isSelected),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isSelected ? kPrimaryColor : Colors.transparent,
                      width: 2,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      seatNum,
                      style: TextStyle(
                        color: status == 'occupied' || isSelected ? Colors.white : kSecondaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
          
          const SizedBox(height: 20),
          _buildLegend(),
        ],
      ),
    );
  }

  Color _getSeatColor(String status, bool isSelected) {
    if (isSelected) return kPrimaryColor;
    if (status == 'occupied') return Colors.grey.shade400;
    if (status == 'boarded') return kGreenColor;
    return Colors.white;
  }

  Widget _buildLegend() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _legendItem("Available", Colors.white, Colors.grey.shade300),
        _legendItem("Selected", kPrimaryColor, kPrimaryColor),
        _legendItem("Occupied", Colors.grey.shade400, Colors.grey.shade400),
      ],
    );
  }

  Widget _legendItem(String label, Color color, Color border) {
    return Row(
      children: [
        Container(
          width: 15,
          height: 15,
          decoration: BoxDecoration(color: color, border: Border.all(color: border), borderRadius: BorderRadius.circular(4)),
        ),
        const SizedBox(width: 5),
        Text(label, style: const TextStyle(fontSize: 10, color: kGreyColor)),
      ],
    );
  }
}
