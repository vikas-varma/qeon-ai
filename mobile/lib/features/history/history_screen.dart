import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../core/widgets/qeon_components.dart';
import '../../data/mock_data.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return QeonPage(
      child: Column(
        children: [
          const ScreenHeader(
            title: 'History',
            subtitle: 'Your previous conversations.',
          ),
          const SizedBox(height: 15),
          const TextField(
            decoration: InputDecoration(
              hintText: 'Search conversations...',
              prefixIcon: Icon(Icons.search_rounded),
              suffixIcon: Icon(Icons.tune_rounded),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 40,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: const [
                Padding(
                  padding: EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text('All'),
                    selected: true,
                    onSelected: null,
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text('Pinned'),
                    selected: false,
                    onSelected: null,
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text('This week'),
                    selected: false,
                    onSelected: null,
                  ),
                ),
                ChoiceChip(
                  label: Text('This month'),
                  selected: false,
                  onSelected: null,
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: QeonCard(
              padding: EdgeInsets.zero,
              child: ListView.separated(
                itemCount: mockConversations.length,
                separatorBuilder: (_, _) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final item = mockConversations[index];
                  return ListTile(
                    onTap: () => context.push('/chat'),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 7,
                    ),
                    leading: CircleIcon(
                      icon: item.icon,
                      color: AppColors.primary,
                      size: 42,
                    ),
                    title: Text(
                      item.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                    subtitle: Text(item.time),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (item.pinned)
                          const Icon(
                            Icons.push_pin_rounded,
                            size: 17,
                            color: AppColors.warning,
                          ),
                        const Icon(Icons.chevron_right_rounded),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
