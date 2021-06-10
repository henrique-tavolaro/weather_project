class Favorite {
  final int id;
  final String cityName;

  Favorite(this.id,this.cityName);

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'cityName': cityName,
    };
  }

  @override
  String toString() {
    return 'Favorite{id: $id, cityName: $cityName}';
  }
}