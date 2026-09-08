import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:demandium/feature/auth/controller/auth_controller.dart';
import 'package:demandium/feature/profile/controller/user_controller.dart';
import 'package:demandium/feature/area/controller/service_area_controller.dart';
import 'dart:math';

class ChatMessage {
  final String text;
  final bool isUser;
  final bool isHtml;

  ChatMessage({required this.text, required this.isUser, this.isHtml = false});
}

class ChatbotController extends GetxController {
  var messages = <ChatMessage>[].obs;
  var quickReplies = <String>[].obs;
  var isTyping = false.obs;

  bool isWaitingForEmail = true;
  String? currentEmail;
  String? currentUserId;
  bool isNewCustomer = false;
  late String sessionId;

  final Map<String, String> categoryLinks = {
    "end of lease": "/category-service-form?categoryId=5eecf6f9-00d6-4d00-958b-e6804d89ad88",
    "carpet steam": "/category-service-form?categoryId=6732c9a5-f2bf-46bb-af57-7bb94b9419a3",
    "spring cleaning": "/category-service-form?categoryId=a7cc829f-352d-496e-840b-05193e1fc9a2",
    "office cleaning": "/category-service-form?categoryId=4c7cd24d-f3a2-480b-8c3f-f115bc6dd242",
    "oven cleaning": "/category-service-form?categoryId=dd556a6e-8175-45aa-8ec4-accc93913785",
    "bbq cleaning": "/category-service-form?categoryId=12723afe-78a0-411c-8742-c6bec7a2c121",
    "bond cleaning": "/category-service-form?categoryId=f119a7c0-2048-40b7-92af-a6a5e8c434f2",
    "pest control": "/category-service-form?categoryId=a7212a3a-d735-4465-a3c9-e7a32414568a",
    "upholstery": "/category-service-form?categoryId=162ba6bd-3f40-492c-8104-5c835dd5a5c9",
    "domestic cleaning": "/category-service-form?categoryId=0bff5522-b90d-43b1-b7aa-a473729eaa1b",
    "construction cleaning": "/category-service-form?categoryId=3a3c8771-cd02-40e0-8211-fb98a863431b",
    "move in cleaning": "/category-service-form?categoryId=16b951bb-9f80-4109-b470-9a9c14dde513",
    "window cleaning": "/category-service-form?categoryId=9b931edc-05e4-4647-9736-2deabfef70ec",
    "airbnb cleaning": "/category-service-form?categoryId=880e6077-3f33-468b-9b39-bb1646d9cd66",
    "renovation cleaning": "/category-service-form?categoryId=a07797ae-a203-47f7-b03f-5d2ab501067a"
  };

  @override
  void onInit() {
    super.onInit();
    sessionId = 'sess_${Random().nextInt(1000000)}_${DateTime.now().millisecondsSinceEpoch}';
    checkAuthAndStart();
  }

  void checkAuthAndStart() {
    bool isLoggedIn = Get.find<AuthController>().isLoggedIn();
    if (isLoggedIn) {
      currentEmail = Get.find<UserController>().userInfoModel?.email ?? "user@app.com";
      isWaitingForEmail = false;
      addBotMessage("Hi! 👋 Welcome back to **Dirt2Tidy**.");
      Future.delayed(const Duration(milliseconds: 600), () {
        addBotMessage("How can I help you today?");
        showMainOptions();
      });
    } else {
      isWaitingForEmail = true;
      addBotMessage("Hi! 👋 Welcome to **Dirt2Tidy**.");
      Future.delayed(const Duration(milliseconds: 600), () {
        addBotMessage("To better assist you, please provide your **email address** first. We'll use this to set up your account and to serve you better way.");
      });
    }
  }

  void showMainOptions() {
    quickReplies.value = ["✨ Service List", "💰 View Pricing", "📍 Areas", "📅 Book Now"];
  }

  void addMessage(String text, {required bool isUser, bool isHtml = false}) {
    messages.add(ChatMessage(text: text, isUser: isUser, isHtml: isHtml));
    saveMessageToDB(text, isUser ? 'user' : 'bot');
  }

  void addBotMessage(String text, {int delayMs = 0, bool isHtml = false}) {
    if (delayMs > 0) {
      isTyping.value = true;
      Future.delayed(Duration(milliseconds: delayMs), () {
        isTyping.value = false;
        addMessage(text, isUser: false, isHtml: isHtml);
      });
    } else {
      addMessage(text, isUser: false, isHtml: isHtml);
    }
  }

  void handleUserInput(String text) async {
    addMessage(text, isUser: true);
    quickReplies.clear();
    isTyping.value = true;
    
    await Future.delayed(const Duration(milliseconds: 600));
    isTyping.value = false;
    processBotResponse(text);
  }

  bool validateEmail(String email) {
    return RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+").hasMatch(email);
  }

  void processBotResponse(String rawInput) async {
    String text = rawInput.toLowerCase();

    if (isWaitingForEmail) {
      if (validateEmail(text)) {
        addBotMessage("Thank you! Please wait a moment while I set up your account...");
        isTyping.value = true;
        try {
          var response = await http.post(
            Uri.parse('https://app.dirt2tidy.com.au/api/v1/chatbot/onboard'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({"email": text}),
          );
          isTyping.value = false;
          if (response.statusCode == 200) {
            var data = jsonDecode(response.body);
            isWaitingForEmail = false;
            currentEmail = text;
            currentUserId = data['content'] != null ? data['content']['user_id']?.toString() : null;
            isNewCustomer = true;

            addBotMessage("Success! 🎉 Your account has been created and your login credentials (with a unique 8-digit password) have been sent to your email address.", delayMs: 400);
            Future.delayed(const Duration(milliseconds: 1000), () {
              addBotMessage("Now, I'm your official AI Assistant. I can help with **Booking any of our 15 services**, **Pricing**, and **Support**. How can I help you today?", delayMs: 200);
              Future.delayed(const Duration(milliseconds: 600), showMainOptions);
            });
          } else if (response.statusCode == 400) {
            var data = jsonDecode(response.body);
            String errorMsg = data['errors'] != null && data['errors'].isNotEmpty ? data['errors'][0]['message'] : "This email already has an account. Please share another email.";
            addBotMessage("**$errorMsg**");
          } else {
            addBotMessage("I'm sorry, I encountered an error. Could you please re-send your email?");
          }
        } catch (e) {
          isTyping.value = false;
          addBotMessage("I'm having trouble connecting to the server. Please try again soon.");
        }
      } else {
        addBotMessage("That doesn't look like a valid email. Please provide a valid email address to continue.");
      }
      return;
    }

    if (text.contains('book now') || text.contains('booking')) {
      addBotMessage("Certainly! We have 15 specialized cleaning services. Please choose one to proceed with your booking:");
      Future.delayed(const Duration(milliseconds: 800), () {
        quickReplies.value = [
          "End of Lease", "Carpet Steam", "Spring Clean", "Office Clean", "Oven Clean",
          "BBQ Cleaning", "Bond Cleaning", "Pest Control", "Upholstery", "Domestic Clean",
          "Construction", "Move In Clean", "Window Clean", "Airbnb Clean", "Renovation"
        ];
      });
    } else if (text.contains('lease') || text.contains('carpet') || text.contains('spring') || 
               text.contains('office') || text.contains('oven') || text.contains('bbq') || 
               text.contains('bond') || text.contains('pest') || text.contains('upholstery') || 
               text.contains('domestic') || text.contains('construction') || text.contains('move') || 
               text.contains('window') || text.contains('airbnb') || text.contains('renovation')) {
      
      String matchedKey = "end of lease";
      for (var key in categoryLinks.keys) {
        if (text.contains(key.split(' ')[0])) {
          matchedKey = key;
          break;
        }
      }

      addBotMessage("Great choice! Opening the **$rawInput** service form now...");
      // In Flutter, we can simply pass a string that the UI recognizes as a link
      String link = categoryLinks[matchedKey]!;
      Future.delayed(const Duration(milliseconds: 600), () {
        addBotMessage("LINK: $link|🎯 Click here to select your $rawInput options");
      });
    } else if (text.contains('price') || text.contains('pricing') || text.contains('cost')) {
      addBotMessage("Our rates are very competitive. Check our End of Lease service price below:");
      Future.delayed(const Duration(milliseconds: 500), () {
        quickReplies.value = ["End of Lease Prices"];
      });
    } else if (text.contains('lease prices')) {
      addBotMessage("🏡 **End of Lease Prices:**\n🔹 Studio: **\$325**\n🔹 1BR: **\$340**\n🔹 2BR: **\$385**\n🔹 3BR: **\$470**");
      Future.delayed(const Duration(milliseconds: 500), () {
        quickReplies.value = ["📅 Book Now", "Main Menu"];
      });
    } else if (text.contains('service') || text.contains('list')) {
      addBotMessage("We offer 15 premium cleaning services tailored to your needs. From Bond Cleaning to Pest Control, we cover it all!");
      Future.delayed(const Duration(milliseconds: 500), () {
        quickReplies.value = ["💰 View Pricing", "📅 Book Now"];
      });
    } else if (text.contains('hi') || text.contains('hello')) {
      addBotMessage("Hi! How can I help you today?");
      Future.delayed(const Duration(milliseconds: 500), showMainOptions);
    } else if (text.contains('support')) {
      addBotMessage("📞 Call: **1300 DIRTY2TIDY**\n✉️ Email: **support@dirt2tidy.com.au**");
    } else if (text.contains('menu')) {
      showMainOptions();
    } else if (text.contains('area') || text.contains('zone')) {
      addBotMessage("Please wait a moment while I fetch our service areas...");
      isTyping.value = true;
      try {
        var serviceAreaController = Get.find<ServiceAreaController>();
        if (serviceAreaController.zoneList == null) {
          await serviceAreaController.getZoneList(reload: true);
        }
        isTyping.value = false;
        if (serviceAreaController.zoneList != null && serviceAreaController.zoneList!.isNotEmpty) {
          String zoneNames = serviceAreaController.zoneList!.map((zone) => "🔹 ${zone.name}").join("\n");
          addBotMessage("🏡 **Our Service Areas & Zones:**\n\n$zoneNames");
        } else {
          addBotMessage("We are currently serving in several key areas. To see if we service your specific location, please select '📅 Book Now' to enter your address!");
        }
      } catch (e) {
        isTyping.value = false;
        addBotMessage("We serve all major regions and suburbs. Please select '📅 Book Now' and enter your address to confirm service availability for your location!");
      }
      Future.delayed(const Duration(milliseconds: 800), () {
        quickReplies.value = ["📅 Book Now", "Main Menu"];
      });
    } else {
      addBotMessage("I can definitely help with your cleaning needs. Pick an option below or mention any of our 15 services.");
      Future.delayed(const Duration(milliseconds: 600), showMainOptions);
    }
  }

  void saveMessageToDB(String text, String side) async {
    try {
      await http.post(
        Uri.parse('https://app.dirt2tidy.com.au/api/v1/chatbot/save-message'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "session_id": sessionId,
          "message": text,
          "sender": side,
          "email": currentEmail,
          "user_id": currentUserId,
          "is_new_customer": isNewCustomer
        }),
      );
    } catch (e) {
      // Ignore
    }
  }
}
