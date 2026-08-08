import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/section_card.dart';
import '../../../urge/domain/entities/support_contact.dart';
import '../../../urge/domain/usecases/save_support_contact.dart';
import '../cubit/support_form_cubit.dart';

class SupportFormPage extends StatelessWidget {
  final SupportContact? initialContact;

  const SupportFormPage({super.key, this.initialContact});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => SupportFormCubit(
        saveSupportContact: GetIt.I<SaveSupportContact>(),
        initialContact: initialContact,
      ),
      child: const _SupportFormView(),
    );
  }
}

class _SupportFormView extends StatefulWidget {
  const _SupportFormView();

  @override
  State<_SupportFormView> createState() => _SupportFormViewState();
}

class _SupportFormViewState extends State<_SupportFormView> {
  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _templateController;

  @override
  void initState() {
    super.initState();
    final state = context.read<SupportFormCubit>().state;
    _nameController = TextEditingController(text: state.name);
    _phoneController = TextEditingController(text: state.phone);
    _templateController = TextEditingController(text: state.messageTemplate);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _templateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    
    return BlocConsumer<SupportFormCubit, SupportFormState>(
      listenWhen: (previous, current) => previous.status != current.status,
      listener: (context, state) {
        if (state.status == SupportFormStatus.success) {
          Navigator.of(context).pop();
        } else if (state.status == SupportFormStatus.failure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.errorMessage ?? l10n.failureUnexpected)),
          );
        }
      },
      builder: (context, state) {
        final cubit = context.read<SupportFormCubit>();
        final isEditing = context.findAncestorWidgetOfExactType<SupportFormPage>()?.initialContact != null;

        return Scaffold(
          appBar: AppBar(
            title: Text(isEditing ? l10n.editSupportContact : l10n.addSupportContact),
            actions: [
              TextButton(
                onPressed: state.status == SupportFormStatus.saving ? null : () => cubit.save(),
                child: state.status == SupportFormStatus.saving
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(l10n.save),
              ),
              const SizedBox(width: AppSpacing.sm),
            ],
          ),
          body: ListView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            children: [
              SectionCard(
                title: 'Contact Details',
                child: Column(
                  children: [
                    TextField(
                      controller: _nameController,
                      decoration: InputDecoration(hintText: l10n.contactName),
                      onChanged: cubit.updateName,
                      textInputAction: TextInputAction.next,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    TextField(
                      controller: _phoneController,
                      decoration: InputDecoration(hintText: l10n.contactPhone),
                      keyboardType: TextInputType.phone,
                      onChanged: cubit.updatePhone,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              SectionCard(
                title: l10n.contactMessageTemplate,
                child: TextField(
                  controller: _templateController,
                  decoration: InputDecoration(hintText: l10n.contactMessageHint),
                  maxLines: 4,
                  minLines: 2,
                  onChanged: cubit.updateMessageTemplate,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
