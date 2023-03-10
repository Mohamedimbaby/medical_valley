import 'dart:math';

import 'package:cool_alert/cool_alert.dart';
import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:medical_valley/core/app_colors.dart';
import 'package:medical_valley/core/app_styles.dart';
import 'package:medical_valley/core/dialogs/loading_dialog.dart';
import 'package:medical_valley/core/medical_injection.dart';
import 'package:medical_valley/core/strings/images.dart';
import 'package:medical_valley/core/widgets/custom_app_bar.dart';
import 'package:medical_valley/core/widgets/loading_screen.dart';
import 'package:medical_valley/features/offers/presentation/data/model/offers_response.dart';
import 'package:medical_valley/features/offers/presentation/presentation/bloc/negotiate/negotiate_bloc.dart';
import 'package:medical_valley/features/offers/presentation/presentation/bloc/negotiate/negotiate_state.dart';
import 'package:medical_valley/features/offers/presentation/presentation/bloc/offers_bloc.dart';
import 'package:medical_valley/features/offers/presentation/presentation/bloc/offers_state.dart';
import 'package:medical_valley/features/offers/widgets/offers_options_button.dart';
import 'package:rxdart/rxdart.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
class OffersScreen extends StatefulWidget {
 final int serviceId , categoryId ;
  const OffersScreen({
    required this.categoryId ,
    required this.serviceId,
    Key? key}) : super(key: key);

  @override
  State<OffersScreen> createState() => _OffersScreenState();
}

class _OffersScreenState extends State<OffersScreen> {
  BehaviorSubject<bool> optionDisplayed = BehaviorSubject();
  OffersBloc offersBloc = getIt.get<OffersBloc>();
  NegotiateBloc negotiateBloc = getIt.get<NegotiateBloc>();
  BehaviorSubject<int> sortOption = BehaviorSubject();
  BehaviorSubject<List<int?>> negotiatedOffersSubject = BehaviorSubject();
  final PagingController<int, OfferModel> pagingController =
  PagingController(firstPageKey: 1);
  int nextPage = 1 ;
  int nextPageKey = 1 ;

  @override
  void initState() {
    offersBloc.getOffers(OffersEvent(nextPage, 10 , 24509  , 11));
    negotiatedOffersSubject.sink.add([]);
    pagingController.addPageRequestListener((pageKey) {
      nextPageKey = pageKey;
      nextPage += 1;
      offersBloc.getOffers(OffersEvent(nextPage, 10 , 24509  , 11));
    });
    optionDisplayed.sink.add(false);
    sortOption.sink.add(0);
    super.initState();
  }
  @override
  Widget build(BuildContext context) {

    return GestureDetector(
      onTap: () => optionDisplayed.sink.add(false),
      child: Scaffold(
        appBar:  MyCustomAppBar(
          header: AppLocalizations.of(context)!.request_price,
          leadingIcon: GestureDetector(
              onTap: (){
                Navigator.pop(context);
              },
              child: const Icon(Icons.arrow_back_ios)),
        ),
        body: Stack(
          children: [
            BlocBuilder<OffersBloc, OffersState>(
                bloc: offersBloc,
                builder: (context, state) {
                  if(state is OffersStateLoading){
                    return SizedBox(
                        height: MediaQuery.of(context).size.height,
                        width: MediaQuery.of(context).size.width,
                        child: const Center(child: CircularProgressIndicator()));
                  }
                  if(state is OffersStateSuccess){
                    if(state.offersResponse.data!.results!.length == 10){
                      pagingController.appendPage(state.offersResponse.data!.results!, nextPageKey);
                    }else {
                      if(pagingController.value.itemList != state.offersResponse.data!.results) {
                        pagingController.appendLastPage(
                            state.offersResponse.data!.results!);
                      }
                    }
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 60.0),
                      child: StreamBuilder<List<int?>>(
                        stream: negotiatedOffersSubject.stream,
                        builder: (context, snapshot) {
                          return PagedListView<int, OfferModel>(
                            pagingController: pagingController,
                            builderDelegate: PagedChildBuilderDelegate(
                              itemBuilder: (context, OfferModel item, index) {
                                return OfferCard(items:item,
                                  onNegotiatePressed: onNegotiatePressed,
                                  onBookPressed: (int? id) {    },
                                  isEnabled: !offersNegotiatedIds.contains(item.id),
                                );
                              },
                            ),
                          );
                        }
                      ),
                    );
                  }
                  return const SizedBox();
                }
            ),
            StreamBuilder<List<int?>>(
              stream: negotiatedOffersSubject.stream,
              builder: (context, snapshot) {
                return Align(
                    alignment: Alignment.bottomCenter,
                    child:
                    BlocListener<NegotiateBloc, NegotiateState >(
                      bloc: negotiateBloc,
                      listener: (context, state) {
                        if(state is NegotiateStateLoading ){
                          LoadingDialogs.showLoadingDialog(context);
                        }
                        else if(state  is NegotiateStateSuccess ){
                          LoadingDialogs.hideLoadingDialog();
                          CoolAlert.show(
                            barrierDismissible: false,
                            context: context,
                            onConfirmBtnTap: ()async{
                              Navigator.pop(context);
                              Navigator.pushReplacement(context, MaterialPageRoute(builder: (c)=> const LoadingScreen()));
                            },
                            type: CoolAlertType.success,
                            text: AppLocalizations.of(context)!.booked_successed,
                          );
                        }
                        else {
                          LoadingDialogs.hideLoadingDialog();
                          CoolAlert.show(
                            barrierDismissible: false,
                            context: context,
                            onConfirmBtnTap: ()async{
                              Navigator.pop(context);
                            },
                            type: CoolAlertType.error,
                            text: AppLocalizations.of(context)!.something_went_wrong,
                          );
                        }
                      },
                      child : GestureDetector(
                        onTap: ()=>negotiateBloc.negotiate(offersNegotiatedIds),
                        child: Container(
                        height: 90.h,
                        alignment: Alignment.center,
                        decoration: const BoxDecoration(
                            color: secondaryColor
                        ),
                        child:  Text("${AppLocalizations.of(context)!.negotiate} (${negotiatedOffersSubject.value.length})", style: AppStyles.baloo2FontWith500WeightAnd25Size.copyWith(color: whiteColor),),
                    ),
                      )
                    )
                );
              }
            )
          ],
        ),
      ),
    );
  }
  List<int?> offersNegotiatedIds = [];
  onNegotiatePressed  (int? id ) {
    offersNegotiatedIds.contains(id) ? offersNegotiatedIds.remove(id): offersNegotiatedIds.add(id);
    negotiatedOffersSubject.sink.add(offersNegotiatedIds);
  }

  onBookPressed (int? id ) {

  }
}
class OfferCard extends StatelessWidget {
  final OfferModel items;
  final Function(int? id) onNegotiatePressed , onBookPressed ;
  final bool isEnabled ;
   const OfferCard({required this.items,required this.onNegotiatePressed,
     required this.onBookPressed ,
     required this.isEnabled ,
     Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 160.h,
      margin: const EdgeInsets.symmetric(horizontal: 12 ,vertical: 8),
      decoration: BoxDecoration(
          color: whiteColor ,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(
                color: Color(0xffF2F2F2),
                offset: Offset(2,2),
                blurRadius: 3,
                spreadRadius: 2
            )
          ]
      ),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Padding(
              padding: const EdgeInsets.only(left: 12 ,right: 12,top: 12,bottom: 12),
              child: Row(
                children: [
                  Column(
                    children: [
                      Text( "3 min" , style: AppStyles.baloo2FontWith400WeightAnd18SizeAndBlack,),
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color:Colors.grey.shade300 ),
                            image: const DecorationImage(
                              image: AssetImage(personImage),
                            )
                        ),
                      ),
                      Row(
                        children: [
                          const Icon(Icons.star , color: Color(0xffEB8B17),size: 16,),
                          Text("4.2", style: AppStyles.baloo2FontWith400WeightAnd18SizeAndBlack.copyWith(color: const Color(0xffD8D7D9)),),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(width:16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(items.providerStr ?? "", style: AppStyles.baloo2FontWith400WeightAnd18SizeAndBlack,),
                        const SizedBox(height:2),
                        Row(
                          children: [
                            const Icon(Icons.location_pin, color: primaryColor,),
                            Expanded(child: Text(items.distanceInMeter.toString(), style: AppStyles.baloo2FontWith400WeightAnd18SizeAndBlack,overflow: TextOverflow.ellipsis,maxLines: 1,)),
                            Text("m" , style: AppStyles.baloo2FontWith400WeightAnd18SizeAndBlack,),
                          ],
                        ),
                        Column(
                          children: [
                            const SizedBox(height:8),
                            Container(
                              decoration: BoxDecoration(color: primaryColor, borderRadius: BorderRadius.circular(8)),                      alignment: Alignment.center,
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                              child: Text("${items.price} RS", style: AppStyles.baloo2FontWith400WeightAnd18SizeAndBlack.copyWith(color: whiteColor,fontSize: 14),),
                            )
                          ],
                        )
                      ],
                    ),
                  ),
                  const SizedBox(width:16),
                ],
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Column(
              children: [
                Expanded(
                    flex: Random(5).nextInt(10),
                    child: GestureDetector(
                        onTap: ()=> onNegotiatePressed(items.id),
                        child: OffersOptionsButton(buttonType : ButtonType.negotiate,title :  AppLocalizations.of(context)!.negotiate,isEnabled: isEnabled, ))),
                const SizedBox(height: 4,),
                Expanded(
                    flex: Random(5).nextInt(10),
                    child: GestureDetector(
                        onTap: ()=> onBookPressed(items.id),
                        child: OffersOptionsButton(buttonType :ButtonType.book,title : AppLocalizations.of(context)!.book,isEnabled: isEnabled))),
              ],
            ),
          )
        ],
      ),
    );
  }




}



