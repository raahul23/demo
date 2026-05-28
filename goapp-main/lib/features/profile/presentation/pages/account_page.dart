import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/utils/snackbar_utils.dart';
import '../bloc/profile_bloc.dart';
import '../bloc/profile_state.dart';
import 'profile_setup_page.dart';
import '../../../activity/presentation/widgets/appbar.dart';

class AccountPage extends StatelessWidget {
  const AccountPage({super.key});

  @override
  Widget build(BuildContext context) {
    ProfileBloc? profileBloc;
    try {
      profileBloc = BlocProvider.of<ProfileBloc>(context, listen: false);
    } catch (_) {
      profileBloc = null;
    }
    if (profileBloc == null) {
      return Scaffold(
        appBar: const AppAppBar(
          title: 'Profile',
          showBack: false,
        ),
        body: _buildContent(
          context,
          name: 'Your Name',
          email: 'Tap to complete profile',
        ),
      );
    }
    return Scaffold(
      appBar: const AppAppBar(
        title: 'Profile',
        showBack: false,
      ),
      body: BlocBuilder<ProfileBloc, ProfileState>(
        builder: (context, state) {
          final name = state is ProfileSuccess ? state.profile.name : 'Your Name';
          final email = state is ProfileSuccess
              ? state.profile.email
              : 'Tap to complete profile';
          return _buildContent(
            context,
            name: name,
            email: email,
          );
        },
      ),
    );
  }

  Widget _buildContent(
    BuildContext context, {
    required String name,
    required String email,
  }) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      children: [
        _ProfileCard(
          name: name,
          email: email,
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => const ProfileSetupPage(allowBack: true),
              ),
            );
          },
        ),
        const SizedBox(height: 20),
        _SectionTitle(title: 'ACCOUNT'),
        const SizedBox(height: 8),
        _MenuCard(
          items: [
            _MenuItem(
              icon: Icons.history,
              title: 'My Rides',
            ),
            _MenuItem(
              icon: Icons.bookmark_border,
              title: 'Saved Locations',
            ),
            _MenuItem(
              icon: Icons.account_balance_wallet_outlined,
              title: 'Wallet',
            ),
            _MenuItem(
              icon: Icons.notifications_none,
              title: 'Notification',
            ),
            _MenuItem(
              icon: Icons.shield_outlined,
              title: 'Safety',
            ),
          ],
        ),
        const SizedBox(height: 20),
        _SectionTitle(title: 'BENEFITS'),
        const SizedBox(height: 8),
        _MenuCard(
          items: [
            _MenuItem(
              icon: Icons.star_border,
              title: 'Rewards',
            ),
            _MenuItem(
              icon: Icons.monetization_on_outlined,
              title: 'Coins Center',
            ),
            _MenuItem(
              icon: Icons.card_giftcard,
              title: 'Refer & Earn',
              subtitle: 'Get 100 coin',
            ),
          ],
        ),
      ],
    );
  }
}

class _ProfileCard extends StatelessWidget {
  const _ProfileCard({
    required this.name,
    required this.email,
    required this.onTap,
  });

  final String name;
  final String email;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(
              blurRadius: 12,
              color: Color(0x14000000),
              offset: Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            const CircleAvatar(
              radius: 26,
              backgroundColor: Color(0xFFE8EBF3),
              child: Icon(Icons.person, color: Colors.black54),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    email,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.black54,
                        ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.black45),
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: Theme.of(context).textTheme.labelMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: Colors.black45,
            letterSpacing: 0.6,
          ),
    );
  }
}

class _MenuCard extends StatelessWidget {
  const _MenuCard({required this.items});

  final List<_MenuItem> items;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            blurRadius: 10,
            color: Color(0x11000000),
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          for (var index = 0; index < items.length; index++)
            _MenuTile(
              item: items[index],
              showDivider: index != items.length - 1,
            ),
        ],
      ),
    );
  }
}

class _MenuItem {
  const _MenuItem({
    required this.icon,
    required this.title,
    this.subtitle,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
}

class _MenuTile extends StatelessWidget {
  const _MenuTile({required this.item, required this.showDivider});

  final _MenuItem item;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          leading: Icon(item.icon, color: Colors.black54),
          title: Text(item.title),
          subtitle: item.subtitle == null
              ? null
              : Text(
                  item.subtitle!,
                  style: Theme.of(context)
                      .textTheme
                      .labelSmall
                      ?.copyWith(color: Colors.black45),
                ),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {
            SnackBarUtils.show(context, 'Coming soon');
          },
        ),
        if (showDivider)
          const Divider(height: 1, thickness: 0.6),
      ],
    );
  }
}
