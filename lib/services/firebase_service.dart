import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:my_app/models/payment_card.dart';
import 'package:my_app/models/transaction.dart';

/// Wraps Cloud Firestore operations.
///
/// Call [FirebaseService.initialize] once in main().
/// Check [FirebaseService.isAvailable] before making calls — if false,
/// the app runs purely on local SharedPreferences storage.
///
/// Data is scoped per authenticated user: `users/{uid}/cards`, `users/{uid}/transactions`.
class FirebaseService {
  static bool isAvailable = false;

  /// Placeholder project ID written into the bundled google-services.json.
  /// When this matches, Firebase is not yet configured by the user.
  static const _placeholderProjectId = 'placeholder-firebase-id';

  static FirebaseFirestore get _db => FirebaseFirestore.instance;

  /// Current user's UID, or null if not signed in.
  static String? get _uid => FirebaseAuth.instance.currentUser?.uid;

  // ── Initialisation ──────────────────────────────────────────────────────────

  static Future<void> initialize() async {
    try {
      await Firebase.initializeApp();
      if (Firebase.app().options.projectId == _placeholderProjectId) {
        isAvailable = false;
        return;
      }
      isAvailable = true;
    } catch (_) {
      isAvailable = false;
    }
  }

  // ── User-scoped collection helpers ──────────────────────────────────────────

  static CollectionReference<Map<String, dynamic>>? get _cards {
    final uid = _uid;
    if (uid == null) return null;
    return _db.collection('users').doc(uid).collection('cards');
  }

  static CollectionReference<Map<String, dynamic>>? get _transactions {
    final uid = _uid;
    if (uid == null) return null;
    return _db.collection('users').doc(uid).collection('transactions');
  }

  // ── Cards ───────────────────────────────────────────────────────────────────

  static Future<List<PaymentCard>> loadCards() async {
    final col = _cards;
    if (col == null) return [];
    final snap = await col.orderBy('createdAt').get();
    return snap.docs
        .map((d) => PaymentCard.fromJson(d.data()))
        .toList();
  }

  static Future<void> saveCard(PaymentCard card) async {
    await _cards?.doc(card.id).set(card.toJson());
  }

  static Future<void> deleteCard(String id) async {
    await _cards?.doc(id).delete();
  }

  static Stream<List<PaymentCard>> cardsStream() {
    final col = _cards;
    if (col == null) return Stream.value([]);
    return col
        .orderBy('createdAt')
        .snapshots()
        .map((s) => s.docs.map((d) => PaymentCard.fromJson(d.data())).toList());
  }

  // ── Transactions ─────────────────────────────────────────────────────────────

  static Future<List<AppTransaction>> loadTransactions() async {
    final col = _transactions;
    if (col == null) return [];
    final snap = await col.orderBy('date', descending: true).get();
    return snap.docs
        .map((d) => AppTransaction.fromJson(d.data()))
        .toList();
  }

  static Future<void> saveTransaction(AppTransaction tx) async {
    await _transactions?.doc(tx.id).set(tx.toJson());
  }

  static Future<void> deleteTransaction(String id) async {
    await _transactions?.doc(id).delete();
  }

  static Stream<List<AppTransaction>> transactionsStream() {
    final col = _transactions;
    if (col == null) return Stream.value([]);
    return col
        .orderBy('date', descending: true)
        .snapshots()
        .map((s) =>
            s.docs.map((d) => AppTransaction.fromJson(d.data())).toList());
  }
}
