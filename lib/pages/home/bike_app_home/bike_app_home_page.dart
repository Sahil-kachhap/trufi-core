import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trufi_core/blocs/app_review_cubit.dart';
import 'package:trufi_core/blocs/configuration/configuration_cubit.dart';
import 'package:trufi_core/blocs/home_page_cubit.dart';
import 'package:trufi_core/blocs/payload_data_plan/payload_data_plan_cubit.dart';
import 'package:trufi_core/blocs/preferences/preferences_cubit.dart';
import 'package:trufi_core/blocs/search_locations/search_locations_cubit.dart';
import 'package:trufi_core/l10n/trufi_localization.dart';
import 'package:trufi_core/models/map_route_state.dart';
import 'package:trufi_core/models/trufi_place.dart';
import 'package:trufi_core/pages/home/bike_app_home/results_screen.dart';
import 'package:trufi_core/pages/home/plan_map/widget/custom_text_button.dart';
import 'package:trufi_core/pages/home/bike_app_home/widgets/location_icon.dart';
import 'package:trufi_core/widgets/fetch_error_handler.dart';
import 'package:trufi_core/widgets/trufi_drawer.dart';

import '../../choose_location.dart';
import '../home_page.dart';
import 'widgets/ba_form_field_landscape.dart';
import 'widgets/ba_form_field_portrait.dart';
import 'widgets/date_time_picker/date_selector.dart';

class BikeAppHomePage extends StatefulWidget {
  static const String route = '/';
  const BikeAppHomePage({Key key}) : super(key: key);

  @override
  _BikeAppHomePageState createState() => _BikeAppHomePageState();
}

class _BikeAppHomePageState extends State<BikeAppHomePage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  int selectedRadio = 0;
  double rating = 0;
  bool firstScreen = true;

  void setSelectedRadio(int value) {
    setState(() {
      selectedRadio = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isPortrait =
        MediaQuery.of(context).orientation == Orientation.portrait;
    final homePageCubit = context.watch<HomePageCubit>();
    final homePageState = homePageCubit.state;
    final config = context.read<ConfigurationCubit>().state;
    return BlocListener<HomePageCubit, MapRouteState>(
      listener: (context, state) {
        final hasPlan = state.plan != null && state.plan.error == null;
        if (hasPlan) {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (BuildContext context) =>
                  ResultsScreen(plan: state.plan),
            ),
          );
        }
      },
      listenWhen: (oldState, newState) {
        return oldState.plan == null;
      },
      child: Scaffold(
        key: _scaffoldKey,
        backgroundColor: const Color(0xFFF4F4F4),
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(100),
          child: AppBar(
            elevation: 0,
            toolbarHeight: 100,
            leading: Padding(
              padding: const EdgeInsets.only(left: 15),
              child: IconButton(
                onPressed: () => _scaffoldKey.currentState.openDrawer(),
                icon: const Icon(
                  Icons.menu_outlined,
                  size: 35,
                ),
              ),
            ),
            title: Padding(
              padding: const EdgeInsets.only(right: 15),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: const [
                  Text(
                    "Bike & Bahn",
                    style: TextStyle(fontSize: 25, color: Colors.white),
                    textAlign: TextAlign.right,
                  ),
                ],
              ),
            ),
          ),
        ),
        body: SafeArea(
          child: Stack(
            children: [
              ListView(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                children: [
                  // TODO translate
                  const SizedBox(height: 35),
                  Text(
                    "Willkomment!",
                    style: theme.textTheme.subtitle1.copyWith(fontSize: 30),
                  ),
                  const SizedBox(height: 28),
                  if (isPortrait)
                    BAFormFieldsPortrait(
                      spaceBetween: 20,
                      onSaveFrom: (TrufiLocation fromPlace) =>
                          homePageCubit.setFromPlace(fromPlace),
                      onSaveTo: (TrufiLocation fromPlace) =>
                          homePageCubit.setToPlace(fromPlace),
                      onSwap: () => homePageCubit.swapLocations(),
                    )
                  else
                    BAFormFieldsLandscape(
                      onSaveFrom: (TrufiLocation fromPlace) =>
                          homePageCubit.setFromPlace(fromPlace),
                      onSaveTo: (TrufiLocation fromPlace) =>
                          homePageCubit.setToPlace(fromPlace),
                      onSwap: () => homePageCubit.swapLocations(),
                    ),
                  const SizedBox(height: 25),
                  if (isPortrait)
                    Column(
                      children: [
                        DateSelector(
                          color: const Color(0xff747474),
                          onFetchPlan: () {},
                        ),
                        const SizedBox(height: 35),
                        Row(
                          children: [
                            const Text(
                              'Mehr Rad',
                              style: TextStyle(fontSize: 16),
                            ),
                            Expanded(
                              child: Slider(
                                value: rating,
                                onChanged: (value) {
                                  setState(() {
                                    log(value.toString());
                                    rating = value;
                                  });
                                },
                                label: '',
                                max: 100,
                              ),
                            ),
                            const Text(
                              'Mehr Offi',
                              style: TextStyle(fontSize: 16),
                            ),
                          ],
                        ),
                      ],
                    )
                  else
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: DateSelector(
                            color: const Color(0xff747474),
                            onFetchPlan: () {},
                          ),
                        ),
                        const SizedBox(width: 48.0),
                        Expanded(
                          child: Row(
                            children: [
                              const Text(
                                'Mehr Rad',
                                style: TextStyle(fontSize: 16),
                              ),
                              Expanded(
                                child: Slider(
                                  value: rating,
                                  onChanged: (value) {
                                    setState(() {
                                      log(value.toString());
                                      rating = value;
                                    });
                                  },
                                  label: '',
                                  max: 100,
                                ),
                              ),
                              const Text(
                                'Mehr Offi',
                                style: TextStyle(fontSize: 16),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  const SizedBox(height: 25),
                  Text(
                    "Favoriten",
                    style: theme.textTheme.subtitle1.copyWith(fontSize: 17),
                  ),
                  SizedBox(
                    height: 80,
                    child: Row(
                      children: [
                        Flexible(
                          child: BlocBuilder<SearchLocationsCubit,
                              SearchLocationsState>(
                            builder: (context, state) {
                              return ListView(
                                scrollDirection: Axis.horizontal,
                                physics: const BouncingScrollPhysics(),
                                shrinkWrap: true,
                                children: [
                                  Row(
                                    children: [
                                      ...state.myDefaultPlaces
                                          .map(
                                            (place) => LocationIcon(
                                              location: place,
                                              margin: const EdgeInsets.symmetric(
                                                  horizontal: 5),
                                            ),
                                          )
                                          .toList(),
                                      ...state.myPlaces
                                          .map(
                                            (place) => LocationIcon(
                                              location: place,
                                              margin: const EdgeInsets.symmetric(
                                                  horizontal: 5),
                                            ),
                                          )
                                          .toList(),
                                      Container(
                                        margin: const EdgeInsets.only(left: 5),
                                        child: InkWell(
                                          onTap: () {
                                            _addNewPlace(context);
                                          },
                                          child: Container(
                                            padding: const EdgeInsets.all(5),
                                            decoration: BoxDecoration(
                                              color: Colors.transparent,
                                              shape: BoxShape.circle,
                                              border: Border.all(
                                                width: 2,
                                                color: theme.accentColor,
                                              ),
                                            ),
                                            child: Icon(
                                              Icons.add,
                                              color: theme.accentColor,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  )
                                ],
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 25),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 50),
                    child: CustomTextButton(
                      text: 'SUCHEN',
                      onPressed: () {
                        _callFetchPlan(context);
                      },
                      color: theme.accentColor,
                      borderRadius: 10,
                      height: 45,
                    ),
                  ),
                ],
              ),
              if (config.animations.loading != null && homePageState.isFetching)
                Positioned.fill(
                    child: Container(
                  color: Colors.black.withOpacity(0.5),
                  child: const Center(child: CircularProgressIndicator()),
                ))
            ],
          ),
        ),
        drawer: const TrufiDrawer(HomePage.route),
      ),
    );
  }

  Future<void> _addNewPlace(BuildContext context) async {
    final searchLocationsCubit = context.read<SearchLocationsCubit>();
    final ChooseLocationDetail chooseLocationDetail =
        await ChooseLocationPage.selectPosition(
      context,
    );
    if (chooseLocationDetail != null) {
      searchLocationsCubit.insertMyPlace(TrufiLocation(
        description: chooseLocationDetail.description,
        address: chooseLocationDetail.street,
        latitude: chooseLocationDetail.location.latitude,
        longitude: chooseLocationDetail.location.longitude,
        type: 'saved_place:map',
      ));
    }
  }

  Future<void> _callFetchPlan(BuildContext context) async {
    final TrufiLocalization localization = TrufiLocalization.of(context);
    final homePageCubit = context.read<HomePageCubit>();
    final appReviewCubit = context.read<AppReviewCubit>();
    final correlationId = context.read<PreferencesCubit>().state.correlationId;
    final payloadDataPlanCubit = context.read<PayloadDataPlanCubit>();
    await homePageCubit
        .fetchPlan(correlationId, localization,
            advancedOptions: payloadDataPlanCubit.state)
        .then((value) => appReviewCubit.incrementReviewWorthyActions())
        .catchError((error) => onFetchError(context, error as Exception));
    final homePageState = homePageCubit.state;
    final hasPlan =
        homePageState.plan != null && homePageState.plan.error == null;
    if (hasPlan) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (BuildContext context) =>
              ResultsScreen(plan: homePageState.plan),
        ),
      );
    }
  }
}
