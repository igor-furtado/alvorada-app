// ignore_for_file: deprecated_member_use

// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get navigationConcursos => 'Exams';

  @override
  String get navigationDisciplines => 'Subjects';

  @override
  String get navigationSection => 'Navigation';

  @override
  String get navigationPath => 'Navigation path';

  @override
  String get navigationSearch => 'Go to an area…';

  @override
  String get useLightTheme => 'Use light theme';

  @override
  String get useDarkTheme => 'Use dark theme';

  @override
  String get loading => 'Loading';

  @override
  String get search => 'Search';

  @override
  String get loadingMore => 'Loading more results';

  @override
  String get tryAgain => 'Try again';

  @override
  String get update => 'Refresh';

  @override
  String get clearSearch => 'Clear search';

  @override
  String get noMoreResults => 'All results have been loaded.';

  @override
  String get genericErrorTitle => 'Unable to load';

  @override
  String get genericErrorMessage => 'Try again. Your data has been preserved.';

  @override
  String get offlineTitle => 'You are offline';

  @override
  String get offlineMessage => 'Check your connection and try again.';

  @override
  String get permissionDeniedTitle => 'Access denied';

  @override
  String get permissionDeniedMessage => 'Review the permission to continue.';

  @override
  String get successTitle => 'All set';

  @override
  String get emptyTitle => 'Nothing here yet';

  @override
  String get requiredField => 'Required field';

  @override
  String get formHasErrors => 'Review the first highlighted field.';

  @override
  String get requiredSuffix => 'required';

  @override
  String get cancel => 'Cancel';

  @override
  String get close => 'Close';

  @override
  String get understand => 'Got it';

  @override
  String get add => 'Add';

  @override
  String get name => 'Name';

  @override
  String get notNow => 'Not now';

  @override
  String get start => 'Start';

  @override
  String get undo => 'Undo';

  @override
  String get novoConcurso => 'New Exam';

  @override
  String get novoConcursoDescription => 'Enter the main details and exam information.';

  @override
  String get concurso => 'Exam';

  @override
  String get concursoPrioritario => 'Priority exam';

  @override
  String get concursosSubtitle => 'Your target exams ordered by exam date.';

  @override
  String get noticeProgress => 'Syllabus progress';

  @override
  String get exam => 'Exam date';

  @override
  String get nenhumConcursoAtivo => 'No active exam';

  @override
  String get institution => 'Institution';

  @override
  String get role => 'Position / Specialty';

  @override
  String get board => 'Exam board';

  @override
  String get organizationAcronym => 'Institution acronym';

  @override
  String get vacancies => 'Number of openings';

  @override
  String get hiringRegime => 'Employment type';

  @override
  String get hiringRegimePlaceholder => 'Select an employment type';

  @override
  String get statutoryHiringRegime => 'Statutory';

  @override
  String get cltHiringRegime => 'Employment contract';

  @override
  String get remuneration => 'Salary';

  @override
  String get remunerationPlaceholder => 'E.g. 12.345,67';

  @override
  String get weeklyWorkload => 'Weekly workload';

  @override
  String get weeklyWorkloadHelp => 'Enter the number of hours per week.';

  @override
  String get examLocation => 'Exam location';

  @override
  String get examStartTime => 'Start time';

  @override
  String get examEndTime => 'End time';

  @override
  String get timePlaceholder => 'HH:MM';

  @override
  String get requirements => 'Requirements';

  @override
  String get requirementsHelp => 'Degrees, education, registrations, and required proof.';

  @override
  String get scoringCriteria => 'Score calculation';

  @override
  String get scoringCriteriaHelp => 'Weights, tie-break criteria, and other scoring rules.';

  @override
  String get concursoInformation => 'Exam information';

  @override
  String get invalidNonNegativeInteger => 'Enter a whole number greater than or equal to zero.';

  @override
  String get invalidWeeklyWorkload => 'Enter between 1 and 168 hours per week.';

  @override
  String get invalidRemuneration => 'Enter a valid amount, such as 12.345,67.';

  @override
  String get invalidExamTime => 'Enter a valid time in HH:MM format.';

  @override
  String get invalidExamTimeRange => 'Enter a start and end time, with the end after the start.';

  @override
  String get examDate => 'Exam date';

  @override
  String get examDatePlaceholder => 'DD/MM/YYYY';

  @override
  String get invalidExamDate => 'Enter a valid date in DD/MM/YYYY format.';

  @override
  String get definirConcursoPrioritario => 'Set as priority';

  @override
  String get concursoPrioritarioField => 'Use as priority exam';

  @override
  String get concursoPrioritarioHelp => 'It will take priority when the available hours cannot cover the full scope.';

  @override
  String get criarConcurso => 'Create Exam';

  @override
  String get editarConcurso => 'Edit Exam';

  @override
  String get editarConcursoDescription => 'Update this exam\'s details and information.';

  @override
  String get toBeDefined => 'To be defined';

  @override
  String get excluirConcurso => 'Delete Exam';

  @override
  String get excluirConcursoQuestion => 'Delete Exam?';

  @override
  String get days => 'days';

  @override
  String get openNotice => 'Open Syllabus';

  @override
  String get moreActions => 'More actions';

  @override
  String get seeDetails => 'View details';

  @override
  String get archive => 'Archive';

  @override
  String get delete => 'Delete';

  @override
  String get concursosEmpty => 'Add an Exam to get started.';

  @override
  String get notice => 'Syllabus';

  @override
  String get carregandoConcursos => 'Loading Exams';

  @override
  String get concursoCriado => 'Exam created.';

  @override
  String get concursoAtualizado => 'Exam updated.';

  @override
  String get concursoPriorizado => 'Priority exam updated.';

  @override
  String get concursoRestaurado => 'Exam restored.';

  @override
  String get concursoExcluido => 'Exam deleted.';

  @override
  String get concursosAtualizados => 'Exams refreshed.';

  @override
  String get concursoOperacaoFalhou => 'Unable to complete the change. Try again.';

  @override
  String get concursosSincronizacaoPendente => 'Change saved. Refresh to see the latest Exams.';

  @override
  String get newDiscipline => 'New Subject';

  @override
  String get newDisciplineDescription => 'Add a Subject to organize its Topics.';

  @override
  String get editDisciplineDescription => 'Update the Subject name in the shared catalog.';

  @override
  String get disciplineNameExample => 'E.g. English Language';

  @override
  String get main => 'Main';

  @override
  String get disciplineName => 'Name';

  @override
  String get disciplineWeight => 'Syllabus weight';

  @override
  String get noDiscipline => 'No Subject linked to this Syllabus.';

  @override
  String get concursoNaoEncontrado => 'Exam not found';

  @override
  String get contentCatalog => 'Subjects';

  @override
  String get contentCatalogSubtitle => 'Catalog of Subjects and Topics shared across Exams.';

  @override
  String get searchContent => 'Search Subjects and Topics';

  @override
  String get addDiscipline => 'Add Subject';

  @override
  String get addTopics => 'Add Topics';

  @override
  String get addTopicsDescription => 'Add one or more Topics to the selected Subject.';

  @override
  String get topicsPerLineExample => 'E.g.\nReading comprehension\nPunctuation\nGrammar';

  @override
  String get rename => 'Rename';

  @override
  String get editDiscipline => 'Edit Subject';

  @override
  String get editTopic => 'Edit Topic';

  @override
  String get editTopicDescription => 'Update the Topic name in the shared catalog.';

  @override
  String get saveChanges => 'Save changes';

  @override
  String get deleteDiscipline => 'Delete Subject';

  @override
  String get deleteDisciplineQuestion => 'Delete Subject?';

  @override
  String get deleteTopicQuestion => 'Delete Topic?';

  @override
  String get noContentFound => 'No Subject';

  @override
  String get noContentFoundMessage => 'Add a Subject to get started.';

  @override
  String get mandatoryTopic => 'Required Topic';

  @override
  String get mandatory => 'Required';

  @override
  String get protected => 'Protected';

  @override
  String get topics => 'Topics';

  @override
  String get loadingDisciplines => 'Loading Subjects';

  @override
  String get disciplinesUpdated => 'Subjects refreshed.';

  @override
  String get disciplineCreated => 'Subject added.';

  @override
  String get disciplineUpdated => 'Subject updated.';

  @override
  String get disciplineDeleted => 'Subject deleted.';

  @override
  String get topicCreated => 'Topics added.';

  @override
  String get topicUpdated => 'Topic updated.';

  @override
  String get topicDeleted => 'Topic deleted.';

  @override
  String get contentUpdateFailed => 'Unable to refresh. The displayed data has been preserved.';

  @override
  String get contentSavedSyncPending => 'Change saved. Refresh to see the latest data.';

  @override
  String get contentOperationFailed => 'Unable to save the change. Try again.';

  @override
  String get today => 'today';

  @override
  String loadedItems(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count results loaded.',
      one: '1 result loaded.',
    );
    return '$_temp0';
  }

  @override
  String catalogSummary(int disciplineCount, int topicCount) {
    String _temp0 = intl.Intl.pluralLogic(
      disciplineCount,
      locale: localeName,
      other: '$disciplineCount Subjects',
      one: '1 Subject',
    );
    String _temp1 = intl.Intl.pluralLogic(
      topicCount,
      locale: localeName,
      other: '$topicCount Topics',
      one: '1 Topic',
    );
    return '$_temp0  ·  $_temp1';
  }

  @override
  String disciplineResults(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Subjects',
      one: '1 Subject',
    );
    return '$_temp0';
  }

  @override
  String topicCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Topics',
      one: '1 Topic',
    );
    return '$_temp0';
  }

  @override
  String topicCountInCatalog(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Topics in the catalog.',
      one: '1 Topic in the catalog.',
    );
    return '$_temp0';
  }

  @override
  String topicsPerLineDescription(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Topics ready to add.',
      one: '1 Topic ready to add.',
      zero: 'No Topics ready to add.',
    );
    return 'Enter one Topic per line. Empty lines will be ignored. $_temp0';
  }

  @override
  String addTopicsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Add $count Topics',
      one: 'Add 1 Topic',
      zero: 'Add Topics',
    );
    return '$_temp0';
  }

  @override
  String disciplineDeletedImpact(String name) {
    return '$name and its Topics will be deleted from the shared catalog. This action cannot be undone.';
  }

  @override
  String topicDeletedImpact(String name) {
    return '$name will be deleted from the shared catalog. This action cannot be undone.';
  }

  @override
  String concursoArquivado(String name) {
    return '$name was archived.';
  }

  @override
  String nextExamIn(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: 'The next exam is in $days days',
      one: 'The next exam is in 1 day',
    );
    return '$_temp0';
  }

  @override
  String vacanciesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count openings',
      one: '1 opening',
    );
    return '$_temp0';
  }

  @override
  String excluirConcursoImpacto(String name) {
    return '$name and its Syllabus will be removed. This action cannot be undone.';
  }

  @override
  String removeItem(String label) {
    return 'Remove $label';
  }

  @override
  String get closeNotification => 'Close notification';

  @override
  String get resizePanels => 'Resize panels';

  @override
  String get tryAgainLater => 'Try again in a moment.';

  @override
  String get topicsInSyllabusDescription => 'Topics from this Subject included in the Syllabus.';

  @override
  String get information => 'Information';

  @override
  String get priority => 'Priority';

  @override
  String get location => 'Location';

  @override
  String get searchDiscipline => 'Search Subject';

  @override
  String get editSyllabus => 'Edit Syllabus';

  @override
  String get syllabusDisciplines => 'Syllabus Subjects';

  @override
  String get syllabusContentSubtitle => 'Content covered by this Exam';

  @override
  String get syllabusEmptyMessage => 'Add a Subject or an existing Topic from the catalog.';

  @override
  String get disciplineSearchEmptyTitle => 'No Subject found';

  @override
  String get disciplineSearchEmptyMessage => 'Try searching for another name.';

  @override
  String get advanceLowerTitle => 'Up to 25% progress';

  @override
  String get advanceLowerSubtitle => 'Subjects at the start of the Syllabus';

  @override
  String get advanceMiddleTitle => '26% to 60% progress';

  @override
  String get advanceMiddleSubtitle => 'Subjects in development';

  @override
  String get advanceUpperTitle => 'Above 60% progress';

  @override
  String get advanceUpperSubtitle => 'Most advanced Subjects';

  @override
  String get performanceLowerTitle => 'Below 60% performance';

  @override
  String get performanceLowerSubtitle => 'Subjects with lower performance';

  @override
  String get performanceMiddleTitle => '60% to 79% performance';

  @override
  String get performanceMiddleSubtitle => 'Subjects with intermediate performance';

  @override
  String get performanceUpperTitle => '80% performance or higher';

  @override
  String get performanceUpperSubtitle => 'Subjects with higher performance';

  @override
  String openDiscipline(String name) {
    return 'Open $name';
  }

  @override
  String get examJourneyEyebrow => 'EXAM JOURNEY';

  @override
  String get examJourneyTitle => 'From qualification to appointment';

  @override
  String get examJourneyDescription => 'Exam conditions shown in the order in which they affect your decision.';

  @override
  String get qualification => 'Qualification';

  @override
  String get entryRequirement => 'Entry requirement';

  @override
  String get assessment => 'Assessment';

  @override
  String get examsAndScoring => 'Exams and scoring';

  @override
  String get time => 'Time';

  @override
  String get ranking => 'Ranking';

  @override
  String get expectedOffer => 'Expected offer';

  @override
  String get total => 'Total';

  @override
  String get appointment => 'Appointment';

  @override
  String get positionConditions => 'Position conditions';

  @override
  String get employmentType => 'Employment type';

  @override
  String get startingSalary => 'Starting salary';

  @override
  String get workload => 'Workload';

  @override
  String get concursoNotFoundMessage => 'Return to Exams and choose another item.';

  @override
  String get addToSyllabus => 'Add to Syllabus';

  @override
  String get linkCatalogContent => 'Link existing content from the catalog.';

  @override
  String get loadingCatalog => 'Loading catalog';

  @override
  String get discipline => 'Subject';

  @override
  String get topic => 'Topic';

  @override
  String get disciplineSearchExample => 'E.g. Criminal Law';

  @override
  String get linkDisciplineNote => 'Link a Subject that already exists in the shared catalog to the Syllabus.';

  @override
  String topicsInCatalog(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Topics in the catalog',
      one: '1 Topic in the catalog',
    );
    return '$_temp0';
  }

  @override
  String get added => 'Added';

  @override
  String get chooseDisciplineNote => 'Choose a Subject from the Syllabus and link or remove an existing Topic.';

  @override
  String get selectDiscipline => 'Select a Subject';

  @override
  String get searchTopic => 'Search Topic';

  @override
  String get topicSearchExample => 'E.g. Tax obligations';

  @override
  String get noSyllabusDiscipline => 'No Subject in the Syllabus';

  @override
  String get noSyllabusDisciplineMessage => 'Add a Subject before linking Topics individually.';

  @override
  String get sharedCatalog => 'Shared catalog';

  @override
  String get removeFromSyllabus => 'Remove from Syllabus';

  @override
  String get disciplineAddedToSyllabus => 'Subject added to the Syllabus.';

  @override
  String get topicAddedToSyllabus => 'Topic added to the Syllabus.';

  @override
  String get topicRemovedFromSyllabus => 'Topic removed from the Syllabus.';

  @override
  String get syllabusRuleViolation => 'The Syllabus could not be updated with this change.';

  @override
  String get syllabusUpdateFailed => 'Unable to update the Syllabus. Try again.';

  @override
  String get advance => 'Progress';

  @override
  String get performance => 'Performance';

  @override
  String get averagePerformance => 'Average performance';

  @override
  String get upTo25Percent => 'Up to 25%';

  @override
  String get from26To60Percent => '26% to 60%';

  @override
  String get above60Percent => 'Above 60%';

  @override
  String get below60Percent => 'Below 60%';

  @override
  String get from60To79Percent => '60% to 79%';

  @override
  String get from80Percent => '80% and above';

  @override
  String get nextExamDateUndefined => 'The next exam date has not been set';

  @override
  String get syllabusContentEyebrow => 'Syllabus content';

  @override
  String get viewRoleDuties => 'View position duties';

  @override
  String get advanceUnavailable => 'Progress has not been calculated yet';

  @override
  String get performanceUnavailable => 'Performance has not been calculated yet';

  @override
  String get metricStructureReady => 'The structure is ready to receive this metric';

  @override
  String advanceInDiscipline(String name) {
    return 'Progress in $name';
  }

  @override
  String performanceInDiscipline(String name) {
    return 'Performance in $name';
  }

  @override
  String get comboboxEmpty => 'No results found.';

  @override
  String get clearSelection => 'Clear selection';

  @override
  String get closeOptions => 'Close options';

  @override
  String get openOptions => 'Open options';

  @override
  String get progress => 'Progress';

  @override
  String get concursoSaveFailed => 'Unable to save the Exam. Try again.';

  @override
  String get institutionRequired => 'Enter the Exam institution.';

  @override
  String get institutionTooLong => 'The institution must have no more than 160 characters.';

  @override
  String get roleRequired => 'Enter the Exam position or specialty.';

  @override
  String get roleTooLong => 'The position or specialty must have no more than 160 characters.';

  @override
  String get boardTooLong => 'The exam board must have no more than 120 characters.';

  @override
  String get acronymTooLong => 'The institution acronym must have no more than 24 characters.';

  @override
  String get examLocationTooLong => 'The exam location must have no more than 240 characters.';

  @override
  String get requirementsTooLong => 'Requirements must have no more than 10,000 characters.';

  @override
  String get scoringCriteriaTooLong => 'Scoring information must have no more than 10,000 characters.';

  @override
  String get disciplineSaveFailed => 'Unable to save the Subject. Try again.';

  @override
  String get topicSaveFailed => 'Unable to save the Topic. Try again.';

  @override
  String get disciplineNameTooLong => 'The Subject name must have no more than 120 characters.';

  @override
  String get topicNameTooLong => 'The Topic name must have no more than 120 characters.';

  @override
  String get disciplineColorInvalid => 'The Subject color must use the #RRGGBB hexadecimal format.';
}
