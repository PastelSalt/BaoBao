import 'dart:convert';

import 'package:baobao/core/database/app_database.dart';
import 'package:baobao/features/conversation/domain/conversation_session.dart';
import 'package:drift/drift.dart';

class ConversationRepository {
  const ConversationRepository(this._db);

  final AppDatabase _db;

  /// Remembers where [session] got to, replacing any earlier record.
  Future<void> save(int profileId, ConversationSession session, DateTime now) {
    return _db
        .into(_db.conversationProgress)
        .insertOnConflictUpdate(
          ConversationProgressCompanion.insert(
            profileId: Value(profileId),
            treeId: session.tree.id,
            lastNodeId: session.current.id,
            path: jsonEncode(session.path),
            updatedAt: now,
          ),
        );
  }

  Future<ConversationProgressData?> latest(int profileId) => (_db.select(
    _db.conversationProgress,
  )..where((c) => c.profileId.equals(profileId))).getSingleOrNull();
}
