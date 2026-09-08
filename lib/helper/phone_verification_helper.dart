import 'package:demandium/utils/core_export.dart';
import 'package:get/get.dart';


class PhoneVerificationHelper {

  static String isPhoneValid(String number, {required bool fromAuthPage}) {
    String cleanNumber = number.replaceAll(RegExp(r'[^0-9]'), '');
    if (cleanNumber.isEmpty) return "";

    String dialCode = Get.find<LocationController>().countryDialCode.replaceAll(RegExp(r'[^0-9]'), '');

    try {
      PhoneNumber phoneNumber = PhoneNumber.parse(number);
      String nsn = phoneNumber.nsn.toString();
      String cc = phoneNumber.countryCode;
      
      // Prevent double country code if the parser included CC in NSN due to formatting
      if (nsn.startsWith(cc) && nsn.length > cc.length && nsn.length > 7) {
        nsn = nsn.substring(cc.length);
      } else if (dialCode.isNotEmpty && nsn.startsWith(dialCode) && nsn.length > dialCode.length && nsn.length > 7) {
         nsn = nsn.substring(dialCode.length);
      }

      if (nsn.length >= 7) {
        if (!fromAuthPage) {
          Get.find<LocationController>().countryDialCode = "+${phoneNumber.countryCode}";
        }
        // Strip leading 0 if present in NSN
        if(nsn.startsWith('0')) nsn = nsn.replaceFirst('0', '');
        return nsn;
      }
    } catch (e) {
      if (kDebugMode) {
        print("Phone Number parsing failed: $e");
      }
    }

    // Manual Fallback: Strip the current country dial code if it exists at the start
    String fallbackNsn = cleanNumber;
    if (dialCode.isNotEmpty && cleanNumber.startsWith(dialCode)) {
      fallbackNsn = cleanNumber.substring(dialCode.length);
    }
    
    // Also strip leading zero from fallback NSN
    if(fallbackNsn.startsWith('0')) fallbackNsn = fallbackNsn.replaceFirst('0', '');

    if (fallbackNsn.length >= 7 && fallbackNsn.length <= 15) {
      return fallbackNsn;
    }

    return "";
  }


  static String getValidPhoneNumber(String number, {bool withCountryCode = false}) {
    bool isValid = false;
    String phone = "";

    try{
      PhoneNumber phoneNumber = PhoneNumber.parse(number);
      isValid = phoneNumber.isValid();
      if(isValid){
        phone =  withCountryCode ? "+${phoneNumber.countryCode}${phoneNumber.nsn}" : phoneNumber.nsn.toString();
        if (kDebugMode) {
          print("Phone Number : $phone");
        }
      }
    }catch(e) {
      if (kDebugMode) {
        print(e.toString());
      }
    }
    return phone;
  }

  static String getCountryCode(String number, {bool withCountryCode = false}) {
    bool isValid = false;
    String countryCode = "";

    try{
      PhoneNumber phoneNumber = PhoneNumber.parse(number);
      isValid = phoneNumber.isValid();
      if(isValid){
        countryCode = "+${phoneNumber.countryCode}";
        if (kDebugMode) {
          print("Country Code : $countryCode");
        }
      }
    }catch(e) {
      if (kDebugMode) {
        print(e.toString());
      }
    }
    return countryCode;
  }



  static String updateCountryAndNumberInEditProfilePage (String number){
    try {
      PhoneNumber phoneNumber = PhoneNumber.parse(number);
      if (kDebugMode) {
        print("phone number is : $number");
      }
      bool isValid = phoneNumber.isValid();
      if(isValid){
        Get.find<UserController>().countryDialCode = "+${phoneNumber.countryCode}";
        return phoneNumber.nsn.toString();
      }else{
        Get.find<UserController>().countryDialCode =
        CountryCode.fromCountryCode(Get.find<SplashController>().configModel.content?.countryCode ?? "AU").dialCode!;
        return number;
      }
    } catch (e) {
      Get.find<UserController>().countryDialCode =
      CountryCode.fromCountryCode(Get.find<SplashController>().configModel.content?.countryCode ?? "AU").dialCode!;
      debugPrint('Phone Number is not parsing: $e');
      return number;

    }
  }

}