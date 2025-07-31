import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:rxdart/rxdart.dart';

class MessageStream {
  // Singleton instance
  static final MessageStream _instance = MessageStream._internal();

  // Private constructor
  MessageStream._internal();

  // Singleton accessor
  static MessageStream get instance => _instance;

  // RxDart subject for messages (can accept null)
  final BehaviorSubject<RemoteMessage?> _messageSubject = BehaviorSubject<RemoteMessage?>();

  // Expose stream
  Stream<RemoteMessage?> get messageStream => _messageSubject.stream;

  // Add a message (can add null to "reset" stream)
  void addMessage(RemoteMessage? msg) => _messageSubject.add(msg);

  // Dispose when no longer needed (call in main dispose, if desired)
  void dispose() => _messageSubject.close();
}
