import 'package:demandium/utils/core_export.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class CustomTimePicker extends StatelessWidget {
  const CustomTimePicker({super.key}) ;

  @override
  Widget build(BuildContext context) {
    return Padding(padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('time'.tr, style: robotoBold.copyWith(fontSize: Dimensions.fontSizeLarge, color: Theme.of(Get.context!).colorScheme.primary)),
          const SizedBox(height: Dimensions.paddingSizeSmall),
          
          GetBuilder<ScheduleController>(builder: (createPostController) {
            // Generate time slots from 08:00 to 18:00 (6:00 PM) with 30 min intervals
            List<DateTime> timeSlots = [];
            DateTime startTime = DateTime(2000, 1, 1, 8, 0);
            DateTime endTime = DateTime(2000, 1, 1, 18, 0);
            
            DateTime now = DateTime.now();
            String todayStr = DateFormat('yyyy-MM-dd').format(now);
            bool isToday = createPostController.selectedDate == todayStr;

            while (startTime.isBefore(endTime) || startTime.isAtSameMomentAs(endTime)) {
              if (isToday) {
                // If today, only show slots starting at least 2 hours in the future
                DateTime slotDateTime = DateTime(now.year, now.month, now.day, startTime.hour, startTime.minute);
                if (slotDateTime.isAfter(now.add(const Duration(hours: 2))) || slotDateTime.isAtSameMomentAs(now.add(const Duration(hours: 2)))) {
                  timeSlots.add(startTime);
                }
              } else {
                timeSlots.add(startTime);
              }
              startTime = startTime.add(const Duration(minutes: 30));
            }

            if (timeSlots.isEmpty) {
              return SizedBox(
                height: 60,
                child: Center(
                  child: Text(
                    'no_available_slots_for_today'.tr == 'no_available_slots_for_today' ? 'No slots available for today' : 'no_available_slots_for_today'.tr,
                    style: robotoMedium.copyWith(color: Theme.of(context).disabledColor),
                  ),
                ),
              );
            }

            return Container(
              height: 120, // Adjusted height for 2 rows of selection
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  childAspectRatio: 2.5,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                ),
                itemCount: timeSlots.length,
                shrinkWrap: true,
                scrollDirection: Axis.vertical,
                itemBuilder: (context, index) {
                  DateTime slot = timeSlots[index];
                  String formattedTime = DateFormat('hh:mm a').format(slot);
                  String rawTime = DateFormat('HH:mm:ss').format(slot);
                  
                  bool isSelected = createPostController.selectedTime == rawTime;

                  return InkWell(
                    onTap: () {
                      createPostController.selectedTime = rawTime;
                      createPostController.updateScheduleType(scheduleType: ScheduleType.schedule);
                      createPostController.update();
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: isSelected ? Theme.of(context).colorScheme.primary : Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                        border: Border.all(
                          color: isSelected ? Theme.of(context).colorScheme.primary : Theme.of(context).hintColor.withValues(alpha: 0.3),
                        ),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        formattedTime,
                        style: robotoMedium.copyWith(
                          fontSize: Dimensions.fontSizeSmall,
                          color: isSelected ? Colors.white : Theme.of(context).textTheme.bodyLarge?.color,
                        ),
                      ),
                    ),
                  );
                },
              ),
            );
          }),
        ],
      ),
    );
  }
}
