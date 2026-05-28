import "package:flutter/material.dart";
import "../../../../core/utils/constants.dart";
import "../../../../core/utils/responsive.dart";
import "../widgets/appbar.dart";
import "../widgets/buttons.dart";
import "../widgets/textfield.dart";
import "activity_page.dart";

class SavedLocationPage extends StatelessWidget {
  const SavedLocationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppAppBar(
        title: "Saved location",
        onBack: () {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (_) => const ActivityPage(),
            ),
          );
        },
      ),
      body: Padding(
        padding: Responsive.insetsLTRB(
          context,
          left: 16,
          top: 8,
          right: 16,
          bottom: 0,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _SearchField(),
            SizedBox(height: Responsive.size(context, 16)),
            _SetOnMapCard(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const SaveLocationMapPage(),
                  ),
                );
              },
            ),
            SizedBox(height: Responsive.size(context, 20)),
            const Text(
              "Favorites",
              style: TextStyle(
                fontFamily: AppFonts.saira,
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.black,
              ),
            ),
            SizedBox(height: Responsive.size(context, 12)),
            const Expanded(
              child: _FavoritesList(),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        minimum: Responsive.insetsLTRB(
          context,
          left: 16,
          top: 8,
          right: 16,
          bottom: 16,
        ),
        child: AppButton(
          label: "+ Add New Location",
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => const AddDestinationPage(),
              ),
            );
          },
          size: AppButtonSize.large,
        ),
      ),
    );
  }
}

class _SearchField extends StatelessWidget {
  const _SearchField({this.hintText = "Search location"});

  final String hintText;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
        BorderRadius.circular(Responsive.size(context, 14)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: Responsive.size(context, 16),
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: TextField(
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: const TextStyle(
            fontFamily: AppFonts.saira,
            fontSize: 14,
            color: AppColors.gray,
          ),
          prefixIcon: Icon(
            Icons.search,
            size: Responsive.size(context, 18),
          ),
          suffixIcon: Icon(
            Icons.mic,
            size: Responsive.size(context, 18),
          ),
          border: OutlineInputBorder(
            borderRadius:
            BorderRadius.circular(Responsive.size(context, 14)),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: Responsive.insetsSymmetric(
            context,
            horizontal: 16,
            vertical: 14,
          ),
        ),
      ),
    );
  }
}

class _SetOnMapCard extends StatelessWidget {
  const _SetOnMapCard({this.onTap});

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius:
      BorderRadius.circular(Responsive.size(context, 16)),
      child: InkWell(
        borderRadius:
        BorderRadius.circular(Responsive.size(context, 16)),
        onTap: onTap,
        child: Container(
          padding: Responsive.insetsAll(context, 14),
          decoration: BoxDecoration(
            borderRadius:
            BorderRadius.circular(Responsive.size(context, 16)),
            border: Border.all(color: AppColors.silver),
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: Responsive.size(context, 20),
                backgroundColor: AppColors.sky,
                child: Icon(
                  Icons.map_outlined,
                  color: AppColors.blue,
                  size: Responsive.size(context, 20),
                ),
              ),
              SizedBox(width: Responsive.size(context, 12)),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Set on map",
                      style: TextStyle(
                        fontFamily: AppFonts.saira,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.black,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      "Pin precise location manually",
                      style: TextStyle(
                        fontFamily: AppFonts.saira,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: AppColors.charcoal,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: AppColors.gray,
                size: Responsive.size(context, 20),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SaveLocationMapPage extends StatelessWidget {
  const SaveLocationMapPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppAppBar(
        title: "Save location",
      ),
      body: SafeArea(
        child: Padding(
          padding: Responsive.insetsLTRB(
            context,
            left: 16,
            top: 8,
            right: 16,
            bottom: 0,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius:
                BorderRadius.circular(Responsive.size(context, 16)),
                child: Image.asset(
                  "assets/images/map.jpg",
                  height: Responsive.size(context, 220),
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              SizedBox(height: Responsive.size(context, 20)),
              const Text(
                "Select label",
                style: TextStyle(
                  fontFamily: AppFonts.saira,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.black,
                ),
              ),
              SizedBox(height: Responsive.size(context, 12)),
              Wrap(
                spacing: Responsive.size(context, 10),
                runSpacing: Responsive.size(context, 10),
                children: const [
                  _LabelChip(
                    icon: Icons.home_outlined,
                    label: "Home",
                  ),
                  _LabelChip(
                    icon: Icons.work_outline,
                    label: "Work",
                  ),
                  _LabelChip(
                    icon: Icons.fitness_center_outlined,
                    label: "Gym",
                  ),
                  _LabelChip(
                    icon: Icons.add,
                    label: "Add",
                  ),
                ],
              ),
              SizedBox(height: Responsive.size(context, 20)),
              const Text(
                "Custom Name (optional)",
                style: TextStyle(
                  fontFamily: AppFonts.saira,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.black,
                ),
              ),
              SizedBox(height: Responsive.size(context, 8)),
              const AppTextField(
                label: "Name",
                hint: "e.g. Friend home",
                filled: true,
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        minimum: Responsive.insetsLTRB(
          context,
          left: 16,
          top: 8,
          right: 16,
          bottom: 16,
        ),
        child: AppButton(
          label: "Save Location",
          size: AppButtonSize.large,
          onPressed: () {
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(
                builder: (_) => const SavedLocationPage(),
              ),
                  (route) => false,
            );
          },
        ),
      ),
    );
  }
}

class _LabelChip extends StatelessWidget {
  const _LabelChip({
    required this.icon,
    required this.label,
  });

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: Responsive.insetsSymmetric(
        context,
        horizontal: 12,
        vertical: 10,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
        BorderRadius.circular(Responsive.size(context, 20)),
        border: Border.all(color: AppColors.silver),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: Responsive.size(context, 18),
            color: AppColors.blue,
          ),
          SizedBox(width: Responsive.size(context, 6)),
          Text(
            label,
            style: const TextStyle(
              fontFamily: AppFonts.saira,
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.black,
            ),
          ),
        ],
      ),
    );
  }
}

class AddDestinationPage extends StatelessWidget {
  const AddDestinationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppAppBar(
        title: "Add Destination",
      ),
      body: Padding(
        padding: Responsive.insetsLTRB(
          context,
          left: 16,
          top: 8,
          right: 16,
          bottom: 16,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _SearchField(hintText: "Search destination"),
            SizedBox(height: Responsive.size(context, 16)),
            _SetOnMapCard(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const SaveLocationMapPage(),
                  ),
                );
              },
            ),
            SizedBox(height: Responsive.size(context, 20)),
            const Text(
              "Recent Destination",
              style: TextStyle(
                fontFamily: AppFonts.saira,
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.black,
              ),
            ),
            SizedBox(height: Responsive.size(context, 12)),
            const Expanded(
              child: _RecentDestinationList(),
            ),
          ],
        ),
      ),
    );
  }
}

class _RecentDestinationList extends StatelessWidget {
  const _RecentDestinationList();

  static const _items = [
    _RecentDestinationItem(
      title: "Main Place",
      address: "12, Market Road, New York",
    ),
    _RecentDestinationItem(
      title: "City Center",
      address: "88, Broadway Street, New York",
    ),
    _RecentDestinationItem(
      title: "Union Square",
      address: "14, Union Ave, New York",
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      itemCount: _items.length,
      separatorBuilder: (_, index) => const Divider(
        height: 1,
        color: AppColors.silver,
      ),
      itemBuilder: (context, index) {
        final item = _items[index];
        return Padding(
          padding: Responsive.insetsSymmetric(
            context,
            vertical: 10,
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: Responsive.size(context, 18),
                backgroundColor: AppColors.lavender,
                child: Icon(
                  Icons.access_time,
                  color: AppColors.violet,
                  size: Responsive.size(context, 18),
                ),
              ),
              SizedBox(width: Responsive.size(context, 12)),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      style: const TextStyle(
                        fontFamily: AppFonts.saira,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.black,
                      ),
                    ),
                    SizedBox(height: Responsive.size(context, 4)),
                    Text(
                      item.address,
                      style: const TextStyle(
                        fontFamily: AppFonts.saira,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: AppColors.charcoal,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: AppColors.gray,
                size: Responsive.size(context, 20),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _RecentDestinationItem {
  const _RecentDestinationItem({
    required this.title,
    required this.address,
  });

  final String title;
  final String address;
}

class _FavoritesList extends StatelessWidget {
  const _FavoritesList();

  static const _items = [
    _FavoriteItem(
      title: "Home",
      address: "24, Green Street, New York",
    ),
    _FavoriteItem(
      title: "Office",
      address: "18, Market Road, New York",
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      itemCount: _items.length,
      separatorBuilder: (_, index) =>
          SizedBox(height: Responsive.size(context, 10)),
      itemBuilder: (context, index) {
        final item = _items[index];
        return Container(
          padding: Responsive.insetsAll(context, 14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius:
            BorderRadius.circular(Responsive.size(context, 14)),
            border: Border.all(color: AppColors.silver),
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: Responsive.size(context, 18),
                backgroundColor: AppColors.lavender,
                child: Icon(
                  Icons.home_outlined,
                  color: AppColors.violet,
                  size: Responsive.size(context, 18),
                ),
              ),
              SizedBox(width: Responsive.size(context, 12)),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      style: const TextStyle(
                        fontFamily: AppFonts.saira,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.black,
                      ),
                    ),
                    SizedBox(height: Responsive.size(context, 4)),
                    Text(
                      item.address,
                      style: const TextStyle(
                        fontFamily: AppFonts.saira,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: AppColors.charcoal,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: AppColors.gray,
                size: Responsive.size(context, 20),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _FavoriteItem {
  const _FavoriteItem({
    required this.title,
    required this.address,
  });

  final String title;
  final String address;
}
