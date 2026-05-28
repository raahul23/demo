import "package:flutter/material.dart";
import "../../../../core/utils/constants.dart";
import "../../../../core/utils/date_time.dart";
import "../../../../core/utils/responsive.dart";
import "../widgets/appbar.dart";
import "../widgets/buttons.dart";
import "../widgets/minute_ticker.dart";
import "help_support.dart";

class ReceiptPage extends StatelessWidget {
  const ReceiptPage({
    super.key,
    this.status,
  });

  final String? status;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const AppAppBar(
        title: "",
      ),
      body: MinuteTicker(
        builder: (now) => Padding(
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
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: Responsive.size(context, 28),
                    backgroundColor: Colors.transparent,
                    child: ClipOval(
                      child: Image.asset(
                        "assets/images/logo.png",
                        width: Responsive.size(context, 56),
                        height: Responsive.size(context, 56),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const Spacer(),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        "INVOICE NO.",
                        style: TextStyle(
                          fontFamily: AppFonts.saira,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: AppColors.charcoal,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        "#LX-IN-99281",
                        style: TextStyle(
                          fontFamily: AppFonts.saira,
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                          color: AppColors.black,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(height: Responsive.size(context, 16)),
              Row(
                children: [
                  const Text(
                    "Receipt",
                    style: TextStyle(
                      fontFamily: AppFonts.saira,
                      fontSize: 41,
                      fontWeight: FontWeight.w400,
                      color: AppColors.black,
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
                        fontWeight: FontWeight.w700,
                        color: _statusColor(status),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: Responsive.size(context, 16)),
              const Text(
                "TRIP INFORMATION",
                style: TextStyle(
                  fontFamily: AppFonts.saira,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.gray,
                ),
              ),
              SizedBox(height: Responsive.size(context, 12)),
              const Divider(height: 1, color: AppColors.warmGray),
              SizedBox(height: Responsive.size(context, 12)),
              Container(
                padding: Responsive.insetsAll(context, 14),
                decoration: BoxDecoration(
                  color: Colors.white,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: _InfoBlock(
                            label: "DATE",
                            value: DateTimeUtils.formatDate(now),
                          ),
                        ),
                        SizedBox(width: Responsive.size(context, 12)),
                        const Expanded(
                          child: _InfoBlock(
                            label: "VEHICLE",
                            value: "Black Lux Sedan",
                            alignEnd: true,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: Responsive.size(context, 12)),
                    Row(
                      children: [
                        const Expanded(
                          child: _InfoBlock(
                            label: "TRIP ID",
                            value: "in-82-j9p1-m12",
                          ),
                        ),
                        SizedBox(width: Responsive.size(context, 12)),
                        const Expanded(
                          child: _InfoBlock(
                            label: "DURATION",
                            value: "10 Minutes",
                            alignEnd: true,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(height: Responsive.size(context, 16)),
              const Text(
                "ROUTE SUMMARY",
                style: TextStyle(
                  fontFamily: AppFonts.saira,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.gray,
                ),
              ),
              SizedBox(height: Responsive.size(context, 12)),
              const Divider(height: 1, color: AppColors.warmGray),
              SizedBox(height: Responsive.size(context, 12)),
              Container(
                padding: Responsive.insetsAll(context, 14),
                decoration: BoxDecoration(
                  color: Colors.white,
                ),
                child: _PickupDropBlock(
                  pickupTime: DateTimeUtils.formatTime24(now),
                  dropTime: DateTimeUtils.formatTime24(now),
                ),
              ),
              SizedBox(height: Responsive.size(context, 16)),
              const Text(
                "FARE BREAKDOWN",
                style: TextStyle(
                  fontFamily: AppFonts.saira,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.gray,
                ),
              ),
              SizedBox(height: Responsive.size(context, 12)),
              const Divider(height: 1, color: AppColors.warmGray),
              SizedBox(height: Responsive.size(context, 12)),
              const _KeyValueRow(
                label: "Distance",
                value: "4.2 km",
                valueColor: AppColors.emerald,
              ),
              SizedBox(height: Responsive.size(context, 8)),
              const _KeyValueRow(
                label: "Base Fare",
                value: "₹104.00",
              ),
              SizedBox(height: Responsive.size(context, 8)),
              const _KeyValueRow(
                label: "GST",
                value: "₹12.00",
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        minimum: Responsive.insetsLTRB(
          context,
          left: 16,
          top: 12,
          right: 16,
          bottom: 16,
        ),
        child: Row(
          children: [
            Expanded(
              child: AppButton(
                label: "Download PDF",
                size: AppButtonSize.medium,
                leading: Icon(
                  Icons.download,
                  size: Responsive.size(context, 18),
                ),
                backgroundColor: AppColors.warmGray,
                foregroundColor: AppColors.black,
                onPressed: () {},
              ),
            ),
            SizedBox(width: Responsive.size(context, 12)),
            Expanded(
              child: AppButton(
                label: "Help",
                size: AppButtonSize.medium,
                leading: Icon(
                  Icons.live_help_outlined,
                  size: Responsive.size(context, 18),
                ),
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const HelpSupportPage(),
                    ),
                  );
                },
              ),
            ),
          ],
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

class _InfoBlock extends StatelessWidget {
  const _InfoBlock({
    required this.label,
    required this.value,
    this.alignEnd = false,
  });

  final String label;
  final String value;
  final bool alignEnd;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment:
      alignEnd ? CrossAxisAlignment.start : CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontFamily: AppFonts.saira,
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: AppColors.gray,
          ),
        ),
        SizedBox(height: Responsive.size(context, 4)),
        Text(
          value,
          style: const TextStyle(
            fontFamily: AppFonts.saira,
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: AppColors.black,
          ),
        ),
      ],
    );
  }
}

class _KeyValueRow extends StatelessWidget {
  const _KeyValueRow({
    required this.label,
    required this.value,
    this.valueColor,
  });

  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          label,
          style: const TextStyle(
            fontFamily: AppFonts.saira,
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.charcoal,
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: TextStyle(
            fontFamily: AppFonts.saira,
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: valueColor ?? AppColors.black,
          ),
        ),
      ],
    );
  }
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
          title: "ARUMBAKKAM",
          subtitle: "123 Main Street, Downtown",
          time: pickupTime,
          color: AppColors.green,
          showLine: false,
        ),
        SizedBox(height: Responsive.size(context, 16)),
        _PickupDropRow(
          title: "VR MALL",
          subtitle: "VR Mall Anna Nagar, Ch-92",
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
                  width: 1,
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
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.charcoal,
                ),
              ),
              SizedBox(height: Responsive.size(context, 4)),
              Text(
                subtitle,
                style: const TextStyle(
                  fontFamily: AppFonts.saira,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
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
            fontWeight: FontWeight.w500,
            color: AppColors.gray,
          ),
        ),
      ],
    );
  }
}

