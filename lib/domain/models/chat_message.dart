class ChatMessage {
    final String id;
    final String senderId;    
    final String receiverId;
    final String text;
    final DateTime sentAt;
    final bool isRead;

    const ChatMessage({
        required this.id,
        required this.senderId,
        required this.receiverId,
        required this.text,
        required this.sentAt,
        this.isRead = false;
    });
    
    ChatMessage copyWith({
        String? id,
        String? senderId,
        String? receiverId,
        String? text,
        DateTime? sentAt,
        bool? isRead,
    }){
        return ChatMessage(
            id: id ?? this.id,
            senderId: senderId ?? this.senderId,
            receiverId: receiverId ?? this.receiverId,
            text: text ?? this.text,
            sentAt: sentAt ?? this.sentAt,
            isRead: isRead ?? this.isRead,
        );
    }
}