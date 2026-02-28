import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class BentoHeroCard extends StatefulWidget {
  final int count;
  final String label;
  final IconData icon;
  final LinearGradient gradient;
  final VoidCallback? onTap;

  const BentoHeroCard({
    super.key,
    required this.count,
    required this.label,
    required this.icon,
    required this.gradient,
    this.onTap,
  });

  @override
  State<BentoHeroCard> createState() => _BentoHeroCardState();
}

class _BentoHeroCardState extends State<BentoHeroCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
    );
    _scaleAnim = Tween<double>(
      begin: 1.0,
      end: 0.96,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _ctrl.forward(),
      onTapUp: (_) {
        _ctrl.reverse();
        widget.onTap?.call();
      },
      onTapCancel: () => _ctrl.reverse(),
      child: AnimatedBuilder(
        animation: _scaleAnim,
        builder: (_, child) =>
            Transform.scale(scale: _scaleAnim.value, child: child),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 22),
          decoration: BoxDecoration(
            gradient: widget.gradient,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: widget.gradient.colors.first.withValues(alpha: 0.3),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.label,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.white.withValues(alpha: 0.85),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '${widget.count}',
                      style: GoogleFonts.montserrat(
                        fontSize: 42,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        height: 1.1,
                        letterSpacing: -1,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Icon(widget.icon, color: Colors.white, size: 28),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class BentoStatCard extends StatelessWidget {
  final int count;
  final String label;
  final IconData icon;
  final Color accentColor;
  final VoidCallback? onTap;

  const BentoStatCard({
    super.key,
    required this.count,
    required this.label,
    required this.icon,
    required this.accentColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: _themedCardDecoration(cs, isDark, radius: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: accentColor.withValues(alpha: isDark ? 0.2 : 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, size: 20, color: accentColor),
            ),
            const SizedBox(height: 12),
            Text(
              '$count',
              style: GoogleFonts.montserrat(
                fontSize: 28,
                fontWeight: FontWeight.w800,
                color: cs.onSurface,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: cs.onSurfaceVariant,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

class SoftAnalyticsCard extends StatefulWidget {
  final String label;
  final int count;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;

  const SoftAnalyticsCard({
    super.key,
    required this.label,
    required this.count,
    required this.icon,
    required this.color,
    this.onTap,
  });

  @override
  State<SoftAnalyticsCard> createState() => _SoftAnalyticsCardState();
}

class _SoftAnalyticsCardState extends State<SoftAnalyticsCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _scale = Tween(
      begin: 1.0,
      end: 0.97,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Expanded(
      child: GestureDetector(
        onTapDown: (_) => _ctrl.forward(),
        onTapUp: (_) {
          _ctrl.reverse();
          widget.onTap?.call();
        },
        onTapCancel: () => _ctrl.reverse(),
        child: AnimatedBuilder(
          animation: _scale,
          builder: (_, child) =>
              Transform.scale(scale: _scale.value, child: child),
          child: Container(
            decoration: _themedCardDecoration(cs, isDark, radius: 20),
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: widget.color.withValues(alpha: isDark ? 0.2 : 0.1),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(widget.icon, color: widget.color, size: 24),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${widget.count}',
                        style: GoogleFonts.montserrat(
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                          color: cs.onSurface,
                          letterSpacing: -0.5,
                          height: 1.1,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        widget.label,
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: cs.onSurfaceVariant,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                if (widget.onTap != null)
                  Icon(
                    Icons.chevron_right_rounded,
                    color: widget.color.withValues(alpha: 0.5),
                    size: 22,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

BoxDecoration _themedCardDecoration(
  ColorScheme cs,
  bool isDark, {
  double radius = 20,
}) {
  return BoxDecoration(
    color: isDark ? cs.surfaceContainerHigh : cs.surfaceContainerLowest,
    borderRadius: BorderRadius.circular(radius),
    border: Border.all(
      color: isDark
          ? cs.outlineVariant.withValues(alpha: 0.3)
          : cs.outlineVariant.withValues(alpha: 0.2),
    ),
    boxShadow: isDark
        ? []
        : [
            BoxShadow(
              color: const Color(0xFF000000).withValues(alpha: 0.04),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
            BoxShadow(
              color: const Color(0xFF000000).withValues(alpha: 0.02),
              blurRadius: 4,
              offset: const Offset(0, 1),
            ),
          ],
  );
}

BoxDecoration softCardDecoration({double radius = 20, Color? color}) {
  return BoxDecoration(
    color: color ?? Colors.white,
    borderRadius: BorderRadius.circular(radius),
    boxShadow: [
      BoxShadow(
        color: const Color(0xFF000000).withValues(alpha: 0.04),
        blurRadius: 24,
        offset: const Offset(0, 8),
      ),
      BoxShadow(
        color: const Color(0xFF000000).withValues(alpha: 0.02),
        blurRadius: 6,
        offset: const Offset(0, 2),
      ),
    ],
  );
}
