import 'package:fc_app3_dailypad/utils/constants.dart';
import 'package:flutter/material.dart';

enum NoteCategory { personal, work, study, ideas, shopping }

extension NoteCategoryExtension on NoteCategory {
  String get label {
    switch (this) {
      case NoteCategory.personal:
        return 'Personal';
      case NoteCategory.work:
        return 'Work';
      case NoteCategory.study:
        return 'Study';
      case NoteCategory.ideas:
        return 'Ideas';
      case NoteCategory.shopping:
        return 'Shopping';
    }
  }

  Color get color {
    switch (this) {
      case NoteCategory.personal:
        return AppColors.categoryPersonal;
      case NoteCategory.work:
        return AppColors.categoryWork;
      case NoteCategory.study:
        return AppColors.categoryStudy;
      case NoteCategory.ideas:
        return AppColors.categoryIdeas;
      case NoteCategory.shopping:
        return AppColors.categoryShopping;
    }
  }

  static NoteCategory fromString(String value) {
    return NoteCategory.values.firstWhere(
      (c) => c.name == value,
      orElse: () => NoteCategory.personal,
    );
  }
}

class Note {
  Note({
    required this.id,
    required this.title,
    required this.content,
    required this.category,
    this.isFavorite = false,
    this.isPinned = false,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  String title;
  String content;
  NoteCategory category;
  bool isFavorite;
  bool isPinned;
  final DateTime createdAt;
  DateTime updatedAt;

  Map<String, dynamic> toMap() => {
        'id': id,
        'title': title,
        'content': content,
        'category': category.name,
        'isFavorite': isFavorite,
        'isPinned': isPinned,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
      };

  factory Note.fromMap(Map<String, dynamic> map) => Note(
        id: map['id'] as String,
        title: map['title'] as String? ?? '',
        content: map['content'] as String? ?? '',
        category: NoteCategoryExtension.fromString(
          map['category'] as String? ?? 'personal',
        ),
        isFavorite: map['isFavorite'] as bool? ?? false,
        isPinned: map['isPinned'] as bool? ?? false,
        createdAt: DateTime.parse(map['createdAt'] as String),
        updatedAt: DateTime.parse(map['updatedAt'] as String),
      );

  Note copyWith({
    String? title,
    String? content,
    NoteCategory? category,
    bool? isFavorite,
    bool? isPinned,
    DateTime? updatedAt,
  }) {
    return Note(
      id: id,
      title: title ?? this.title,
      content: content ?? this.content,
      category: category ?? this.category,
      isFavorite: isFavorite ?? this.isFavorite,
      isPinned: isPinned ?? this.isPinned,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
