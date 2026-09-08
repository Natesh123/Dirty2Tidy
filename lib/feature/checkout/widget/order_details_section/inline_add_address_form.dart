import 'package:get/get.dart';
import 'package:demandium/feature/lead/controller/lead_controller.dart';
import 'package:demandium/utils/core_export.dart';
import 'package:demandium/feature/address/view/add_address_screen.dart';
import 'package:demandium/feature/location/widget/location_search_dialog.dart';

class InlineAddAddressForm extends StatefulWidget {
  final AddressModel? address;
  final VoidCallback? onSaveSuccess;
  final ValueChanged<bool>? onBasicInfoValidityChanged;
  final double? grandTotal;

  const InlineAddAddressForm({super.key, this.address, this.onSaveSuccess, this.onBasicInfoValidityChanged, this.grandTotal});

  @override
  State<InlineAddAddressForm> createState() => InlineAddAddressFormState();
}

class InlineAddAddressFormState extends State<InlineAddAddressForm> {
  final TextEditingController _contactPersonNameController = TextEditingController();
  final TextEditingController _contactPersonNumberController = TextEditingController();
  final TextEditingController _alternativeController = TextEditingController();
  final TextEditingController _serviceAddressController = TextEditingController();
  final TextEditingController _houseController = TextEditingController();
  final TextEditingController _floorController = TextEditingController();
  final TextEditingController _countryController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _zipController = TextEditingController();
  final TextEditingController _streetController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  final FocusNode _nameNode = FocusNode();
  final FocusNode _numberNode = FocusNode();
  final FocusNode _emailNode = FocusNode();
  final FocusNode _serviceAddressNode = FocusNode();
  final FocusNode _houseNode = FocusNode();
  final FocusNode _floorNode = FocusNode();
  final FocusNode _countryNode = FocusNode();
  final FocusNode _cityNode = FocusNode();
  final FocusNode _zipNode = FocusNode();
  final FocusNode _streetNode = FocusNode();

  LatLng? _initialPosition;
  final GlobalKey<FormState> addressFormKey = GlobalKey<FormState>();
  final Completer<GoogleMapController> _controller = Completer();

  CameraPosition? _cameraPosition;
  bool _isBasicInfoValid = false;
  bool _isAddressSame = false;

  @override
  void initState() {
    super.initState();
    Get.find<LocationController>().resetAddress();
    
     _contactPersonNameController.addListener(_checkBasicInfoValidity);
     _contactPersonNumberController.addListener(_checkBasicInfoValidity);
     _emailController.addListener(_checkBasicInfoValidity);

    if(widget.address != null) {
      setControllerData();
    }else{
      Get.find<LocationController>().updateAddressLabel(addressLabelString: 'home'.tr);
      Get.find<LocationController>().countryDialCode = CountryCode.fromCountryCode(Get.find<SplashController>().configModel.content?.countryCode ?? "AU").dialCode!;
      _countryController.text = '';

      AddressModel? activeAddress = Get.find<LocationController>().getUserAddress();
      if (activeAddress != null && activeAddress.latitude != null && activeAddress.longitude != null) {
        Get.find<LocationController>().setUpdateAddress(activeAddress);
        
        _serviceAddressController.text = activeAddress.address ?? "";
        _houseController.text = activeAddress.house ?? "";
        _floorController.text = activeAddress.floor ?? "";
        _cityController.text = activeAddress.city ?? "";
        _countryController.text = activeAddress.country ?? "";
        _zipController.text = activeAddress.zipCode ?? "";
        _streetController.text = activeAddress.street ?? "";
        
        _initialPosition = LatLng(
          double.tryParse(activeAddress.latitude!) ?? Get.find<SplashController>().configModel.content?.defaultLocation?.latitude ?? 23.0000,
          double.tryParse(activeAddress.longitude!) ?? Get.find<SplashController>().configModel.content?.defaultLocation?.longitude ?? 90.0000,
        );
      } else {
        _initialPosition = LatLng(
          Get.find<SplashController>().configModel.content?.defaultLocation?.latitude ?? 23.0000,
          Get.find<SplashController>().configModel.content?.defaultLocation?.longitude ?? 90.0000,
        );
      }
    }
    WidgetsBinding.instance.addPostFrameCallback((_) => _checkBasicInfoValidity());
  }
  
  void _checkBasicInfoValidity() {
    String name = _contactPersonNameController.text.trim();
    String phoneNumber = _contactPersonNumberController.text.trim();
    String email = _emailController.text.trim();

    bool nameValid = name.isNotEmpty && name.length >= 2;
    String dialCode = Get.find<LocationController>().countryDialCode;
    bool phoneValid = false;

    if(dialCode == "+91") {
      phoneValid = phoneNumber.length == 10 && RegExp(r'^[6-9][0-9]{9}$').hasMatch(phoneNumber);
    } else if(dialCode == "+61") {
      phoneValid = (phoneNumber.length == 9 && RegExp(r'^[0-9]{9}$').hasMatch(phoneNumber))
          || (phoneNumber.length == 10 && RegExp(r'^0[0-9]{9}$').hasMatch(phoneNumber));
    } else {
      phoneValid = phoneNumber.length >= 8 && phoneNumber.length <= 15;
    }

    bool emailValid = GetUtils.isEmail(email);
    bool isValid = phoneValid && emailValid;
    
    if(_isBasicInfoValid != isValid){
      setState(() {
        _isBasicInfoValid = isValid;
      });
      if(widget.onBasicInfoValidityChanged != null){
        widget.onBasicInfoValidityChanged!(isValid);
      }
      
      if(isValid) {
        try {
          var cartController = Get.find<CartController>();
          var scheduleController = Get.find<ScheduleController>();
          
          String? serviceName;
          double? totalAmount;
          int? quantity;
          String scheduleTime = "";

          if(scheduleController.selectedServiceType == ServiceType.regular) {
            scheduleTime = scheduleController.scheduleTime ?? "";
          } else {
            scheduleTime = "${scheduleController.selectedTime}"; 
          }

          String? categoryId;
          String? serviceId;
          if (cartController.initialCartList.isNotEmpty) {
            serviceName = cartController.initialCartList.first.service?.name;
            totalAmount = widget.grandTotal ?? cartController.initialCartList.first.totalCost.toDouble();
            quantity = 1;
            categoryId = cartController.initialCartList.first.categoryId;
            serviceId = cartController.initialCartList.first.serviceId;
          }

          String? variantKey;
          var listToUse = cartController.initialCartList;
          if (listToUse.isNotEmpty) {
            List<String> variants = [];
            for (int i = 0; i < listToUse.length; i++) {
              var item = listToUse[i];
              if (item.quantity > 0) {
                if (item.variantKey != null && item.variantKey!.isNotEmpty) {
                  variants.add("${item.variantKey} x${item.quantity}");
                } else if (item.service?.name != null) {
                   // Fallback if variantKey is empty but it's an addon service
                  variants.add("${item.service!.name} x${item.quantity}");
                }
              }
            }
            variantKey = variants.join(',');
          }

          String nsn = PhoneVerificationHelper.isPhoneValid(
            Get.find<LocationController>().countryDialCode + _contactPersonNumberController.text.trim(),
            fromAuthPage: false,
          );
          
          Get.find<LeadController>().saveLeadBasicInfo(
            _contactPersonNameController.text.trim(),
            nsn.isNotEmpty ? (Get.find<LocationController>().countryDialCode + nsn) : (Get.find<LocationController>().countryDialCode + _contactPersonNumberController.text.trim()),
            _emailController.text.trim(),
            serviceName: serviceName,
            scheduleTime: scheduleTime,
            totalAmount: totalAmount,
            quantity: quantity,
            variantKey: variantKey,
            categoryId: categoryId,
            serviceId: serviceId,
            zoneId: Get.find<LocationController>().zoneID,
          );
        } catch (e) {
          debugPrint("Error saving lead info: $e");
        }
      }
    }
  }

  setControllerData() async {
    _serviceAddressController.text = widget.address?.address??"";
    _contactPersonNameController.text = widget.address?.contactPersonName??'';
    _alternativeController.text = widget.address?.alternativeContactPersonNumber ?? '';
    _emailController.text = widget.address?.email ?? '';

    String numberAfterValidation = PhoneVerificationHelper.isPhoneValid(
        widget.address?.contactPersonNumber ?? Get.find<UserController>().userInfoModel?.phone ?? "", fromAuthPage: false);
    if(numberAfterValidation == ""){
      _contactPersonNumberController.text = widget.address?.contactPersonNumber?.replaceAll("null", "") ?? "";
    }else{
      _contactPersonNumberController.text = numberAfterValidation;
    }
    _cityController.text = widget.address?.city ?? '';
    _countryController.text = widget.address?.country ?? '';
    _streetController.text = widget.address?.street ?? "";
    _zipController.text = widget.address?.zipCode ?? '';
    _houseController.text = widget.address?.house ?? '';
    _floorController.text = widget.address?.floor ?? '';

    Get.find<LocationController>().updateAddressLabel(addressLabelString: widget.address?.addressLabel??"");
    Get.find<LocationController>().setPlaceMark(addressModel : widget.address);
    Get.find<LocationController>().buttonDisabledOption = false;

    Get.find<LocationController>().setUpdateAddress(widget.address!);
    _initialPosition = LatLng(
      double.parse(widget.address?.latitude ?? '0'),
      double.parse(widget.address?.longitude ?? '0'),
    );
    _checkBasicInfoValidity();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<LocationController>(builder: (locationController) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault, vertical: Dimensions.paddingSizeSmall),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
          border: Border.all(color: Theme.of(context).primaryColor.withValues(alpha: 0.1)),
        ),
        child: Form(key: addressFormKey, child: Column(children: [


          
           Text("add_new_address".tr, style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeLarge),),
           const SizedBox(height: Dimensions.paddingSizeDefault),

            Column(children: [
              _firstList(locationController),
              if(_isBasicInfoValid) ...[
                const SizedBox(height: Dimensions.paddingSizeDefault,),
                _secondList(locationController),
              ],
            ],),

          const SizedBox(height: Dimensions.paddingSizeLarge),

          // CustomButton(
          //   radius: Dimensions.radiusDefault, fontSize: Dimensions.fontSizeLarge,
          //   buttonText: widget.address == null ? 'save_location'.tr : 'update_address'.tr,
          //   isLoading: locationController.isLoading,
          //   onPressed : (locationController.buttonDisabled || locationController.loading) ? null : () => saveAddress(locationController),
          // ),
        ])),
      );
    });
  }

  void saveAddress (LocationController locationController ){
    final isValid = addressFormKey.currentState!.validate();

    if(isValid ){
      addressFormKey.currentState!.save();

      AddressModel addressModel = AddressModel(
        id: widget.address?.id ,
        addressType: locationController.selectedAddressType.name,
        addressLabel:locationController.selectedAddressLabel.name.toLowerCase(),
        contactPersonName: _contactPersonNameController.text,
        contactPersonNumber: Get.find<LocationController>().countryDialCode + PhoneVerificationHelper.isPhoneValid(Get.find<LocationController>().countryDialCode + _contactPersonNumberController.text, fromAuthPage: false),
        address: _serviceAddressController.text,
        city: _cityController.text,
        zipCode: _zipController.value.text,
        country: _countryController.text,
        house: _houseController.text,
        floor: _floorController.text,
        latitude: locationController.position.latitude.toString(),
        longitude: locationController.position.longitude.toString(),
        zoneId: locationController.zoneID,
        street: _streetController.text,
        alternativeContactPersonNumber: _alternativeController.text,
        email: _emailController.text,
      );
      
      if(widget.address == null) {
        // Adding new address - Pass 'false' to avoid auto-back navigation
        locationController.addAddress(addressModel, false).then((response){
             if(response.isSuccess == true){
                 locationController.updateSelectedAddress(locationController.selectedAddress);
                 customSnackBar(response.message?.tr, type: ToasterMessageType.success);
                 if (widget.onSaveSuccess != null) {
                   widget.onSaveSuccess!();
                 }
             }else{
                 customSnackBar(response.message?.tr);
             }
        });
      }else {
          // Update Logic
           locationController.updateAddress(addressModel, widget.address!.id!).then((response) {
            if(response.isSuccess == true) {
              locationController.updateSelectedAddress(addressModel);
              if(widget.address!.id == locationController.getUserAddress()?.id) {
                locationController.saveUserAddress(addressModel);
              }
              customSnackBar(response.message!.tr,type : ToasterMessageType.success);
               if (widget.onSaveSuccess != null) {
                   widget.onSaveSuccess!();
               }
            }else {
              customSnackBar(response.message!.tr);
            }
          });
      }
    }
  }

  void _checkPermission(Function onTap) async {
    LocationPermission permission = await Geolocator.checkPermission();
    if(permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if(permission == LocationPermission.denied) {
      customSnackBar('you_have_to_allow'.tr, type: ToasterMessageType.info);
    }else if(permission == LocationPermission.deniedForever) {
      Get.dialog(const PermissionDialog());
    }else {
      onTap();
    }
  }

  Widget _firstList(LocationController locationController) {
    return Column(children: [
      const SizedBox(height: Dimensions.paddingSizeDefault),
      CustomTextField(
        title: 'name'.tr,
        hintText: 'contact_person_name_hint'.tr,
        inputType: TextInputType.name,
        controller: _contactPersonNameController,
        focusNode: _nameNode,
        nextFocus: _numberNode,
        capitalization: TextCapitalization.words,
        onChanged: (value) => _checkBasicInfoValidity(),
        onValidate: (String? value){
          if(value == null || value.isEmpty){
            return 'enter_contact_person_name'.tr;
          }
          if(!RegExp(r"^[a-zA-Z\s]+$").hasMatch(value)){
            return 'enter_valid_name'.tr;
          }
          return null;
        },
      ),
      const SizedBox(height: Dimensions.paddingSizeExtraLarge),

      CustomTextField(
        onCountryChanged: (CountryCode countryCode) {
          locationController.countryDialCode = countryCode.dialCode!;
          _checkBasicInfoValidity();
          },
        countryDialCode: locationController.countryDialCode,
        title: 'phone_number'.tr,
        hintText: 'contact_person_number_hint'.tr,
        inputType: TextInputType.phone,
        inputAction: TextInputAction.next,
        focusNode: _numberNode,
        nextFocus: _emailNode,
        controller: _contactPersonNumberController,
        onChanged: (value) => _checkBasicInfoValidity(),
        onValidate: (String? value){
          if(value == null || value.isEmpty){
            return 'please_enter_phone_number'.tr;
          }
          String dialCode = locationController.countryDialCode;
          if(dialCode == "+91") {
            if(value.length != 10) return 'mobile_number_must_be_10_digits'.tr;
            if(!RegExp(r'^[6-9][0-9]{9}$').hasMatch(value)) return 'enter_valid_phone_number'.tr;
          } else if(dialCode == "+61") {
            bool validAu = (value.length == 9 && RegExp(r'^[0-9]{9}$').hasMatch(value))
                || (value.length == 10 && RegExp(r'^0[0-9]{9}$').hasMatch(value));
            if(!validAu) return 'enter_valid_phone_number'.tr;
          } else {
            if(value.length < 8) return 'enter_valid_phone_number'.tr;
          }
          return null;
        },
      ),
      const SizedBox(height: Dimensions.paddingSizeExtraLarge),

      CustomTextField(
        title: 'email'.tr,
        hintText: 'Email',
        inputType: TextInputType.emailAddress,
        inputAction: TextInputAction.done,
        focusNode: _emailNode,
        nextFocus: _serviceAddressNode,
        controller: _emailController,
        isRequired: true,
        onChanged: (value) => _checkBasicInfoValidity(),
        onValidate: (String? value){
          if(value == null || value.isEmpty){
            return 'please_enter_email_address'.tr;
          }
          if(!RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]{2,}").hasMatch(value)){
             return 'invalid_email_address'.tr;
          }
          return null;
        },
      ),
      const SizedBox(height: Dimensions.paddingSizeExtraLarge),

      CustomTextField(
        title: 'Alternative Number'.tr,
        hintText: 'Alternative Number',
        inputType: TextInputType.phone,
        inputAction: TextInputAction.done,
        controller: _alternativeController,
        isRequired: false,
      ),
      if(_isBasicInfoValid) ...[
      const SizedBox(height: Dimensions.paddingSizeLarge * 1.2),

      const SizedBox(),

      ],
    ],);
  }

  Widget _secondList(LocationController locationController) {
    return Column(children: [
      const AddressLabelWidget(),
      const SizedBox(height: Dimensions.paddingSizeTextFieldGap),
      CustomTextField(
          title: 'Booking Address',
          hintText: 'Enter booking address...',
          inputType: TextInputType.streetAddress,
          focusNode: _serviceAddressNode,
          nextFocus: _streetNode,
          controller: _serviceAddressController..text = locationController.address.address ?? "",
          isEnabled: false,
          onChanged: (text) {
             locationController.setPlaceMark(address: text);
             if (_isAddressSame) {
               _streetController.text = text;
               locationController.address.street = text;
             }
          },
          onValidate: (String? value){
            if(value == null || value.isEmpty){
              return 'enter_your_address'.tr;
            }
            return null;
          }
      ),
      const SizedBox(height: Dimensions.paddingSizeTextFieldGap),

      InkWell(
        onTap: () {
          setState(() {
            _isAddressSame = !_isAddressSame;
            if (_isAddressSame) {
              _streetController.text = _serviceAddressController.text;
              locationController.address.street = _serviceAddressController.text;
            } else {
              _streetController.text = "";
              locationController.address.street = "";
            }
          });
        },
        child: Row(
          children: [
            SizedBox(
              height: 24, width: 24,
              child: Checkbox(
                value: _isAddressSame,
                onChanged: (bool? value) {
                  setState(() {
                    _isAddressSame = value!;
                    if (_isAddressSame) {
                      _streetController.text = _serviceAddressController.text;
                      locationController.address.street = _serviceAddressController.text;
                    } else {
                      _streetController.text = "";
                      locationController.address.street = "";
                    }
                  });
                },
                activeColor: Theme.of(context).primaryColor,
              ),
            ),
            const SizedBox(width: Dimensions.paddingSizeSmall),
            Text(
              "Booking Address and Service Address same?",
              style: robotoBold.copyWith(
                color: Theme.of(context).primaryColor,
                fontSize: Dimensions.fontSizeDefault,
              ),
            ),
          ],
        ),
      ),

      const SizedBox(height: Dimensions.paddingSizeTextFieldGap),

      CustomTextField(
          title: 'Service Address',
          hintText: 'Enter service address (optional)',
          inputType: TextInputType.streetAddress,
          focusNode: _streetNode,
          inputAction: TextInputAction.done,
          controller: _streetController,
          isRequired: false,
          isEnabled: !_isAddressSame,
          onChanged: (text) {
             locationController.address.street = text;
             if (_isAddressSame && text != _serviceAddressController.text) {
               setState(() {
                 _isAddressSame = false;
               });
             }
          },
      ),
    ],);
  }
}
