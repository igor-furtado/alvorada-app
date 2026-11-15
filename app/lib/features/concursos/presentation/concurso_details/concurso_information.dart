import 'package:estudos_app/core/design_system/design_system.dart';
import 'package:material_ui/material_ui.dart';

import '../concurso_view_data.dart';

const _stepIndicatorSize = 30.0;
const _compactFieldWidth = 120.0;

class ConcursoInformation extends StatelessWidget {
  const ConcursoInformation({required this.concurso, super.key});

  final ConcursoViewData concurso;

  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.only(top: context.tokens.spacing.xxxl, bottom: context.tokens.spacing.jumbo),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.l10n.examJourneyEyebrow,
          style: context.tokens.typography.labelSmall.copyWith(color: context.tokens.colors.info),
        ),
        SizedBox(height: context.tokens.spacing.sm),
        Text(context.l10n.examJourneyTitle, style: context.tokens.typography.headlineLarge),
        SizedBox(height: context.tokens.spacing.sm),
        Text(
          context.l10n.examJourneyDescription,
          style: context.tokens.typography.bodyLarge.copyWith(color: context.tokens.colors.onSurfaceMuted),
        ),
        SizedBox(height: context.tokens.spacing.xxxl),
        _JourneyStep(
          number: 1,
          stage: context.l10n.qualification,
          title: context.l10n.entryRequirement,
          description: concurso.requirements,
        ),
        _JourneyStep(
          number: 2,
          stage: context.l10n.assessment,
          title: context.l10n.examsAndScoring,
          description: concurso.scoringCriteria,
          facts: [(context.l10n.time, concurso.examTime)],
        ),
        _JourneyStep(
          number: 3,
          stage: context.l10n.ranking,
          title: context.l10n.expectedOffer,
          facts: [(context.l10n.total, concurso.vacancies)],
        ),
        _JourneyStep(
          number: 4,
          stage: context.l10n.appointment,
          title: context.l10n.positionConditions,
          facts: [
            (context.l10n.employmentType, concurso.hiringRegime),
            (context.l10n.startingSalary, concurso.remuneration),
            (context.l10n.workload, concurso.weeklyWorkload),
          ],
          last: true,
        ),
      ],
    ),
  );
}

class _JourneyStep extends StatelessWidget {
  const _JourneyStep({
    required this.number,
    required this.stage,
    required this.title,
    this.description,
    this.facts = const [],
    this.last = false,
  });

  final int number;
  final String stage;
  final String title;
  final String? description;
  final List<(String, String)> facts;
  final bool last;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final compact = constraints.maxWidth < context.tokens.layout.toolbar;
      final marker = Container(
        width: _stepIndicatorSize,
        height: _stepIndicatorSize,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: context.tokens.colors.surface,
          border: Border.all(color: context.tokens.colors.controlOutline),
          borderRadius: context.tokens.borders.full,
        ),
        child: Text('$number', style: context.tokens.typography.labelSmall),
      );
      final card = AppCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: context.tokens.typography.titleMedium),
            if (description != null) ...[
              SizedBox(height: context.tokens.spacing.sm),
              Text(
                description!,
                style: context.tokens.typography.bodyMedium.copyWith(color: context.tokens.colors.onSurfaceMuted),
              ),
            ],
            if (facts.isNotEmpty) ...[
              SizedBox(height: context.tokens.spacing.lg),
              Wrap(
                spacing: context.tokens.spacing.xxxl,
                runSpacing: context.tokens.spacing.lg,
                children: [for (final fact in facts) _JourneyFact(label: fact.$1, value: fact.$2)],
              ),
            ],
          ],
        ),
      );
      final bottom = last ? 0.0 : context.tokens.spacing.xxxl;
      if (compact) {
        return Padding(
          padding: EdgeInsets.only(bottom: bottom),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              marker,
              SizedBox(width: context.tokens.spacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(stage, style: context.tokens.typography.labelLarge),
                    SizedBox(height: context.tokens.spacing.sm),
                    card,
                  ],
                ),
              ),
            ],
          ),
        );
      }
      return Padding(
        padding: EdgeInsets.only(bottom: bottom),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            marker,
            SizedBox(width: context.tokens.spacing.xxl),
            SizedBox(
              width: _compactFieldWidth,
              child: Padding(
                padding: EdgeInsets.only(top: context.tokens.spacing.xs),
                child: Text(stage, style: context.tokens.typography.labelLarge),
              ),
            ),
            SizedBox(width: context.tokens.spacing.xxl),
            Expanded(child: card),
          ],
        ),
      );
    },
  );
}

class _JourneyFact extends StatelessWidget {
  const _JourneyFact({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        label,
        style: context.tokens.typography.labelSmall.copyWith(color: context.tokens.colors.onSurfaceMuted),
      ),
      SizedBox(height: context.tokens.spacing.xxxs),
      Text(value, style: context.tokens.typography.titleMedium),
    ],
  );
}
