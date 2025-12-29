class DateModel{
  final int year;
  final int month;
  final int day;
  int? hour;
  int? minute;
  int?second;
  int? millisecond;

  DateModel({required this.year, required this.month, required this.day, this.hour, this. millisecond, this.minute, this.second});


   Map<String, dynamic> toJson()
  {
    return {
      "year" : year,
      "month" : month,
      "day" : day,
      "hour" : hour,
      "minute" : minute,
      "second" : second,
      "millisecond" : millisecond
    };
  }

  factory DateModel.fromString(String jsDate)
  {
    return DateModel(year: int.parse(jsDate.substring(0, 4)), month: int.parse(jsDate.substring(5, 7)), day: int.parse(jsDate.substring(8, 10)));
  }

  factory DateModel.fromJson(Map<String, dynamic> json)
  {
    return DateModel(year: json["year"], month: json["month"], day: json["day"], hour: json["hour"], minute: json["minute"], second: json["second"],
    millisecond: json["millisecond"]);
  }
}