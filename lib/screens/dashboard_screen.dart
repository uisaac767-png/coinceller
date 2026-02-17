import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import '../theme/bybit_theme.dart';
import '../widgets/bottom_navigator.dart';
import '../services/wallet_service.dart';
import '../services/api_service.dart';
import 'transfer_screen.dart';
import 'transaction_screen.dart';
import 'profile_screen.dart';
import 'deposit_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int index = 0;

  final screens = const [
    WalletHome(),
    TransferScreen(),
    TransactionScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: screens[index],
      bottomNavigationBar: BottomNavigator(
        currentIndex: index,
        onTap: (i) => setState(() => index = i),
      ),
    );
  }
}

class WalletHome extends StatefulWidget {
  const WalletHome({super.key});

  @override
  State<WalletHome> createState() => _WalletHomeState();
}

class _WalletHomeState extends State<WalletHome> {
  bool hardRefreshing = false;
  bool priceRefreshing = false;
  bool pricesLoaded = false;
  bool onchainRefreshing = false;
  bool candleRefreshing = false;
  String candleCoin = "BTC";
  List<_Candle> candles = [];
  Timer? _priceTimer;
  Timer? _candleTimer;

  @override
  void initState() {
    super.initState();
    _primePrices();
    _refreshCandles();
    _priceTimer = Timer.periodic(
      const Duration(seconds: 30),
      (_) => _refreshPricesSilent(),
    );
    _candleTimer = Timer.periodic(
      const Duration(seconds: 60),
      (_) => _refreshCandles(),
    );
  }

  @override
  void dispose() {
    _priceTimer?.cancel();
    _candleTimer?.cancel();
    super.dispose();
  }

  Future<void> _primePrices() async {
    if (pricesLoaded) return;
    pricesLoaded = true;
    await WalletService.refreshPrices();
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> openDeposit() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const DepositScreen()),
    );
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> refreshNow() async {
    final result = await WalletService.refreshFromBackend();
    if (!mounted) return;
    setState(() {});
    if (result != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result),
          backgroundColor: Colors.orange.shade700,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Wallet refreshed"),
          backgroundColor: BybitTheme.success,
        ),
      );
    }
  }

  Future<void> refreshPricesNow() async {
    if (priceRefreshing) return;
    setState(() => priceRefreshing = true);
    final result = await WalletService.refreshPrices();
    if (!mounted) return;
    setState(() => priceRefreshing = false);
    setState(() {});

    if (result != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result),
          backgroundColor: Colors.orange.shade700,
        ),
      );
    }
  }

  Future<void> _refreshPricesSilent() async {
    if (priceRefreshing) return;
    priceRefreshing = true;
    await WalletService.refreshPrices();
    priceRefreshing = false;
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> refreshOnchainNow() async {
    if (onchainRefreshing) return;
    setState(() => onchainRefreshing = true);
    final result = await WalletService.refreshOnchainBalances();
    if (!mounted) return;
    setState(() => onchainRefreshing = false);
    setState(() {});

    if (result != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result),
          backgroundColor: Colors.orange.shade700,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("External ledger refreshed"),
          backgroundColor: BybitTheme.success,
        ),
      );
    }
  }

  Future<void> _refreshCandles() async {
    if (candleRefreshing) return;
    setState(() => candleRefreshing = true);
    try {
      final response = await ApiService.getMarketCandles(
        candleCoin,
        interval: "5m",
      );
      if (response is Map && response['candles'] is List) {
        final parsed = <_Candle>[];
        for (final raw in response['candles']) {
          if (raw is Map) {
            final t = raw['t'];
            final o = raw['o'];
            final h = raw['h'];
            final l = raw['l'];
            final c = raw['c'];
            if (t is num && o is num && h is num && l is num && c is num) {
              parsed.add(_Candle(
                time: DateTime.fromMillisecondsSinceEpoch(t.toInt()),
                open: o.toDouble(),
                high: h.toDouble(),
                low: l.toDouble(),
                close: c.toDouble(),
              ));
            }
          }
        }
        candles = parsed;
      }
    } catch (_) {}
    if (!mounted) return;
    setState(() => candleRefreshing = false);
  }

  Future<void> hardRefreshNow() async {
    if (hardRefreshing) return;
    setState(() => hardRefreshing = true);
    final result = await WalletService.hardRefresh();
    if (!mounted) return;
    setState(() => hardRefreshing = false);
    setState(() {});

    if (result != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result),
          backgroundColor: Colors.orange.shade700,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Hard refresh completed"),
          backgroundColor: BybitTheme.success,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final totalUsd = WalletService.totalUsd();
    final prices = WalletService.coinPriceUsd;
    final balances = WalletService.coinBalances;
    final onchain = WalletService.onchainBalances;

    return SafeArea(
      child: RefreshIndicator(
        onRefresh: refreshNow,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Expanded(
                    child: Text("Wallet",
                        style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: BybitTheme.text)),
                  ),
                  IconButton(
                    onPressed: hardRefreshing ? null : hardRefreshNow,
                    icon: hardRefreshing
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.refresh, color: BybitTheme.gold),
                    tooltip: "Hard Refresh",
                  ),
                ],
              ),
              const SizedBox(height: 14),
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.asset(
                  "assets/images/home_banner.png",
                  width: double.infinity,
                  height: 130,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    height: 130,
                    color: BybitTheme.card,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text("\$${totalUsd.toStringAsFixed(2)}",
                  style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: BybitTheme.gold)),
              const SizedBox(height: 14),
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      "Live Prices",
                      style: TextStyle(
                        color: BybitTheme.text,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: priceRefreshing ? null : refreshPricesNow,
                    icon: priceRefreshing
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.sync, color: BybitTheme.gold),
                    tooltip: "Refresh Prices",
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Column(
                children: [
                  _priceRow("BTC", balances["BTC"] ?? 0, prices["BTC"]),
                  _priceRow("ETH", balances["ETH"] ?? 0, prices["ETH"]),
                  _priceRow("USDT", balances["USDT"] ?? 0, prices["USDT"]),
                  _priceRow("TRX", balances["TRX"] ?? 0, prices["TRX"]),
                  _priceRow("SOL", balances["SOL"] ?? 0, prices["SOL"]),
                ],
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      "External Ledger (On-chain)",
                      style: TextStyle(
                        color: BybitTheme.text,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: onchainRefreshing ? null : refreshOnchainNow,
                    icon: onchainRefreshing
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.public, color: BybitTheme.gold),
                    tooltip: "Refresh external ledger",
                  ),
                ],
              ),
              const SizedBox(height: 8),
              onchain.isEmpty
                  ? const Text(
                      "No external ledger balances yet",
                      style: TextStyle(color: BybitTheme.subText),
                    )
                  : Column(
                      children: onchain.entries
                          .map((e) => _externalRow(e.key, e.value))
                          .toList(),
                    ),
              const SizedBox(height: 18),
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      "Candlesticks (5m)",
                      style: TextStyle(
                        color: BybitTheme.text,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  DropdownButton<String>(
                    value: candleCoin,
                    dropdownColor: BybitTheme.card,
                    items: const ["BTC", "ETH", "USDT", "TRX", "SOL"]
                        .map((c) =>
                            DropdownMenuItem(value: c, child: Text(c)))
                        .toList(),
                    onChanged: (v) {
                      if (v == null) return;
                      setState(() => candleCoin = v);
                      _refreshCandles();
                    },
                  ),
                  IconButton(
                    onPressed: candleRefreshing ? null : _refreshCandles,
                    icon: candleRefreshing
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.show_chart, color: BybitTheme.gold),
                    tooltip: "Refresh candles",
                  ),
                ],
              ),
              const SizedBox(height: 8),
              _candlesChart(),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: openDeposit,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _actionImage("assets/images/flash_icon.png"),
                          const SizedBox(width: 8),
                          const Text("Deposit"),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const TransferScreen()));
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _actionImage("assets/images/send_icon.png"),
                          const SizedBox(width: 8),
                          const Text("Send"),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 400),
            ],
          ),
        ),
      ),
    );
  }

  Widget _actionImage(String assetPath) {
    return SizedBox(
      width: 16,
      height: 16,
      child: Image.asset(
        assetPath,
        fit: BoxFit.contain,
        errorBuilder: (_, __, ___) => const Icon(
          Icons.circle,
          size: 14,
          color: Colors.black54,
        ),
      ),
    );
  }

  Widget _priceRow(String coin, double balance, double? priceUsd) {
    final priceText =
        priceUsd == null ? "—" : "\$${priceUsd.toStringAsFixed(2)}";
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: BybitTheme.card,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              coin,
              style: const TextStyle(
                color: BybitTheme.text,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Text(
            balance.toStringAsFixed(6),
            style: const TextStyle(color: BybitTheme.subText),
          ),
          const SizedBox(width: 14),
          Text(
            priceText,
            style: const TextStyle(color: BybitTheme.gold),
          ),
        ],
      ),
    );
  }

  Widget _externalRow(String label, double balance) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: BybitTheme.card,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                color: BybitTheme.text,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Text(
            balance.toStringAsFixed(6),
            style: const TextStyle(color: BybitTheme.subText),
          ),
        ],
      ),
    );
  }

  Widget _candlesChart() {
    if (candles.isEmpty) {
      return const Text(
        "No candle data yet",
        style: TextStyle(color: BybitTheme.subText),
      );
    }
    final recent = candles.length > 120
        ? candles.sublist(candles.length - 120)
        : candles;
    return Container(
      height: 240,
      decoration: BoxDecoration(
        color: BybitTheme.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: BybitTheme.border),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
        child: LayoutBuilder(
          builder: (_, constraints) {
            return CustomPaint(
              size: Size(constraints.maxWidth, constraints.maxHeight),
              painter: _CandleChartPainter(data: recent),
            );
          },
        ),
      ),
    );
  }
}

class _Candle {
  final DateTime time;
  final double open;
  final double high;
  final double low;
  final double close;

  const _Candle({
    required this.time,
    required this.open,
    required this.high,
    required this.low,
    required this.close,
  });
}

class _CandleChartPainter extends CustomPainter {
  final List<_Candle> data;

  _CandleChartPainter({required this.data});

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty || size.width <= 0 || size.height <= 0) return;

    final high = data.fold<double>(data.first.high, (p, e) => math.max(p, e.high));
    final low = data.fold<double>(data.first.low, (p, e) => math.min(p, e.low));
    final range = (high - low).abs() < 1e-12 ? 1.0 : (high - low);

    final gridPaint = Paint()
      ..color = BybitTheme.card2
      ..strokeWidth = 1;
    const hLines = 4;
    for (var i = 1; i <= hLines; i++) {
      final y = size.height * i / (hLines + 1);
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    final count = data.length;
    final stepX = size.width / math.max(count, 1);
    final bodyWidth = math.max(2.0, stepX * 0.55);

    for (var i = 0; i < count; i++) {
      final c = data[i];
      final x = (i + 0.5) * stepX;

      double toY(double price) => size.height - ((price - low) / range) * size.height;

      final yHigh = toY(c.high);
      final yLow = toY(c.low);
      final yOpen = toY(c.open);
      final yClose = toY(c.close);
      final isBull = c.close >= c.open;

      final wickPaint = Paint()
        ..color = isBull ? BybitTheme.success : BybitTheme.danger
        ..strokeWidth = 1.2;
      canvas.drawLine(Offset(x, yHigh), Offset(x, yLow), wickPaint);

      final top = math.min(yOpen, yClose);
      final bottom = math.max(yOpen, yClose);
      final rect = Rect.fromLTWH(
        x - bodyWidth / 2,
        top,
        bodyWidth,
        math.max(1.4, bottom - top),
      );
      final bodyPaint = Paint()
        ..color = isBull ? BybitTheme.success : BybitTheme.danger;
      canvas.drawRect(rect, bodyPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _CandleChartPainter oldDelegate) {
    return oldDelegate.data != data;
  }
}
