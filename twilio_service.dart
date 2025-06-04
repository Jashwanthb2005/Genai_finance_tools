import 'package:twilio_flutter/twilio_flutter.dart';

class TwilioService {
  final TwilioFlutter twilioFlutter = TwilioFlutter(
    accountSid: 'AC3ff282299db875dc67b7013605416221',
    authToken: 'cb736d6b146bae7e70425538bf144f89',
    twilioNumber: '+17158003203',
  );

  void sendOtp(String phoneNumber, String otp) async {
    await twilioFlutter.sendSMS(
      toNumber: phoneNumber,
      messageBody: 'Your OTP is: $otp',
    );
  }
}