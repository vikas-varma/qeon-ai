import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../core/auth/auth_service.dart';
import '../features/integrations/connected_apps_screen.dart'
    as existing_connections;
import '../features/integrations/email_agent_screen.dart' as existing_email;
import '../state/app_state.dart';

class QeonApp extends StatelessWidget {
  const QeonApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Qeon AI',
      theme: QTheme.light,
      home: const SplashScreen(),
      routes: {
        '/gmail-connected': (_) => const GmailConnectionCompleteScreen(),
      },
    );
  }
}

class QColors {
  static const bg = Color(0xFFF7F8FA);
  static const surface = Color(0xFFFFFFFF);
  static const surface2 = Color(0xFFF1F3F6);
  static const text = Color(0xFF111318);
  static const subtext = Color(0xFF6C727F);
  static const muted = Color(0xFFA7ACB5);
  static const border = Color(0xFFE8EAEF);
  static const accent = Color(0xFF5B5FEF);
  static const accent2 = Color(0xFF7478FF);
  static const accentSoft = Color(0xFFEEEEFF);
  static const success = Color(0xFF22A06B);
  static const warning = Color(0xFFE9A23B);
  static const error = Color(0xFFE5484D);
}

class QTheme {
  static ThemeData get light {
    final base = ThemeData.light(useMaterial3: true);
    return base.copyWith(
      scaffoldBackgroundColor: QColors.bg,
      colorScheme: ColorScheme.fromSeed(
        seedColor: QColors.accent,
        brightness: Brightness.light,
        surface: QColors.surface,
      ),
      textTheme: base.textTheme.apply(
        bodyColor: QColors.text,
        displayColor: QColors.text,
        fontFamily: 'Inter',
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: QColors.bg,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        foregroundColor: QColors.text,
      ),
      dividerColor: QColors.border,
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: QColors.surface,
        hintStyle: const TextStyle(color: QColors.muted),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 15,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: QColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: QColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: QColors.accent, width: 1.5),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: QColors.accent,
          foregroundColor: Colors.white,
          minimumSize: const Size.fromHeight(52),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: QColors.text,
          minimumSize: const Size.fromHeight(52),
          side: const BorderSide(color: QColors.border),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }
}

Route<T> qRoute<T>(Widget page) {
  return PageRouteBuilder<T>(
    transitionDuration: const Duration(milliseconds: 280),
    reverseTransitionDuration: const Duration(milliseconds: 220),
    pageBuilder: (_, animation, _) => page,
    transitionsBuilder: (_, animation, _, child) {
      final curved = CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutCubic,
      );
      return FadeTransition(
        opacity: curved,
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, .025),
            end: Offset.zero,
          ).animate(curved),
          child: child,
        ),
      );
    },
  );
}

void qPush(BuildContext context, Widget page) {
  Navigator.of(context).push(qRoute(page));
}

void qReplace(BuildContext context, Widget page) {
  Navigator.of(context).pushReplacement(qRoute(page));
}

class QLogo extends StatelessWidget {
  final double size;
  final bool withTile;
  const QLogo({super.key, this.size = 36, this.withTile = false});

  @override
  Widget build(BuildContext context) {
    final logo = CustomPaint(size: Size.square(size), painter: _QLogoPainter());
    if (!withTile) return logo;
    return Container(
      width: size + 22,
      height: size + 22,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: QColors.border),
        boxShadow: const [
          BoxShadow(
            blurRadius: 22,
            offset: Offset(0, 8),
            color: Color(0x11000000),
          ),
        ],
      ),
      alignment: Alignment.center,
      child: logo,
    );
  }
}

class _QLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final stroke = size.width * .15;
    final rect = Rect.fromLTWH(
      stroke * .6,
      stroke * .6,
      size.width - stroke * 1.2,
      size.height - stroke * 1.2,
    );
    final p = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round
      ..shader = const LinearGradient(
        colors: [Color(0xFF4E54E8), Color(0xFF746CFF)],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    canvas.drawArc(rect, math.pi * .17, math.pi * 1.72, false, p);

    final tail = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round
      ..shader = p.shader;
    canvas.drawLine(
      Offset(size.width * .62, size.height * .63),
      Offset(size.width * .82, size.height * .83),
      tail,
    );

    final dot = Paint()..color = QColors.accent;
    canvas.drawCircle(
      Offset(size.width * .86, size.height * .38),
      size.width * .055,
      dot,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class SurfaceCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;
  final Color? color;
  final double radius;

  const SurfaceCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.onTap,
    this.color,
    this.radius = 20,
  });

  @override
  Widget build(BuildContext context) {
    final card = Container(
      padding: padding,
      decoration: BoxDecoration(
        color: color ?? QColors.surface,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: QColors.border),
        boxShadow: const [
          BoxShadow(
            blurRadius: 24,
            offset: Offset(0, 8),
            color: Color(0x08000000),
          ),
        ],
      ),
      child: child,
    );
    if (onTap == null) return card;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(radius),
      child: card,
    );
  }
}

class SectionHeader extends StatelessWidget {
  final String title;
  final String? action;
  final VoidCallback? onAction;
  const SectionHeader({
    super.key,
    required this.title,
    this.action,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
          ),
        ),
        if (action != null)
          TextButton(
            onPressed: onAction,
            child: Text(
              action!,
              style: const TextStyle(color: QColors.subtext),
            ),
          ),
      ],
    );
  }
}

class MiniBadge extends StatelessWidget {
  final String text;
  final Color color;
  const MiniBadge(this.text, {super.key, this.color = QColors.accentSoft});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        text,
        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
      ),
    );
  }
}

class AgentIcon extends StatelessWidget {
  final IconData icon;
  final double size;
  const AgentIcon(this.icon, {super.key, this.size = 42});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: QColors.accentSoft,
        borderRadius: BorderRadius.circular(size * .32),
      ),
      alignment: Alignment.center,
      child: Icon(icon, color: QColors.accent, size: size * .50),
    );
  }
}

class QeonBottomNav extends StatelessWidget {
  final int selectedIndex;
  final VoidCallback? onQTap;
  const QeonBottomNav({super.key, required this.selectedIndex, this.onQTap});

  void _go(BuildContext context, int index) {
    Widget page;
    switch (index) {
      case 0:
        page = const HomeScreen();
        break;
      case 1:
        page = const TasksScreen();
        break;
      case 3:
        page = const ActivityScreen();
        break;
      case 4:
        page = const ProfileScreen();
        break;
      default:
        page = const ChatScreen();
    }
    qReplace(context, page);
  }

  @override
  Widget build(BuildContext context) {
    Widget item(int index, IconData icon, String label) {
      final selected = selectedIndex == index;
      return Expanded(
        child: InkWell(
          onTap: () => _go(context, index),
          child: SizedBox(
            height: 68,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  color: selected ? QColors.accent : QColors.muted,
                  size: 21,
                ),
                const SizedBox(height: 4),
                Text(
                  label,
                  style: TextStyle(
                    color: selected ? QColors.accent : QColors.subtext,
                    fontSize: 10.5,
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return SafeArea(
      top: false,
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: QColors.border)),
        ),
        child: Row(
          children: [
            item(0, Icons.home_rounded, 'Home'),
            item(1, Icons.check_box_outlined, 'Tasks'),
            Expanded(
              child: Center(
                child: Transform.translate(
                  offset: const Offset(0, -8),
                  child: GestureDetector(
                    onTap:
                        onQTap ?? () => qReplace(context, const ChatScreen()),
                    child: Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: QColors.border),
                        boxShadow: const [
                          BoxShadow(
                            blurRadius: 18,
                            offset: Offset(0, 8),
                            color: Color(0x16000000),
                          ),
                        ],
                      ),
                      alignment: Alignment.center,
                      child: const QLogo(size: 30),
                    ),
                  ),
                ),
              ),
            ),
            item(3, Icons.notifications_none_rounded, 'Activity'),
            item(4, Icons.person_outline_rounded, 'You'),
          ],
        ),
      ),
    );
  }
}

class QComposer extends StatelessWidget {
  final String hint;
  final bool compact;
  final VoidCallback? onPlus;
  final VoidCallback? onSend;
  final VoidCallback? onVoice;

  const QComposer({
    super.key,
    this.hint = 'Ask anything...',
    this.compact = false,
    this.onPlus,
    this.onSend,
    this.onVoice,
  });

  @override
  Widget build(BuildContext context) {
    return SurfaceCard(
      padding: EdgeInsets.fromLTRB(14, compact ? 8 : 14, 10, 10),
      radius: 24,
      child: Column(
        children: [
          if (!compact)
            TextField(
              minLines: 1,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: hint,
                filled: false,
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                contentPadding: EdgeInsets.zero,
              ),
            )
          else
            Align(
              alignment: Alignment.centerLeft,
              child: Text(hint, style: const TextStyle(color: QColors.muted)),
            ),
          const SizedBox(height: 8),
          Row(
            children: [
              _RoundIconButton(icon: Icons.add_rounded, onTap: onPlus),
              const Spacer(),
              _RoundIconButton(icon: Icons.mic_none_rounded, onTap: onVoice),
              const SizedBox(width: 8),
              _RoundIconButton(
                icon: Icons.arrow_upward_rounded,
                filled: true,
                onTap: onSend,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _RoundIconButton extends StatelessWidget {
  final IconData icon;
  final bool filled;
  final VoidCallback? onTap;
  const _RoundIconButton({required this.icon, this.filled = false, this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: filled ? QColors.accent : QColors.surface2,
          borderRadius: BorderRadius.circular(14),
        ),
        alignment: Alignment.center,
        child: Icon(
          icon,
          size: 19,
          color: filled ? Colors.white : QColors.text,
        ),
      ),
    );
  }
}

class ListRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String? trailing;
  final VoidCallback? onTap;
  final bool greenDot;

  const ListRow({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.trailing,
    this.onTap,
    this.greenDot = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AgentIcon(icon, size: 38),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: const TextStyle(fontWeight: FontWeight.w800),
                        ),
                      ),
                      if (greenDot)
                        Container(
                          width: 7,
                          height: 7,
                          margin: const EdgeInsets.only(right: 6),
                          decoration: const BoxDecoration(
                            color: QColors.success,
                            shape: BoxShape.circle,
                          ),
                        ),
                      if (trailing != null)
                        Text(
                          trailing!,
                          style: const TextStyle(
                            color: QColors.subtext,
                            fontSize: 11.5,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: QColors.subtext,
                      fontSize: 12.5,
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ),
            if (onTap != null)
              const Padding(
                padding: EdgeInsets.only(left: 8, top: 8),
                child: Icon(Icons.chevron_right_rounded, color: QColors.muted),
              ),
          ],
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// 01. GETTING STARTED
// -----------------------------------------------------------------------------

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;
  late final Animation<double> _scale;
  late final Animation<double> _fade;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 850),
    )..forward();
    _scale = CurvedAnimation(parent: _c, curve: Curves.easeOutBack);
    _fade = CurvedAnimation(parent: _c, curve: Curves.easeOut);
    _timer = Timer(const Duration(milliseconds: 1500), () {
      if (!mounted) return;
      final signedIn = ref.read(authServiceProvider).currentUser != null;
      qReplace(
        context,
        signedIn ? const HomeScreen() : const OnboardingScreen(),
      );
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [QColors.bg, QColors.bg, Color(0xFFECEBFF)],
          ),
        ),
        child: Center(
          child: FadeTransition(
            opacity: _fade,
            child: ScaleTransition(
              scale: _scale,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  QLogo(size: 54, withTile: true),
                  SizedBox(height: 26),
                  Text(
                    'Qeon AI',
                    style: TextStyle(fontSize: 34, fontWeight: FontWeight.w800),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Personal agents that get things done.',
                    style: TextStyle(color: QColors.subtext, fontSize: 15),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pc = PageController();
  int page = 0;

  final pages = const [
    _OnboardData(
      title: 'Your personal\nAI assistant',
      body: 'Qeon AI helps you focus on what matters by handling the rest.',
      type: 0,
    ),
    _OnboardData(
      title: 'Built-in memory.\nPersonalized for you.',
      body:
          'Qeon AI remembers what’s important and tailors every response to your context.',
      type: 1,
    ),
    _OnboardData(
      title: 'Agents that get\nthings done.',
      body:
          'From research to scheduling, Qeon AI agents work for you so you can achieve more.',
      type: 2,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => qReplace(context, const SignInScreen()),
                    child: const Text(
                      'Skip',
                      style: TextStyle(color: QColors.subtext),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _pc,
                itemCount: pages.length,
                onPageChanged: (i) => setState(() => page = i),
                itemBuilder: (_, i) => _OnboardPage(data: pages[i]),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 28),
              child: Row(
                children: [
                  Row(
                    children: List.generate(
                      pages.length,
                      (i) => AnimatedContainer(
                        duration: const Duration(milliseconds: 220),
                        width: i == page ? 22 : 7,
                        height: 7,
                        margin: const EdgeInsets.only(right: 7),
                        decoration: BoxDecoration(
                          color: i == page ? QColors.accent : QColors.border,
                          borderRadius: BorderRadius.circular(999),
                        ),
                      ),
                    ),
                  ),
                  const Spacer(),
                  InkWell(
                    onTap: () {
                      if (page == pages.length - 1) {
                        qReplace(context, const SignInScreen());
                      } else {
                        _pc.nextPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeOutCubic,
                        );
                      }
                    },
                    borderRadius: BorderRadius.circular(18),
                    child: Container(
                      width: 54,
                      height: 54,
                      decoration: BoxDecoration(
                        color: QColors.accent,
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: const Icon(
                        Icons.arrow_forward_rounded,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OnboardData {
  final String title;
  final String body;
  final int type;
  const _OnboardData({
    required this.title,
    required this.body,
    required this.type,
  });
}

class _OnboardPage extends StatelessWidget {
  final _OnboardData data;
  const _OnboardPage({required this.data});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            data.title,
            style: const TextStyle(
              fontSize: 34,
              height: 1.05,
              fontWeight: FontWeight.w800,
              letterSpacing: -.6,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            data.body,
            style: const TextStyle(
              fontSize: 15,
              color: QColors.subtext,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 28),
          Expanded(child: _OnboardVisual(type: data.type)),
        ],
      ),
    );
  }
}

class _OnboardVisual extends StatelessWidget {
  final int type;
  const _OnboardVisual({required this.type});

  @override
  Widget build(BuildContext context) {
    if (type == 1) {
      return Stack(
        alignment: Alignment.center,
        children: [
          Container(
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [QColors.accentSoft, Colors.transparent],
              ),
            ),
          ),
          const CircleAvatar(
            radius: 66,
            backgroundColor: Colors.white,
            child: Icon(Icons.person_rounded, size: 78, color: QColors.accent),
          ),
          const Positioned(
            top: 50,
            right: 10,
            child: MiniBadge('Product Designer'),
          ),
          const Positioned(
            top: 115,
            right: 0,
            child: MiniBadge('Works at Acme'),
          ),
          const Positioned(
            bottom: 80,
            right: 28,
            child: MiniBadge('Prefers concise'),
          ),
          const Positioned(
            bottom: 45,
            left: 20,
            child: MiniBadge('Based in SF'),
          ),
        ],
      );
    }

    if (type == 2) {
      return LayoutBuilder(
        builder: (context, constraints) => Center(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: SizedBox(
              width: constraints.maxWidth,
              child: SurfaceCard(
                padding: const EdgeInsets.all(10),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    ListRow(
                      icon: Icons.search_rounded,
                      title: 'Research Agent',
                      subtitle: 'Find insights and answers',
                    ),
                    Divider(height: 1),
                    ListRow(
                      icon: Icons.calendar_month_rounded,
                      title: 'Calendar Agent',
                      subtitle: 'Manage your schedule',
                    ),
                    Divider(height: 1),
                    ListRow(
                      icon: Icons.mail_outline_rounded,
                      title: 'Email Agent',
                      subtitle: 'Summarize and draft emails',
                    ),
                    Divider(height: 1),
                    ListRow(
                      icon: Icons.check_circle_outline_rounded,
                      title: 'Task Agent',
                      subtitle: 'Plan, organize, and track',
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) => Center(
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: SizedBox(
            width: constraints.maxWidth,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SurfaceCard(
                  child: ListRow(
                    icon: Icons.calendar_today_rounded,
                    title: 'Design review',
                    subtitle: 'Product team sync',
                  ),
                ),
                const SizedBox(height: 12),
                const SurfaceCard(
                  child: ListRow(
                    icon: Icons.event_note_rounded,
                    title: 'Weekly planning',
                    subtitle: 'Team stand-up',
                  ),
                ),
                const SizedBox(height: 12),
                SurfaceCard(
                  child: Column(
                    children: [
                      const ListRow(
                        icon: Icons.search_rounded,
                        title: 'Research Agent',
                        subtitle: 'Find 5 AI tools that match your profile',
                      ),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(99),
                        child: const LinearProgressIndicator(
                          value: .60,
                          minHeight: 6,
                          color: QColors.accent,
                          backgroundColor: QColors.accentSoft,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class AuthShell extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget child;
  const AuthShell({
    super.key,
    required this.title,
    required this.subtitle,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Navigator.canPop(context) ? const BackButton() : null,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 36),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w800,
                letterSpacing: -.4,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: const TextStyle(color: QColors.subtext, fontSize: 15),
            ),
            const SizedBox(height: 28),
            child,
          ],
        ),
      ),
    );
  }
}

class SignInScreen extends ConsumerStatefulWidget {
  const SignInScreen({super.key});

  @override
  ConsumerState<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends ConsumerState<SignInScreen> {
  bool signingIn = false;

  Future<void> _signIn() async {
    if (signingIn) return;
    setState(() => signingIn = true);
    try {
      await ref.read(authServiceProvider).signInWithGoogle();
      if (mounted) qReplace(context, const HomeScreen());
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Google sign-in did not complete. Please try again.'),
        ),
      );
    } finally {
      if (mounted) setState(() => signingIn = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authServiceProvider);
    return AuthShell(
      title: 'Welcome to Qeon AI',
      subtitle: 'Sign in securely to keep your data private to your account.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          OutlinedButton.icon(
            key: const Key('complete-ui-google-sign-in'),
            onPressed: auth.configured && !signingIn ? _signIn : null,
            icon: signingIn
                ? const SizedBox.square(
                    dimension: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.g_mobiledata_rounded, size: 30),
            label: Text(signingIn ? 'Signing in…' : 'Continue with Google'),
          ),
          const SizedBox(height: 18),
          const SurfaceCard(
            color: QColors.accentSoft,
            child: Text(
              'Signing in creates your Qeon AI account. Gmail access is separate and requested only when you choose Connect Gmail.',
              style: TextStyle(height: 1.45),
            ),
          ),
          if (!auth.configured) ...[
            const SizedBox(height: 16),
            const Text(
              'Firebase setup is incomplete. Add google-services.json before testing sign-in.',
              textAlign: TextAlign.center,
              style: TextStyle(color: QColors.error, fontSize: 12),
            ),
          ],
          const SizedBox(height: 12),
          TextButton(
            onPressed: () => qPush(context, const PermissionsScreen()),
            child: const Text('Privacy & data controls'),
          ),
        ],
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// 02. CORE AI EXPERIENCE
// -----------------------------------------------------------------------------

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  void _showAttachments(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const AttachmentsSheet(),
    );
  }

  void _showAgentPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const AgentPickerSheet(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authStateProvider).asData?.value;
    final displayName = user?.displayName?.trim() ?? '';
    final firstName = displayName.isEmpty
        ? 'there'
        : displayName.split(' ').first;
    final tasks = ref.watch(tasksProvider);
    return Scaffold(
      bottomNavigationBar: const QeonBottomNav(selectedIndex: 0),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  IconButton(
                    onPressed: () => _showAgentPicker(context),
                    icon: const Icon(Icons.menu_rounded),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => qPush(context, const ActivityScreen()),
                    icon: const Icon(Icons.notifications_none_rounded),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                'Hello, $firstName',
                style: TextStyle(
                  color: QColors.accent,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'What would you\nlike to get done?',
                style: TextStyle(
                  fontSize: 34,
                  height: 1.05,
                  letterSpacing: -.7,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 24),
              QComposer(
                onPlus: () => _showAttachments(context),
                onVoice: () => qPush(context, const VoiceModeScreen()),
                onSend: () => qPush(context, const ChatScreen()),
              ),
              const SizedBox(height: 28),
              SectionHeader(
                title: 'Today',
                action: 'View all',
                onAction: () => qPush(context, const TasksScreen()),
              ),
              tasks.when(
                loading: () => const SurfaceCard(
                  child: Center(child: CircularProgressIndicator()),
                ),
                error: (_, _) => const SurfaceCard(
                  child: Text(
                    'Could not load today’s tasks.',
                    style: TextStyle(color: QColors.subtext),
                  ),
                ),
                data: (items) => SurfaceCard(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  child: items.isEmpty
                      ? const Padding(
                          padding: EdgeInsets.symmetric(vertical: 10),
                          child: Text(
                            'No tasks yet. Create one from the Tasks tab.',
                            style: TextStyle(color: QColors.subtext),
                          ),
                        )
                      : Column(
                          children: [
                            for (
                              var index = 0;
                              index < items.take(3).length;
                              index++
                            ) ...[
                              ListRow(
                                icon: Icons.event_note_rounded,
                                title: items[index].title,
                                subtitle: items[index].schedule,
                                onTap: () => qPush(
                                  context,
                                  TaskDetailScreen(taskId: items[index].id),
                                ),
                              ),
                              if (index < items.take(3).length - 1)
                                const Divider(height: 1),
                            ],
                          ],
                        ),
                ),
              ),
              const SizedBox(height: 24),
              const SectionHeader(title: 'Working for you'),
              SurfaceCard(
                onTap: () => qPush(context, const EmailAgentScreen()),
                child: Column(
                  children: [
                    const ListRow(
                      icon: Icons.mail_outline_rounded,
                      title: 'Email Agent',
                      subtitle:
                          'Search, summarize, draft, and send with approval.',
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(99),
                            child: const LinearProgressIndicator(
                              value: 1,
                              minHeight: 6,
                              color: QColors.accent,
                              backgroundColor: QColors.accentSoft,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        const Text(
                          'Ready',
                          style: TextStyle(
                            color: QColors.subtext,
                            fontWeight: FontWeight.w700,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Expanded(
                    child: SurfaceCard(
                      onTap: () => qPush(context, const AgentsHubScreen()),
                      child: const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AgentIcon(Icons.smart_toy_outlined),
                          SizedBox(height: 12),
                          Text(
                            'Agents',
                            style: TextStyle(fontWeight: FontWeight.w800),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Specialized help',
                            style: TextStyle(
                              color: QColors.subtext,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: SurfaceCard(
                      onTap: () => qPush(context, const MemoryOverviewScreen()),
                      child: const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AgentIcon(Icons.memory_rounded),
                          SizedBox(height: 12),
                          Text(
                            'Memory',
                            style: TextStyle(fontWeight: FontWeight.w800),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Personal context',
                            style: TextStyle(
                              color: QColors.subtext,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({super.key, this.conversationId});

  final String? conversationId;

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => ref
          .read(chatProvider.notifier)
          .openConversation(widget.conversationId),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final value = _controller.text.trim();
    if (value.isEmpty) return;
    _controller.clear();
    await ref.read(chatProvider.notifier).send(value);
    if (!mounted || !_scrollController.hasClients) return;
    await _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final messages = ref.watch(chatProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            QLogo(size: 24),
            SizedBox(width: 8),
            Text('Qeon AI', style: TextStyle(fontWeight: FontWeight.w800)),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Conversation history',
            onPressed: () => qPush(context, const ConversationHistoryScreen()),
            icon: const Icon(Icons.history_rounded),
          ),
        ],
      ),
      bottomNavigationBar: const QeonBottomNav(selectedIndex: 2),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final message = messages[index];
                if (message.isUser) {
                  return Align(
                    alignment: Alignment.centerRight,
                    child: Container(
                      constraints: BoxConstraints(
                        maxWidth: MediaQuery.sizeOf(context).width * .78,
                      ),
                      margin: const EdgeInsets.only(bottom: 14),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 11,
                      ),
                      decoration: BoxDecoration(
                        color: QColors.accent,
                        borderRadius: BorderRadius.circular(17),
                      ),
                      child: Text(
                        message.text,
                        style: const TextStyle(
                          color: Colors.white,
                          height: 1.4,
                        ),
                      ),
                    ),
                  );
                }
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const QLogo(size: 22),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          message.text,
                          style: const TextStyle(height: 1.5),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 10),
              child: SurfaceCard(
                padding: const EdgeInsets.fromLTRB(14, 5, 8, 5),
                radius: 22,
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        key: const Key('complete-ui-chat-field'),
                        controller: _controller,
                        minLines: 1,
                        maxLines: 4,
                        textInputAction: TextInputAction.send,
                        onSubmitted: (_) => _send(),
                        decoration: const InputDecoration(
                          hintText: 'Message Qeon AI…',
                          filled: false,
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(horizontal: 4),
                        ),
                      ),
                    ),
                    _RoundIconButton(
                      icon: Icons.mic_none_rounded,
                      onTap: () => qPush(context, const VoiceModeScreen()),
                    ),
                    const SizedBox(width: 7),
                    _RoundIconButton(
                      icon: Icons.arrow_upward_rounded,
                      filled: true,
                      onTap: _send,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ConversationHistoryScreen extends ConsumerWidget {
  const ConversationHistoryScreen({super.key});

  Future<void> _delete(
    BuildContext context,
    WidgetRef ref,
    String id,
    String title,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete conversation?'),
        content: Text('“$title” will be permanently deleted.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await ref.read(conversationsProvider.notifier).delete(id);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final history = ref.watch(conversationsProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('History'),
        actions: [
          IconButton(
            tooltip: 'New conversation',
            onPressed: () => qReplace(context, const ChatScreen()),
            icon: const Icon(Icons.add_comment_outlined),
          ),
        ],
      ),
      body: history.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) => Center(
          child: OutlinedButton(
            onPressed: () => ref.invalidate(conversationsProvider),
            child: const Text('Try again'),
          ),
        ),
        data: (items) => items.isEmpty
            ? const Center(
                child: Text(
                  'Your saved conversations will appear here.',
                  style: TextStyle(color: QColors.subtext),
                ),
              )
            : ListView.separated(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                itemCount: items.length,
                separatorBuilder: (_, _) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final item = items[index];
                  return SurfaceCard(
                    onTap: () =>
                        qPush(context, ChatScreen(conversationId: item.id)),
                    child: Row(
                      children: [
                        const AgentIcon(Icons.auto_awesome_rounded),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                item.preview.isEmpty ? item.time : item.preview,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: QColors.subtext,
                                  fontSize: 12.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          tooltip: 'Delete',
                          onPressed: () =>
                              _delete(context, ref, item.id, item.title),
                          icon: const Icon(Icons.delete_outline_rounded),
                        ),
                      ],
                    ),
                  );
                },
              ),
      ),
    );
  }
}

class JobMatchCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String company;
  final List<String> tags;
  final String? match;
  final String? pay;

  const JobMatchCard({
    super.key,
    required this.icon,
    required this.title,
    required this.company,
    required this.tags,
    this.match,
    this.pay,
  });

  @override
  Widget build(BuildContext context) {
    return SurfaceCard(
      padding: const EdgeInsets.all(14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AgentIcon(icon, size: 38),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: const TextStyle(fontWeight: FontWeight.w800),
                      ),
                    ),
                    if (match != null)
                      Text(
                        match!,
                        style: const TextStyle(
                          color: QColors.success,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  company,
                  style: const TextStyle(
                    color: QColors.subtext,
                    fontSize: 12.5,
                  ),
                ),
                if (pay != null) ...[
                  const SizedBox(height: 3),
                  Text(
                    pay!,
                    style: const TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
                const SizedBox(height: 8),
                Wrap(
                  spacing: 7,
                  runSpacing: 7,
                  children: tags.map((e) => MiniBadge(e)).toList(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class AiResultsScreen extends StatelessWidget {
  const AiResultsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Qeon AI')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        children: [
          const Text(
            'Here’s a tailored summary and next steps based on your request.',
            style: TextStyle(
              fontSize: 15,
              color: QColors.subtext,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 18),
          const SectionHeader(title: 'Top AI Job Matches'),
          const JobMatchCard(
            icon: Icons.hub_outlined,
            title: 'Applied AI Researcher',
            company: 'OpenAI · San Francisco, CA',
            pay: '\$180k–\$250k · Full-time',
            match: '98% match',
            tags: ['Research'],
          ),
          const SizedBox(height: 10),
          const JobMatchCard(
            icon: Icons.auto_awesome_outlined,
            title: 'Machine Learning Engineer',
            company: 'Anthropic · New York, NY',
            pay: '\$160k–\$210k · Full-time',
            match: '95% match',
            tags: ['Engineering'],
          ),
          const SizedBox(height: 10),
          const JobMatchCard(
            icon: Icons.language_rounded,
            title: 'Staff AI Engineer',
            company: 'Google · Remote',
            pay: '\$150k–\$200k · Full-time',
            match: '93% match',
            tags: ['Engineering'],
          ),
          const SizedBox(height: 20),
          const SectionHeader(title: 'Recommended Next Steps'),
          SurfaceCard(
            child: Column(
              children: const [
                _CheckLine('Update your resume for AI roles'),
                _CheckLine('Tailor your profile for top matches'),
                _CheckLine('Apply to 3 roles this week'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CheckLine extends StatelessWidget {
  final String text;
  const _CheckLine(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          const Icon(
            Icons.check_circle_outline_rounded,
            color: QColors.accent,
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }
}

class VoiceModeScreen extends StatefulWidget {
  const VoiceModeScreen({super.key});

  @override
  State<VoiceModeScreen> createState() => _VoiceModeScreenState();
}

class _VoiceModeScreenState extends State<VoiceModeScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.close_rounded),
        ),
        title: const Text('Voice Mode'),
      ),
      body: SafeArea(
        child: Column(
          children: [
            const Spacer(),
            AnimatedBuilder(
              animation: _c,
              builder: (_, _) {
                final t = Curves.easeInOut.transform(_c.value);
                return Stack(
                  alignment: Alignment.center,
                  children: List.generate(4, (i) {
                    final scale = .55 + i * .18 + t * .06;
                    return Transform.scale(
                      scale: scale,
                      child: Container(
                        width: 240,
                        height: 240,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: QColors.accent.withValues(
                              alpha: .10 + i * .04,
                            ),
                            width: 1.5,
                          ),
                        ),
                      ),
                    );
                  }),
                );
              },
            ),
            const SizedBox(height: 8),
            const Text(
              'Voice mode coming soon',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            const Text(
              'Use text chat while voice support is being prepared.',
              style: TextStyle(color: QColors.subtext),
            ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.fromLTRB(28, 0, 28, 26),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _RoundIconButton(
                    icon: Icons.keyboard_alt_outlined,
                    onTap: () => Navigator.pop(context),
                  ),
                  Container(
                    width: 76,
                    height: 76,
                    decoration: BoxDecoration(
                      color: QColors.accent,
                      borderRadius: BorderRadius.circular(26),
                      boxShadow: const [
                        BoxShadow(
                          blurRadius: 28,
                          offset: Offset(0, 12),
                          color: Color(0x335B5FEF),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.graphic_eq_rounded,
                      color: Colors.white,
                      size: 34,
                    ),
                  ),
                  _RoundIconButton(
                    icon: Icons.close_rounded,
                    onTap: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AttachmentsSheet extends StatelessWidget {
  const AttachmentsSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return _BottomSheetShell(
      title: 'Add to your request',
      children: [
        const ListRow(
          icon: Icons.photo_camera_outlined,
          title: 'Camera',
          subtitle: 'Coming soon',
        ),
        const Divider(height: 1),
        const ListRow(
          icon: Icons.photo_library_outlined,
          title: 'Photo Library',
          subtitle: 'Coming soon',
        ),
        const Divider(height: 1),
        const ListRow(
          icon: Icons.insert_drive_file_outlined,
          title: 'File',
          subtitle: 'Coming soon',
        ),
        const Divider(height: 1),
        ListRow(
          icon: Icons.link_rounded,
          title: 'Connect App',
          subtitle: 'Manage your Gmail connection',
          onTap: () {
            final navigator = Navigator.of(context);
            navigator.pop();
            navigator.push(
              MaterialPageRoute(builder: (_) => const ConnectionsScreen()),
            );
          },
        ),
        const Divider(height: 1),
        ListRow(
          icon: Icons.add_task_rounded,
          title: 'Create Task',
          subtitle: 'Turn this into a task',
          onTap: () {
            final navigator = Navigator.of(context);
            navigator.pop();
            navigator.push(
              MaterialPageRoute(builder: (_) => const TasksScreen()),
            );
          },
        ),
        const Divider(height: 1),
        const ListRow(
          icon: Icons.smart_toy_outlined,
          title: 'Use Agent',
          subtitle: 'Coming soon',
        ),
      ],
    );
  }
}

class AgentPickerSheet extends StatelessWidget {
  const AgentPickerSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return _BottomSheetShell(
      title: 'Choose an agent or action',
      children: [
        ListRow(
          icon: Icons.search_rounded,
          title: 'Research Agent',
          subtitle: 'Find insights and do deep research',
          onTap: () {
            Navigator.pop(context);
            qPush(context, const AgentDetailScreen(agent: AgentData.research));
          },
        ),
        const Divider(height: 1),
        const ListRow(
          icon: Icons.edit_outlined,
          title: 'Writing Agent',
          subtitle: 'Draft, edit, and improve content',
        ),
        const Divider(height: 1),
        const ListRow(
          icon: Icons.bar_chart_rounded,
          title: 'Data Agent',
          subtitle: 'Analyze data and generate reports',
        ),
        const Divider(height: 1),
        ListRow(
          icon: Icons.calendar_month_rounded,
          title: 'Calendar Agent',
          subtitle: 'Manage schedule and meetings',
          onTap: () {
            Navigator.pop(context);
            qPush(context, const AgentDetailScreen(agent: AgentData.calendar));
          },
        ),
        const Divider(height: 1),
        ListRow(
          icon: Icons.mail_outline_rounded,
          title: 'Email Agent',
          subtitle: 'Write, summarize, and respond',
          onTap: () {
            Navigator.pop(context);
            qPush(context, const EmailAgentScreen());
          },
        ),
        const SizedBox(height: 10),
        TextButton(
          onPressed: () {
            Navigator.pop(context);
            qPush(context, const AgentsHubScreen());
          },
          child: const Text('View all agents'),
        ),
      ],
    );
  }
}

class _BottomSheetShell extends StatelessWidget {
  final String title;
  final List<Widget> children;
  const _BottomSheetShell({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        margin: const EdgeInsets.only(top: 70),
        padding: const EdgeInsets.fromLTRB(18, 12, 18, 22),
        decoration: const BoxDecoration(
          color: QColors.bg,
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 42,
              height: 4,
              decoration: BoxDecoration(
                color: QColors.border,
                borderRadius: BorderRadius.circular(99),
              ),
            ),
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            const SizedBox(height: 12),
            SurfaceCard(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              child: Column(children: children),
            ),
          ],
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// 03. PRODUCTIVITY & ACTIVITY
// -----------------------------------------------------------------------------

class TasksScreen extends ConsumerWidget {
  const TasksScreen({super.key});

  Future<void> _showCreateTask(BuildContext context) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const NewTaskSheet(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasks = ref.watch(tasksProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tasks'),
        actions: [
          IconButton(
            tooltip: 'Create task',
            onPressed: () => _showCreateTask(context),
            icon: const Icon(Icons.add_rounded),
          ),
        ],
      ),
      bottomNavigationBar: const QeonBottomNav(selectedIndex: 1),
      body: tasks.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) => Center(
          child: OutlinedButton(
            onPressed: () => ref.invalidate(tasksProvider),
            child: const Text('Try again'),
          ),
        ),
        data: (items) => items.isEmpty
            ? Center(
                child: Padding(
                  padding: const EdgeInsets.all(28),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const AgentIcon(Icons.check_box_outlined, size: 68),
                      const SizedBox(height: 18),
                      const Text(
                        'No tasks yet',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 7),
                      const Text(
                        'Create a task and Qeon AI will keep it organized here.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: QColors.subtext),
                      ),
                      const SizedBox(height: 18),
                      ElevatedButton.icon(
                        onPressed: () => _showCreateTask(context),
                        icon: const Icon(Icons.add_rounded),
                        label: const Text('Create task'),
                      ),
                    ],
                  ),
                ),
              )
            : RefreshIndicator(
                onRefresh: () async {
                  ref.invalidate(tasksProvider);
                  await ref.read(tasksProvider.future);
                },
                child: ListView.separated(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                  itemCount: items.length,
                  separatorBuilder: (_, _) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final task = items[index];
                    return ListRow(
                      icon: task.status.name == 'completed'
                          ? Icons.check_circle_rounded
                          : Icons.radio_button_unchecked_rounded,
                      title: task.title,
                      subtitle: '${task.schedule} · ${task.status.name}',
                      trailing: 'Open',
                      onTap: () =>
                          qPush(context, TaskDetailScreen(taskId: task.id)),
                    );
                  },
                ),
              ),
      ),
    );
  }
}

class NewTaskSheet extends ConsumerStatefulWidget {
  const NewTaskSheet({super.key});

  @override
  ConsumerState<NewTaskSheet> createState() => _NewTaskSheetState();
}

class _NewTaskSheetState extends ConsumerState<NewTaskSheet> {
  final instruction = TextEditingController();
  final schedule = TextEditingController(text: 'once');
  bool requiresApproval = true;
  bool saving = false;

  @override
  void dispose() {
    instruction.dispose();
    schedule.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (instruction.text.trim().length < 2 || saving) return;
    setState(() => saving = true);
    try {
      await ref
          .read(tasksProvider.notifier)
          .addTask(
            instruction: instruction.text.trim(),
            schedule: schedule.text.trim().isEmpty
                ? 'once'
                : schedule.text.trim(),
            requiresApproval: requiresApproval,
          );
      if (mounted) Navigator.pop(context);
    } catch (_) {
      if (!mounted) return;
      setState(() => saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not create the task.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return _BottomSheetShell(
      title: 'Create task',
      children: [
        TextField(
          key: const Key('complete-ui-task-instruction'),
          controller: instruction,
          minLines: 2,
          maxLines: 5,
          decoration: const InputDecoration(
            labelText: 'What should Qeon AI do?',
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: schedule,
          decoration: const InputDecoration(
            labelText: 'Schedule',
            hintText: 'once, daily, or a date and time',
          ),
        ),
        CheckboxListTile(
          value: requiresApproval,
          onChanged: (value) =>
              setState(() => requiresApproval = value ?? true),
          contentPadding: EdgeInsets.zero,
          controlAffinity: ListTileControlAffinity.leading,
          title: const Text('Ask before external actions'),
        ),
        ElevatedButton(
          onPressed: saving ? null : _save,
          child: Text(saving ? 'Creating…' : 'Create task'),
        ),
      ],
    );
  }
}

class TaskDetailScreen extends ConsumerWidget {
  const TaskDetailScreen({super.key, required this.taskId});

  final String taskId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final items = ref.watch(tasksProvider).asData?.value ?? const [];
    final matches = items.where((task) => task.id == taskId);
    final task = matches.isEmpty ? null : matches.first;
    return Scaffold(
      appBar: AppBar(title: const Text('Task Detail')),
      body: task == null
          ? const Center(child: Text('Task not found.'))
          : ListView(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 28),
              children: [
                Text(
                  task.title,
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 20),
                SurfaceCard(
                  child: Column(
                    children: [
                      ListRow(
                        icon: Icons.schedule_rounded,
                        title: 'Schedule',
                        subtitle: task.schedule,
                      ),
                      const Divider(height: 1),
                      ListRow(
                        icon: Icons.info_outline_rounded,
                        title: 'Status',
                        subtitle: task.status.name,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                const SectionHeader(title: 'Instruction'),
                Text(
                  task.subtitle,
                  style: const TextStyle(color: QColors.subtext, height: 1.5),
                ),
                const SizedBox(height: 28),
                OutlinedButton.icon(
                  onPressed: () async {
                    await ref.read(tasksProvider.notifier).delete(task.id);
                    if (context.mounted) Navigator.pop(context);
                  },
                  icon: const Icon(Icons.delete_outline_rounded),
                  label: const Text('Delete task'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: QColors.error,
                  ),
                ),
              ],
            ),
    );
  }
}

class CalendarDayScreen extends StatelessWidget {
  const CalendarDayScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final events = const [
      ('9:00 AM', 'Reply to emails', 'Email Agent'),
      ('10:30 AM', 'Team stand-up', 'Ooma HQ'),
      ('11:00 AM', 'Prepare design review', 'Conference Room B'),
      ('12:30 PM', 'Lunch with Mike', 'Ooma Cafe, SoHo'),
      ('2:30 PM', 'Design Review', 'Conference Room B'),
      ('4:00 PM', 'Coffee with Sarah', 'Ooma Cafe, SoHo'),
    ];
    return Scaffold(
      appBar: AppBar(
        title: const Text('May 23'),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.calendar_month_rounded),
          ),
        ],
      ),
      bottomNavigationBar: const QeonBottomNav(selectedIndex: 1),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              for (final d in const [
                ('M', '20'),
                ('T', '21'),
                ('W', '22'),
                ('T', '23'),
                ('F', '24'),
                ('S', '25'),
                ('S', '26'),
              ])
                Column(
                  children: [
                    Text(
                      d.$1,
                      style: const TextStyle(
                        color: QColors.subtext,
                        fontSize: 11,
                      ),
                    ),
                    const SizedBox(height: 7),
                    Container(
                      width: 36,
                      height: 36,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: d.$2 == '23'
                            ? QColors.accent
                            : Colors.transparent,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        d.$2,
                        style: TextStyle(
                          color: d.$2 == '23' ? Colors.white : QColors.text,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
            ],
          ),
          const SizedBox(height: 18),
          ...events.map(
            (e) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 68,
                    child: Text(
                      e.$1,
                      style: const TextStyle(
                        color: QColors.subtext,
                        fontSize: 11.5,
                      ),
                    ),
                  ),
                  Expanded(
                    child: SurfaceCard(
                      padding: const EdgeInsets.all(13),
                      color: e.$1 == '11:00 AM'
                          ? QColors.accentSoft
                          : QColors.surface,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            e.$2,
                            style: const TextStyle(fontWeight: FontWeight.w800),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            e.$3,
                            style: const TextStyle(
                              color: QColors.subtext,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ActivityScreen extends ConsumerStatefulWidget {
  const ActivityScreen({super.key});

  @override
  ConsumerState<ActivityScreen> createState() => _ActivityScreenState();
}

class _ActivityScreenState extends ConsumerState<ActivityScreen> {
  bool loading = true;
  String? error;
  List<Map<String, dynamic>> activity = const [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      loading = true;
      error = null;
    });
    try {
      final rows = await ref.read(apiClientProvider).listActivity();
      if (!mounted) return;
      setState(() {
        activity = rows;
        loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        loading = false;
        error = 'Could not load your security activity.';
      });
    }
  }

  String _title(String action) {
    const titles = {
      'gmail.connected': 'Gmail connected',
      'gmail.disconnected': 'Gmail disconnected',
      'gmail.draft_created': 'Email draft created',
      'gmail.draft_approved_and_sent': 'Email approved and sent',
      'task.created': 'Task created',
      'task.deleted': 'Task deleted',
      'memory.created': 'Memory saved',
      'memory.deleted': 'Memory deleted',
      'memory.cleared': 'Memory cleared',
      'conversation.deleted': 'Conversation deleted',
    };
    return titles[action] ?? 'Account activity';
  }

  IconData _icon(String action) {
    if (action.startsWith('gmail.')) return Icons.mail_outline_rounded;
    if (action.startsWith('task.')) return Icons.check_box_outlined;
    if (action.startsWith('memory.')) return Icons.memory_rounded;
    if (action.startsWith('conversation.')) return Icons.chat_bubble_outline;
    return Icons.shield_outlined;
  }

  String _time(String? raw) {
    final value = DateTime.tryParse(raw ?? '')?.toLocal();
    if (value == null) return '';
    final hour = value.hour % 12 == 0 ? 12 : value.hour % 12;
    final minute = value.minute.toString().padLeft(2, '0');
    return '$hour:$minute ${value.hour >= 12 ? 'PM' : 'AM'}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Activity'),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            onPressed: _load,
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      bottomNavigationBar: const QeonBottomNav(selectedIndex: 3),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : error != null
          ? Center(
              child: OutlinedButton(onPressed: _load, child: Text(error!)),
            )
          : activity.isEmpty
          ? const Center(
              child: Text(
                'Security-relevant actions will appear here.',
                style: TextStyle(color: QColors.subtext),
              ),
            )
          : RefreshIndicator(
              onRefresh: _load,
              child: ListView.separated(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                itemCount: activity.length,
                separatorBuilder: (_, _) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final item = activity[index];
                  final action = item['action'] as String? ?? '';
                  return ListRow(
                    icon: _icon(action),
                    title: _title(action),
                    subtitle: 'Recorded securely without message contents',
                    trailing: _time(item['created_at'] as String?),
                    greenDot: true,
                  );
                },
              ),
            ),
    );
  }
}

// -----------------------------------------------------------------------------
// 04. AGENTS & MEMORY
// -----------------------------------------------------------------------------

class AgentData {
  final String name;
  final IconData icon;
  final String description;
  final List<String> abilities;
  final List<String> prompts;

  const AgentData({
    required this.name,
    required this.icon,
    required this.description,
    required this.abilities,
    required this.prompts,
  });

  static const research = AgentData(
    name: 'Research Agent',
    icon: Icons.search_rounded,
    description:
        'Finds, analyzes, and summarizes credible information from the web.',
    abilities: [
      'Research any topic or question',
      'Compare ideas, products, or trends',
      'Summarize long articles or reports',
      'Extract key insights and sources',
    ],
    prompts: [
      'Research the future of renewable energy',
      'Compare iPhone and Galaxy',
      'Summarize this article for me',
    ],
  );

  static const email = AgentData(
    name: 'Email Agent',
    icon: Icons.mail_outline_rounded,
    description:
        'Summarizes, drafts, and helps you manage your email effortlessly.',
    abilities: [
      'Summarize unread emails',
      'Search Gmail metadata',
      'Create Gmail drafts',
      'Send only after your approval',
    ],
    prompts: [
      'Summarize my unread emails',
      'Draft a reply to this email',
      'Find emails from John last week',
    ],
  );

  static const calendar = AgentData(
    name: 'Calendar Agent',
    icon: Icons.calendar_month_rounded,
    description: 'Helps you manage your schedule and never miss what matters.',
    abilities: [
      'Show today’s or upcoming events',
      'Reschedule or plan meetings',
      'Find time for focused work',
      'Set reminders and follow-ups',
    ],
    prompts: [
      'What’s on my schedule today?',
      'Find time to meet next week',
      'Remind me to prep for the review',
    ],
  );

  static const jobs = AgentData(
    name: 'Jobs Agent',
    icon: Icons.work_outline_rounded,
    description: 'Find jobs, track applications, and prepare for interviews.',
    abilities: [
      'Find matching job opportunities',
      'Track applications',
      'Compare roles',
      'Prepare interview briefs',
    ],
    prompts: [
      'Find AI jobs',
      'Track my applications',
      'Prepare me for an interview',
    ],
  );

  static const finance = AgentData(
    name: 'Finance Agent',
    icon: Icons.account_balance_wallet_outlined,
    description: 'Track spending, budgets, and financial insights.',
    abilities: [
      'Review spending',
      'Build a budget',
      'Track goals',
      'Summarize cash flow',
    ],
    prompts: [
      'Show this month spending',
      'Create a budget',
      'Track my savings goal',
    ],
  );

  static const travel = AgentData(
    name: 'Travel Agent',
    icon: Icons.flight_takeoff_rounded,
    description: 'Plan trips, find options, and organize itineraries.',
    abilities: [
      'Plan itineraries',
      'Compare flights',
      'Organize bookings',
      'Prepare trip checklists',
    ],
    prompts: ['Plan a weekend trip', 'Compare flights', 'Build my itinerary'],
  );
}

class AgentsHubScreen extends StatelessWidget {
  const AgentsHubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final agents = const [
      AgentData.research,
      AgentData.email,
      AgentData.calendar,
      AgentData.jobs,
      AgentData.finance,
      AgentData.travel,
    ];
    return Scaffold(
      appBar: AppBar(
        title: const Text('Agents'),
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.add_rounded)),
        ],
      ),
      bottomNavigationBar: const QeonBottomNav(selectedIndex: 2),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        children: [
          const Text(
            'Your specialized\nagents',
            style: TextStyle(
              fontSize: 32,
              height: 1.04,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Each agent is an expert in its field, ready to help you get more done.',
            style: TextStyle(color: QColors.subtext, height: 1.5),
          ),
          const SizedBox(height: 22),
          SurfaceCard(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            child: Column(
              children: [
                for (int i = 0; i < agents.length; i++) ...[
                  ListRow(
                    icon: agents[i].icon,
                    title: agents[i].name,
                    subtitle: agents[i].description,
                    trailing: agents[i].name == 'Email Agent'
                        ? 'Ready'
                        : 'Coming soon',
                    onTap: () =>
                        qPush(context, AgentDetailScreen(agent: agents[i])),
                  ),
                  if (i != agents.length - 1) const Divider(height: 1),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class AgentDetailScreen extends StatelessWidget {
  final AgentData agent;
  const AgentDetailScreen({super.key, required this.agent});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(agent.name),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.more_horiz_rounded),
          ),
        ],
      ),
      bottomNavigationBar: const QeonBottomNav(selectedIndex: 2),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 6, 20, 28),
        children: [
          Center(child: AgentIcon(agent.icon, size: 76)),
          const SizedBox(height: 18),
          Text(
            agent.name,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          Text(
            agent.description,
            textAlign: TextAlign.center,
            style: const TextStyle(color: QColors.subtext, height: 1.5),
          ),
          const SizedBox(height: 28),
          const SectionHeader(title: 'You can ask me to'),
          SurfaceCard(
            child: Column(
              children: agent.abilities.map((e) => _CheckLine(e)).toList(),
            ),
          ),
          const SizedBox(height: 24),
          const SectionHeader(title: 'Example prompts'),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: agent.prompts.map((e) => MiniBadge(e)).toList(),
          ),
          const SizedBox(height: 28),
          ElevatedButton(
            onPressed: agent.name == 'Email Agent'
                ? () => qPush(context, const EmailAgentScreen())
                : null,
            child: Text(
              agent.name == 'Email Agent' ? 'Open Email Agent' : 'Coming soon',
            ),
          ),
        ],
      ),
    );
  }
}

class MemoryOverviewScreen extends ConsumerWidget {
  const MemoryOverviewScreen({super.key});

  Future<void> _clear(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear all memory?'),
        content: const Text(
          'All saved personal context will be permanently deleted.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Clear memory'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await ref.read(memoriesProvider.notifier).clear();
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final memories = ref.watch(memoriesProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Memory'),
        actions: [
          IconButton(
            tooltip: 'Add memory',
            onPressed: () => showModalBottomSheet<void>(
              context: context,
              isScrollControlled: true,
              useSafeArea: true,
              backgroundColor: Colors.transparent,
              builder: (_) => const NewMemorySheet(),
            ),
            icon: const Icon(Icons.add_rounded),
          ),
        ],
      ),
      bottomNavigationBar: const QeonBottomNav(selectedIndex: 2),
      body: memories.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) => Center(
          child: OutlinedButton(
            onPressed: () => ref.invalidate(memoriesProvider),
            child: const Text('Try again'),
          ),
        ),
        data: (items) => ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          children: [
            const Text(
              'Only the memories shown here are stored for personalization. You can delete any item at any time.',
              style: TextStyle(color: QColors.subtext, height: 1.5),
            ),
            const SizedBox(height: 18),
            if (items.isEmpty)
              const SurfaceCard(
                child: Text(
                  'No memories saved.',
                  style: TextStyle(color: QColors.subtext),
                ),
              )
            else
              SurfaceCard(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                child: Column(
                  children: [
                    for (var index = 0; index < items.length; index++) ...[
                      ListRow(
                        icon: Icons.memory_rounded,
                        title: items[index].title,
                        subtitle: items[index].value,
                        trailing: items[index].category,
                        onTap: () => qPush(
                          context,
                          MemoryDetailScreen(memoryId: items[index].id),
                        ),
                      ),
                      if (index != items.length - 1) const Divider(height: 1),
                    ],
                  ],
                ),
              ),
            const SizedBox(height: 18),
            SurfaceCard(
              color: QColors.accentSoft,
              child: const ListRow(
                icon: Icons.shield_outlined,
                title: 'Your memory, your control',
                subtitle:
                    'Qeon AI does not silently add mailbox content to memory.',
              ),
            ),
            if (items.isNotEmpty) ...[
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: () => _clear(context, ref),
                icon: const Icon(Icons.delete_sweep_outlined),
                label: const Text('Clear all memory'),
                style: OutlinedButton.styleFrom(foregroundColor: QColors.error),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class NewMemorySheet extends ConsumerStatefulWidget {
  const NewMemorySheet({super.key});

  @override
  ConsumerState<NewMemorySheet> createState() => _NewMemorySheetState();
}

class _NewMemorySheetState extends ConsumerState<NewMemorySheet> {
  final category = TextEditingController(text: 'Preference');
  final title = TextEditingController();
  final value = TextEditingController();
  bool saving = false;

  @override
  void dispose() {
    category.dispose();
    title.dispose();
    value.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (title.text.trim().length < 2 || value.text.trim().isEmpty || saving) {
      return;
    }
    setState(() => saving = true);
    try {
      await ref
          .read(memoriesProvider.notifier)
          .add(
            category: category.text.trim(),
            title: title.text.trim(),
            value: value.text.trim(),
          );
      if (mounted) Navigator.pop(context);
    } catch (_) {
      if (!mounted) return;
      setState(() => saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not save the memory.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return _BottomSheetShell(
      title: 'Add memory',
      children: [
        TextField(
          controller: category,
          decoration: const InputDecoration(labelText: 'Category'),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: title,
          decoration: const InputDecoration(labelText: 'Title'),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: value,
          minLines: 2,
          maxLines: 5,
          decoration: const InputDecoration(
            labelText: 'What should Qeon AI remember?',
          ),
        ),
        const SizedBox(height: 14),
        ElevatedButton(
          onPressed: saving ? null : _save,
          child: Text(saving ? 'Saving…' : 'Save memory'),
        ),
      ],
    );
  }
}

class MemoryDetailScreen extends ConsumerWidget {
  const MemoryDetailScreen({super.key, required this.memoryId});

  final String memoryId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final items = ref.watch(memoriesProvider).asData?.value ?? const [];
    final matches = items.where((memory) => memory.id == memoryId);
    final memory = matches.isEmpty ? null : matches.first;
    return Scaffold(
      appBar: AppBar(title: const Text('Memory Detail')),
      body: memory == null
          ? const Center(child: Text('Memory not found.'))
          : ListView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
              children: [
                ListRow(
                  icon: Icons.memory_rounded,
                  title: memory.title,
                  subtitle: memory.category,
                ),
                const SizedBox(height: 18),
                SurfaceCard(
                  child: Text(
                    memory.value,
                    style: const TextStyle(height: 1.5),
                  ),
                ),
                const SizedBox(height: 22),
                OutlinedButton.icon(
                  onPressed: () async {
                    await ref.read(memoriesProvider.notifier).delete(memory.id);
                    if (context.mounted) Navigator.pop(context);
                  },
                  icon: const Icon(Icons.delete_outline_rounded),
                  label: const Text('Delete memory'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: QColors.error,
                  ),
                ),
              ],
            ),
    );
  }
}

// -----------------------------------------------------------------------------
// 05. PROFILE, CONNECTIONS & SETTINGS
// -----------------------------------------------------------------------------

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authStateProvider).asData?.value;
    final name = user?.displayName?.trim().isNotEmpty == true
        ? user!.displayName!.trim()
        : 'Qeon user';
    final initials = name
        .split(' ')
        .where((part) => part.isNotEmpty)
        .take(2)
        .map((part) => part[0].toUpperCase())
        .join();
    return Scaffold(
      appBar: AppBar(title: const Text('You')),
      bottomNavigationBar: const QeonBottomNav(selectedIndex: 4),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
        children: [
          const SizedBox(height: 10),
          Center(
            child: CircleAvatar(
              radius: 50,
              backgroundColor: QColors.accentSoft,
              child: Text(
                initials,
                style: const TextStyle(
                  fontSize: 28,
                  color: QColors.accent,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            name,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 4),
          Text(
            user?.email ?? '',
            textAlign: TextAlign.center,
            style: const TextStyle(color: QColors.subtext),
          ),
          const SizedBox(height: 24),
          SurfaceCard(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            child: Column(
              children: [
                ListRow(
                  icon: Icons.memory_rounded,
                  title: 'Memory',
                  subtitle: 'Review and delete saved personal context',
                  onTap: () => qPush(context, const MemoryOverviewScreen()),
                ),
                const Divider(height: 1),
                ListRow(
                  icon: Icons.link_rounded,
                  title: 'Connections',
                  subtitle: 'Manage Gmail permissions',
                  onTap: () => qPush(context, const ConnectionsScreen()),
                ),
                const Divider(height: 1),
                ListRow(
                  icon: Icons.history_rounded,
                  title: 'Conversation history',
                  subtitle: 'Open or delete saved chats',
                  onTap: () =>
                      qPush(context, const ConversationHistoryScreen()),
                ),
                const Divider(height: 1),
                ListRow(
                  icon: Icons.shield_outlined,
                  title: 'Privacy & permissions',
                  subtitle: 'Approval rules and data deletion',
                  onTap: () => qPush(context, const PermissionsScreen()),
                ),
                const Divider(height: 1),
                ListRow(
                  icon: Icons.receipt_long_outlined,
                  title: 'Security activity',
                  subtitle: 'Review account and agent actions',
                  onTap: () => qPush(context, const ActivityScreen()),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          OutlinedButton.icon(
            onPressed: () async {
              await ref.read(authServiceProvider).signOut();
              if (context.mounted) qReplace(context, const SignInScreen());
            },
            icon: const Icon(Icons.logout_rounded),
            label: const Text('Sign out'),
            style: OutlinedButton.styleFrom(foregroundColor: QColors.error),
          ),
        ],
      ),
    );
  }
}

class ConnectionsScreen extends ConsumerStatefulWidget {
  const ConnectionsScreen({super.key});

  @override
  ConsumerState<ConnectionsScreen> createState() => _ConnectionsScreenState();
}

class _ConnectionsScreenState extends ConsumerState<ConnectionsScreen> {
  bool loading = true;
  bool connected = false;
  String? email;
  String? error;

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  Future<void> _refresh() async {
    try {
      final status = await ref.read(apiClientProvider).gmailStatus();
      if (!mounted) return;
      setState(() {
        loading = false;
        connected = status['connected'] as bool? ?? false;
        email = status['email'] as String?;
        error = null;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        loading = false;
        error = 'Could not check the Gmail connection.';
      });
    }
  }

  Future<void> _connect() async {
    final consented = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => const existing_connections.GmailConsentSheet(),
    );
    if (consented != true || !mounted) return;
    setState(() {
      loading = true;
      error = null;
    });
    try {
      final url = await ref.read(apiClientProvider).connectGmail();
      final opened = await launchUrl(url, mode: LaunchMode.externalApplication);
      if (!opened) throw StateError('Could not open Google consent.');
      if (!mounted) return;
      setState(() => loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Finish Google consent, then return to Qeon AI.'),
        ),
      );
    } catch (_) {
      if (!mounted) return;
      setState(() {
        loading = false;
        error = 'Could not start Gmail connection.';
      });
    }
  }

  Future<void> _disconnect() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Disconnect Gmail?'),
        content: const Text(
          'Qeon AI will revoke access and remove the stored Gmail credential.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Disconnect'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    setState(() => loading = true);
    try {
      await ref.read(apiClientProvider).disconnectGmail();
      await _refresh();
    } catch (_) {
      if (!mounted) return;
      setState(() {
        loading = false;
        error = 'Could not disconnect Gmail.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Connections'),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            onPressed: _refresh,
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      bottomNavigationBar: const QeonBottomNav(selectedIndex: 4),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 6, 20, 24),
        children: [
          const Text(
            'Connected services are private to your Qeon AI account and can be revoked at any time.',
            style: TextStyle(color: QColors.subtext, height: 1.5),
          ),
          const SizedBox(height: 22),
          const SectionHeader(title: 'Email'),
          SurfaceCard(
            child: Column(
              children: [
                ListRow(
                  icon: Icons.mail_outline_rounded,
                  title: 'Gmail',
                  subtitle: connected
                      ? email ?? 'Connected Google account'
                      : 'Search, summarize, and prepare drafts',
                  trailing: connected ? 'Connected' : 'Connect',
                  greenDot: connected,
                  onTap: loading
                      ? null
                      : connected
                      ? () => qPush(context, const EmailAgentScreen())
                      : _connect,
                ),
                if (connected) ...[
                  const Divider(height: 1),
                  ListRow(
                    icon: Icons.link_off_rounded,
                    title: 'Disconnect Gmail',
                    subtitle: 'Revoke Google access and remove the token',
                    onTap: _disconnect,
                  ),
                ],
              ],
            ),
          ),
          if (loading) ...[
            const SizedBox(height: 18),
            const Center(child: CircularProgressIndicator()),
          ],
          if (error != null) ...[
            const SizedBox(height: 14),
            Text(error!, style: const TextStyle(color: QColors.error)),
          ],
          const SizedBox(height: 22),
          const SurfaceCard(
            color: QColors.accentSoft,
            child: ListRow(
              icon: Icons.verified_user_outlined,
              title: 'Approval controlled',
              subtitle:
                  'Qeon AI never sends email until you review and explicitly approve the draft.',
            ),
          ),
        ],
      ),
    );
  }
}

class EmailAgentScreen extends ConsumerStatefulWidget {
  const EmailAgentScreen({super.key});

  @override
  ConsumerState<EmailAgentScreen> createState() => _EmailAgentScreenState();
}

class _EmailAgentScreenState extends ConsumerState<EmailAgentScreen> {
  final search = TextEditingController(text: 'in:inbox');
  bool loading = true;
  bool connected = false;
  bool working = false;
  String? email;
  String? summary;
  String? error;
  List<Map<String, dynamic>> messages = const [];

  @override
  void initState() {
    super.initState();
    _status();
  }

  @override
  void dispose() {
    search.dispose();
    super.dispose();
  }

  Future<void> _status() async {
    try {
      final result = await ref.read(apiClientProvider).gmailStatus();
      if (!mounted) return;
      setState(() {
        loading = false;
        connected = result['connected'] as bool? ?? false;
        email = result['email'] as String?;
        error = null;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        loading = false;
        error = 'Could not check Gmail.';
      });
    }
  }

  Future<void> _summarize() async {
    setState(() {
      working = true;
      error = null;
    });
    try {
      final result = await ref.read(apiClientProvider).summarizeGmail();
      if (!mounted) return;
      setState(() => summary = result['summary'] as String? ?? '');
    } catch (_) {
      if (mounted) setState(() => error = 'Could not summarize Gmail.');
    } finally {
      if (mounted) setState(() => working = false);
    }
  }

  Future<void> _search() async {
    final query = search.text.trim();
    if (query.isEmpty) return;
    setState(() {
      working = true;
      error = null;
    });
    try {
      final rows = await ref.read(apiClientProvider).searchGmail(query);
      if (!mounted) return;
      setState(() => messages = rows);
    } catch (_) {
      if (mounted) setState(() => error = 'Could not search Gmail.');
    } finally {
      if (mounted) setState(() => working = false);
    }
  }

  Future<void> _compose() async {
    final draft = await showModalBottomSheet<Map<String, String>>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => const existing_email.GmailComposeSheet(),
    );
    if (draft == null || !mounted) return;
    setState(() => working = true);
    try {
      final api = ref.read(apiClientProvider);
      final created = await api.createGmailDraft(
        to: draft['to']!,
        cc: draft['cc'],
        subject: draft['subject']!,
        body: draft['body']!,
      );
      if (!mounted) return;
      final sent = await showModalBottomSheet<bool>(
        context: context,
        isScrollControlled: true,
        useSafeArea: true,
        builder: (_) => existing_email.EmailDraftReviewSheet(
          draft: created,
          onApprove: () =>
              api.sendApprovedGmailDraft(created['approval_id'] as String),
        ),
      );
      if (sent == true && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Email sent after your approval.')),
        );
      }
    } catch (_) {
      if (mounted) {
        setState(() => error = 'Could not create or send the Gmail draft.');
      }
    } finally {
      if (mounted) setState(() => working = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Email Agent'),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            onPressed: _status,
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
              children: [
                SurfaceCard(
                  color: connected ? const Color(0xFFE8F7F0) : null,
                  child: ListRow(
                    icon: connected
                        ? Icons.mark_email_read_rounded
                        : Icons.link_off_rounded,
                    title: connected
                        ? 'Gmail connected'
                        : 'Connect Gmail first',
                    subtitle: connected
                        ? email ?? 'Connected Google account'
                        : 'Open Connections to grant Gmail access.',
                    greenDot: connected,
                    onTap: connected
                        ? null
                        : () => qPush(context, const ConnectionsScreen()),
                  ),
                ),
                if (error != null) ...[
                  const SizedBox(height: 12),
                  Text(error!, style: const TextStyle(color: QColors.error)),
                ],
                if (connected) ...[
                  const SizedBox(height: 22),
                  const SectionHeader(title: 'Unread briefing'),
                  SurfaceCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          summary ??
                              'Summarize unread messages and highlight requests, deadlines, and replies you owe.',
                          style: const TextStyle(height: 1.5),
                        ),
                        const SizedBox(height: 14),
                        ElevatedButton.icon(
                          onPressed: working ? null : _summarize,
                          icon: const Icon(Icons.auto_awesome_rounded),
                          label: const Text('Summarize unread'),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 22),
                  const SectionHeader(title: 'Search Gmail'),
                  TextField(
                    controller: search,
                    textInputAction: TextInputAction.search,
                    onSubmitted: (_) => _search(),
                    decoration: InputDecoration(
                      hintText: 'from:person@example.com is:unread',
                      prefixIcon: const Icon(Icons.search_rounded),
                      suffixIcon: IconButton(
                        onPressed: working ? null : _search,
                        icon: const Icon(Icons.arrow_forward_rounded),
                      ),
                    ),
                  ),
                  if (messages.isNotEmpty) ...[
                    const SizedBox(height: 14),
                    SurfaceCard(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      child: Column(
                        children: [
                          for (
                            var index = 0;
                            index < messages.length;
                            index++
                          ) ...[
                            ListRow(
                              icon: messages[index]['unread'] == true
                                  ? Icons.mark_email_unread_outlined
                                  : Icons.mail_outline_rounded,
                              title:
                                  messages[index]['subject'] as String? ??
                                  '(no subject)',
                              subtitle:
                                  messages[index]['sender'] as String? ?? '',
                            ),
                            if (index != messages.length - 1)
                              const Divider(height: 1),
                          ],
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 22),
                  ElevatedButton.icon(
                    key: const Key('complete-ui-compose-email'),
                    onPressed: working ? null : _compose,
                    icon: const Icon(Icons.edit_outlined),
                    label: const Text('Compose with approval'),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Drafting does not send. You must review the exact recipients, subject, and body before Approve and send becomes available.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: QColors.subtext,
                      fontSize: 12,
                      height: 1.4,
                    ),
                  ),
                ],
              ],
            ),
    );
  }
}

class GmailConnectionCompleteScreen extends ConsumerStatefulWidget {
  const GmailConnectionCompleteScreen({super.key});

  @override
  ConsumerState<GmailConnectionCompleteScreen> createState() =>
      _GmailConnectionCompleteScreenState();
}

class _GmailConnectionCompleteScreenState
    extends ConsumerState<GmailConnectionCompleteScreen> {
  bool loading = true;
  bool connected = false;
  String? email;

  @override
  void initState() {
    super.initState();
    _confirm();
  }

  Future<void> _confirm() async {
    try {
      final result = await ref.read(apiClientProvider).gmailStatus();
      if (!mounted) return;
      setState(() {
        loading = false;
        connected = result['connected'] as bool? ?? false;
        email = result['email'] as String?;
      });
    } catch (_) {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const QLogo(size: 54, withTile: true),
                const SizedBox(height: 24),
                if (loading)
                  const CircularProgressIndicator()
                else
                  Icon(
                    connected
                        ? Icons.mark_email_read_rounded
                        : Icons.error_outline_rounded,
                    size: 58,
                    color: connected ? QColors.success : QColors.error,
                  ),
                const SizedBox(height: 16),
                Text(
                  loading
                      ? 'Confirming Gmail…'
                      : connected
                      ? 'Gmail connected'
                      : 'Connection not confirmed',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  connected
                      ? '${email ?? 'Your Gmail account'} is ready for the Email Agent.'
                      : 'Finish Google consent and check again.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: QColors.subtext),
                ),
                const SizedBox(height: 22),
                if (connected)
                  ElevatedButton(
                    onPressed: () =>
                        qReplace(context, const EmailAgentScreen()),
                    child: const Text('Open Email Agent'),
                  )
                else if (!loading)
                  OutlinedButton(
                    onPressed: _confirm,
                    child: const Text('Check again'),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class PreferencesScreen extends StatefulWidget {
  const PreferencesScreen({super.key});

  @override
  State<PreferencesScreen> createState() => _PreferencesScreenState();
}

class _PreferencesScreenState extends State<PreferencesScreen> {
  bool task = true;
  bool email = true;
  bool agent = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Preferences')),
      bottomNavigationBar: const QeonBottomNav(selectedIndex: 4),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 6, 20, 24),
        children: [
          const SectionHeader(title: 'General'),
          const SurfaceCard(
            child: Column(
              children: [
                _SettingLine('Language', 'English (US)'),
                Divider(height: 1),
                _SettingLine('Time zone', '(GMT-7) Pacific Time'),
                Divider(height: 1),
                _SettingLine('Date format', 'MMM D, YYYY'),
                Divider(height: 1),
                _SettingLine('Start week on', 'Monday'),
              ],
            ),
          ),
          const SizedBox(height: 22),
          const SectionHeader(title: 'Notifications'),
          SurfaceCard(
            child: Column(
              children: [
                _SwitchLine(
                  'Task reminders',
                  task,
                  (v) => setState(() => task = v),
                ),
                const Divider(height: 1),
                _SwitchLine(
                  'Email summaries',
                  email,
                  (v) => setState(() => email = v),
                ),
                const Divider(height: 1),
                _SwitchLine(
                  'Agent updates',
                  agent,
                  (v) => setState(() => agent = v),
                ),
              ],
            ),
          ),
          const SizedBox(height: 22),
          const SectionHeader(title: 'App'),
          const SurfaceCard(
            child: Column(
              children: [
                _SettingLine('Default view', 'Tasks'),
                Divider(height: 1),
                _SettingLine('Items per page', '20'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SettingLine extends StatelessWidget {
  final String title;
  final String value;
  const _SettingLine(this.title, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 13),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          Text(
            value,
            style: const TextStyle(color: QColors.subtext, fontSize: 12.5),
          ),
          const SizedBox(width: 4),
          const Icon(
            Icons.chevron_right_rounded,
            color: QColors.muted,
            size: 19,
          ),
        ],
      ),
    );
  }
}

class _SwitchLine extends StatelessWidget {
  final String title;
  final bool value;
  final ValueChanged<bool> onChanged;
  const _SwitchLine(this.title, this.value, this.onChanged);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
        Switch(value: value, onChanged: onChanged),
      ],
    );
  }
}

class PermissionsScreen extends ConsumerWidget {
  const PermissionsScreen({super.key});

  Future<void> _deleteData(BuildContext context, WidgetRef ref) async {
    final controller = TextEditingController();
    var enabled = false;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Delete all Qeon AI data?'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'This permanently deletes conversations, tasks, memory, Gmail credentials, drafts, and activity. Type DELETE to continue.',
              ),
              const SizedBox(height: 14),
              TextField(
                key: const Key('complete-ui-delete-confirmation'),
                controller: controller,
                onChanged: (value) =>
                    setDialogState(() => enabled = value == 'DELETE'),
                decoration: const InputDecoration(labelText: 'Type DELETE'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              key: const Key('complete-ui-delete-data'),
              onPressed: enabled ? () => Navigator.pop(context, true) : null,
              child: const Text('Delete my data'),
            ),
          ],
        ),
      ),
    );
    controller.dispose();
    if (confirmed != true) return;
    try {
      await ref.read(apiClientProvider).deleteMyData();
      await ref.read(authServiceProvider).signOut();
      if (context.mounted) qReplace(context, const SignInScreen());
    } catch (_) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not delete your data.')),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Permissions')),
      bottomNavigationBar: const QeonBottomNav(selectedIndex: 4),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        children: [
          const Center(child: AgentIcon(Icons.shield_outlined, size: 76)),
          const SizedBox(height: 16),
          const Text(
            'You’re in control',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 6),
          const Text(
            'Manage what Qeon AI can access and do on your behalf.',
            textAlign: TextAlign.center,
            style: TextStyle(color: QColors.subtext, height: 1.45),
          ),
          const SizedBox(height: 26),
          const SectionHeader(title: 'Agent actions'),
          const SurfaceCard(
            child: Column(
              children: [
                _SettingLine('Search and summarize Gmail', 'Allowed'),
                Divider(height: 1),
                _SettingLine('Create Gmail drafts', 'Allowed'),
                Divider(height: 1),
                _SettingLine('Send emails', 'Always ask first'),
              ],
            ),
          ),
          const SizedBox(height: 20),
          const SectionHeader(title: 'Data handling'),
          const SurfaceCard(
            child: Column(
              children: [
                _SettingLine('Conversation storage', 'Until you delete it'),
                Divider(height: 1),
                _SettingLine('Gmail message bodies', 'Not stored'),
                Divider(height: 1),
                _SettingLine('OAuth refresh token', 'Encrypted'),
              ],
            ),
          ),
          const SizedBox(height: 20),
          OutlinedButton.icon(
            onPressed: () => launchUrl(
              Uri.parse('https://qeonai.com/privacy/'),
              mode: LaunchMode.externalApplication,
            ),
            icon: const Icon(Icons.open_in_new_rounded),
            label: const Text('Read privacy policy'),
          ),
          const SizedBox(height: 10),
          OutlinedButton.icon(
            onPressed: () => qPush(context, const ActivityScreen()),
            icon: const Icon(Icons.receipt_long_outlined),
            label: const Text('View security activity'),
          ),
          const SizedBox(height: 10),
          OutlinedButton.icon(
            onPressed: () => _deleteData(context, ref),
            icon: const Icon(Icons.delete_forever_outlined),
            label: const Text('Delete all my data'),
            style: OutlinedButton.styleFrom(foregroundColor: QColors.error),
          ),
        ],
      ),
    );
  }
}

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      bottomNavigationBar: const QeonBottomNav(selectedIndex: 4),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 6, 20, 24),
        children: [
          const SectionHeader(title: 'Appearance'),
          SurfaceCard(
            child: Column(
              children: [
                const _SettingLine('Theme', 'Light'),
                const Divider(height: 1),
                Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Dark mode',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                    Switch(value: false, onChanged: (_) {}),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          const SectionHeader(title: 'Security'),
          const SurfaceCard(
            child: Column(
              children: [
                _SettingLine('Change password', ''),
                Divider(height: 1),
                _SettingLine('Two-factor authentication', 'On'),
                Divider(height: 1),
                _SettingLine('Active sessions', '3'),
              ],
            ),
          ),
          const SizedBox(height: 20),
          const SectionHeader(title: 'Support'),
          const SurfaceCard(
            child: Column(
              children: [
                _SettingLine('Help center', ''),
                Divider(height: 1),
                _SettingLine('Contact support', ''),
                Divider(height: 1),
                _SettingLine('Report an issue', ''),
              ],
            ),
          ),
          const SizedBox(height: 20),
          const SectionHeader(title: 'About'),
          const SurfaceCard(
            child: Column(
              children: [
                _SettingLine('Version', '1.2.0'),
                Divider(height: 1),
                _SettingLine('What’s new', ''),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const Center(
            child: Column(
              children: [
                QLogo(size: 30),
                SizedBox(height: 8),
                Text('Qeon AI', style: TextStyle(fontWeight: FontWeight.w800)),
                SizedBox(height: 3),
                Text(
                  'Personal agents that get things done.',
                  style: TextStyle(color: QColors.subtext, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
