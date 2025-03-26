import 'package:flutter/material.dart';

class PreferencesCard extends StatefulWidget {
  final List<String> dietaryPreferences;
  final List<String> allergies;
  final Map<String, bool> healthGoals;

  const PreferencesCard({
    super.key,
    required this.dietaryPreferences,
    required this.allergies,
    required this.healthGoals,
  });

  @override
  State<PreferencesCard> createState() => _PreferencesCardState();
}

class _PreferencesCardState extends State<PreferencesCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF0A1128).withOpacity(0.7),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Theme.of(context).colorScheme.secondary.withOpacity(0.5),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.secondary.withOpacity(0.2),
            blurRadius: 15,
            spreadRadius: -2,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Dietary Preferences Section
          _buildSectionHeader(
            'DIETARY PREFERENCES',
            Icons.restaurant_menu,
            Theme.of(context).colorScheme.secondary,
          ),
          const SizedBox(height: 16),

          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              for (final preference in widget.dietaryPreferences)
                _buildTechChip(
                  preference,
                  Colors.teal,
                  Icon(
                    _getDietaryIcon(preference),
                    size: 14,
                    color: Colors.teal,
                  ),
                ),
            ],
          ),

          const SizedBox(height: 24),

          // Allergies Section
          _buildSectionHeader(
            'ALLERGIES',
            Icons.warning_amber_outlined,
            Colors.redAccent,
          ),
          const SizedBox(height: 16),

          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              if (widget.allergies.isEmpty)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF05102C),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: Colors.grey.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    'No allergies recorded',
                    style: TextStyle(
                      color: Colors.grey[400],
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                )
              else
                for (final allergy in widget.allergies)
                  _buildTechChip(
                    allergy,
                    Colors.redAccent,
                    const Icon(
                      Icons.dangerous_outlined,
                      size: 14,
                      color: Colors.redAccent,
                    ),
                  ),
            ],
          ),

          const SizedBox(height: 24),

          // Health Goals Section
          _buildSectionHeader(
            'HEALTH GOALS',
            Icons.fitness_center,
            Colors.cyanAccent[400]!,
          ),
          const SizedBox(height: 16),

          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            childAspectRatio: 2.8,
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              for (final entry in widget.healthGoals.entries)
                _buildGoalItem(
                  _formatGoalName(entry.key),
                  entry.value,
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon, Color color) {
    return Row(
      children: [
        AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: color
                        .withOpacity(0.1 + 0.1 * _animationController.value),
                    blurRadius: 10,
                    spreadRadius: 0.5 + _animationController.value,
                  ),
                ],
              ),
              child: Icon(
                icon,
                color: color,
                size: 18,
              ),
            );
          },
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: TextStyle(
            color: color,
            fontSize: 14,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildTechChip(String label, Color color, Icon leadingIcon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.2),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          leadingIcon,
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGoalItem(String goal, bool isActive) {
    final Color activeColor = Colors.cyanAccent[400]!;
    final Color inactiveColor = Colors.grey;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF05102C),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isActive
              ? activeColor.withOpacity(0.3)
              : inactiveColor.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color:
                  isActive ? activeColor.withOpacity(0.1) : Colors.transparent,
              border: Border.all(
                color: isActive ? activeColor : inactiveColor,
                width: 1.5,
              ),
            ),
            child: isActive
                ? Icon(
                    Icons.check,
                    size: 14,
                    color: activeColor,
                  )
                : null,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              goal,
              style: TextStyle(
                color: isActive ? Colors.white : Colors.white.withOpacity(0.5),
                fontSize: 12,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  String _formatGoalName(String key) {
    // Convert snake_case to Title Case
    return key
        .split('_')
        .map((word) => word[0].toUpperCase() + word.substring(1))
        .join(' ');
  }

  IconData _getDietaryIcon(String preference) {
    final lowercasePreference = preference.toLowerCase();

    if (lowercasePreference.contains('vegetarian')) {
      return Icons.eco;
    } else if (lowercasePreference.contains('vegan')) {
      return Icons.spa;
    } else if (lowercasePreference.contains('low carb')) {
      return Icons.grain;
    } else if (lowercasePreference.contains('high protein')) {
      return Icons.fitness_center;
    } else if (lowercasePreference.contains('keto')) {
      return Icons.no_food;
    } else if (lowercasePreference.contains('paleo')) {
      return Icons.egg_alt;
    } else if (lowercasePreference.contains('gluten')) {
      return Icons.do_not_disturb;
    } else {
      return Icons.restaurant;
    }
  }
}
