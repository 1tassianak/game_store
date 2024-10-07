class Game{

  String? id;
  String? nome;
  String? sobre;
  String? img;
  String? thumb;
  double? rating;
  double? downloads;
  String? categoria;
  String? lancamentoOuDestaque;
  String? link;

  Game({
    required this.id,
    required this.nome,
    required this.sobre,
    required this.img,
    required this.thumb,
    required this.rating,
    required this.downloads,
    required this.categoria,
    required this.lancamentoOuDestaque,
    required this.link,
  });

  //Cria um objeto Game a partir de um Map
  //Permite reconstruir o objeto Game a partir de dados brutos, como os recebidos de um banco de dados.
  factory Game.fromMap(Map<String, dynamic> map){
    return Game(
      id: map['id'] ?? '', // Busca o valor de 'id' no map; se não existir, usa a string vazia como padrão
      nome: map['nome'] ?? '',
      sobre: map['sobre'] ?? '',
      img: map['img'] ?? '',
      thumb: map['thumb'] ?? '',
      rating: map['rating']?.toDouble() ?? 0.0, // Converte o valor de 'rating' para double; usa 0.0 se for nulo
      downloads: map['downloads']?.toDouble() ?? 0.0,
      categoria: map['categoria'] ?? '',
      lancamentoOuDestaque: map['lancamentoOuDestaque'] ?? '',
      link: map['link'] ?? '',
    );
  }

  // Converte o objeto Game para um Map
  //Prepara o objeto para ser armazenado em um banco de dados que usa JSON ou Map.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nome': nome,
      'sobre': sobre,
      'img': img,
      'thumb': thumb,
      'rating': rating,
      'downloads': downloads,
      'categoria': categoria,
      'lancamentoOuDestaque': lancamentoOuDestaque,
      'link': link,
    };
  }


}