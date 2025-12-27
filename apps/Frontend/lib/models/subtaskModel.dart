class SubtaskModel{
  final String title;
  bool? completed;

  SubtaskModel({required this.title, this.completed});


  Map<String, dynamic> toJson()
  {
    return {
      "title" : title,
      "completed" : completed
    };
  }

  factory SubtaskModel.fromJson(Map<String, dynamic> json)
  {
    return SubtaskModel(title: json["title"], completed: json["completed"]);
  }

}