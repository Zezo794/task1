 abstract class AppState {}

 class InitialAppState extends AppState{}


 class ChangeNavBarStates extends AppState{}

 class FetchVideoQualitiesLoadingState extends AppState{}
 class FetchVideoQualitiesSuccessState extends AppState{}
 class FetchVideoQualitiesErrorState extends AppState {
  final String error;

  FetchVideoQualitiesErrorState(this.error);
 }

 class ChangeVideoQualitySuccessState extends AppState{}

 class ChangInitializePlayerDataSuccessState extends AppState{}



