class DzoSearchResponse {
  String id;
  String keyword;
  String pos;
  String definition;
  String terminology;
  String message;

  DzoSearchResponse(
      {this.id,
      this.pos,
      this.keyword,
      this.terminology,
      this.message,
      this.definition});

  // Create a DzoSearchResponse from JSON data
  factory DzoSearchResponse.fromJson(Map<String, dynamic> json) =>
      new DzoSearchResponse(
          id: json["id"],
          keyword: json["keyword"],
          terminology: json["terminology"],
          pos: json["pos"],
          message: json["message"],
          definition: json["definition"]);

  // Convert our DzoSearchResponse to JSON to make it easier when we store it in the database
  Map<String, dynamic> toJson() => {
        "id": id,
        "keyword": keyword,
        "terminology": terminology,
        "pos": pos,
        "message": message,
        "definition": definition
      };
}
