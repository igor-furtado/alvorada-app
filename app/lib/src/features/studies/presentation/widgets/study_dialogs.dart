import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/study_catalog.dart';

typedef SubjectDraft = ({String name, int difficulty, String color});

const subjectColors = [
  '#6657D9',
  '#3178C6',
  '#2D9C78',
  '#E07A4E',
  '#D95573',
  '#7A5C43',
];

Future<String?> showNameDialog(
  BuildContext context, {
  required String title,
  required String label,
  String initialValue = '',
}) async {
  final controller = TextEditingController(text: initialValue);
  final formKey = GlobalKey<FormState>();
  final result = await showDialog<String>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(title),
      content: SizedBox(
        width: 420,
        child: Form(
          key: formKey,
          child: TextFormField(
            controller: controller,
            autofocus: true,
            maxLength: 120,
            decoration: InputDecoration(
              labelText: label,
              hintText: 'Digite um nome',
            ),
            validator: (value) => value == null || value.trim().isEmpty
                ? 'Informe um nome'
                : null,
            onFieldSubmitted: (_) {
              if (formKey.currentState!.validate()) {
                Navigator.pop(context, controller.text.trim());
              }
            },
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: () {
            if (formKey.currentState!.validate()) {
              Navigator.pop(context, controller.text.trim());
            }
          },
          child: const Text('Salvar'),
        ),
      ],
    ),
  );
  controller.dispose();
  return result;
}

Future<SubjectDraft?> showSubjectDialog(
  BuildContext context, {
  StudySubject? subject,
}) async {
  final controller = TextEditingController(text: subject?.name ?? '');
  final formKey = GlobalKey<FormState>();
  var difficulty = subject?.difficulty.value ?? 3;
  var color = subject?.colorHex ?? subjectColors.first;

  final result = await showDialog<SubjectDraft>(
    context: context,
    builder: (context) => StatefulBuilder(
      builder: (context, setState) => AlertDialog(
        title: Text(subject == null ? 'Nova disciplina' : 'Editar disciplina'),
        content: SizedBox(
          width: 460,
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  controller: controller,
                  autofocus: true,
                  maxLength: 120,
                  decoration: const InputDecoration(
                    labelText: 'Nome da disciplina',
                    hintText: 'Ex.: Direito Constitucional',
                  ),
                  validator: (value) => value == null || value.trim().isEmpty
                      ? 'Informe um nome'
                      : null,
                ),
                const SizedBox(height: 14),
                const Text(
                  'Como essa matéria é para você?',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: AppColors.ink,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: Difficulty.values
                      .map(
                        (item) => ChoiceChip(
                          label: Text(item.label),
                          selected: difficulty == item.value,
                          onSelected: (_) =>
                              setState(() => difficulty = item.value),
                        ),
                      )
                      .toList(),
                ),
                const SizedBox(height: 18),
                const Text(
                  'Cor',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: AppColors.ink,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 10,
                  children: subjectColors.map((item) {
                    final itemColor = Color(
                      int.parse('FF${item.substring(1)}', radix: 16),
                    );
                    return InkWell(
                      borderRadius: BorderRadius.circular(20),
                      onTap: () => setState(() => color = item),
                      child: Container(
                        width: 34,
                        height: 34,
                        decoration: BoxDecoration(
                          color: itemColor,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: color == item
                                ? AppColors.ink
                                : Colors.transparent,
                            width: 3,
                          ),
                        ),
                        child: color == item
                            ? const Icon(
                                Icons.check,
                                color: Colors.white,
                                size: 18,
                              )
                            : null,
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                Navigator.pop(context, (
                  name: controller.text.trim(),
                  difficulty: difficulty,
                  color: color,
                ));
              }
            },
            child: Text(
              subject == null ? 'Criar disciplina' : 'Salvar alterações',
            ),
          ),
        ],
      ),
    ),
  );
  controller.dispose();
  return result;
}

Future<bool> confirmDelete(BuildContext context, String itemName) async =>
    await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Excluir item?'),
        content: Text(
          '“$itemName” será excluído. Os itens dentro dele também serão removidos.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.danger),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Excluir'),
          ),
        ],
      ),
    ) ??
    false;
