
import 'dart:io';

void main(List<String> args) {
  if (args.isEmpty) {
    print('Usage: dart tools/keygen.dart IB-XXXX-XXXX');
    return;
  }

  final String requestId = args[0].trim().toUpperCase();
  const String salt = "IgniteBill_Secret_2024_Salt";
  
  final String input = requestId + salt;
  var hash = 0;
  for (var i = 0; i < input.length; i++) {
    hash = (31 * hash + input.codeUnitAt(i)) & 0xFFFFFFFF;
  }
  
  final String key = hash.toRadixString(16).toUpperCase();
  
  print('-----------------------------------------');
  print('ID Demande : $requestId');
  print('CLÉ PRO    : $key');
  print('-----------------------------------------');
}
