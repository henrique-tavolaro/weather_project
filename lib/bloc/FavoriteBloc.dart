import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:weather_project/data/models/favorite.dart';
import 'package:weather_project/data/source/Dao.dart';

abstract class FavoriteEvents extends Equatable {}

class AddFavoriteEvent extends FavoriteEvents {
  final Favorite favorite;

  AddFavoriteEvent(this.favorite);

  @override
  // TODO: implement props
  List<Object?> get props => throw UnimplementedError();
}

class DeleteFavoriteEvent extends FavoriteEvents{
  final int id;

  DeleteFavoriteEvent(this.id);


  @override
  // TODO: implement props
  List<Object?> get props => throw UnimplementedError();

}

class GetAllFavoritesEvent extends FavoriteEvents {
  GetAllFavoritesEvent();

  @override
  // TODO: implement props
  List<Object?> get props => throw UnimplementedError();
}



abstract class FavoriteState extends Equatable {}

class FavoriteInitialState extends FavoriteState {
  @override
  // TODO: implement props
  List<Object?> get props => [];
}

class FavoriteIsLoadingState extends FavoriteState {
  @override
  // TODO: implement props
  List<Object?> get props => [];
}

class FavoriteLoadedState extends FavoriteState {
  final List<Favorite> favoriteList;

  FavoriteLoadedState({required this.favoriteList});

  @override
  // TODO: implement props
  List<Object?> get props => throw UnimplementedError();
}

class FavoriteErrorState extends FavoriteState {
  final String message;

  FavoriteErrorState({required this.message});

  @override
  // TODO: implement props
  List<Object?> get props => throw UnimplementedError();
}

class FavoriteAddedState extends FavoriteState {
  @override
  // TODO: implement props
  List<Object?> get props => [];
}

class FavoriteDeletedState extends FavoriteState {
  @override
  // TODO: implement props
  List<Object?> get props => [];
}




class FavoriteBloc extends Bloc<FavoriteEvents, FavoriteState> {
  final FavoriteDao favoriteDao;

  FavoriteBloc(this.favoriteDao) : super(FavoriteInitialState());

  @override
  Stream<FavoriteState> mapEventToState(FavoriteEvents event) async* {
    if (event is GetAllFavoritesEvent) {
      yield FavoriteIsLoadingState();
      try {
        List<Favorite> favoriteList = await FavoriteDao().getFavorites();
        yield FavoriteLoadedState(favoriteList: favoriteList);
      } catch (e) {
        yield FavoriteErrorState(message: e.toString());
      }
    }
    if (event is AddFavoriteEvent) {
      try {
        await FavoriteDao().insertFavorite(event.favorite);
        yield FavoriteAddedState();
      } catch (e) {
        yield FavoriteErrorState(message: e.toString());
      }
    }
    if(event is DeleteFavoriteEvent) {
      try {
        await FavoriteDao().deleteFavorite(event.id);
        yield FavoriteDeletedState();
      } catch (e) {
        yield FavoriteErrorState(message: e.toString());
    }
    }
  }
}
