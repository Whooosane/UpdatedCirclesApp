import 'package:circleapp/controller/api/offer_apis.dart';
import 'package:circleapp/models/offer_models/offers_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';

class OffersController extends GetxController {
  late final BuildContext context;

  OffersController(this.context);

  RxBool loading = false.obs;
  Rxn<OffersModel?> offersModel = Rxn<OffersModel>();
  Rxn<Offer?> offer = Rxn<Offer>();

  Future<void> getOffers({required bool load, required String interest}) async {
    if (load) {
      loading.value = true;
    }

    offersModel.value = await OfferApis(context).getOffers(interest);

    loading.value = false;
  }

  Future<void> getOfferDetails({required bool load, required String offerId}) async {
    if (load) {
      loading.value = true;
    }

    // offersModel.value = await OfferApis(context).getOffers(interest);

    loading.value = false;
  }

  Future<void> sendOffer({required bool load, required String offerId, required String circleId}) async {
    if (load) {
      loading.value = true;
    }

    offer.value = await OfferApis(context).sendOffer(offerId, circleId);

    loading.value = false;
  }
}
