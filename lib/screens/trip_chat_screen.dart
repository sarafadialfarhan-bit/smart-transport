import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:geolocator/geolocator.dart';
import '../constants.dart';
import '../services/chat_service.dart';
import '../services/user_service.dart';
import 'package:intl/intl.dart';

class TripChatScreen extends StatefulWidget {
  final String tripId;
  final String from;
  final String to;
  final DateTime arrivalTime;

  const TripChatScreen({
    super.key,
    required this.tripId,
    required this.from,
    required this.to,
    required this.arrivalTime,
  });

  @override
  State<TripChatScreen> createState() => _TripChatScreenState();
}

class _TripChatScreenState extends State<TripChatScreen> {
  final ChatService _chatService = ChatService();
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final User? _user = FirebaseAuth.instance.currentUser;
  bool _isLocked = false;
  bool _isCompanyOrAdmin = false;

  @override
  void initState() {
    super.initState();
    _checkUserRole();
    _checkLockStatus();
  }

  void _checkUserRole() async {
    if (_user != null) {
      final role = await UserService().getUserRole(_user!.uid);
      if (role == 'admin' || role == 'company') {
        setState(() {
          _isCompanyOrAdmin = true;
        });
      }
    }
  }

  void _checkLockStatus() {
    final lockTime = widget.arrivalTime.add(const Duration(days: 1));
    if (DateTime.now().isAfter(lockTime)) {
      setState(() {
        _isLocked = true;
      });
    }
  }

  Future<void> _sendLocation() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.always || permission == LocationPermission.whileInUse) {
        Position position = await Geolocator.getCurrentPosition();
        await _chatService.sendMessage(
          tripId: widget.tripId,
          senderId: _user?.uid ?? '',
          senderName: _user?.displayName ?? _user?.email?.split('@')[0] ?? 'User',
          text: 'Shared location',
          type: 'location',
          location: {
            'lat': position.latitude,
            'lng': position.longitude,
          },
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  Future<void> _triggerEmergency() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("emergency_alert_title".tr()),
        content: Text("emergency_alert_confirm".tr()),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text("cancel".tr())),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text("send".tr(), style: const TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        Position position = await Geolocator.getCurrentPosition();
        await _chatService.triggerEmergency(
          tripId: widget.tripId,
          senderId: _user?.uid ?? '',
          senderName: _user?.displayName ?? _user?.email?.split('@')[0] ?? 'User',
          location: {
            'lat': position.latitude,
            'lng': position.longitude,
          },
        );
      } catch (e) {
        // Even if location fails, send emergency without location?
        await _chatService.sendMessage(
          tripId: widget.tripId,
          senderId: _user?.uid ?? '',
          senderName: _user?.displayName ?? _user?.email?.split('@')[0] ?? 'User',
          text: 'EMERGENCY_ALERT_NO_GPS',
          type: 'emergency',
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      appBar: AppBar(
        title: Column(
          children: [
            Text("${widget.from.tr()} → ${widget.to.tr()}", style: const TextStyle(fontWeight: FontWeight.bold, color: kWhiteColor)),
            Text("trip_chat".tr(), style: const TextStyle(fontSize: 12, color: kWhiteColor)),
          ],
        ),
        centerTitle: true,
        backgroundColor: kPrimaryColor,
        iconTheme: const IconThemeData(color: kWhiteColor),
        actions: [
          if (!_isLocked || _isCompanyOrAdmin)
            IconButton(
              icon: const Icon(Icons.warning_amber_rounded, color: Colors.orangeAccent),
              onPressed: _triggerEmergency,
            ),
        ],
      ),
      body: Column(
        children: [
          if (_isLocked && !_isCompanyOrAdmin)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              color: Colors.red.shade100,
              child: Text(
                "chat_locked_desc".tr(),
                style: const TextStyle(color: Colors.red, fontSize: 12),
                textAlign: TextAlign.center,
              ),
            ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _chatService.getMessages(widget.tripId),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                final messages = snapshot.data!.docs;
                return ListView.builder(
                  controller: _scrollController,
                  reverse: true,
                  padding: const EdgeInsets.all(15),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final data = messages[index].data() as Map<String, dynamic>;
                    bool isMe = data['senderId'] == _user?.uid;
                    return _buildMessageBubble(data, isMe);
                  },
                );
              },
            ),
          ),
          if (!_isLocked || _isCompanyOrAdmin) _buildInputArea(),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(Map<String, dynamic> data, bool isMe) {
    String type = data['type'] ?? 'text';
    Color bubbleColor = isMe ? kPrimaryColor : kWhiteColor;
    Color textColor = isMe ? kWhiteColor : kSecondaryColor;

    if (type == 'emergency') {
      bubbleColor = Colors.red;
      textColor = Colors.white;
    }

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: bubbleColor,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(15),
            topRight: const Radius.circular(15),
            bottomLeft: isMe ? const Radius.circular(15) : Radius.zero,
            bottomRight: isMe ? Radius.zero : const Radius.circular(15),
          ),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5, offset: const Offset(0, 2))
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!isMe)
              Text(
                data['senderName'] ?? '',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10, color: textColor.withOpacity(0.7)),
              ),
            if (type == 'text' || type == 'emergency')
              Text(data['text'] ?? '', style: TextStyle(color: textColor)),
            if (type == 'location')
              Column(
                children: [
                  const Icon(Icons.location_on, color: kSecondaryColor),
                  Text("location_shared".tr(), style: TextStyle(color: textColor, fontSize: 12)),
                  TextButton(
                    onPressed: () {
                      // Logic to open map
                    },
                    child: Text("view_on_map".tr(), style: TextStyle(color: isMe ? Colors.white : kPrimaryColor)),
                  )
                ],
              ),
            const SizedBox(height: 5),
            Text(
              data['timestamp'] != null 
                ? DateFormat('hh:mm a').format((data['timestamp'] as Timestamp).toDate())
                : '',
              style: TextStyle(fontSize: 8, color: textColor.withOpacity(0.5)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: kWhiteColor,
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5, offset: const Offset(0, -2))
        ],
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.location_on_outlined, color: kPrimaryColor),
            onPressed: _sendLocation,
          ),
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: InputDecoration(
                hintText: "type_message".tr(),
                border: InputBorder.none,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.send_rounded, color: kPrimaryColor),
            onPressed: () {
              if (_messageController.text.trim().isNotEmpty) {
                _chatService.sendMessage(
                  tripId: widget.tripId,
                  senderId: _user?.uid ?? '',
                  senderName: _user?.displayName ?? _user?.email?.split('@')[0] ?? 'User',
                  text: _messageController.text.trim(),
                );
                _messageController.clear();
              }
            },
          ),
        ],
      ),
    );
  }
}
