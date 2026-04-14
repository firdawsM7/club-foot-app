package com.club.dto;

import com.club.model.ChatMessage;
import java.time.LocalDateTime;

public class ChatMessageDto {
    private String content;
    private Long senderId;
    private String senderName;
    private Long teamId;
    private ChatMessage.MessageType type;
    private LocalDateTime timestamp;

    public ChatMessageDto() {
    }

    public ChatMessageDto(String content, Long senderId, String senderName, Long teamId, ChatMessage.MessageType type,
            LocalDateTime timestamp) {
        this.content = content;
        this.senderId = senderId;
        this.senderName = senderName;
        this.teamId = teamId;
        this.type = type;
        this.timestamp = timestamp;
    }

    public String getContent() {
        return content;
    }

    public void setContent(String content) {
        this.content = content;
    }

    public Long getSenderId() {
        return senderId;
    }

    public void setSenderId(Long senderId) {
        this.senderId = senderId;
    }

    public String getSenderName() {
        return senderName;
    }

    public void setSenderName(String senderName) {
        this.senderName = senderName;
    }

    public Long getTeamId() {
        return teamId;
    }

    public void setTeamId(Long teamId) {
        this.teamId = teamId;
    }

    public ChatMessage.MessageType getType() {
        return type;
    }

    public void setType(ChatMessage.MessageType type) {
        this.type = type;
    }

    public LocalDateTime getTimestamp() {
        return timestamp;
    }

    public void setTimestamp(LocalDateTime timestamp) {
        this.timestamp = timestamp;
    }
}
