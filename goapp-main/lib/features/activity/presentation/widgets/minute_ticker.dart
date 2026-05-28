import 'dart:async';

import 'package:flutter/widgets.dart';

class MinuteTicker extends StatefulWidget {
  const MinuteTicker({
    super.key,
    required this.builder,
  });

  final Widget Function(DateTime now) builder;

  @override
  State<MinuteTicker> createState() => _MinuteTickerState();
}

class _MinuteTickerState extends State<MinuteTicker> {
  late DateTime _now;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _now = DateTime.now();
    _scheduleNextTick();
  }

  void _scheduleNextTick() {
    final nextMinute = DateTime(
      _now.year,
      _now.month,
      _now.day,
      _now.hour,
      _now.minute + 1,
    );
    final delay = nextMinute.difference(_now);
    _timer?.cancel();
    _timer = Timer(delay, _handleTick);
  }

  void _handleTick() {
    if (!mounted) return;
    setState(() {
      _now = DateTime.now();
    });
    _scheduleNextTick();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.builder(_now);
}
