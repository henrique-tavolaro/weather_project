import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:weather_project/data/models/forecast.dart';
import 'package:weather_project/data/source/NetworkService.dart';

abstract class FetchForecastEvent extends Equatable{}

class ForecastEvent extends FetchForecastEvent{
  final String cityName;

  ForecastEvent(this.cityName);

  @override
  // TODO: implement props
  List<Object?> get props => throw UnimplementedError();
}

abstract class FetchForecastState extends Equatable{}

class ForecastInitialState extends FetchForecastState{
  @override
  // TODO: implement props
  List<Object?> get props => [];

}

class ForecastLoadingState extends FetchForecastState {
  @override
  // TODO: implement props
  List<Object?> get props => [];
}
class ForecastLoadedState extends FetchForecastState {

  final Forecast forecast;

  ForecastLoadedState({required this.forecast});

  @override
  // TODO: implement props
  List<Object?> get props => throw UnimplementedError();
}

class ForecastErrorState extends FetchForecastState {

  final String message;

  ForecastErrorState({required this.message});

  @override
  // TODO: implement props
  List<Object?> get props => throw UnimplementedError();
}


class ForecastBloc extends Bloc<FetchForecastEvent, FetchForecastState> {

  final NetworkService networkService;

  ForecastBloc(this.networkService) : super(ForecastInitialState());

  @override
  Stream<FetchForecastState> mapEventToState(FetchForecastEvent event) async* {
    if(event is ForecastEvent){
      yield ForecastLoadingState();
      try {
        dynamic forecast = await networkService.fetchForecast(event.cityName);
        yield ForecastLoadedState(forecast: forecast);
      } catch (e) {
        yield ForecastErrorState(message: e.toString());
      }
    } else {
      throw UnimplementedError();
    }
  }
}