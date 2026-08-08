import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../domain/entities/tool_action.dart';
import '../../domain/usecases/delete_tool_action.dart';
import '../../toolbox_injection.dart';
import '../cubit/toolbox_form_cubit.dart';
import '../cubit/toolbox_form_state.dart';

class ToolboxFormPage extends StatelessWidget {
  const ToolboxFormPage({super.key, this.action});

  final ToolAction? action;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ToolboxFormCubit(
        saveToolAction: sl(),
        action: action,
      ),
      child: _ToolboxFormView(action: action),
    );
  }
}

class _ToolboxFormView extends StatelessWidget {
  const _ToolboxFormView({this.action});
  final ToolAction? action;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    
    return BlocListener<ToolboxFormCubit, ToolboxFormState>(
      listenWhen: (previous, current) => previous.status != current.status,
      listener: (context, state) {
        if (state.status == ToolboxFormStatus.saved) {
          Navigator.of(context).pop();
        } else if (state.status == ToolboxFormStatus.failure && state.failure != null) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(SnackBar(content: Text(l10n.forFailure(state.failure!))));
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(action == null ? l10n.newToolTitle : l10n.editToolTitle),
          actions: [
            if (action != null)
              IconButton(
                icon: const Icon(Icons.delete_outline),
                onPressed: () async {
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: Text(l10n.deleteTool),
                      content: Text(l10n.deleteToolMessage),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(false),
                          child: Text(l10n.cancel),
                        ),
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(true),
                          child: Text(l10n.delete),
                        ),
                      ],
                    ),
                  );

                  if (confirm == true && context.mounted) {
                    await sl<DeleteToolAction>()(action!.id);
                    if (context.mounted) Navigator.of(context).pop();
                  }
                },
              ),
          ],
        ),
        body: ListView(
          padding: const EdgeInsets.all(AppSpacing.md),
          children: [
            BlocBuilder<ToolboxFormCubit, ToolboxFormState>(
              buildWhen: (p, c) => p.title != c.title || p.titleErrorCode != c.titleErrorCode,
              builder: (context, state) {
                return TextFormField(
                  initialValue: state.title,
                  decoration: InputDecoration(
                    labelText: l10n.toolNameHint,
                    errorText: state.titleErrorCode != null ? l10n.failureNameRequired : null,
                  ),
                  onChanged: context.read<ToolboxFormCubit>().setTitle,
                );
              },
            ),
            const SizedBox(height: AppSpacing.md),
            BlocBuilder<ToolboxFormCubit, ToolboxFormState>(
              buildWhen: (p, c) => p.description != c.description,
              builder: (context, state) {
                return TextFormField(
                  initialValue: state.description,
                  maxLines: 3,
                  decoration: InputDecoration(labelText: l10n.toolDescriptionHint),
                  onChanged: context.read<ToolboxFormCubit>().setDescription,
                );
              },
            ),
            const SizedBox(height: AppSpacing.md),
            // For brevity, using simple slider for duration
            BlocBuilder<ToolboxFormCubit, ToolboxFormState>(
              buildWhen: (p, c) => p.durationMin != c.durationMin,
              builder: (context, state) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('${l10n.toolDurationLabel}: ${state.durationMin}'),
                    Slider(
                      value: state.durationMin.toDouble(),
                      min: 1,
                      max: 60,
                      divisions: 59,
                      onChanged: (val) => context.read<ToolboxFormCubit>().setDuration(val.toInt()),
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: AppSpacing.xl),
            BlocBuilder<ToolboxFormCubit, ToolboxFormState>(
              builder: (context, state) {
                return FilledButton(
                  onPressed: state.isSaving
                      ? null
                      : () => context.read<ToolboxFormCubit>().submit(
                            action?.timesUsed,
                            action?.timesWorked,
                          ),
                  child: Text(l10n.save),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
