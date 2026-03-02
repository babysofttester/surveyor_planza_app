/* import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:showcaseview/showcaseview.dart';

class CommonDropDown extends StatelessWidget {
  GlobalKey showkey;
  String description;
  
   CommonDropDown({super.key, required this.showkey,required this.description,});

  @override
  Widget build(BuildContext context) {
    return    Obx(() => Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 12.0, vertical: 8.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10.0),
                border: Border.all(
                  color: Colors.grey,
                  width: 1.0,
                ),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 4.0,
                    spreadRadius: 1.0,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: DropdownButton<BusinessUnits>(
                value: checkInController.selectedBusinessUnit.value,
                hint: const Text('Select Business Unit'),
                items: staticBusinessUnits.map((BusinessUnits unit) {
                  return DropdownMenuItem<BusinessUnits>(
                    value: unit,
                    child: Text(unit.name!),
                  );
                }).toList(),
                onChanged: (BusinessUnits? newValue) {
                  if (newValue != null) {
                    checkInController.selectedBusinessUnit.value =
                        newValue;
                    checkInController.bID.value =
                        newValue.id.toString();
                    checkInController.resetProperty();
                    checkInController
                        .fetchRelatedProperty(newValue.id.toString());
                    checkInController.gotPropertyDetailData.value =
                        false;
                  }
                },
                underline: const SizedBox(),
                isExpanded: true,
              ),
         ),
            Positioned(
              left: 20,
              top: -6,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 4.0),
                color: Colors.white,
                child: const Text(
                  'Business Unit',
                  style: TextStyle(
                    fontSize: 12.0,
                    color: Colors.grey,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ))
        ;
  }
}
 */

// import 'dart:ffi';

// import 'package:flutter/material.dart' hide BoxDecoration, BoxShadow;
// import 'package:flutter_inset_box_shadow/flutter_inset_box_shadow.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

// ignore: must_be_immutable
class CommonDropdownButton extends StatelessWidget {
  String? chosenValue = '';
  final String? hintText;
  final List<String>? itemsList;
  final Function(dynamic value)? onChanged;
  final String? Function(String?)? validator;
  final Key formKey;
  double? mleft;
  double? mright;
  double? mtop;
  CommonDropdownButton(
      {super.key,
      this.chosenValue,
      this.hintText,
      this.itemsList,
      this.onChanged,
      this.validator,
      required this.formKey,
      this.mleft,
      this.mright,
      this.mtop});
  RxBool isTrue = true.obs;
  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Obx(
        () => isTrue.value == true
            ? Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12.0, vertical: 8.0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10.0),
                      border: Border.all(
                        color: Colors.grey,
                        width: 1.0,
                      ),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 4.0,
                          spreadRadius: 1.0,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButtonFormField<String>(
                        decoration:
                            const InputDecoration.collapsed(hintText: ""),
                        elevation: 1,
                        validator: validator,
                        isExpanded: true,
                        hint: Text(hintText ?? ''),
                        iconSize: Get.width * 0.03,
                        iconEnabledColor: Colors.black,
                        icon: Icon(
                          Icons.arrow_drop_down_sharp,
                          size: Get.width * 0.06,
                        ),
                        value: chosenValue,
                        items: itemsList!.map((item) {
                          // Capitalize the first letter of each item
                          String displayText =
                              item[0].toUpperCase() + item.substring(1);

                          return DropdownMenuItem<String>(
                            value: item,
                            child: Text(displayText),
                          );
                        }).toList(),
                        // items: itemsList?.map<DropdownMenuItem<String>>((String value) {
                        //   return DropdownMenuItem<String>(
                        //     value: value,
                        //     child: Text(value),
                        //   );
                        // }).toList(),
                        onChanged: onChanged,
                      ),
                    ),
                  ),
                  Positioned(
                    left: 20,
                    top: -6,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 4.0),
                      color: Colors.white,
                      child: Text(
                        hintText!,
                        // 'Business Unit',
                        style: const TextStyle(
                          fontSize: 12.0,
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              )
            : const SizedBox(),
      ),
    );
  }
}
