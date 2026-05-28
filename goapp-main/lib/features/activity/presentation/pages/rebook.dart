import "package:flutter/material.dart";
import "package:goapp/features/activity/presentation/pages/receipt.dart";
import "../../../../core/utils/constants.dart";
import "../../../../core/utils/date_time.dart";
import "../../../../core/utils/responsive.dart";
import "../widgets/appbar.dart";
import "../widgets/buttons.dart";
import "../widgets/minute_ticker.dart";

class RebookPage extends StatelessWidget {
  const RebookPage({
    super.key,
    this.status,
  });

  final String? status;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const AppAppBar(
        title: "Activity",
      ),
      body: MinuteTicker(
        builder: (now) => SingleChildScrollView(
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
              Stack(
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
                  Positioned(
                    right: Responsive.size(context, 12),
                    bottom: Responsive.size(context, 12),
                    child: FloatingActionButton.small(
                      onPressed: () {},
                      backgroundColor: Colors.white,
                      foregroundColor: AppColors.emerald,
                      child: Icon(
                        Icons.my_location,
                        size: Responsive.size(context, 18),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: Responsive.size(context, 16)),
              const Text(
                "VR Mall, Anna Nagar",
                style: TextStyle(
                  fontFamily: AppFonts.saira,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.black,
                ),
              ),
              SizedBox(height: Responsive.size(context, 4)),
              Row(
                children: [
                  Text(
                    DateTimeUtils.formatDateTime(now),
                    style: const TextStyle(
                      fontFamily: AppFonts.saira,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.charcoal,
                    ),
                  ),
                  SizedBox(width: Responsive.size(context, 8)),
                  const Text(
                    "• Cab",
                    style: TextStyle(
                      fontFamily: AppFonts.saira,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.charcoal,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: Responsive.insetsSymmetric(
                      context,
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _statusColor(status).withValues(alpha: 0.12),
                      borderRadius:
                      BorderRadius.circular(Responsive.size(context, 12)),
                    ),
                    child: Text(
                      status ?? "Completed",
                      style: TextStyle(
                        fontFamily: AppFonts.saira,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: _statusColor(status),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: Responsive.size(context, 16)),
              Container(
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
                      radius: Responsive.size(context, 22),
                      backgroundColor: AppColors.warmGray,
                      child: Icon(
                        Icons.person_outline,
                        color: AppColors.gray,
                        size: Responsive.size(context, 22),
                      ),
                    ),
                    SizedBox(width: Responsive.size(context, 12)),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Alex Johnson",
                            style: TextStyle(
                              fontFamily: AppFonts.saira,
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: AppColors.black,
                            ),
                          ),
                          SizedBox(height: Responsive.size(context, 4)),
                          Row(
                            children: [
                              Icon(
                                Icons.star,
                                color: AppColors.gold,
                                size: Responsive.size(context, 16),
                              ),
                              SizedBox(width: Responsive.size(context, 4)),
                              Text(
                                "4.9",
                                style: TextStyle(
                                  fontFamily: AppFonts.saira,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.charcoal,
                                ),
                              ),


                              SizedBox(width: Responsive.size(context, 4)),
                              Text(
                                "• (155 rides)",
                                style: TextStyle(
                                  fontFamily: AppFonts.saira,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.charcoal,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: Responsive.size(context, 16)),
              Container(
                padding: Responsive.insetsAll(context, 14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius:
                  BorderRadius.circular(Responsive.size(context, 14)),
                  border: Border.all(color: AppColors.silver),
                ),
                child: _PickupDropBlock(
                  pickupTime: DateTimeUtils.formatTime24(now),
                  dropTime: DateTimeUtils.formatTime24(now),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: Responsive.size(context, 16),
              offset: const Offset(0, -6),
            ),
          ],
        ),
        child: SafeArea(
          minimum: Responsive.insetsLTRB(
            context,
            left: 16,
            top: 12,
            right: 16,
            bottom: 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: double.infinity,
                child: AppButton(
                  label: "Rebook Ride",
                  size: AppButtonSize.large,
                  leading: Icon(
                    Icons.history,
                    size: Responsive.size(context, 18),
                  ),
                  onPressed: () {},
                ),
              ),
              SizedBox(height: Responsive.size(context, 10)),
              SizedBox(
                width: double.infinity,
                child: AppButton(
                  label: "Receipt",
                  size: AppButtonSize.large,
                  leading: Icon(
                    Icons.receipt_long,
                    size: Responsive.size(context, 18),
                  ),
                  backgroundColor: AppColors.warmGray,
                  foregroundColor: AppColors.black,
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => ReceiptPage(status: status),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Color _statusColor(String? status) {
  final normalized = (status ?? "completed").toLowerCase();
  if (normalized.contains("cancel")) return AppColors.red;
  return AppColors.green;
}

class _PickupDropBlock extends StatelessWidget {
  const _PickupDropBlock({
    required this.pickupTime,
    required this.dropTime,
  });

  final String pickupTime;
  final String dropTime;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _PickupDropRow(
          title: "Pickup location",
          subtitle: "Airport Terminal 2",
          time: pickupTime,
          color: AppColors.green,
          showLine: false,
        ),
        SizedBox(height: Responsive.size(context, 16)),
        _PickupDropRow(
          title: "Drop location",
          subtitle: "Central Park West",
          time: dropTime,
          color: AppColors.red,
          showLine: false,
        ),
      ],
    );
  }
}

class _PickupDropRow extends StatelessWidget {
  const _PickupDropRow({
    required this.title,
    required this.subtitle,
    required this.time,
    required this.color,
    required this.showLine,
  });

  final String title;
  final String subtitle;
  final String time;
  final Color color;
  final bool showLine;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: Responsive.size(context, 32),
          child: Column(
            children: [
              CircleAvatar(
                radius: Responsive.size(context, 12),
                backgroundColor: color.withValues(alpha: 0.15),
                child: Icon(
                  Icons.circle,
                  size: Responsive.size(context, 10),
                  color: color,
                ),
              ),
              if (showLine)
                Container(
                  width: 2,
                  height: Responsive.size(context, 20),
                  color: AppColors.silver,
                ),
            ],
          ),
        ),
        SizedBox(width: Responsive.size(context, 12)),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontFamily: AppFonts.saira,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.charcoal,
                ),
              ),
              SizedBox(height: Responsive.size(context, 4)),
              Text(
                subtitle,
                style: const TextStyle(
                  fontFamily: AppFonts.saira,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.black,
                ),
              ),
            ],
          ),
        ),
        Text(
          time,
          style: const TextStyle(
            fontFamily: AppFonts.saira,
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.gray,
          ),
        ),
      ],
    );
  }
}

