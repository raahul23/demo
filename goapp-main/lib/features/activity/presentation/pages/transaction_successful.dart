import "package:flutter/material.dart";
import "../../../../core/utils/constants.dart";
import "../../../../core/utils/responsive.dart";
import "../widgets/appbar.dart";
import "activity_page.dart";

class TransactionSuccessPage extends StatelessWidget {
  const TransactionSuccessPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: AppColors.coolwhite,
        appBar: AppAppBar(
          title: "",
          onBack: () {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (_) => const ActivityPage(),
              ),
            );
          },
        ),
        body: LayoutBuilder( builder: (context, constraints) {
          final width = constraints.maxWidth;
          final height = constraints.maxHeight;

          return Center(
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _SuccessIcon(size: width * 0.35),
                          SizedBox(height: height * 0.04),
                          SizedBox(height: Responsive.size(context, 16)),
                          const Text(
                            "₹550.00",
                            style: TextStyle(
                              fontFamily: AppFonts.saira,
                              fontSize: 30,
                              fontWeight: FontWeight.w700,
                              color: AppColors.black,
                            ),
                          ),
                          SizedBox(height: Responsive.size(context, 6)),
                          const Text(
                            "Added Successfully",
                            style: TextStyle(
                              fontFamily: AppFonts.saira,
                              fontSize: 30,
                              fontWeight: FontWeight.w600,
                              color: AppColors.charcoal,
                            ),
                          ),
                          SizedBox(height: Responsive.size(context, 6)),
                          const Text(
                            "Transaction Confirmed",
                            style: TextStyle(
                              fontFamily: AppFonts.saira,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: AppColors.gray,
                            ),
                          ),
                        ],
                      ),
                    ),]
              )
          );
        }
        )
    );
  }
}
class _SuccessIcon extends StatelessWidget {
  final double size;

  const _SuccessIcon({required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: const Color(0xFFA5E9D1).withValues(alpha: 0.3),
      ),
      child: Center(
        child: Container(
          width: size * 0.65,
          height: size * 0.65,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white,
          ),
          child: Center(
            child: Container(
              width: size * 0.35,
              height: size * 0.35,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.emerald,
              ),
              child: Icon(
                Icons.attach_money,
                color: Colors.white,
                size: size * 0.25,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
