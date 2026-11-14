import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/ui/app_ui.dart';

class FieldCatalogDemo extends StatefulWidget {
  const FieldCatalogDemo({super.key});

  @override
  State<FieldCatalogDemo> createState() => _FieldCatalogDemoState();
}

class _FieldCatalogDemoState extends State<FieldCatalogDemo> {
  String? _department;
  String? _month;
  String? _year;
  String? _plan = 'mensal';
  var _sameAddress = true;
  var _syncFolders = true;
  var _hardDisks = false;
  var _externalDisks = false;
  var _mediaDevices = false;
  var _servers = false;
  var _multiFactor = false;

  static const _departments = [
    'Engenharia',
    'Design',
    'Marketing',
    'Vendas',
    'Suporte ao cliente',
    'Recursos humanos',
    'Financeiro',
    'Operações',
  ];

  @override
  Widget build(BuildContext context) => ConstrainedBox(
    constraints: BoxConstraints(maxWidth: context.tokens.sizes.dialogWide),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _Example(
          title: 'AppForm',
          child: AppForm(
            title: 'Forma de pagamento',
            description: 'Todas as transações são seguras e criptografadas.',
            onSubmit: () async {},
            contentBuilder: (context, submitting, submit) => [
              _textField(label: 'Nome no cartão', placeholder: 'Maria Silva'),
              _textField(
                label: 'Número do cartão',
                placeholder: '1234 5678 9012 3456',
                description: 'Digite os 16 números do cartão.',
              ),
              _ResponsiveFields(
                children: [
                  AppField(
                    label: 'Mês',
                    control: AppCombobox<String>(
                      options: const ['01', '02', '03'],
                      displayStringForOption: (option) => option,
                      value: _month,
                      placeholder: 'MM',
                      semanticLabel: 'Mês de validade',
                      onChanged: (value) => setState(() => _month = value),
                    ),
                  ),
                  AppField(
                    label: 'Ano',
                    control: AppCombobox<String>(
                      options: const ['2026', '2027', '2028'],
                      displayStringForOption: (option) => option,
                      value: _year,
                      placeholder: 'AAAA',
                      semanticLabel: 'Ano de validade',
                      onChanged: (value) => setState(() => _year = value),
                    ),
                  ),
                  _textField(label: 'CVV', placeholder: '123'),
                ],
              ),
              AppField(
                label: 'Igual ao endereço de entrega',
                description: 'O endereço de cobrança associado à sua forma de pagamento.',
                orientation: AppFieldOrientation.horizontal,
                controlPlacement: AppFieldControlPlacement.leading,
                control: AppCheckbox(
                  value: _sameAddress,
                  semanticLabel: 'Igual ao endereço de entrega',
                  onChanged: (value) => setState(() => _sameAddress = value ?? false),
                ),
              ),
              const AppField(
                label: 'Comentários',
                control: AppTextarea(
                  placeholder: 'Adicione observações',
                  semanticLabel: 'Comentários',
                ),
              ),
            ],
            builder: (context, submitting, submit, content) => Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                content,
                SizedBox(height: context.tokens.spacing.lg),
                Wrap(
                  spacing: context.tokens.spacing.sm,
                  runSpacing: context.tokens.spacing.sm,
                  children: [
                    AppButton(label: 'Enviar', onPressed: submit),
                    AppButton(label: 'Cancelar', variant: AppButtonVariant.outline, onPressed: () {}),
                  ],
                ),
              ],
            ),
          ),
        ),
        _Example(
          title: 'Input',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _textField(
                label: 'Nome de usuário',
                placeholder: 'Max Leiter',
                description: 'Escolha um nome de usuário exclusivo para sua conta.',
              ),
              SizedBox(height: context.tokens.spacing.lg),
              _textField(
                label: 'Senha',
                placeholder: '••••••••',
                description: 'Deve ter pelo menos 8 caracteres.',
                descriptionPlacement: AppFieldDescriptionPlacement.beforeControl,
                obscureText: true,
              ),
            ],
          ),
        ),
        const _Example(
          title: 'Textarea',
          child: AppField(
            label: 'Feedback',
            description: 'Compartilhe sua opinião sobre o serviço.',
            control: AppTextarea(
              placeholder: 'Seu feedback nos ajuda a melhorar...',
              semanticLabel: 'Feedback',
            ),
          ),
        ),
        _Example(
          title: 'Combobox',
          child: AppField(
            label: 'Departamento',
            description: 'Selecione seu departamento ou área de atuação.',
            control: AppCombobox<String>(
              options: _departments,
              displayStringForOption: (option) => option,
              value: _department,
              placeholder: 'Escolha um departamento',
              semanticLabel: 'Departamento',
              showClear: true,
              onChanged: (value) => setState(() => _department = value),
            ),
          ),
        ),
        _Example(
          title: 'Checkbox',
          child: AppForm(
            title: 'Mostrar estes itens na área de trabalho',
            description: 'Selecione os itens que deseja exibir na área de trabalho.',
            spacing: context.tokens.spacing.xxs,
            onSubmit: () async {},
            contentBuilder: (context, submitting, submit) => [
              _checkboxField('Discos rígidos', _hardDisks, (value) => _hardDisks = value),
              _checkboxField('Discos externos', _externalDisks, (value) => _externalDisks = value),
              _checkboxField('CDs, DVDs e iPods', _mediaDevices, (value) => _mediaDevices = value),
              _checkboxField('Servidores conectados', _servers, (value) => _servers = value),
              AppField(
                label: 'Sincronizar pastas Área de Trabalho e Documentos',
                description:
                    'As pastas estão sendo sincronizadas com o armazenamento em nuvem e podem ser acessadas em outros dispositivos.',
                orientation: AppFieldOrientation.horizontal,
                controlPlacement: AppFieldControlPlacement.leading,
                control: AppCheckbox(
                  value: _syncFolders,
                  semanticLabel: 'Sincronizar pastas Área de Trabalho e Documentos',
                  onChanged: (value) => setState(() => _syncFolders = value ?? false),
                ),
              ),
            ],
            builder: (context, submitting, submit, content) => content,
          ),
        ),
        _Example(
          title: 'Radio',
          child: AppField(
            label: 'Plano de assinatura',
            description: 'Os planos anual e vitalício oferecem economia significativa.',
            control: AppRadioGroup<String>(
              value: _plan,
              options: const [
                AppRadioOption(value: 'mensal', label: r'Mensal (R$ 9,99/mês)'),
                AppRadioOption(value: 'anual', label: r'Anual (R$ 99,99/ano)'),
                AppRadioOption(value: 'vitalicio', label: r'Vitalício (R$ 299,99)'),
              ],
              onChanged: (value) => setState(() => _plan = value),
            ),
          ),
        ),
        _Example(
          title: 'Switch',
          child: AppField(
            label: 'Autenticação multifator',
            orientation: AppFieldOrientation.horizontal,
            control: AppSwitch(
              value: _multiFactor,
              semanticLabel: 'Autenticação multifator',
              onChanged: (value) => setState(() => _multiFactor = value),
            ),
          ),
        ),
      ],
    ),
  );

  Widget _textField({
    required String label,
    String? placeholder,
    String? description,
    AppFieldDescriptionPlacement descriptionPlacement = AppFieldDescriptionPlacement.afterControl,
    bool obscureText = false,
  }) => AppField(
    label: label,
    description: description,
    descriptionPlacement: descriptionPlacement,
    control: AppTextInput(
      placeholder: placeholder,
      obscureText: obscureText,
      semanticLabel: label,
    ),
  );

  Widget _checkboxField(String label, bool value, ValueChanged<bool> update) => AppField(
    label: label,
    orientation: AppFieldOrientation.horizontal,
    controlPlacement: AppFieldControlPlacement.leading,
    control: AppCheckbox(
      value: value,
      semanticLabel: label,
      onChanged: (selected) => setState(() => update(selected ?? false)),
    ),
  );
}

class _Example extends StatelessWidget {
  const _Example({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.only(bottom: context.tokens.spacing.huge),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(title, style: context.tokens.typography.titleMedium),
        SizedBox(height: context.tokens.spacing.xl),
        child,
      ],
    ),
  );
}

class _ResponsiveFields extends StatelessWidget {
  const _ResponsiveFields({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      if (constraints.maxWidth < context.tokens.layout.compact) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (var index = 0; index < children.length; index++) ...[
              children[index],
              if (index != children.length - 1) SizedBox(height: context.tokens.spacing.lg),
            ],
          ],
        );
      }
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (var index = 0; index < children.length; index++) ...[
            Expanded(child: children[index]),
            if (index != children.length - 1) SizedBox(width: context.tokens.spacing.md),
          ],
        ],
      );
    },
  );
}
