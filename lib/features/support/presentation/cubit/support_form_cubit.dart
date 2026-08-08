import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import '../../../urge/domain/entities/support_contact.dart';
import '../../../urge/domain/usecases/save_support_contact.dart';

enum SupportFormStatus { initial, saving, success, failure }

class SupportFormState extends Equatable {
  final SupportFormStatus status;
  final String id;
  final String name;
  final String phone;
  final String messageTemplate;
  final String? errorMessage;

  const SupportFormState({
    this.status = SupportFormStatus.initial,
    required this.id,
    this.name = '',
    this.phone = '',
    this.messageTemplate = '',
    this.errorMessage,
  });

  SupportFormState copyWith({
    SupportFormStatus? status,
    String? name,
    String? phone,
    String? messageTemplate,
    String? errorMessage,
  }) {
    return SupportFormState(
      status: status ?? this.status,
      id: id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      messageTemplate: messageTemplate ?? this.messageTemplate,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, id, name, phone, messageTemplate, errorMessage];
}

class SupportFormCubit extends Cubit<SupportFormState> {
  final SaveSupportContact saveSupportContact;

  SupportFormCubit({
    required this.saveSupportContact,
    SupportContact? initialContact,
  }) : super(initialContact != null
            ? SupportFormState(
                id: initialContact.id,
                name: initialContact.name,
                phone: initialContact.phone,
                messageTemplate: initialContact.messageTemplate,
              )
            : SupportFormState(id: const Uuid().v4()));

  void updateName(String name) => emit(state.copyWith(name: name));
  void updatePhone(String phone) => emit(state.copyWith(phone: phone));
  void updateMessageTemplate(String template) => emit(state.copyWith(messageTemplate: template));

  Future<void> save() async {
    if (state.name.trim().isEmpty || state.phone.trim().isEmpty) {
      emit(state.copyWith(
        status: SupportFormStatus.failure,
        errorMessage: 'Name and phone are required',
      ));
      return;
    }

    emit(state.copyWith(status: SupportFormStatus.saving));
    
    final contact = SupportContact(
      id: state.id,
      name: state.name.trim(),
      phone: state.phone.trim(),
      messageTemplate: state.messageTemplate.trim(),
    );

    final result = await saveSupportContact(contact);
    result.fold(
      (failure) => emit(state.copyWith(
        status: SupportFormStatus.failure,
        errorMessage: 'Failed to save contact',
      )),
      (_) => emit(state.copyWith(status: SupportFormStatus.success)),
    );
  }
}
