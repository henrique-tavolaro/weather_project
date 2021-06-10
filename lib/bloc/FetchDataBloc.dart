
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:weather_project/data/models/weather.dart';
import 'package:weather_project/data/source/NetworkService.dart';

abstract class FetchDataEvent extends Equatable{}

class FetchEvent extends FetchDataEvent{
  final String cityName;

  FetchEvent(this.cityName);

  @override
  // TODO: implement props
  List<Object?> get props => throw UnimplementedError();
}

abstract class FetchDataState extends Equatable{}

class FetchInitialState extends FetchDataState{
  @override
  // TODO: implement props
  List<Object?> get props => [];

}

class FetchLoadingState extends FetchDataState {
  @override
  // TODO: implement props
  List<Object?> get props => [];
}
class FetchLoadedState extends FetchDataState {

  final Weather weather;

  FetchLoadedState({required this.weather});

  @override
  // TODO: implement props
  List<Object?> get props => throw UnimplementedError();
}

class FetchErrorState extends FetchDataState {

  final String message;

  FetchErrorState({required this.message});

  @override
  // TODO: implement props
  List<Object?> get props => throw UnimplementedError();
}


class FetchDataBloc extends Bloc<FetchDataEvent, FetchDataState> {

  final NetworkService networkService;

  FetchDataBloc(this.networkService) : super(FetchInitialState());

  @override
  Stream<FetchDataState> mapEventToState(FetchDataEvent event) async* {
    if(event is FetchEvent){
      yield FetchLoadingState();
      try {
        Weather weather = await networkService.fetchWeather(event.cityName);
        yield FetchLoadedState(weather: weather);
      } catch (e) {
        yield FetchErrorState(message: e.toString());
      }
    } else {
      throw UnimplementedError();
    }

  }

}