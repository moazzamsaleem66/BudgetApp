import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../data/models/budget_models.dart';
import '../state/budget_state_scope.dart';
import 'login_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final firebaseUser = FirebaseAuth.instance.currentUser;
    final profile = BudgetStateScope.of(context).profile;
    final items = profile.items.where((item) => item.iconName != 'premium').toList();
    final name = (firebaseUser?.displayName?.trim().isNotEmpty ?? false)
        ? firebaseUser!.displayName!.trim()
        : profile.name;
    final email = firebaseUser?.email ?? profile.email;
    final initial = name.trim().isEmpty ? 'M' : name.trim()[0].toUpperCase();

    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF0C9AA9), Color(0xFF6AD9CF), Color(0xFFA8ECDD)],
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: -70,
            right: -40,
            child: _GlowCircle(size: 260, opacity: 0.14),
          ),
          Positioned(
            left: -110,
            bottom: 80,
            child: _GlowCircle(size: 320, opacity: 0.1),
          ),
          Positioned(
            right: -30,
            bottom: -40,
            child: _GlowCircle(size: 240, opacity: 0.12),
          ),
          SafeArea(
            top: false,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
              children: [
                Row(
                  children: [
                    Container(
                      width: 70,
                      height: 70,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white.withValues(alpha: 0.45), width: 2),
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [Color(0xFF2BC187), Color(0xFF129D7C)],
                        ),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        initial,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 42 / 2,
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            name,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                              fontSize: 26 / 1.2,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            email,
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.9),
                              fontWeight: FontWeight.w500,
                              fontSize: 15,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ...items.map(
                  (item) => _GlassItemTile(
                    title: item.title,
                    subtitle: item.subtitle,
                    icon: _iconFor(item),
                    onTap: () => _openSettingDialog(context, item),
                  ),
                ),
                _GlassItemTile(
                  title: 'Logout',
                  subtitle: 'Sign out from this device',
                  icon: Icons.logout_rounded,
                  onTap: () => _logout(context),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  height: 50,
                  child: FilledButton.icon(
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFF0B8F6E),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    onPressed: () => _logout(context),
                    icon: const Icon(Icons.logout_rounded),
                    label: const Text('Logout', style: TextStyle(fontWeight: FontWeight.w700)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

Future<void> _logout(BuildContext context) async {
  await FirebaseAuth.instance.signOut();
  if (!context.mounted) return;
  Navigator.of(context).pushAndRemoveUntil(
    MaterialPageRoute<void>(
      builder: (_) => const LoginScreen(startInLoginMode: true),
    ),
    (route) => false,
  );
}

Future<void> _openSettingDialog(BuildContext context, ProfileItem item) async {
  switch (item.iconName) {
    case 'flag':
      await _openMonthlyTargetDialog(context);
      return;
    case 'currency':
      await _openCurrencyDialog(context);
      return;
    case 'language':
      await _openLanguageDialog(context);
      return;
    case 'lock':
      await _openSecurityDialog(context);
      return;
    case 'notifications':
      await _openNotificationsDialog(context);
      return;
    case 'stars':
      await _openSavingsGoalsDialog(context);
      return;
    default:
      await _openInfoDialog(context, item);
  }
}

Future<void> _openInfoDialog(BuildContext context, ProfileItem item) async {
  await showDialog<void>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text(item.title),
      content: Text('Current: ${item.subtitle}'),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(dialogContext).pop(),
          style: FilledButton.styleFrom(backgroundColor: const Color(0xFF10A37F)),
          child: const Text('Save'),
        ),
      ],
    ),
  );
}

Future<void> _openMonthlyTargetDialog(BuildContext context) async {
  final appState = BudgetStateScope.read(context);
  final controller = TextEditingController(
    text: _formatMonthlyTargetValue(appState.monthlySavingTarget),
  );
  final formKey = GlobalKey<FormState>();

  try {
    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          titlePadding: const EdgeInsets.fromLTRB(22, 20, 22, 4),
          contentPadding: const EdgeInsets.fromLTRB(22, 8, 22, 6),
          actionsPadding: const EdgeInsets.fromLTRB(16, 6, 16, 14),
          title: Row(
            children: [
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.94, end: 1),
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOutCubic,
                builder: (context, value, child) => Transform.scale(
                  scale: value,
                  child: child,
                ),
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8FAF3),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.savings_rounded,
                    color: Color(0xFF10A37F),
                    size: 20,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Text(
                  'Set Monthly Target',
                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: 22),
                ),
              ),
            ],
          ),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Define how much you want to save each month',
                  style: TextStyle(
                    fontSize: 14.5,
                    color: Color(0xFF5E7382),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 14),
                const Text(
                  'Enter your monthly saving goal:',
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF2D485A),
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: controller,
                  keyboardType: TextInputType.number,
                  textInputAction: TextInputAction.done,
                  decoration: InputDecoration(
                    prefixText: 'KD ',
                    hintText: '300',
                    filled: true,
                    fillColor: Colors.white,
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: Color(0xFFD0DCE4),
                        width: 1.2,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: Color(0xFF10A37F),
                        width: 1.8,
                      ),
                    ),
                  ),
                  validator: (value) {
                    final text = (value ?? '').trim();
                    final amount = double.tryParse(text);
                    if (text.isEmpty || amount == null || amount <= 0) {
                      return 'Please enter a valid amount';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                const Text(
                  'Tip: Setting a goal helps you track savings better',
                  style: TextStyle(
                    fontSize: 13.2,
                    color: Color(0xFF5E7382),
                    fontStyle: FontStyle.italic,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancel'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF10A37F),
              ),
              onPressed: () {
                if (!(formKey.currentState?.validate() ?? false)) {
                  return;
                }

                final amount = double.parse(controller.text.trim());
                appState.setMonthlySavingTarget(amount);
                Navigator.of(dialogContext).pop();
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  } finally {
    controller.dispose();
  }
}

String _formatMonthlyTargetValue(double amount) {
  if (amount % 1 == 0) {
    return amount.toInt().toString();
  }
  return amount.toStringAsFixed(1);
}

Future<void> _openCurrencyDialog(BuildContext context) async {
  final appState = BudgetStateScope.read(context);
  var selected = appState.selectedCurrency;
  const options = _currencyOptions;

  await showDialog<void>(
    context: context,
    builder: (dialogContext) => StatefulBuilder(
      builder: (context, setState) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Currency Selection'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Select your preferred currency for all amounts.'),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: selected,
              items: options
                  .map(
                    (e) => DropdownMenuItem<String>(
                      value: e,
                      child: Text(e),
                    ),
                  )
                  .toList(growable: false),
              onChanged: (value) {
                if (value == null) return;
                setState(() => selected = value);
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: const Color(0xFF10A37F)),
            onPressed: () {
              appState.setCurrency(selected);
              Navigator.of(dialogContext).pop();
            },
            child: const Text('Save'),
          ),
        ],
      ),
    ),
  );
}

const List<String> _currencyOptions = [
  'Afghan Afghani (AFN)',
  'Albanian Lek (ALL)',
  'Algerian Dinar (DZD)',
  'Angolan Kwanza (AOA)',
  'Argentine Peso (ARS)',
  'Armenian Dram (AMD)',
  'Aruban Florin (AWG)',
  'Australian Dollar (AUD)',
  'Azerbaijani Manat (AZN)',
  'Bahamian Dollar (BSD)',
  'Bahraini Dinar (BHD)',
  'Bangladeshi Taka (BDT)',
  'Barbadian Dollar (BBD)',
  'Belarusian Ruble (BYN)',
  'Belize Dollar (BZD)',
  'Bermudian Dollar (BMD)',
  'Bhutanese Ngultrum (BTN)',
  'Bolivian Boliviano (BOB)',
  'Bosnia and Herzegovina Convertible Mark (BAM)',
  'Botswana Pula (BWP)',
  'Brazilian Real (BRL)',
  'Brunei Dollar (BND)',
  'Bulgarian Lev (BGN)',
  'Burundian Franc (BIF)',
  'Cambodian Riel (KHR)',
  'Canadian Dollar (CAD)',
  'Cape Verdean Escudo (CVE)',
  'Cayman Islands Dollar (KYD)',
  'CFA Franc BCEAO (XOF)',
  'CFA Franc BEAC (XAF)',
  'CFP Franc (XPF)',
  'Chilean Peso (CLP)',
  'Chinese Yuan (CNY)',
  'Colombian Peso (COP)',
  'Comorian Franc (KMF)',
  'Congolese Franc (CDF)',
  'Costa Rican Colon (CRC)',
  'Croatian Euro (EUR)',
  'Cuban Peso (CUP)',
  'Czech Koruna (CZK)',
  'Danish Krone (DKK)',
  'Djiboutian Franc (DJF)',
  'Dominican Peso (DOP)',
  'East Caribbean Dollar (XCD)',
  'Egyptian Pound (EGP)',
  'Eritrean Nakfa (ERN)',
  'Ethiopian Birr (ETB)',
  'Euro (EUR)',
  'Fijian Dollar (FJD)',
  'Gambian Dalasi (GMD)',
  'Georgian Lari (GEL)',
  'Ghanaian Cedi (GHS)',
  'Guatemalan Quetzal (GTQ)',
  'Guinean Franc (GNF)',
  'Guyanese Dollar (GYD)',
  'Haitian Gourde (HTG)',
  'Honduran Lempira (HNL)',
  'Hong Kong Dollar (HKD)',
  'Hungarian Forint (HUF)',
  'Icelandic Krona (ISK)',
  'Indian Rupee (INR)',
  'Indonesian Rupiah (IDR)',
  'Iranian Rial (IRR)',
  'Iraqi Dinar (IQD)',
  'Israeli New Shekel (ILS)',
  'Jamaican Dollar (JMD)',
  'Japanese Yen (JPY)',
  'Jordanian Dinar (JOD)',
  'Kazakhstani Tenge (KZT)',
  'Kenyan Shilling (KES)',
  'Kuwaiti Dinar (KD)',
  'Kyrgyzstani Som (KGS)',
  'Lao Kip (LAK)',
  'Lebanese Pound (LBP)',
  'Lesotho Loti (LSL)',
  'Liberian Dollar (LRD)',
  'Libyan Dinar (LYD)',
  'Macanese Pataca (MOP)',
  'Malagasy Ariary (MGA)',
  'Malawian Kwacha (MWK)',
  'Malaysian Ringgit (MYR)',
  'Maldivian Rufiyaa (MVR)',
  'Mauritanian Ouguiya (MRU)',
  'Mauritian Rupee (MUR)',
  'Mexican Peso (MXN)',
  'Moldovan Leu (MDL)',
  'Mongolian Tugrik (MNT)',
  'Moroccan Dirham (MAD)',
  'Mozambican Metical (MZN)',
  'Myanmar Kyat (MMK)',
  'Namibian Dollar (NAD)',
  'Nepalese Rupee (NPR)',
  'Netherlands Antillean Guilder (ANG)',
  'New Taiwan Dollar (TWD)',
  'New Zealand Dollar (NZD)',
  'Nicaraguan Cordoba (NIO)',
  'Nigerian Naira (NGN)',
  'North Korean Won (KPW)',
  'North Macedonian Denar (MKD)',
  'Norwegian Krone (NOK)',
  'Omani Rial (OMR)',
  'Pakistani Rupee (PKR)',
  'Panamanian Balboa (PAB)',
  'Papua New Guinean Kina (PGK)',
  'Paraguayan Guarani (PYG)',
  'Peruvian Sol (PEN)',
  'Philippine Peso (PHP)',
  'Polish Zloty (PLN)',
  'Qatari Riyal (QAR)',
  'Romanian Leu (RON)',
  'Russian Ruble (RUB)',
  'Rwandan Franc (RWF)',
  'Saint Helena Pound (SHP)',
  'Samoan Tala (WST)',
  'Sao Tome and Principe Dobra (STN)',
  'Saudi Riyal (SAR)',
  'Serbian Dinar (RSD)',
  'Seychellois Rupee (SCR)',
  'Sierra Leonean Leone (SLE)',
  'Singapore Dollar (SGD)',
  'Solomon Islands Dollar (SBD)',
  'Somali Shilling (SOS)',
  'South African Rand (ZAR)',
  'South Korean Won (KRW)',
  'South Sudanese Pound (SSP)',
  'Sri Lankan Rupee (LKR)',
  'Sudanese Pound (SDG)',
  'Surinamese Dollar (SRD)',
  'Swazi Lilangeni (SZL)',
  'Swedish Krona (SEK)',
  'Swiss Franc (CHF)',
  'Syrian Pound (SYP)',
  'Tajikistani Somoni (TJS)',
  'Tanzanian Shilling (TZS)',
  'Thai Baht (THB)',
  'Tongan Paanga (TOP)',
  'Trinidad and Tobago Dollar (TTD)',
  'Tunisian Dinar (TND)',
  'Turkish Lira (TRY)',
  'Turkmenistani Manat (TMT)',
  'Ugandan Shilling (UGX)',
  'Ukrainian Hryvnia (UAH)',
  'United Arab Emirates Dirham (AED)',
  'Uruguayan Peso (UYU)',
  'US Dollar (USD)',
  'Uzbekistani Som (UZS)',
  'Vanuatu Vatu (VUV)',
  'Venezuelan Bolivar (VES)',
  'Vietnamese Dong (VND)',
  'Yemeni Rial (YER)',
  'Zambian Kwacha (ZMW)',
  'Zimbabwe Gold (ZWG)',
];

Future<void> _openLanguageDialog(BuildContext context) async {
  final appState = BudgetStateScope.read(context);
  var selected = appState.selectedLanguage;
  const options = ['English', 'Arabic', 'Urdu', 'Hindi'];

  await showDialog<void>(
    context: context,
    builder: (dialogContext) => StatefulBuilder(
      builder: (context, setState) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Language'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Choose app language.'),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: selected,
              items: options
                  .map(
                    (e) => DropdownMenuItem<String>(
                      value: e,
                      child: Text(e),
                    ),
                  )
                  .toList(growable: false),
              onChanged: (value) {
                if (value == null) return;
                setState(() => selected = value);
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: const Color(0xFF10A37F)),
            onPressed: () {
              appState.setLanguage(selected);
              Navigator.of(dialogContext).pop();
            },
            child: const Text('Save'),
          ),
        ],
      ),
    ),
  );
}

Future<void> _openSecurityDialog(BuildContext context) async {
  final appState = BudgetStateScope.read(context);
  var enabled = appState.securityEnabled;

  await showDialog<void>(
    context: context,
    builder: (dialogContext) => StatefulBuilder(
      builder: (context, setState) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Security'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Enable biometric + PIN lock for app security.'),
            const SizedBox(height: 12),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              value: enabled,
              onChanged: (value) => setState(() => enabled = value),
              title: const Text('Biometric + PIN'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: const Color(0xFF10A37F)),
            onPressed: () {
              appState.setSecurityEnabled(enabled);
              Navigator.of(dialogContext).pop();
            },
            child: const Text('Save'),
          ),
        ],
      ),
    ),
  );
}

Future<void> _openNotificationsDialog(BuildContext context) async {
  final appState = BudgetStateScope.read(context);
  var enabled = appState.notificationsEnabled;

  await showDialog<void>(
    context: context,
    builder: (dialogContext) => StatefulBuilder(
      builder: (context, setState) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Notification Preferences'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Turn budget alerts and reminders on/off.'),
            const SizedBox(height: 12),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              value: enabled,
              onChanged: (value) => setState(() => enabled = value),
              title: const Text('Alerts and reminders'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: const Color(0xFF10A37F)),
            onPressed: () {
              appState.setNotificationsEnabled(enabled);
              Navigator.of(dialogContext).pop();
            },
            child: const Text('Save'),
          ),
        ],
      ),
    ),
  );
}

Future<void> _openSavingsGoalsDialog(BuildContext context) async {
  final appState = BudgetStateScope.read(context);
  final controller = TextEditingController(text: appState.activeSavingsGoals.toString());
  final formKey = GlobalKey<FormState>();

  try {
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Savings Goals'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Set number of active saving goals.'),
              const SizedBox(height: 12),
              TextFormField(
                controller: controller,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Active goals',
                  hintText: '3',
                ),
                validator: (value) {
                  final count = int.tryParse((value ?? '').trim());
                  if (count == null || count <= 0) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              FocusScope.of(dialogContext).unfocus();
              Navigator.of(dialogContext).pop();
            },
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: const Color(0xFF10A37F)),
            onPressed: () {
              if (!(formKey.currentState?.validate() ?? false)) return;
              FocusScope.of(dialogContext).unfocus();
              appState.setActiveSavingsGoals(int.parse(controller.text.trim()));
              Navigator.of(dialogContext).pop();
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  } finally {
    controller.dispose();
  }
}

class _GlowCircle extends StatelessWidget {
  const _GlowCircle({required this.size, required this.opacity});

  final double size;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withValues(alpha: opacity),
      ),
    );
  }
}

class _GlassItemTile extends StatelessWidget {
  const _GlassItemTile({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        color: Colors.white.withValues(alpha: 0.32),
        border: Border.all(color: Colors.white.withValues(alpha: 0.48), width: 1.6),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(22),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 8, 10),
            child: Row(
              children: [
                Container(
                  width: 54,
                  height: 54,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.38),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.45), width: 1.2),
                  ),
                  child: Icon(icon, color: const Color(0xFF0D8A82), size: 28),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          color: Color(0xFF1B3D54),
                          fontWeight: FontWeight.w800,
                          fontSize: 21 / 1.2,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          color: Color(0xFF2E546E),
                          fontWeight: FontWeight.w500,
                          fontSize: 15 / 1.04,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right_rounded, color: Color(0xFF2D6B73), size: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

IconData _iconFor(ProfileItem item) {
  switch (item.iconName) {
    case 'flag':
      return Icons.flag_rounded;
    case 'currency':
      return Icons.monetization_on_rounded;
    case 'language':
      return Icons.language_rounded;
    case 'lock':
      return Icons.shield_rounded;
    case 'notifications':
      return Icons.notifications_active_rounded;
    case 'stars':
      return Icons.outlined_flag_rounded;
    default:
      return Icons.settings_rounded;
  }
}
