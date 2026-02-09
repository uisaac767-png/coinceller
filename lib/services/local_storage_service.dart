import 'currency_service.dart';

class LocalStorageService {
  static String? _savedEmail;
  static String? _savedPassword;

  static Currency _currency = Currency.usd;

  static Future<void> saveUser(String email, String password) async {
    _savedEmail = email;
    _savedPassword = password;
  }

  static Future<bool> validateUser(String email, String password) async {
    return _savedEmail == email && _savedPassword == password;
  }

  static Future<void> setCurrency(Currency currency) async {
    _currency = currency;
  }

  static Future<Currency> getCurrency() async {
    return _currency;
  }
}
