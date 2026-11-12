import 'package:flutter/foundation.dart';

enum AppComponentCategory { atom, molecule, organism }

@immutable
class AppComponentDefinition {
  const AppComponentDefinition({required this.name, required this.interfaceName, required this.category});

  final String name;
  final String interfaceName;
  final AppComponentCategory category;
}

abstract final class AppComponentRegistry {
  static const components = <AppComponentDefinition>[
    AppComponentDefinition(
      name: 'Accordion',
      interfaceName: 'AppAccordion',
      category: AppComponentCategory.organism,
    ),
    AppComponentDefinition(name: 'Alert', interfaceName: 'AppAlert', category: AppComponentCategory.molecule),
    AppComponentDefinition(
      name: 'Alert Dialog',
      interfaceName: 'AppAlertDialog',
      category: AppComponentCategory.organism,
    ),
    AppComponentDefinition(
      name: 'Attachment',
      interfaceName: 'AppAttachment',
      category: AppComponentCategory.molecule,
    ),
    AppComponentDefinition(name: 'Avatar', interfaceName: 'AppAvatar', category: AppComponentCategory.atom),
    AppComponentDefinition(name: 'Badge', interfaceName: 'AppBadge', category: AppComponentCategory.atom),
    AppComponentDefinition(
      name: 'Breadcrumb',
      interfaceName: 'AppBreadcrumbs',
      category: AppComponentCategory.molecule,
    ),
    AppComponentDefinition(name: 'Button', interfaceName: 'AppButton', category: AppComponentCategory.atom),
    AppComponentDefinition(
      name: 'Button Group',
      interfaceName: 'AppButtonGroup',
      category: AppComponentCategory.molecule,
    ),
    AppComponentDefinition(name: 'Calendar', interfaceName: 'AppCalendar', category: AppComponentCategory.organism),
    AppComponentDefinition(name: 'Card', interfaceName: 'AppCard', category: AppComponentCategory.atom),
    AppComponentDefinition(name: 'Checkbox', interfaceName: 'AppCheckbox', category: AppComponentCategory.atom),
    AppComponentDefinition(
      name: 'Combobox',
      interfaceName: 'AppCombobox',
      category: AppComponentCategory.molecule,
    ),
    AppComponentDefinition(
      name: 'Data Table',
      interfaceName: 'AppDataTable',
      category: AppComponentCategory.organism,
    ),
    AppComponentDefinition(
      name: 'Date Picker',
      interfaceName: 'AppDatePicker',
      category: AppComponentCategory.organism,
    ),
    AppComponentDefinition(name: 'Dialog', interfaceName: 'AppDialog', category: AppComponentCategory.organism),
    AppComponentDefinition(name: 'Drawer', interfaceName: 'AppDrawer', category: AppComponentCategory.organism),
    AppComponentDefinition(
      name: 'State View',
      interfaceName: 'AppStateView',
      category: AppComponentCategory.organism,
    ),
    AppComponentDefinition(name: 'Field', interfaceName: 'AppField', category: AppComponentCategory.molecule),
    AppComponentDefinition(name: 'Form', interfaceName: 'AppForm', category: AppComponentCategory.organism),
    AppComponentDefinition(
      name: 'Hover Card',
      interfaceName: 'AppHoverCard',
      category: AppComponentCategory.organism,
    ),
    AppComponentDefinition(name: 'Input', interfaceName: 'AppTextInput', category: AppComponentCategory.atom),
    AppComponentDefinition(
      name: 'Input Group',
      interfaceName: 'AppInputGroup',
      category: AppComponentCategory.molecule,
    ),
    AppComponentDefinition(name: 'Separator', interfaceName: 'AppDivider', category: AppComponentCategory.atom),
    AppComponentDefinition(name: 'Sheet', interfaceName: 'AppSheet', category: AppComponentCategory.organism),
    AppComponentDefinition(name: 'Sidebar', interfaceName: 'AppSidebar', category: AppComponentCategory.organism),
    AppComponentDefinition(name: 'Skeleton', interfaceName: 'AppSkeleton', category: AppComponentCategory.atom),
    AppComponentDefinition(name: 'Spinner', interfaceName: 'AppSpinner', category: AppComponentCategory.atom),
    AppComponentDefinition(name: 'Switch', interfaceName: 'AppSwitch', category: AppComponentCategory.atom),
    AppComponentDefinition(name: 'Table', interfaceName: 'AppTable', category: AppComponentCategory.organism),
    AppComponentDefinition(name: 'Tabs', interfaceName: 'AppTabs', category: AppComponentCategory.organism),
    AppComponentDefinition(name: 'Textarea', interfaceName: 'AppTextarea', category: AppComponentCategory.atom),
    AppComponentDefinition(name: 'Toast', interfaceName: 'AppToast', category: AppComponentCategory.molecule),
    AppComponentDefinition(name: 'Item', interfaceName: 'AppListItem', category: AppComponentCategory.molecule),
    AppComponentDefinition(name: 'Label', interfaceName: 'AppLabel', category: AppComponentCategory.atom),
    AppComponentDefinition(
      name: 'Pagination',
      interfaceName: 'AppPagination',
      category: AppComponentCategory.molecule,
    ),
    AppComponentDefinition(name: 'Popover', interfaceName: 'AppPopover', category: AppComponentCategory.organism),
    AppComponentDefinition(name: 'Progress', interfaceName: 'AppProgress', category: AppComponentCategory.atom),
    AppComponentDefinition(
      name: 'Radio Group',
      interfaceName: 'AppRadioGroup',
      category: AppComponentCategory.molecule,
    ),
    AppComponentDefinition(
      name: 'Resizable',
      interfaceName: 'AppResizable',
      category: AppComponentCategory.organism,
    ),
    AppComponentDefinition(
      name: 'Scroll Area',
      interfaceName: 'AppScrollArea',
      category: AppComponentCategory.organism,
    ),
    AppComponentDefinition(name: 'Select', interfaceName: 'AppSelect', category: AppComponentCategory.molecule),
  ];
}
