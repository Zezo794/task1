



import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:task1/shared/MainCubit/cubit.dart';
import 'package:task1/shared/MainCubit/states.dart';

import 'package:task1/shared/network/local/Cash_helper.dart';
import 'package:task1/shared/network/remote/dio_helper.dart';

import 'modules/home_scrren/home_screen.dart';






final navigatorKey = GlobalKey<NavigatorState>();

void main() async {
   WidgetsFlutterBinding.ensureInitialized();


  DioHelper.init();
  await CashHelper.init();
  runApp(const MyApp());
}










class MyApp extends StatelessWidget {
  const MyApp({super.key});



  @override
  Widget build(BuildContext context) {


    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) {
          return AppCubit()..connectToMqtt();
        }),
      ],
      child: const MaterialApp(
        debugShowCheckedModeBanner: false,
        home:  PlayVideoFromYoutube(videoUrl: 'https://www.youtube.com/watch?v=A3ltMaM6noM',)
      ),
    );
  }
}
