class PushMessage {
  final String messageId;
  final String title;
  final String body;
  final DateTime sentData;
  final Map<String, dynamic>? data;
  final String? imageUrl;

  PushMessage({
    required this.messageId,
    required this.title,
    required this.body,
    required this.sentData,
    this.data,
    this.imageUrl,
  });

  // * Metodo para poder mostrar el contendio
  @override
  String toString() {
    return '''
      PushMessage - 
      id : $messageId
      title: $title
      body: $body
      sentData: $sentData
      data: $data
      imageUrl:  $imageUrl

     ''';
  }
}
