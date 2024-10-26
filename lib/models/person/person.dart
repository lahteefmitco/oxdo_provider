class Person {
  final int? id;
  final String name;
  final int age;

  Person( { this.id,required this.name, required this.age});

  
  factory Person.fromJson(Map<String, dynamic> json) {
    return Person(id: json["id"] as int ,name: json["name"] as String, age: json["age"] as int);
  }


  Map<String, dynamic> toJson() {
    return {"id":id, "name": name, "age": age};
  }

  @override
  String toString() {
    return "id:$id, name: $name,  age: $age";
  }
}
