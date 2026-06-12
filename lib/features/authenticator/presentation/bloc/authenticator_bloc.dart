import 'dart:async';
import 'package:flutter/foundation.dart' show debugPrint;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:keeauth/core/enums/view_mode.dart';
import 'package:keeauth/features/authenticator/domain/entities/authenticator.dart';
import 'package:keeauth/features/authenticator/domain/entities/category.dart';
import 'package:keeauth/features/authenticator/domain/usecases/authenticator_service.dart';

export '../../../../core/enums/view_mode.dart';

// Events
abstract class AuthenticatorEvent extends Equatable {
  const AuthenticatorEvent();

  @override
  List<Object?> get props => [];
}

class LoadAuthenticators extends AuthenticatorEvent {}

class AddAuthenticator extends AuthenticatorEvent {
  final String uri;
  final List<String>? categoryIds;

  const AddAuthenticator(this.uri, {this.categoryIds});

  @override
  List<Object?> get props => [uri, categoryIds];
}

class UpdateAuthenticator extends AuthenticatorEvent {
  final Authenticator authenticator;

  const UpdateAuthenticator(this.authenticator);

  @override
  List<Object?> get props => [authenticator];
}

class DeleteAuthenticator extends AuthenticatorEvent {
  final String secret;

  const DeleteAuthenticator(this.secret);

  @override
  List<Object?> get props => [secret];
}

class CopyCode extends AuthenticatorEvent {
  final String secret;

  const CopyCode(this.secret);

  @override
  List<Object?> get props => [secret];
}

class RefreshCodes extends AuthenticatorEvent {}

enum SortMode { manual, alphabeticalAsc, alphabeticalDesc, date, mostUsed, leastUsed }

class SetSortMode extends AuthenticatorEvent {
  final SortMode mode;

  const SetSortMode(this.mode);

  @override
  List<Object?> get props => [mode];
}

class SetViewMode extends AuthenticatorEvent {
  final ViewMode mode;

  const SetViewMode(this.mode);

  @override
  List<Object?> get props => [mode];
}

class FilterByCategory extends AuthenticatorEvent {
  final String? categoryId;

  const FilterByCategory(this.categoryId);

  @override
  List<Object?> get props => [categoryId];
}

class ReorderAuthenticators extends AuthenticatorEvent {
  final int oldIndex;
  final int newIndex;

  const ReorderAuthenticators(this.oldIndex, this.newIndex);

  @override
  List<Object?> get props => [oldIndex, newIndex];
}

class SearchAuthenticators extends AuthenticatorEvent {
  final String query;

  const SearchAuthenticators(this.query);

  @override
  List<Object?> get props => [query];
}

class ClearSearch extends AuthenticatorEvent {}

class AdvanceHotpCounter extends AuthenticatorEvent {
  final String secret;

  const AdvanceHotpCounter(this.secret);

  @override
  List<Object?> get props => [secret];
}

class LoadCategories extends AuthenticatorEvent {}

class CreateCategory extends AuthenticatorEvent {
  final String name;
  final int? color;

  const CreateCategory(this.name, {this.color});

  @override
  List<Object?> get props => [name, color];
}

class DeleteCategory extends AuthenticatorEvent {
  final String id;

  const DeleteCategory(this.id);

  @override
  List<Object?> get props => [id];
}

class UpdateCategory extends AuthenticatorEvent {
  final Category category;

  const UpdateCategory(this.category);

  @override
  List<Object?> get props => [category];
}

class ReorderCategories extends AuthenticatorEvent {
  final int oldIndex;
  final int newIndex;

  const ReorderCategories(this.oldIndex, this.newIndex);

  @override
  List<Object?> get props => [oldIndex, newIndex];
}

// State
class AuthenticatorState extends Equatable {
  final List<Authenticator> authenticators;
  final List<Authenticator> filteredAuthenticators;
  final List<Category> categories;
  final String? selectedCategoryId;
  final String searchQuery;
  final SortMode sortMode;
  final ViewMode viewMode;
  final bool isLoading;
  final String? error;
  final Map<String, String> codes; // secret -> code
  final int remainingSeconds;

  const AuthenticatorState({
    this.authenticators = const [],
    this.filteredAuthenticators = const [],
    this.categories = const [],
    this.selectedCategoryId,
    this.searchQuery = '',
    this.sortMode = SortMode.manual,
    this.viewMode = ViewMode.standard,
    this.isLoading = false,
    this.error,
    this.codes = const {},
    this.remainingSeconds = 30,
  });

  AuthenticatorState copyWith({
    List<Authenticator>? authenticators,
    List<Authenticator>? filteredAuthenticators,
    List<Category>? categories,
    String? selectedCategoryId,
    String? searchQuery,
    SortMode? sortMode,
    ViewMode? viewMode,
    bool? isLoading,
    String? error,
    Map<String, String>? codes,
    int? remainingSeconds,
    bool clearError = false,
    bool clearCategory = false,
    bool clearSearch = false,
  }) {
    return AuthenticatorState(
      authenticators: authenticators ?? this.authenticators,
      filteredAuthenticators:
          filteredAuthenticators ?? this.filteredAuthenticators,
      categories: categories ?? this.categories,
      selectedCategoryId:
          clearCategory
              ? null
              : (selectedCategoryId ?? this.selectedCategoryId),
      searchQuery: clearSearch ? '' : (searchQuery ?? this.searchQuery),
      sortMode: sortMode ?? this.sortMode,
      viewMode: viewMode ?? this.viewMode,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      codes: codes ?? this.codes,
      remainingSeconds: remainingSeconds ?? this.remainingSeconds,
    );
  }

  @override
  List<Object?> get props => [
    authenticators,
    filteredAuthenticators,
    categories,
    selectedCategoryId,
    searchQuery,
    viewMode,
    isLoading,
    error,
    codes,
    remainingSeconds,
  ];
}

// BLoC
class AuthenticatorBloc extends Bloc<AuthenticatorEvent, AuthenticatorState> {
  final AuthenticatorService _service;
  Timer? _timer;

  AuthenticatorBloc(this._service) : super(const AuthenticatorState()) {
    on<LoadAuthenticators>(_onLoadAuthenticators);
    on<AddAuthenticator>(_onAddAuthenticator);
    on<UpdateAuthenticator>(_onUpdateAuthenticator);
    on<DeleteAuthenticator>(_onDeleteAuthenticator);
    on<CopyCode>(_onCopyCode);
    on<RefreshCodes>(_onRefreshCodes);
    on<FilterByCategory>(_onFilterByCategory);
    on<ReorderAuthenticators>(_onReorderAuthenticators);
    on<LoadCategories>(_onLoadCategories);
    on<CreateCategory>(_onCreateCategory);
    on<DeleteCategory>(_onDeleteCategory);
    on<UpdateCategory>(_onUpdateCategory);
    on<ReorderCategories>(_onReorderCategories);
    on<SearchAuthenticators>(_onSearchAuthenticators);
    on<ClearSearch>(_onClearSearch);
    on<SetSortMode>(_onSetSortMode);
    on<AdvanceHotpCounter>(_onAdvanceHotpCounter);
    on<SetViewMode>(_onSetViewMode);

    // Load categories on initialization
    add(LoadCategories());

    // Start timer for code refresh
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      add(RefreshCodes());
    });
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    return super.close();
  }

  Future<void> _onLoadAuthenticators(
    LoadAuthenticators event,
    Emitter<AuthenticatorState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, clearError: true));
    try {
      final authenticators = await _service.getAll();
      final categories = await _service.getAllCategories();
      final codes = await _generateCodes(authenticators);
      final remaining = _service.getRemainingSeconds(30);

      // If there's a selected category, re-apply filter
      List<Authenticator> filtered = authenticators;
      if (state.selectedCategoryId != null) {
        filtered =
            authenticators
                .where((a) => a.categoryIds.contains(state.selectedCategoryId))
                .toList();
      }

      filtered = _sortAuthenticators(filtered, state.sortMode);

      emit(
        state.copyWith(
          authenticators: authenticators,
          filteredAuthenticators: filtered,
          categories: categories,
          isLoading: false,
          codes: codes,
          remainingSeconds: remaining,
        ),
      );
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  Future<void> _onAddAuthenticator(
    AddAuthenticator event,
    Emitter<AuthenticatorState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, clearError: true));
    try {
      await _service.addFromUri(event.uri, categoryIds: event.categoryIds);
      add(LoadAuthenticators());
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  Future<void> _onUpdateAuthenticator(
    UpdateAuthenticator event,
    Emitter<AuthenticatorState> emit,
  ) async {
    try {
      await _service.update(event.authenticator);
      // Optimistic UI: update list immediately so list/detail stay in sync
      final newList = state.authenticators
          .map((a) => a.secret == event.authenticator.secret ? event.authenticator : a)
          .toList();
      final newFiltered = state.filteredAuthenticators
          .map((a) => a.secret == event.authenticator.secret ? event.authenticator : a)
          .toList();
      emit(state.copyWith(
        authenticators: newList,
        filteredAuthenticators: newFiltered,
      ));
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }

  Future<void> _onDeleteAuthenticator(
    DeleteAuthenticator event,
    Emitter<AuthenticatorState> emit,
  ) async {
    try {
      await _service.delete(event.secret);
      add(LoadAuthenticators());
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }

  Future<void> _onCopyCode(
    CopyCode event,
    Emitter<AuthenticatorState> emit,
  ) async {
    try {
      await _service.copyCode(event.secret);
      add(LoadAuthenticators());
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }

  Future<void> _onRefreshCodes(
    RefreshCodes event,
    Emitter<AuthenticatorState> emit,
  ) async {
    if (state.authenticators.isEmpty) return;

    final remaining = _service.getRemainingSeconds(30);
    if (remaining == state.remainingSeconds && state.codes.isNotEmpty) return;

    final codes = await _generateCodes(state.authenticators);
    emit(state.copyWith(codes: codes, remainingSeconds: remaining));
  }

  Future<void> _onFilterByCategory(
    FilterByCategory event,
    Emitter<AuthenticatorState> emit,
  ) async {
    if (event.categoryId == null) {
      emit(
        state.copyWith(
          filteredAuthenticators: state.authenticators,
          clearCategory: true,
        ),
      );
    } else {
      final filtered = await _service.getByCategory(event.categoryId!);
      emit(
        state.copyWith(
          filteredAuthenticators:
              filtered.isEmpty ? state.authenticators : filtered,
          selectedCategoryId: event.categoryId,
        ),
      );
    }
  }

  Future<void> _onReorderAuthenticators(
    ReorderAuthenticators event,
    Emitter<AuthenticatorState> emit,
  ) async {
    final list = List<Authenticator>.from(state.filteredAuthenticators);
    final item = list.removeAt(event.oldIndex);
    list.insert(event.newIndex, item);

    // Update rankings
    for (var i = 0; i < list.length; i++) {
      await _service.updateRanking(list[i].secret, i);
    }

    emit(state.copyWith(filteredAuthenticators: list));
  }

  Future<void> _onLoadCategories(
    LoadCategories event,
    Emitter<AuthenticatorState> emit,
  ) async {
    try {
      final categories = await _service.getAllCategories();
      emit(state.copyWith(categories: categories));
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }

  Future<void> _onCreateCategory(
    CreateCategory event,
    Emitter<AuthenticatorState> emit,
  ) async {
    try {
      final category = await _service.createCategory(
        event.name,
        color: event.color,
      );
      final list = List<Category>.from(state.categories)..add(category);
      emit(state.copyWith(categories: list));
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }

  Future<void> _onDeleteCategory(
    DeleteCategory event,
    Emitter<AuthenticatorState> emit,
  ) async {
    try {
      await _service.deleteCategory(event.id);
      add(LoadCategories());
      add(LoadAuthenticators());
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }

  Future<void> _onUpdateCategory(
    UpdateCategory event,
    Emitter<AuthenticatorState> emit,
  ) async {
    try {
      await _service.updateCategory(event.category);
      add(LoadCategories());
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }

  Future<void> _onReorderCategories(
    ReorderCategories event,
    Emitter<AuthenticatorState> emit,
  ) async {
    final list = List<Category>.from(state.categories);
    final item = list.removeAt(event.oldIndex);
    final newIndex = event.newIndex > event.oldIndex
        ? event.newIndex - 1
        : event.newIndex;
    list.insert(newIndex, item);

    for (var i = 0; i < list.length; i++) {
      await _service.updateCategory(list[i].copyWith(ranking: i));
    }

    emit(state.copyWith(categories: list));
  }

  Future<void> _onSearchAuthenticators(
    SearchAuthenticators event,
    Emitter<AuthenticatorState> emit,
  ) async {
    final query = event.query.toLowerCase().trim();
    if (query.isEmpty) {
      emit(
        state.copyWith(
          filteredAuthenticators: state.authenticators,
          searchQuery: query,
        ),
      );
      return;
    }

    final filtered =
        state.authenticators.where((auth) {
          final issuerMatch = auth.issuer.toLowerCase().contains(query);
          final accountMatch = auth.accountName.toLowerCase().contains(query);

          // Search by category name
          bool categoryMatch = false;
          if (auth.categoryIds.isNotEmpty) {
            for (final categoryId in auth.categoryIds) {
              final category = state.categories.firstWhere(
                (c) => c.id == categoryId,
                orElse:
                    () => Category(
                      id: '',
                      name: '',
                      createdAt: DateTime.now(),
                      updatedAt: DateTime.now(),
                    ),
              );
              if (category.name.toLowerCase().contains(query)) {
                categoryMatch = true;
                break;
              }
            }
          }

          return issuerMatch || accountMatch || categoryMatch;
        }).toList();


    emit(state.copyWith(filteredAuthenticators: filtered, searchQuery: query));
  }

  Future<void> _onClearSearch(
    ClearSearch event,
    Emitter<AuthenticatorState> emit,
  ) async {
    emit(
      state.copyWith(
        filteredAuthenticators: state.authenticators,
        clearSearch: true,
      ),
    );
  }

  Future<void> _onSetSortMode(
    SetSortMode event,
    Emitter<AuthenticatorState> emit,
  ) async {
    emit(state.copyWith(sortMode: event.mode));

    // Re-sort the list
    final sorted = _sortAuthenticators(
      state.filteredAuthenticators,
      event.mode,
    );
    emit(state.copyWith(filteredAuthenticators: sorted));
  }

  Future<void> _onSetViewMode(
    SetViewMode event,
    Emitter<AuthenticatorState> emit,
  ) async {
    emit(state.copyWith(viewMode: event.mode));
  }

  Future<void> _onAdvanceHotpCounter(
    AdvanceHotpCounter event,
    Emitter<AuthenticatorState> emit,
  ) async {
    try {
      final authenticator = await _service.getBySecret(event.secret);
      if (authenticator == null) return;

      final updated = authenticator.copyWith(
        counter: authenticator.counter + 1,
        updatedAt: DateTime.now(),
      );
      await _service.update(updated);

      final codes = Map<String, String>.from(state.codes);
      codes[updated.secret] = _service.generateCode(updated);
      emit(state.copyWith(codes: codes));

      add(LoadAuthenticators());
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }

  List<Authenticator> _sortAuthenticators(
    List<Authenticator> authenticators,
    SortMode mode,
  ) {
    final sorted = List<Authenticator>.from(authenticators);
    switch (mode) {
      case SortMode.manual:
        sorted.sort((a, b) => a.ranking.compareTo(b.ranking));
      case SortMode.alphabeticalAsc:
        sorted.sort((a, b) => a.issuer.toLowerCase().compareTo(b.issuer.toLowerCase()));
      case SortMode.alphabeticalDesc:
        sorted.sort((a, b) => b.issuer.toLowerCase().compareTo(a.issuer.toLowerCase()));
      case SortMode.date:
        sorted.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      case SortMode.mostUsed:
        sorted.sort((a, b) {
          final cmp = b.copyCount.compareTo(a.copyCount);
          return cmp != 0 ? cmp : a.issuer.toLowerCase().compareTo(b.issuer.toLowerCase());
        });
      case SortMode.leastUsed:
        sorted.sort((a, b) {
          final cmp = a.copyCount.compareTo(b.copyCount);
          return cmp != 0 ? cmp : a.issuer.toLowerCase().compareTo(b.issuer.toLowerCase());
        });
    }
    return sorted;
  }

  Future<Map<String, String>> _generateCodes(
    List<Authenticator> authenticators,
  ) async {
    final codes = <String, String>{};
    for (final auth in authenticators) {
      try {
        codes[auth.secret] = _service.generateCode(auth);
      } catch (e) {
        debugPrint('[BLoC] Failed to generate code for ${auth.issuer}: $e');
        codes[auth.secret] = 'ERROR';
      }
    }
    return codes;
  }
}
