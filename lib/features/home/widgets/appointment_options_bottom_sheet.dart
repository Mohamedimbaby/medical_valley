import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:medical_valley/core/app_colors.dart';
import 'package:medical_valley/core/app_paddings.dart';
import 'package:medical_valley/core/app_styles.dart';
import 'package:medical_valley/features/home/widgets/option_button.dart';
import 'package:rxdart/rxdart.dart';

import '../home_screen/persentation/screens/calender_screen.dart';

class AppointmentsBottomSheet extends StatelessWidget {
  final Function(int bookTimeId) onBookRequest ;
  final Function() onScheduledPressed ;
   AppointmentsBottomSheet( {
     required this.onBookRequest ,
     required this.onScheduledPressed ,
     Key? key}) : super(key: key);
  late AppointmentType type  ;
  BehaviorSubject<AppointmentType> appointmentTypeSubject = BehaviorSubject.seeded(AppointmentType.immediate);
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AppointmentType>(
      stream: appointmentTypeSubject.stream,
      builder: (context, snapshot) {
        return Container(
          height: 290.h,
          padding: bigPaddingHV,
          decoration: BoxDecoration(
            color: whiteColor,
            boxShadow: const [
              BoxShadow(
                  offset: Offset(2, 1),
                  blurRadius: 5,
                  spreadRadius: 1,
                  color: shadowGrey)
            ],
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: const Icon(
                        Icons.close,
                        color: blackColor,
                      )),
                  Text(
                    AppLocalizations.of(context)!.are_you_sure_about_the_service,
                    style: AppStyles.baloo2FontWith400WeightAnd20Size
                        .copyWith(color: blackColor),
                  ),
                  const SizedBox()
                ],
              ),
              SizedBox(
                height: 23.h,
              ),
              Row(
                children: [
                  Expanded(
                      child: GestureDetector(onTap: ()=> appointmentTypeSubject.sink.add(AppointmentType.immediate),
                        child: OptionButton(
                    title: AppLocalizations.of(context)!.immediate,
                    activatedColor: darkGreen,
                    unActivatedColor: buttonGrey,
                    isActivated: appointmentTypeSubject.value == AppointmentType.immediate,
                  ),
                      )),
                  const SizedBox(
                    width: 8,
                  ),
                  Expanded(
                      child: GestureDetector(
                      onTap: ()=>
                          appointmentTypeSubject.sink.add(AppointmentType.earliest),
                        child: OptionButton(
                    title: AppLocalizations.of(context)!.earliest,
                    activatedColor: primaryColor,
                    unActivatedColor: buttonGrey,
                    isActivated: appointmentTypeSubject.value == AppointmentType.earliest,
                  ),
                      ))
                ],
              ),
              SizedBox(
                height: 14.h,
              ),
              Row(
                children: [
                  Expanded(
                      child:
                      GestureDetector( onTap: (){
                        appointmentTypeSubject
                            .sink.add(AppointmentType.scheduleOnAppointment);
                        Navigator.pop(context);
                        onScheduledPressed();
                      },
                        child: OptionButton(
                    title: AppLocalizations.of(context)!.schedule_on,
                    activatedColor: secondaryColor,
                    unActivatedColor: buttonGrey,
                    isActivated: appointmentTypeSubject.value == AppointmentType.scheduleOnAppointment,
                  ),
                      )),
                ],
              ),
              SizedBox(
                height: 14.h,
              ),
              Row(
                children: [
                  Expanded(
                      child: GestureDetector(
                          onTap: () {
                            onBookRequest(appointmentTypeSubject.value.index+1);
                          },
                          child: OptionButton(
                            textStyle: AppStyles.baloo2FontWith700WeightAnd22Size
                                .copyWith(color: whiteColor),
                            title: AppLocalizations.of(context)!.confirm,
                            activatedColor: primaryColor,
                            unActivatedColor: buttonGrey,
                            isActivated: true,
                          ))),
                ],
              )
            ],
          ),
        );
      }
    );
  }
}
enum AppointmentType {
  immediate , earliest , scheduleOnAppointment
}