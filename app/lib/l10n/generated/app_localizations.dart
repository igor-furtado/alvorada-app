// ignore_for_file: deprecated_member_use

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_pt.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[Locale('en'), Locale('pt')];

  /// No description provided for @navigationConcursos.
  ///
  /// In pt, this message translates to:
  /// **'Concursos'**
  String get navigationConcursos;

  /// No description provided for @navigationDisciplines.
  ///
  /// In pt, this message translates to:
  /// **'Disciplinas'**
  String get navigationDisciplines;

  /// No description provided for @navigationSection.
  ///
  /// In pt, this message translates to:
  /// **'Navegação'**
  String get navigationSection;

  /// No description provided for @navigationPath.
  ///
  /// In pt, this message translates to:
  /// **'Rota de navegação'**
  String get navigationPath;

  /// No description provided for @navigationSearch.
  ///
  /// In pt, this message translates to:
  /// **'Ir para uma área…'**
  String get navigationSearch;

  /// No description provided for @useLightTheme.
  ///
  /// In pt, this message translates to:
  /// **'Usar tema claro'**
  String get useLightTheme;

  /// No description provided for @useDarkTheme.
  ///
  /// In pt, this message translates to:
  /// **'Usar tema escuro'**
  String get useDarkTheme;

  /// No description provided for @appearance.
  ///
  /// In pt, this message translates to:
  /// **'Aparência'**
  String get appearance;

  /// No description provided for @followSystemTheme.
  ///
  /// In pt, this message translates to:
  /// **'Seguir o sistema'**
  String get followSystemTheme;

  /// No description provided for @lightTheme.
  ///
  /// In pt, this message translates to:
  /// **'Tema claro'**
  String get lightTheme;

  /// No description provided for @darkTheme.
  ///
  /// In pt, this message translates to:
  /// **'Tema escuro'**
  String get darkTheme;

  /// No description provided for @loading.
  ///
  /// In pt, this message translates to:
  /// **'Carregando'**
  String get loading;

  /// No description provided for @search.
  ///
  /// In pt, this message translates to:
  /// **'Buscar'**
  String get search;

  /// No description provided for @loadingMore.
  ///
  /// In pt, this message translates to:
  /// **'Carregando mais resultados'**
  String get loadingMore;

  /// No description provided for @tryAgain.
  ///
  /// In pt, this message translates to:
  /// **'Tentar novamente'**
  String get tryAgain;

  /// No description provided for @update.
  ///
  /// In pt, this message translates to:
  /// **'Atualizar'**
  String get update;

  /// No description provided for @clearSearch.
  ///
  /// In pt, this message translates to:
  /// **'Limpar busca'**
  String get clearSearch;

  /// No description provided for @noMoreResults.
  ///
  /// In pt, this message translates to:
  /// **'Todos os resultados foram carregados.'**
  String get noMoreResults;

  /// No description provided for @genericErrorTitle.
  ///
  /// In pt, this message translates to:
  /// **'Não foi possível carregar'**
  String get genericErrorTitle;

  /// No description provided for @genericErrorMessage.
  ///
  /// In pt, this message translates to:
  /// **'Tente novamente. Seus dados foram preservados.'**
  String get genericErrorMessage;

  /// No description provided for @offlineTitle.
  ///
  /// In pt, this message translates to:
  /// **'Você está sem conexão'**
  String get offlineTitle;

  /// No description provided for @offlineMessage.
  ///
  /// In pt, this message translates to:
  /// **'Confira sua conexão e tente novamente.'**
  String get offlineMessage;

  /// No description provided for @permissionDeniedTitle.
  ///
  /// In pt, this message translates to:
  /// **'Acesso não permitido'**
  String get permissionDeniedTitle;

  /// No description provided for @permissionDeniedMessage.
  ///
  /// In pt, this message translates to:
  /// **'Revise a permissão para continuar.'**
  String get permissionDeniedMessage;

  /// No description provided for @successTitle.
  ///
  /// In pt, this message translates to:
  /// **'Tudo certo'**
  String get successTitle;

  /// No description provided for @emptyTitle.
  ///
  /// In pt, this message translates to:
  /// **'Nada por aqui ainda'**
  String get emptyTitle;

  /// No description provided for @requiredField.
  ///
  /// In pt, this message translates to:
  /// **'Campo obrigatório'**
  String get requiredField;

  /// No description provided for @formHasErrors.
  ///
  /// In pt, this message translates to:
  /// **'Revise o primeiro campo indicado.'**
  String get formHasErrors;

  /// No description provided for @requiredSuffix.
  ///
  /// In pt, this message translates to:
  /// **'obrigatório'**
  String get requiredSuffix;

  /// No description provided for @cancel.
  ///
  /// In pt, this message translates to:
  /// **'Cancelar'**
  String get cancel;

  /// No description provided for @close.
  ///
  /// In pt, this message translates to:
  /// **'Fechar'**
  String get close;

  /// No description provided for @understand.
  ///
  /// In pt, this message translates to:
  /// **'Entendi'**
  String get understand;

  /// No description provided for @add.
  ///
  /// In pt, this message translates to:
  /// **'Adicionar'**
  String get add;

  /// No description provided for @name.
  ///
  /// In pt, this message translates to:
  /// **'Nome'**
  String get name;

  /// No description provided for @notNow.
  ///
  /// In pt, this message translates to:
  /// **'Agora não'**
  String get notNow;

  /// No description provided for @start.
  ///
  /// In pt, this message translates to:
  /// **'Começar'**
  String get start;

  /// No description provided for @undo.
  ///
  /// In pt, this message translates to:
  /// **'Desfazer'**
  String get undo;

  /// No description provided for @novoConcurso.
  ///
  /// In pt, this message translates to:
  /// **'Novo Concurso'**
  String get novoConcurso;

  /// No description provided for @novoConcursoDescription.
  ///
  /// In pt, this message translates to:
  /// **'Cadastre os dados principais e as informações da prova.'**
  String get novoConcursoDescription;

  /// No description provided for @concurso.
  ///
  /// In pt, this message translates to:
  /// **'Concurso'**
  String get concurso;

  /// No description provided for @concursoPrioritario.
  ///
  /// In pt, this message translates to:
  /// **'Concurso prioritário'**
  String get concursoPrioritario;

  /// No description provided for @concursosSubtitle.
  ///
  /// In pt, this message translates to:
  /// **'Seus concursos-alvo em ordem de prova.'**
  String get concursosSubtitle;

  /// No description provided for @noticeProgress.
  ///
  /// In pt, this message translates to:
  /// **'Avanço no Edital'**
  String get noticeProgress;

  /// No description provided for @exam.
  ///
  /// In pt, this message translates to:
  /// **'Prova'**
  String get exam;

  /// No description provided for @nenhumConcursoAtivo.
  ///
  /// In pt, this message translates to:
  /// **'Nenhum Concurso ativo'**
  String get nenhumConcursoAtivo;

  /// No description provided for @institution.
  ///
  /// In pt, this message translates to:
  /// **'Órgão ou instituição'**
  String get institution;

  /// No description provided for @role.
  ///
  /// In pt, this message translates to:
  /// **'Cargo / Especialidade'**
  String get role;

  /// No description provided for @board.
  ///
  /// In pt, this message translates to:
  /// **'Banca'**
  String get board;

  /// No description provided for @organizationAcronym.
  ///
  /// In pt, this message translates to:
  /// **'Sigla do órgão'**
  String get organizationAcronym;

  /// No description provided for @vacancies.
  ///
  /// In pt, this message translates to:
  /// **'Quantidade de vagas'**
  String get vacancies;

  /// No description provided for @hiringRegime.
  ///
  /// In pt, this message translates to:
  /// **'Regime de contratação'**
  String get hiringRegime;

  /// No description provided for @hiringRegimePlaceholder.
  ///
  /// In pt, this message translates to:
  /// **'Selecione o regime'**
  String get hiringRegimePlaceholder;

  /// No description provided for @statutoryHiringRegime.
  ///
  /// In pt, this message translates to:
  /// **'Estatutário'**
  String get statutoryHiringRegime;

  /// No description provided for @cltHiringRegime.
  ///
  /// In pt, this message translates to:
  /// **'Celetista'**
  String get cltHiringRegime;

  /// No description provided for @remuneration.
  ///
  /// In pt, this message translates to:
  /// **'Vencimento (remuneração)'**
  String get remuneration;

  /// No description provided for @remunerationPlaceholder.
  ///
  /// In pt, this message translates to:
  /// **'Ex.: 12.345,67'**
  String get remunerationPlaceholder;

  /// No description provided for @weeklyWorkload.
  ///
  /// In pt, this message translates to:
  /// **'Carga horária semanal'**
  String get weeklyWorkload;

  /// No description provided for @weeklyWorkloadHelp.
  ///
  /// In pt, this message translates to:
  /// **'Informe a quantidade de horas por semana.'**
  String get weeklyWorkloadHelp;

  /// No description provided for @examLocation.
  ///
  /// In pt, this message translates to:
  /// **'Local das provas'**
  String get examLocation;

  /// No description provided for @examStartTime.
  ///
  /// In pt, this message translates to:
  /// **'Horário de início'**
  String get examStartTime;

  /// No description provided for @examEndTime.
  ///
  /// In pt, this message translates to:
  /// **'Horário de término'**
  String get examEndTime;

  /// No description provided for @timePlaceholder.
  ///
  /// In pt, this message translates to:
  /// **'HH:MM'**
  String get timePlaceholder;

  /// No description provided for @requirements.
  ///
  /// In pt, this message translates to:
  /// **'Requisitos'**
  String get requirements;

  /// No description provided for @requirementsHelp.
  ///
  /// In pt, this message translates to:
  /// **'Diplomas, escolaridade, registros e comprovações exigidos.'**
  String get requirementsHelp;

  /// No description provided for @scoringCriteria.
  ///
  /// In pt, this message translates to:
  /// **'Cálculo da pontuação'**
  String get scoringCriteria;

  /// No description provided for @scoringCriteriaHelp.
  ///
  /// In pt, this message translates to:
  /// **'Pesos, critérios de desempate e demais regras de pontuação.'**
  String get scoringCriteriaHelp;

  /// No description provided for @concursoInformation.
  ///
  /// In pt, this message translates to:
  /// **'Informações do Concurso'**
  String get concursoInformation;

  /// No description provided for @invalidNonNegativeInteger.
  ///
  /// In pt, this message translates to:
  /// **'Informe um número inteiro igual ou maior que zero.'**
  String get invalidNonNegativeInteger;

  /// No description provided for @invalidWeeklyWorkload.
  ///
  /// In pt, this message translates to:
  /// **'Informe de 1 a 168 horas por semana.'**
  String get invalidWeeklyWorkload;

  /// No description provided for @invalidRemuneration.
  ///
  /// In pt, this message translates to:
  /// **'Informe um valor válido, como 12.345,67.'**
  String get invalidRemuneration;

  /// No description provided for @invalidExamTime.
  ///
  /// In pt, this message translates to:
  /// **'Informe um horário válido no formato HH:MM.'**
  String get invalidExamTime;

  /// No description provided for @invalidExamTimeRange.
  ///
  /// In pt, this message translates to:
  /// **'Informe início e término, com o término posterior ao início.'**
  String get invalidExamTimeRange;

  /// No description provided for @examDate.
  ///
  /// In pt, this message translates to:
  /// **'Data da prova'**
  String get examDate;

  /// No description provided for @examDatePlaceholder.
  ///
  /// In pt, this message translates to:
  /// **'DD/MM/AAAA'**
  String get examDatePlaceholder;

  /// No description provided for @invalidExamDate.
  ///
  /// In pt, this message translates to:
  /// **'Informe uma data válida no formato DD/MM/AAAA.'**
  String get invalidExamDate;

  /// No description provided for @definirConcursoPrioritario.
  ///
  /// In pt, this message translates to:
  /// **'Definir como prioritário'**
  String get definirConcursoPrioritario;

  /// No description provided for @concursoPrioritarioField.
  ///
  /// In pt, this message translates to:
  /// **'Usar como Concurso prioritário'**
  String get concursoPrioritarioField;

  /// No description provided for @concursoPrioritarioHelp.
  ///
  /// In pt, this message translates to:
  /// **'Ele receberá prioridade quando as horas não comportarem todo o escopo.'**
  String get concursoPrioritarioHelp;

  /// No description provided for @criarConcurso.
  ///
  /// In pt, this message translates to:
  /// **'Criar Concurso'**
  String get criarConcurso;

  /// No description provided for @editarConcurso.
  ///
  /// In pt, this message translates to:
  /// **'Editar Concurso'**
  String get editarConcurso;

  /// No description provided for @editarConcursoDescription.
  ///
  /// In pt, this message translates to:
  /// **'Atualize os dados e as informações deste Concurso.'**
  String get editarConcursoDescription;

  /// No description provided for @toBeDefined.
  ///
  /// In pt, this message translates to:
  /// **'A definir'**
  String get toBeDefined;

  /// No description provided for @excluirConcurso.
  ///
  /// In pt, this message translates to:
  /// **'Excluir Concurso'**
  String get excluirConcurso;

  /// No description provided for @excluirConcursoQuestion.
  ///
  /// In pt, this message translates to:
  /// **'Excluir Concurso?'**
  String get excluirConcursoQuestion;

  /// No description provided for @days.
  ///
  /// In pt, this message translates to:
  /// **'dias'**
  String get days;

  /// No description provided for @openNotice.
  ///
  /// In pt, this message translates to:
  /// **'Abrir Edital'**
  String get openNotice;

  /// No description provided for @moreActions.
  ///
  /// In pt, this message translates to:
  /// **'Mais ações'**
  String get moreActions;

  /// No description provided for @seeDetails.
  ///
  /// In pt, this message translates to:
  /// **'Ver detalhes'**
  String get seeDetails;

  /// No description provided for @archive.
  ///
  /// In pt, this message translates to:
  /// **'Arquivar'**
  String get archive;

  /// No description provided for @delete.
  ///
  /// In pt, this message translates to:
  /// **'Excluir'**
  String get delete;

  /// No description provided for @concursosEmpty.
  ///
  /// In pt, this message translates to:
  /// **'Adicione um Concurso para começar.'**
  String get concursosEmpty;

  /// No description provided for @notice.
  ///
  /// In pt, this message translates to:
  /// **'Edital'**
  String get notice;

  /// No description provided for @carregandoConcursos.
  ///
  /// In pt, this message translates to:
  /// **'Carregando Concursos'**
  String get carregandoConcursos;

  /// No description provided for @concursoCriado.
  ///
  /// In pt, this message translates to:
  /// **'Concurso criado.'**
  String get concursoCriado;

  /// No description provided for @concursoAtualizado.
  ///
  /// In pt, this message translates to:
  /// **'Concurso atualizado.'**
  String get concursoAtualizado;

  /// No description provided for @concursoPriorizado.
  ///
  /// In pt, this message translates to:
  /// **'Concurso prioritário atualizado.'**
  String get concursoPriorizado;

  /// No description provided for @concursoRestaurado.
  ///
  /// In pt, this message translates to:
  /// **'Concurso restaurado.'**
  String get concursoRestaurado;

  /// No description provided for @concursoExcluido.
  ///
  /// In pt, this message translates to:
  /// **'Concurso excluído.'**
  String get concursoExcluido;

  /// No description provided for @concursosAtualizados.
  ///
  /// In pt, this message translates to:
  /// **'Concursos atualizados.'**
  String get concursosAtualizados;

  /// No description provided for @concursoOperacaoFalhou.
  ///
  /// In pt, this message translates to:
  /// **'Não foi possível concluir a alteração. Tente novamente.'**
  String get concursoOperacaoFalhou;

  /// No description provided for @concursosSincronizacaoPendente.
  ///
  /// In pt, this message translates to:
  /// **'Alteração salva. Atualize para ver os Concursos mais recentes.'**
  String get concursosSincronizacaoPendente;

  /// No description provided for @newDiscipline.
  ///
  /// In pt, this message translates to:
  /// **'Nova Disciplina'**
  String get newDiscipline;

  /// No description provided for @newDisciplineDescription.
  ///
  /// In pt, this message translates to:
  /// **'Adicione uma Disciplina para organizar seus Tópicos.'**
  String get newDisciplineDescription;

  /// No description provided for @editDisciplineDescription.
  ///
  /// In pt, this message translates to:
  /// **'Atualize o nome da Disciplina no catálogo compartilhado.'**
  String get editDisciplineDescription;

  /// No description provided for @disciplineNameExample.
  ///
  /// In pt, this message translates to:
  /// **'Ex.: Língua Portuguesa'**
  String get disciplineNameExample;

  /// No description provided for @main.
  ///
  /// In pt, this message translates to:
  /// **'Principal'**
  String get main;

  /// No description provided for @disciplineName.
  ///
  /// In pt, this message translates to:
  /// **'Nome'**
  String get disciplineName;

  /// No description provided for @disciplineWeight.
  ///
  /// In pt, this message translates to:
  /// **'Peso no Edital'**
  String get disciplineWeight;

  /// No description provided for @syllabusContentButton.
  ///
  /// In pt, this message translates to:
  /// **'Conteúdo do Edital'**
  String get syllabusContentButton;

  /// No description provided for @editExamData.
  ///
  /// In pt, this message translates to:
  /// **'Editar dados da prova'**
  String get editExamData;

  /// No description provided for @sortAscending.
  ///
  /// In pt, this message translates to:
  /// **'Ordenar do menor para o maior'**
  String get sortAscending;

  /// No description provided for @sortDescending.
  ///
  /// In pt, this message translates to:
  /// **'Ordenar do maior para o menor'**
  String get sortDescending;

  /// No description provided for @syllabusCoverage.
  ///
  /// In pt, this message translates to:
  /// **'Cobertura do Edital'**
  String get syllabusCoverage;

  /// No description provided for @completed.
  ///
  /// In pt, this message translates to:
  /// **'Concluídos'**
  String get completed;

  /// No description provided for @remaining.
  ///
  /// In pt, this message translates to:
  /// **'Faltam'**
  String get remaining;

  /// No description provided for @correctAnswers.
  ///
  /// In pt, this message translates to:
  /// **'Acertos'**
  String get correctAnswers;

  /// No description provided for @wrongAnswers.
  ///
  /// In pt, this message translates to:
  /// **'Erros'**
  String get wrongAnswers;

  /// No description provided for @daysRemaining.
  ///
  /// In pt, this message translates to:
  /// **'{count, plural, =1{1 dia restante} other{{count} dias restantes}}'**
  String daysRemaining(int count);

  /// No description provided for @topicsInSyllabusCount.
  ///
  /// In pt, this message translates to:
  /// **'{count, plural, =1{1 Tópico no Edital} other{{count} Tópicos no Edital}}'**
  String topicsInSyllabusCount(int count);

  /// No description provided for @weightUpdated.
  ///
  /// In pt, this message translates to:
  /// **'Peso da Disciplina atualizado.'**
  String get weightUpdated;

  /// No description provided for @weightUpdateFailed.
  ///
  /// In pt, this message translates to:
  /// **'Não foi possível atualizar o peso da Disciplina.'**
  String get weightUpdateFailed;

  /// No description provided for @noDiscipline.
  ///
  /// In pt, this message translates to:
  /// **'Nenhuma Disciplina vinculada a este Edital.'**
  String get noDiscipline;

  /// No description provided for @concursoNaoEncontrado.
  ///
  /// In pt, this message translates to:
  /// **'Concurso não encontrado'**
  String get concursoNaoEncontrado;

  /// No description provided for @contentCatalog.
  ///
  /// In pt, this message translates to:
  /// **'Catálogo de Disciplinas'**
  String get contentCatalog;

  /// No description provided for @contentCatalogSubtitle.
  ///
  /// In pt, this message translates to:
  /// **'Organize a base de conteúdo usada nos seus editais e planos de estudo.'**
  String get contentCatalogSubtitle;

  /// No description provided for @searchContent.
  ///
  /// In pt, this message translates to:
  /// **'Buscar disciplina ou tópico'**
  String get searchContent;

  /// No description provided for @newTopic.
  ///
  /// In pt, this message translates to:
  /// **'Novo Tópico'**
  String get newTopic;

  /// No description provided for @difficultyVeryEasy.
  ///
  /// In pt, this message translates to:
  /// **'muito fácil'**
  String get difficultyVeryEasy;

  /// No description provided for @difficultyEasy.
  ///
  /// In pt, this message translates to:
  /// **'fácil'**
  String get difficultyEasy;

  /// No description provided for @difficultyMedium.
  ///
  /// In pt, this message translates to:
  /// **'média'**
  String get difficultyMedium;

  /// No description provided for @difficultyHard.
  ///
  /// In pt, this message translates to:
  /// **'difícil'**
  String get difficultyHard;

  /// No description provided for @difficultyVeryHard.
  ///
  /// In pt, this message translates to:
  /// **'muito difícil'**
  String get difficultyVeryHard;

  /// Resumo de uma Disciplina no catálogo.
  ///
  /// In pt, this message translates to:
  /// **'{count, plural, =1{1 Tópico} other{{count} Tópicos}} · Dificuldade {difficulty}'**
  String catalogDisciplineSummary(int count, String difficulty);

  /// Quantidade curta de Tópicos.
  ///
  /// In pt, this message translates to:
  /// **'{count, plural, =1{1 Tópico} other{{count} Tópicos}}'**
  String topicCountShort(int count);

  /// No description provided for @addDiscipline.
  ///
  /// In pt, this message translates to:
  /// **'Adicionar Disciplina'**
  String get addDiscipline;

  /// No description provided for @addTopics.
  ///
  /// In pt, this message translates to:
  /// **'Adicionar Tópicos'**
  String get addTopics;

  /// No description provided for @addTopicsDescription.
  ///
  /// In pt, this message translates to:
  /// **'Adicione um ou vários Tópicos à Disciplina selecionada.'**
  String get addTopicsDescription;

  /// No description provided for @addTopicsQuickDescription.
  ///
  /// In pt, this message translates to:
  /// **'Digite ou cole um Tópico por linha. A lista será criada na ordem informada.'**
  String get addTopicsQuickDescription;

  /// No description provided for @topicsPerLineExample.
  ///
  /// In pt, this message translates to:
  /// **'Ex.:\nInterpretação de textos\nPontuação\nConcordância verbal'**
  String get topicsPerLineExample;

  /// No description provided for @rename.
  ///
  /// In pt, this message translates to:
  /// **'Renomear'**
  String get rename;

  /// No description provided for @editDiscipline.
  ///
  /// In pt, this message translates to:
  /// **'Editar Disciplina'**
  String get editDiscipline;

  /// No description provided for @editTopic.
  ///
  /// In pt, this message translates to:
  /// **'Editar Tópico'**
  String get editTopic;

  /// No description provided for @editTopicDescription.
  ///
  /// In pt, this message translates to:
  /// **'Atualize o nome do Tópico no catálogo compartilhado.'**
  String get editTopicDescription;

  /// No description provided for @saveChanges.
  ///
  /// In pt, this message translates to:
  /// **'Salvar alterações'**
  String get saveChanges;

  /// No description provided for @unsavedChangesTitle.
  ///
  /// In pt, this message translates to:
  /// **'Descartar alterações?'**
  String get unsavedChangesTitle;

  /// No description provided for @unsavedChangesDescription.
  ///
  /// In pt, this message translates to:
  /// **'As alterações feitas neste formulário ainda não foram salvas.'**
  String get unsavedChangesDescription;

  /// No description provided for @keepEditing.
  ///
  /// In pt, this message translates to:
  /// **'Continuar editando'**
  String get keepEditing;

  /// No description provided for @discardChanges.
  ///
  /// In pt, this message translates to:
  /// **'Descartar alterações'**
  String get discardChanges;

  /// No description provided for @concursoIdentificationSection.
  ///
  /// In pt, this message translates to:
  /// **'Identificação'**
  String get concursoIdentificationSection;

  /// No description provided for @concursoIdentificationSectionDescription.
  ///
  /// In pt, this message translates to:
  /// **'Órgão, cargo e banca responsáveis pelo Concurso.'**
  String get concursoIdentificationSectionDescription;

  /// No description provided for @concursoConditionsSection.
  ///
  /// In pt, this message translates to:
  /// **'Condições do cargo'**
  String get concursoConditionsSection;

  /// No description provided for @concursoConditionsSectionDescription.
  ///
  /// In pt, this message translates to:
  /// **'Regime, vagas, remuneração e jornada de trabalho.'**
  String get concursoConditionsSectionDescription;

  /// No description provided for @concursoExamSection.
  ///
  /// In pt, this message translates to:
  /// **'Prova'**
  String get concursoExamSection;

  /// No description provided for @concursoExamSectionDescription.
  ///
  /// In pt, this message translates to:
  /// **'Data, horários e local previstos para a prova.'**
  String get concursoExamSectionDescription;

  /// No description provided for @concursoAdditionalSection.
  ///
  /// In pt, this message translates to:
  /// **'Informações complementares'**
  String get concursoAdditionalSection;

  /// No description provided for @concursoAdditionalSectionDescription.
  ///
  /// In pt, this message translates to:
  /// **'Requisitos, pontuação e prioridade do Concurso.'**
  String get concursoAdditionalSectionDescription;

  /// No description provided for @deleteDiscipline.
  ///
  /// In pt, this message translates to:
  /// **'Excluir Disciplina'**
  String get deleteDiscipline;

  /// No description provided for @deleteDisciplineQuestion.
  ///
  /// In pt, this message translates to:
  /// **'Excluir Disciplina?'**
  String get deleteDisciplineQuestion;

  /// No description provided for @deleteTopicQuestion.
  ///
  /// In pt, this message translates to:
  /// **'Excluir Tópico?'**
  String get deleteTopicQuestion;

  /// No description provided for @noContentFound.
  ///
  /// In pt, this message translates to:
  /// **'Nenhuma Disciplina'**
  String get noContentFound;

  /// No description provided for @noContentFoundMessage.
  ///
  /// In pt, this message translates to:
  /// **'Adicione uma Disciplina para começar.'**
  String get noContentFoundMessage;

  /// No description provided for @mandatoryTopic.
  ///
  /// In pt, this message translates to:
  /// **'Tópico obrigatório'**
  String get mandatoryTopic;

  /// No description provided for @mandatory.
  ///
  /// In pt, this message translates to:
  /// **'Obrigatório'**
  String get mandatory;

  /// No description provided for @protected.
  ///
  /// In pt, this message translates to:
  /// **'Protegido'**
  String get protected;

  /// No description provided for @topics.
  ///
  /// In pt, this message translates to:
  /// **'Tópicos'**
  String get topics;

  /// No description provided for @loadingDisciplines.
  ///
  /// In pt, this message translates to:
  /// **'Carregando Disciplinas'**
  String get loadingDisciplines;

  /// No description provided for @disciplinesUpdated.
  ///
  /// In pt, this message translates to:
  /// **'Disciplinas atualizadas.'**
  String get disciplinesUpdated;

  /// No description provided for @disciplineCreated.
  ///
  /// In pt, this message translates to:
  /// **'Disciplina adicionada.'**
  String get disciplineCreated;

  /// No description provided for @disciplineUpdated.
  ///
  /// In pt, this message translates to:
  /// **'Disciplina atualizada.'**
  String get disciplineUpdated;

  /// No description provided for @disciplineDeleted.
  ///
  /// In pt, this message translates to:
  /// **'Disciplina excluída.'**
  String get disciplineDeleted;

  /// No description provided for @topicCreated.
  ///
  /// In pt, this message translates to:
  /// **'Tópicos adicionados.'**
  String get topicCreated;

  /// No description provided for @topicUpdated.
  ///
  /// In pt, this message translates to:
  /// **'Tópico atualizado.'**
  String get topicUpdated;

  /// No description provided for @topicDeleted.
  ///
  /// In pt, this message translates to:
  /// **'Tópico excluído.'**
  String get topicDeleted;

  /// No description provided for @topicsReordered.
  ///
  /// In pt, this message translates to:
  /// **'Ordem dos Tópicos atualizada.'**
  String get topicsReordered;

  /// No description provided for @reorderTopic.
  ///
  /// In pt, this message translates to:
  /// **'Arraste para reordenar'**
  String get reorderTopic;

  /// No description provided for @contentUpdateFailed.
  ///
  /// In pt, this message translates to:
  /// **'Não foi possível atualizar. Os dados exibidos foram preservados.'**
  String get contentUpdateFailed;

  /// No description provided for @contentSavedSyncPending.
  ///
  /// In pt, this message translates to:
  /// **'Alteração salva. Atualize para ver os dados mais recentes.'**
  String get contentSavedSyncPending;

  /// No description provided for @contentOperationFailed.
  ///
  /// In pt, this message translates to:
  /// **'Não foi possível salvar a alteração. Tente novamente.'**
  String get contentOperationFailed;

  /// No description provided for @today.
  ///
  /// In pt, this message translates to:
  /// **'hoje'**
  String get today;

  /// Quantidade de resultados carregados.
  ///
  /// In pt, this message translates to:
  /// **'{count, plural, =1{1 resultado carregado.} other{{count} resultados carregados.}}'**
  String loadedItems(int count);

  /// Resumo das quantidades do catálogo.
  ///
  /// In pt, this message translates to:
  /// **'{disciplineCount, plural, =1{1 Disciplina} other{{disciplineCount} Disciplinas}}  ·  {topicCount, plural, =1{1 Tópico} other{{topicCount} Tópicos}}'**
  String catalogSummary(int disciplineCount, int topicCount);

  /// Quantidade de Disciplinas.
  ///
  /// In pt, this message translates to:
  /// **'{count, plural, =1{1 Disciplina} other{{count} Disciplinas}}'**
  String disciplineResults(int count);

  /// Quantidade de Tópicos.
  ///
  /// In pt, this message translates to:
  /// **'{count, plural, =1{1 Tópico} other{{count} Tópicos}}'**
  String topicCount(int count);

  /// Quantidade de Tópicos no catálogo.
  ///
  /// In pt, this message translates to:
  /// **'{count, plural, =1{1 Tópico no catálogo.} other{{count} Tópicos no catálogo.}}'**
  String topicCountInCatalog(int count);

  /// Ajuda e contagem do formulário de Tópicos.
  ///
  /// In pt, this message translates to:
  /// **'Digite um Tópico por linha. Linhas vazias serão ignoradas. {count, plural, =0{Nenhum Tópico pronto para adicionar.} =1{1 Tópico pronto para adicionar.} other{{count} Tópicos prontos para adicionar.}}'**
  String topicsPerLineDescription(int count);

  /// No description provided for @preview.
  ///
  /// In pt, this message translates to:
  /// **'Prévia'**
  String get preview;

  /// Quantidade genérica de itens.
  ///
  /// In pt, this message translates to:
  /// **'{count, plural, =0{0 itens} =1{1 item} other{{count} itens}}'**
  String itemsCount(int count);

  /// No description provided for @topicsPreviewEmpty.
  ///
  /// In pt, this message translates to:
  /// **'Os Tópicos aparecerão aqui conforme você digitar.'**
  String get topicsPreviewEmpty;

  /// Rótulo da ação de adicionar Tópicos.
  ///
  /// In pt, this message translates to:
  /// **'{count, plural, =0{Adicionar Tópicos} =1{Adicionar 1 Tópico} other{Adicionar {count} Tópicos}}'**
  String addTopicsCount(int count);

  /// Impacto da exclusão de uma Disciplina.
  ///
  /// In pt, this message translates to:
  /// **'{name} e seus Tópicos serão excluídos do catálogo compartilhado. Esta ação não pode ser desfeita.'**
  String disciplineDeletedImpact(String name);

  /// Impacto da exclusão de um Tópico.
  ///
  /// In pt, this message translates to:
  /// **'{name} será excluído do catálogo compartilhado e removido de todos os Editais. Esta ação não pode ser desfeita.'**
  String topicDeletedImpact(String name);

  /// Confirmação de arquivamento de Concurso.
  ///
  /// In pt, this message translates to:
  /// **'{name} foi arquivado.'**
  String concursoArquivado(String name);

  /// Prazo para a próxima prova.
  ///
  /// In pt, this message translates to:
  /// **'{days, plural, =1{A próxima prova é em 1 dia} other{A próxima prova é em {days} dias}}'**
  String nextExamIn(int days);

  /// Quantidade de vagas.
  ///
  /// In pt, this message translates to:
  /// **'{count, plural, =1{1 vaga} other{{count} vagas}}'**
  String vacanciesCount(int count);

  /// Impacto da exclusão de um Concurso.
  ///
  /// In pt, this message translates to:
  /// **'{name} e seu Edital serão removidos. Esta ação não pode ser desfeita.'**
  String excluirConcursoImpacto(String name);

  /// Nome acessível para remover um item.
  ///
  /// In pt, this message translates to:
  /// **'Remover {label}'**
  String removeItem(String label);

  /// No description provided for @closeNotification.
  ///
  /// In pt, this message translates to:
  /// **'Fechar notificação'**
  String get closeNotification;

  /// No description provided for @resizePanels.
  ///
  /// In pt, this message translates to:
  /// **'Redimensionar painéis'**
  String get resizePanels;

  /// No description provided for @tryAgainLater.
  ///
  /// In pt, this message translates to:
  /// **'Tente novamente em instantes.'**
  String get tryAgainLater;

  /// No description provided for @topicsInSyllabusDescription.
  ///
  /// In pt, this message translates to:
  /// **'Tópicos desta Disciplina presentes no Edital.'**
  String get topicsInSyllabusDescription;

  /// No description provided for @information.
  ///
  /// In pt, this message translates to:
  /// **'Informações'**
  String get information;

  /// No description provided for @priority.
  ///
  /// In pt, this message translates to:
  /// **'Prioritário'**
  String get priority;

  /// No description provided for @location.
  ///
  /// In pt, this message translates to:
  /// **'Local'**
  String get location;

  /// No description provided for @searchDiscipline.
  ///
  /// In pt, this message translates to:
  /// **'Buscar Disciplina'**
  String get searchDiscipline;

  /// No description provided for @editSyllabus.
  ///
  /// In pt, this message translates to:
  /// **'Editar Edital'**
  String get editSyllabus;

  /// No description provided for @syllabusDisciplines.
  ///
  /// In pt, this message translates to:
  /// **'Disciplinas do Edital'**
  String get syllabusDisciplines;

  /// No description provided for @syllabusContentSubtitle.
  ///
  /// In pt, this message translates to:
  /// **'Conteúdo cobrado neste Concurso'**
  String get syllabusContentSubtitle;

  /// No description provided for @syllabusEmptyMessage.
  ///
  /// In pt, this message translates to:
  /// **'Adicione uma Disciplina ou um Tópico existente no catálogo.'**
  String get syllabusEmptyMessage;

  /// No description provided for @disciplineSearchEmptyTitle.
  ///
  /// In pt, this message translates to:
  /// **'Nenhuma Disciplina encontrada'**
  String get disciplineSearchEmptyTitle;

  /// No description provided for @disciplineSearchEmptyMessage.
  ///
  /// In pt, this message translates to:
  /// **'Tente buscar por outro nome.'**
  String get disciplineSearchEmptyMessage;

  /// No description provided for @advanceLowerTitle.
  ///
  /// In pt, this message translates to:
  /// **'Até 25% de avanço'**
  String get advanceLowerTitle;

  /// No description provided for @advanceLowerSubtitle.
  ///
  /// In pt, this message translates to:
  /// **'Disciplinas no início do Edital'**
  String get advanceLowerSubtitle;

  /// No description provided for @advanceMiddleTitle.
  ///
  /// In pt, this message translates to:
  /// **'De 26% a 60% de avanço'**
  String get advanceMiddleTitle;

  /// No description provided for @advanceMiddleSubtitle.
  ///
  /// In pt, this message translates to:
  /// **'Disciplinas em desenvolvimento'**
  String get advanceMiddleSubtitle;

  /// No description provided for @advanceUpperTitle.
  ///
  /// In pt, this message translates to:
  /// **'Acima de 60% de avanço'**
  String get advanceUpperTitle;

  /// No description provided for @advanceUpperSubtitle.
  ///
  /// In pt, this message translates to:
  /// **'Disciplinas mais avançadas'**
  String get advanceUpperSubtitle;

  /// No description provided for @performanceLowerTitle.
  ///
  /// In pt, this message translates to:
  /// **'Abaixo de 60% de desempenho'**
  String get performanceLowerTitle;

  /// No description provided for @performanceLowerSubtitle.
  ///
  /// In pt, this message translates to:
  /// **'Disciplinas com menor aproveitamento'**
  String get performanceLowerSubtitle;

  /// No description provided for @performanceMiddleTitle.
  ///
  /// In pt, this message translates to:
  /// **'De 60% a 79% de desempenho'**
  String get performanceMiddleTitle;

  /// No description provided for @performanceMiddleSubtitle.
  ///
  /// In pt, this message translates to:
  /// **'Disciplinas com aproveitamento intermediário'**
  String get performanceMiddleSubtitle;

  /// No description provided for @performanceUpperTitle.
  ///
  /// In pt, this message translates to:
  /// **'A partir de 80% de desempenho'**
  String get performanceUpperTitle;

  /// No description provided for @performanceUpperSubtitle.
  ///
  /// In pt, this message translates to:
  /// **'Disciplinas com maior aproveitamento'**
  String get performanceUpperSubtitle;

  /// Nome acessível para abrir uma Disciplina.
  ///
  /// In pt, this message translates to:
  /// **'Abrir {name}'**
  String openDiscipline(String name);

  /// No description provided for @examJourneyEyebrow.
  ///
  /// In pt, this message translates to:
  /// **'JORNADA DO CONCURSO'**
  String get examJourneyEyebrow;

  /// No description provided for @examJourneyTitle.
  ///
  /// In pt, this message translates to:
  /// **'Da habilitação à posse'**
  String get examJourneyTitle;

  /// No description provided for @examJourneyDescription.
  ///
  /// In pt, this message translates to:
  /// **'As condições do Concurso apresentadas na ordem em que influenciam sua decisão.'**
  String get examJourneyDescription;

  /// No description provided for @qualification.
  ///
  /// In pt, this message translates to:
  /// **'Habilitação'**
  String get qualification;

  /// No description provided for @entryRequirement.
  ///
  /// In pt, this message translates to:
  /// **'Requisito de ingresso'**
  String get entryRequirement;

  /// No description provided for @assessment.
  ///
  /// In pt, this message translates to:
  /// **'Avaliação'**
  String get assessment;

  /// No description provided for @examsAndScoring.
  ///
  /// In pt, this message translates to:
  /// **'Provas e pontuação'**
  String get examsAndScoring;

  /// No description provided for @time.
  ///
  /// In pt, this message translates to:
  /// **'Horário'**
  String get time;

  /// No description provided for @ranking.
  ///
  /// In pt, this message translates to:
  /// **'Classificação'**
  String get ranking;

  /// No description provided for @expectedOffer.
  ///
  /// In pt, this message translates to:
  /// **'Oferta prevista'**
  String get expectedOffer;

  /// No description provided for @total.
  ///
  /// In pt, this message translates to:
  /// **'Total'**
  String get total;

  /// No description provided for @appointment.
  ///
  /// In pt, this message translates to:
  /// **'Posse'**
  String get appointment;

  /// No description provided for @positionConditions.
  ///
  /// In pt, this message translates to:
  /// **'Condições do cargo'**
  String get positionConditions;

  /// No description provided for @employmentType.
  ///
  /// In pt, this message translates to:
  /// **'Regime'**
  String get employmentType;

  /// No description provided for @startingSalary.
  ///
  /// In pt, this message translates to:
  /// **'Vencimento inicial'**
  String get startingSalary;

  /// No description provided for @workload.
  ///
  /// In pt, this message translates to:
  /// **'Jornada'**
  String get workload;

  /// No description provided for @concursoNotFoundMessage.
  ///
  /// In pt, this message translates to:
  /// **'Volte para Concursos e escolha outro item.'**
  String get concursoNotFoundMessage;

  /// No description provided for @addToSyllabus.
  ///
  /// In pt, this message translates to:
  /// **'Adicionar ao Edital'**
  String get addToSyllabus;

  /// No description provided for @linkCatalogContent.
  ///
  /// In pt, this message translates to:
  /// **'Vincule conteúdo existente no catálogo.'**
  String get linkCatalogContent;

  /// No description provided for @loadingCatalog.
  ///
  /// In pt, this message translates to:
  /// **'Carregando catálogo'**
  String get loadingCatalog;

  /// No description provided for @discipline.
  ///
  /// In pt, this message translates to:
  /// **'Disciplina'**
  String get discipline;

  /// No description provided for @topic.
  ///
  /// In pt, this message translates to:
  /// **'Tópico'**
  String get topic;

  /// No description provided for @disciplineSearchExample.
  ///
  /// In pt, this message translates to:
  /// **'Ex.: Direito Penal'**
  String get disciplineSearchExample;

  /// No description provided for @linkDisciplineNote.
  ///
  /// In pt, this message translates to:
  /// **'Vincule ao Edital uma Disciplina já existente no catálogo compartilhado.'**
  String get linkDisciplineNote;

  /// Quantidade de Tópicos disponíveis no catálogo.
  ///
  /// In pt, this message translates to:
  /// **'{count, plural, =1{1 Tópico no catálogo} other{{count} Tópicos no catálogo}}'**
  String topicsInCatalog(int count);

  /// No description provided for @added.
  ///
  /// In pt, this message translates to:
  /// **'Adicionada'**
  String get added;

  /// No description provided for @chooseDisciplineNote.
  ///
  /// In pt, this message translates to:
  /// **'Escolha uma Disciplina do Edital e vincule ou remova um Tópico existente.'**
  String get chooseDisciplineNote;

  /// No description provided for @selectDiscipline.
  ///
  /// In pt, this message translates to:
  /// **'Selecione uma Disciplina'**
  String get selectDiscipline;

  /// No description provided for @searchTopic.
  ///
  /// In pt, this message translates to:
  /// **'Buscar Tópico'**
  String get searchTopic;

  /// No description provided for @topicSearchExample.
  ///
  /// In pt, this message translates to:
  /// **'Ex.: Obrigação tributária'**
  String get topicSearchExample;

  /// No description provided for @noSyllabusDiscipline.
  ///
  /// In pt, this message translates to:
  /// **'Nenhuma Disciplina no Edital'**
  String get noSyllabusDiscipline;

  /// No description provided for @noSyllabusDisciplineMessage.
  ///
  /// In pt, this message translates to:
  /// **'Adicione uma Disciplina para vincular Tópicos individualmente.'**
  String get noSyllabusDisciplineMessage;

  /// No description provided for @sharedCatalog.
  ///
  /// In pt, this message translates to:
  /// **'Catálogo compartilhado'**
  String get sharedCatalog;

  /// No description provided for @removeFromSyllabus.
  ///
  /// In pt, this message translates to:
  /// **'Remover do Edital'**
  String get removeFromSyllabus;

  /// No description provided for @disciplineAddedToSyllabus.
  ///
  /// In pt, this message translates to:
  /// **'Disciplina adicionada ao Edital.'**
  String get disciplineAddedToSyllabus;

  /// No description provided for @topicAddedToSyllabus.
  ///
  /// In pt, this message translates to:
  /// **'Tópico adicionado ao Edital.'**
  String get topicAddedToSyllabus;

  /// No description provided for @topicRemovedFromSyllabus.
  ///
  /// In pt, this message translates to:
  /// **'Tópico removido do Edital.'**
  String get topicRemovedFromSyllabus;

  /// No description provided for @syllabusRuleViolation.
  ///
  /// In pt, this message translates to:
  /// **'O Edital não pôde ser atualizado com essa alteração.'**
  String get syllabusRuleViolation;

  /// No description provided for @syllabusUpdateFailed.
  ///
  /// In pt, this message translates to:
  /// **'Não foi possível atualizar o Edital. Tente novamente.'**
  String get syllabusUpdateFailed;

  /// No description provided for @syllabusTriageTitle.
  ///
  /// In pt, this message translates to:
  /// **'Conteúdo Programático do Edital'**
  String get syllabusTriageTitle;

  /// Identificação do Concurso no editor do Edital.
  ///
  /// In pt, this message translates to:
  /// **'{institution} · {role}'**
  String syllabusTriageDescription(String institution, String role);

  /// Progresso de seleção de uma Disciplina no editor do Edital.
  ///
  /// In pt, this message translates to:
  /// **'{selected}/{total} Tópicos'**
  String syllabusTriageDisciplineProgress(int selected, int total);

  /// No description provided for @clear.
  ///
  /// In pt, this message translates to:
  /// **'Limpar'**
  String get clear;

  /// No description provided for @selectAll.
  ///
  /// In pt, this message translates to:
  /// **'Selecionar todos'**
  String get selectAll;

  /// No description provided for @filterDisciplineTopics.
  ///
  /// In pt, this message translates to:
  /// **'Filtrar Tópicos desta Disciplina'**
  String get filterDisciplineTopics;

  /// No description provided for @inSyllabus.
  ///
  /// In pt, this message translates to:
  /// **'No Edital'**
  String get inSyllabus;

  /// Ação de salvar a seleção de Tópicos no Edital.
  ///
  /// In pt, this message translates to:
  /// **'{count, plural, =0{Salvar} =1{Salvar 1 Tópico} other{Salvar {count} Tópicos}}'**
  String saveSelectedTopics(int count);

  /// No description provided for @syllabusSaved.
  ///
  /// In pt, this message translates to:
  /// **'Conteúdo do Edital atualizado.'**
  String get syllabusSaved;

  /// No description provided for @noTopics.
  ///
  /// In pt, this message translates to:
  /// **'Nenhum Tópico encontrado'**
  String get noTopics;

  /// No description provided for @noTopicsMessage.
  ///
  /// In pt, this message translates to:
  /// **'Tente buscar por outro nome.'**
  String get noTopicsMessage;

  /// No description provided for @noDisciplineMessage.
  ///
  /// In pt, this message translates to:
  /// **'Cadastre uma Disciplina no catálogo para começar.'**
  String get noDisciplineMessage;

  /// No description provided for @advance.
  ///
  /// In pt, this message translates to:
  /// **'Avanço'**
  String get advance;

  /// No description provided for @performance.
  ///
  /// In pt, this message translates to:
  /// **'Desempenho'**
  String get performance;

  /// No description provided for @averagePerformance.
  ///
  /// In pt, this message translates to:
  /// **'Desempenho médio'**
  String get averagePerformance;

  /// No description provided for @upTo25Percent.
  ///
  /// In pt, this message translates to:
  /// **'Até 25%'**
  String get upTo25Percent;

  /// No description provided for @from26To60Percent.
  ///
  /// In pt, this message translates to:
  /// **'26% a 60%'**
  String get from26To60Percent;

  /// No description provided for @above60Percent.
  ///
  /// In pt, this message translates to:
  /// **'Acima de 60%'**
  String get above60Percent;

  /// No description provided for @below60Percent.
  ///
  /// In pt, this message translates to:
  /// **'Abaixo de 60%'**
  String get below60Percent;

  /// No description provided for @from60To79Percent.
  ///
  /// In pt, this message translates to:
  /// **'60% a 79%'**
  String get from60To79Percent;

  /// No description provided for @from80Percent.
  ///
  /// In pt, this message translates to:
  /// **'A partir de 80%'**
  String get from80Percent;

  /// No description provided for @nextExamDateUndefined.
  ///
  /// In pt, this message translates to:
  /// **'A próxima prova ainda não tem data definida'**
  String get nextExamDateUndefined;

  /// No description provided for @syllabusContentEyebrow.
  ///
  /// In pt, this message translates to:
  /// **'Conteúdo do Edital'**
  String get syllabusContentEyebrow;

  /// No description provided for @viewRoleDuties.
  ///
  /// In pt, this message translates to:
  /// **'Ver atribuições do cargo'**
  String get viewRoleDuties;

  /// No description provided for @advanceUnavailable.
  ///
  /// In pt, this message translates to:
  /// **'Avanço ainda não calculado'**
  String get advanceUnavailable;

  /// No description provided for @performanceUnavailable.
  ///
  /// In pt, this message translates to:
  /// **'Desempenho ainda não calculado'**
  String get performanceUnavailable;

  /// No description provided for @metricStructureReady.
  ///
  /// In pt, this message translates to:
  /// **'A estrutura está pronta para receber esta métrica'**
  String get metricStructureReady;

  /// Progresso de uma Disciplina.
  ///
  /// In pt, this message translates to:
  /// **'Avanço em {name}'**
  String advanceInDiscipline(String name);

  /// Desempenho de uma Disciplina.
  ///
  /// In pt, this message translates to:
  /// **'Desempenho em {name}'**
  String performanceInDiscipline(String name);

  /// No description provided for @comboboxEmpty.
  ///
  /// In pt, this message translates to:
  /// **'Nenhum resultado encontrado.'**
  String get comboboxEmpty;

  /// No description provided for @clearSelection.
  ///
  /// In pt, this message translates to:
  /// **'Limpar seleção'**
  String get clearSelection;

  /// No description provided for @closeOptions.
  ///
  /// In pt, this message translates to:
  /// **'Fechar opções'**
  String get closeOptions;

  /// No description provided for @openOptions.
  ///
  /// In pt, this message translates to:
  /// **'Abrir opções'**
  String get openOptions;

  /// No description provided for @progress.
  ///
  /// In pt, this message translates to:
  /// **'Progresso'**
  String get progress;

  /// No description provided for @concursoSaveFailed.
  ///
  /// In pt, this message translates to:
  /// **'Não foi possível salvar o Concurso. Tente novamente.'**
  String get concursoSaveFailed;

  /// No description provided for @institutionRequired.
  ///
  /// In pt, this message translates to:
  /// **'Informe o órgão ou instituição do Concurso.'**
  String get institutionRequired;

  /// No description provided for @institutionTooLong.
  ///
  /// In pt, this message translates to:
  /// **'O órgão ou instituição deve ter no máximo 160 caracteres.'**
  String get institutionTooLong;

  /// No description provided for @roleRequired.
  ///
  /// In pt, this message translates to:
  /// **'Informe o cargo ou especialidade do Concurso.'**
  String get roleRequired;

  /// No description provided for @roleTooLong.
  ///
  /// In pt, this message translates to:
  /// **'O cargo ou especialidade deve ter no máximo 160 caracteres.'**
  String get roleTooLong;

  /// No description provided for @boardTooLong.
  ///
  /// In pt, this message translates to:
  /// **'A banca deve ter no máximo 120 caracteres.'**
  String get boardTooLong;

  /// No description provided for @acronymTooLong.
  ///
  /// In pt, this message translates to:
  /// **'A sigla do órgão deve ter no máximo 24 caracteres.'**
  String get acronymTooLong;

  /// No description provided for @examLocationTooLong.
  ///
  /// In pt, this message translates to:
  /// **'O local da prova deve ter no máximo 240 caracteres.'**
  String get examLocationTooLong;

  /// No description provided for @requirementsTooLong.
  ///
  /// In pt, this message translates to:
  /// **'Os requisitos devem ter no máximo 10.000 caracteres.'**
  String get requirementsTooLong;

  /// No description provided for @scoringCriteriaTooLong.
  ///
  /// In pt, this message translates to:
  /// **'As informações de pontuação devem ter no máximo 10.000 caracteres.'**
  String get scoringCriteriaTooLong;

  /// No description provided for @disciplineSaveFailed.
  ///
  /// In pt, this message translates to:
  /// **'Não foi possível salvar a Disciplina. Tente novamente.'**
  String get disciplineSaveFailed;

  /// No description provided for @topicSaveFailed.
  ///
  /// In pt, this message translates to:
  /// **'Não foi possível salvar o Tópico. Tente novamente.'**
  String get topicSaveFailed;

  /// No description provided for @disciplineNameTooLong.
  ///
  /// In pt, this message translates to:
  /// **'O nome da Disciplina deve ter no máximo 120 caracteres.'**
  String get disciplineNameTooLong;

  /// No description provided for @topicNameTooLong.
  ///
  /// In pt, this message translates to:
  /// **'O nome do Tópico deve ter no máximo 120 caracteres.'**
  String get topicNameTooLong;

  /// No description provided for @disciplineColorInvalid.
  ///
  /// In pt, this message translates to:
  /// **'A cor da Disciplina deve estar no formato hexadecimal #RRGGBB.'**
  String get disciplineColorInvalid;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['en', 'pt'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'pt':
      return AppLocalizationsPt();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
