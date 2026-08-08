import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/usecase/usecase.dart';
import '../../../urge/domain/entities/support_contact.dart';
import '../../../urge/domain/repositories/support_repository.dart';
import '../../../urge/domain/usecases/delete_support_contact.dart';
import '../../../urge/domain/usecases/get_support_contacts.dart';

enum SupportStatus { initial, loading, success, failure }

class SupportState extends Equatable {
  final SupportStatus status;
  final List<SupportContact> contacts;
  final String? errorMessage;

  const SupportState({
    this.status = SupportStatus.initial,
    this.contacts = const [],
    this.errorMessage,
  });

  SupportState copyWith({
    SupportStatus? status,
    List<SupportContact>? contacts,
    String? errorMessage,
  }) {
    return SupportState(
      status: status ?? this.status,
      contacts: contacts ?? this.contacts,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, contacts, errorMessage];
}

class SupportCubit extends Cubit<SupportState> {
  final GetSupportContacts getSupportContacts;
  final DeleteSupportContact deleteSupportContact;
  final SupportRepository repository;
  
  StreamSubscription? _subscription;

  SupportCubit({
    required this.getSupportContacts,
    required this.deleteSupportContact,
    required this.repository,
  }) : super(const SupportState()) {
    _subscription = repository.watchContacts().listen((_) {
      loadContacts();
    });
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }

  Future<void> loadContacts() async {
    emit(state.copyWith(status: SupportStatus.loading));
    final result = await getSupportContacts(const NoParams());
    result.fold(
      (failure) => emit(state.copyWith(
        status: SupportStatus.failure,
        errorMessage: 'Failed to load contacts.',
      )),
      (contacts) => emit(state.copyWith(
        status: SupportStatus.success,
        contacts: contacts,
      )),
    );
  }

  Future<void> deleteContact(String id) async {
    final result = await deleteSupportContact(id);
    result.fold(
      (failure) => emit(state.copyWith(
        status: SupportStatus.failure,
        errorMessage: 'Failed to delete contact.',
      )),
      (_) {
        // Automatically reloads due to watchContacts()
      },
    );
  }
}
