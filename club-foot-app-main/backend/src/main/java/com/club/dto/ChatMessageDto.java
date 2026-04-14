package com.club.dto;

import com.club.model.ChatMessage;
import java.time.LocalDateTime;

public class ChatMessageDto {
    private String content;
    private Long senderId;
    private String senderName;
    private Long teamId;
    private Long recipientId;
    private ChatMessage.MessageType type;
    private LocalDateTime timestamp;

    private String attachmentUrl;
    private String attachmentName;
    private String attachmentContentType;
    private Long attachmentSize;

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

    public Long getRecipientId() {
        return recipientId;
    }

    public void setRecipientId(Long recipientId) {
        this.recipientId = recipientId;
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

    public String getAttachmentUrl() {
        return attachmentUrl;
    }

    public void setAttachmentUrl(String attachmentUrl) {
        this.attachmentUrl = attachmentUrl;
    }

    public String getAttachmentName() {
        return attachmentName;
    }

    public void setAttachmentName(String attachmentName) {
        this.attachmentName = attachmentName;
    }

    public String getAttachmentContentType() {
        return attachmentContentType;
    }

    public void setAttachmentContentType(String attachmentContentType) {
        this.attachmentContentType = attachmentContentType;
    }

    public Long getAttachmentSize() {
        return attachmentSize;
    }

    public void setAttachmentSize(Long attachmentSize) {
        this.attachmentSize = attachmentSize;
    }

    public static ChatMessageDto fromEntity(ChatMessage message) {
        ChatMessageDto dto = new ChatMessageDto();
        dto.setContent(message.getContent());
        dto.setSenderId(message.getSender().getId());
        dto.setSenderName(message.getSender().getNom() + " " + message.getSender().getPrenom());
        dto.setTeamId(message.getTeamId());
        dto.setRecipientId(message.getRecipientId());
        dto.setType(message.getType());
        dto.setTimestamp(message.getTimestamp());
        dto.setAttachmentUrl(message.getAttachmentUrl());
        dto.setAttachmentName(message.getAttachmentName());
        dto.setAttachmentContentType(message.getAttachmentContentType());
        dto.setAttachmentSize(message.getAttachmentSize());
        return dto;
    }
}
