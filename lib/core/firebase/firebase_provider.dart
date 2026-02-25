import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Firestore 인스턴스 Provider
final firestoreProvider = Provider<FirebaseFirestore>((ref) {
  return FirebaseFirestore.instance;
});

/// noiseReports 컬렉션 레퍼런스
final noiseReportsRef = Provider<CollectionReference>((ref) {
  final firestore = ref.watch(firestoreProvider);
  return firestore.collection('noiseReports');
});
