import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:my_app/models/payment_card.dart';
import 'package:my_app/models/transaction.dart';

/// Wraps Cloud Firestore operations.
///
/// Call [FirebaseService.initialize] once in main().
/// Check [FirebaseService.isAvailable] before making calls — if false,
/// the app runs purely on local SharedPreferences storage.
class FirebaseService {
  static bool isAvailable = false;

  /// Placeholder project ID written into the bundled google-services.json.
  /// When this matches, Firebase is not yet configured by the user.
  static const _placeholderProjectId = 'placeholder-firebase-id';

  static FirebaseFirestore get _db => FirebaseFirestore.instance;

  // ── Initialisation ──────────────────────────────────────────────────────────

  static Future<void> initialize() async {
    try {
      await Firebase.initializeApp();
      if (Firebase.app().options.projectId == _placeholderProjectId) {
        // User hasn't replaced the placeholder google-services.json yet
        isAvailable = false;
        return;
      }
      isAvailable = true;
    } catch (_) {
      isAvailable = false;
    }
  }

  // ── Cards ───────────────────────────────────────────────────────────────────

  static CollectionReference<Map<String, dynamic>> get _cards =>
      _db.collection('cards');

  static Future<List<PaymentCard>> loadCards() async {
    final snap = await _cards.orderBy('createdAt').get();
    return snap.docs
        .map((d) => PaymentCard.fromJson(d.data()))
        .toList();
  }

  static Future<void> saveCard(PaymentCard card) async {
    await _cards.doc(card.id).set(card.toJson());
  }

  static Future<void> deleteCard(String id) async {
    await _cards.doc(id).delete();
  }

  static Stream<List<PaymentCard>> cardsStream() => _cards
      .orderBy('createdAt')
      .snapshots()
      .map((s) => s.docs.map((d) => PaymentCard.fromJson(d.data())).toList());

  // ── Transactions ─────────────────────────────────────────────────────────────

  static CollectionReference<Map<String, dynamic>> get _transactions =>
      _db.collection('transactions');

  static Future<List<AppTransaction>> loadTransactions() async {
    final snap = await _transactions.orderBy('date', descending: true).get();
    return snap.docs
        .map((d) => AppTransaction.fromJson(d.data()))
        .toList();
  }

  static Future<void> saveTransaction(AppTransaction tx) async {
    await _transactions.doc(tx.id).set(tx.toJson());
  }

  static Future<void> deleteTransaction(String id) async {
    await _transactions.doc(id).delete();
  }

  static Stream<List<AppTransaction>> transactionsStream() => _transactions
      .orderBy('date', descending: true)
      .snapshots()
      .map((s) =>
          s.docs.map((d) => AppTransaction.fromJson(d.data())).toList());
}
