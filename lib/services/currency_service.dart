enum Currency { ngn, usd, eur }

class CurrencyService {
  // exchange rates
  static const Map<Currency, double> rateFromUsd = {
    Currency.usd: 1.0,
    Currency.ngn: 1500.0,
    Currency.eur: 0.92,
  };

  static String symbol(Currency c) {
    switch (c) {
      case Currency.ngn:
        return "₦";
      case Currency.usd:
        return "\$";
      case Currency.eur:
        return "€";
    }
  }

  static String name(Currency c) {
    switch (c) {
      case Currency.ngn:
        return "NGN";
      case Currency.usd:
        return "USD";
      case Currency.eur:
        return "EUR";
    }
  }

  static double convertFromUsd(double amountUsd, Currency to) {
    return amountUsd * (rateFromUsd[to] ?? 1.0);
  }

  static String format(double amount, Currency currency) {
    final s = symbol(currency);
    // simple formatting
    final fixed = amount.toStringAsFixed(currency == Currency.ngn ? 2 : 2);
    return "$s $fixed";
  }
}
