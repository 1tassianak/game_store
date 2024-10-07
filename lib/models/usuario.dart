class Usuario{

  String? id;
  String? name;
  String? email;
  String? password;
  String? img;

  Usuario({
    required this.id,
    required this.name,
    required this.email,
    required this.password,
    this.img,
  });

  //Garante que todos os dados sejam obrigatórios
  factory Usuario.fromMap(Map<String, dynamic> map) {
    if (map['id'] == null || map['name'] == null || map['email'] == null || map['password'] == null) {
      throw ArgumentError('Todos os campos são obrigatórios: id, name, email, password');
    }

    return Usuario(
      id: map['id'] as String,
      name: map['name'] as String,
      email: map['email'] as String,
      password: map['password'] as String,
      img: map['img'] as String,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'password': password,
      'img': img,
    };
  }

}