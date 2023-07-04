/// A placeholder class that represents an entity or model.
class Media {
  const Media(
      this.kind, this.title, this.returnDateTime, this.loanDateTime);

  final String kind;
  final String title;
  final DateTime returnDateTime;
  final DateTime loanDateTime;
}

typedef MediaList = List<Media>;
