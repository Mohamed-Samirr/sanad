import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/section_card.dart';
import '../../domain/entities/journal_entry.dart';
import '../../domain/usecases/save_journal_entry.dart';
import '../cubit/journal_form_cubit.dart';

class JournalFormPage extends StatelessWidget {
  final JournalEntry? initialEntry;

  const JournalFormPage({super.key, this.initialEntry});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => JournalFormCubit(
        saveJournalEntry: GetIt.I<SaveJournalEntry>(),
        initialEntry: initialEntry,
      ),
      child: const _JournalFormView(),
    );
  }
}

class _JournalFormView extends StatefulWidget {
  const _JournalFormView();

  @override
  State<_JournalFormView> createState() => _JournalFormViewState();
}

class _JournalFormViewState extends State<_JournalFormView> {
  late final TextEditingController _feltController;
  late final TextEditingController _neededController;
  late final TextEditingController _thoughtController;
  late final TextEditingController _tagController;

  @override
  void initState() {
    super.initState();
    final state = context.read<JournalFormCubit>().state;
    _feltController = TextEditingController(text: state.feltNote);
    _neededController = TextEditingController(text: state.neededNote);
    _thoughtController = TextEditingController(text: state.thoughtNote);
    _tagController = TextEditingController();
  }

  @override
  void dispose() {
    _feltController.dispose();
    _neededController.dispose();
    _thoughtController.dispose();
    _tagController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return BlocConsumer<JournalFormCubit, JournalFormState>(
      listenWhen: (previous, current) => previous.status != current.status,
      listener: (context, state) {
        if (state.status == JournalFormStatus.success) {
          Navigator.of(context).pop();
        } else if (state.status == JournalFormStatus.failure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.errorMessage ?? l10n.failureUnexpected)),
          );
        }
      },
      builder: (context, state) {
        final cubit = context.read<JournalFormCubit>();
        final isEditing = context.findAncestorWidgetOfExactType<JournalFormPage>()?.initialEntry != null;

        return Scaffold(
          appBar: AppBar(
            title: Text(isEditing ? l10n.editJournalEntry : l10n.addJournalEntry),
            actions: [
              TextButton(
                onPressed: state.status == JournalFormStatus.saving ? null : () => cubit.save(),
                child: state.status == JournalFormStatus.saving
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
                title: l10n.journalMood,
                child: _SliderRow(
                  value: state.mood,
                  onChanged: (val) => cubit.updateMood(val.toInt()),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              SectionCard(
                title: l10n.journalEnergy,
                child: _SliderRow(
                  value: state.energy,
                  onChanged: (val) => cubit.updateEnergy(val.toInt()),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              SectionCard(
                title: l10n.journalSleepQuality,
                child: _SliderRow(
                  value: state.sleepQuality,
                  onChanged: (val) => cubit.updateSleepQuality(val.toInt()),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              SectionCard(
                title: l10n.journalStress,
                child: _SliderRow(
                  value: state.stress,
                  onChanged: (val) => cubit.updateStress(val.toInt()),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              SectionCard(
                title: 'Notes',
                child: Column(
                  children: [
                    TextField(
                      controller: _feltController,
                      decoration: InputDecoration(hintText: l10n.journalFeltNote),
                      maxLines: 3,
                      minLines: 1,
                      onChanged: cubit.updateFeltNote,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    TextField(
                      controller: _neededController,
                      decoration: InputDecoration(hintText: l10n.journalNeededNote),
                      maxLines: 3,
                      minLines: 1,
                      onChanged: cubit.updateNeededNote,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    TextField(
                      controller: _thoughtController,
                      decoration: InputDecoration(hintText: l10n.journalThoughtNote),
                      maxLines: 3,
                      minLines: 1,
                      onChanged: cubit.updateThoughtNote,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              SectionCard(
                title: l10n.journalTags,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: _tagController,
                      decoration: InputDecoration(
                        hintText: l10n.journalTags,
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.add),
                          onPressed: () {
                            cubit.addTag(_tagController.text);
                            _tagController.clear();
                          },
                        ),
                      ),
                      onSubmitted: (val) {
                        cubit.addTag(val);
                        _tagController.clear();
                      },
                    ),
                    if (state.tags.isNotEmpty) ...[
                      const SizedBox(height: AppSpacing.md),
                      Wrap(
                        spacing: AppSpacing.sm,
                        runSpacing: AppSpacing.sm,
                        children: state.tags.map((tag) {
                          return InputChip(
                            label: Text(tag),
                            onDeleted: () => cubit.removeTag(tag),
                          );
                        }).toList(),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _SliderRow extends StatelessWidget {
  final int value;
  final ValueChanged<double> onChanged;

  const _SliderRow({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Text('1'),
        Expanded(
          child: Slider(
            value: value.toDouble(),
            min: 1,
            max: 5,
            divisions: 4,
            label: value.toString(),
            onChanged: onChanged,
          ),
        ),
        const Text('5'),
      ],
    );
  }
}
