package com.club.controller;

import com.club.dto.ChatMessageDto;
import com.club.model.ChatMessage;
import com.club.model.User;
import com.club.repository.ChatMessageRepository;
import com.club.repository.UserRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.messaging.handler.annotation.MessageMapping;
import org.springframework.messaging.handler.annotation.Payload;
import org.springframework.messaging.simp.SimpMessageHeaderAccessor;
import org.springframework.messaging.simp.SimpMessagingTemplate;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDateTime;
import java.util.List;
import java.util.stream.Collectors;

@RestController
public class ChatController {

    @Autowired
    private SimpMessagingTemplate messagingTemplate;

    @Autowired
    private ChatMessageRepository chatMessageRepository;

    @Autowired
    private UserRepository userRepository;

    @MessageMapping("/chat.sendMessage")
    public void sendMessage(@Payload ChatMessageDto chatMessageDto) {
        User sender = userRepository.findById(chatMessageDto.getSenderId())
                .orElseThrow(() -> new RuntimeException("User not found"));

        ChatMessage chatMessage = new ChatMessage(
                chatMessageDto.getContent(),
                sender,
                chatMessageDto.getTeamId(),
                LocalDateTime.now(),
                ChatMessage.MessageType.CHAT);

        chatMessageRepository.save(chatMessage);

        // Update DTO with server timestamp and sender name
        chatMessageDto.setTimestamp(chatMessage.getTimestamp());
        chatMessageDto.setSenderName(sender.getPrenom() + " " + sender.getNom());

        messagingTemplate.convertAndSend("/topic/team/" + chatMessageDto.getTeamId(), chatMessageDto);
    }

    @MessageMapping("/chat.addUser")
    public void addUser(@Payload ChatMessageDto chatMessageDto, SimpMessageHeaderAccessor headerAccessor) {
        // Add username in web socket session
        if (headerAccessor.getSessionAttributes() != null) {
            headerAccessor.getSessionAttributes().put("username", chatMessageDto.getSenderName());
        }

        // We could broadcast join message here if needed
        chatMessageDto.setType(ChatMessage.MessageType.JOIN);
        chatMessageDto.setTimestamp(LocalDateTime.now());
        messagingTemplate.convertAndSend("/topic/team/" + chatMessageDto.getTeamId(), chatMessageDto);
    }

    @GetMapping("/api/chat/history/{teamId}")
    public List<ChatMessageDto> getChatHistory(@PathVariable Long teamId) {
        return chatMessageRepository.findByTeamIdOrderByTimestampAsc(teamId).stream()
                .map(msg -> {
                    ChatMessageDto dto = new ChatMessageDto();
                    dto.setContent(msg.getContent());
                    dto.setSenderId(msg.getSender().getId());
                    dto.setSenderName(msg.getSender().getPrenom() + " " + msg.getSender().getNom());
                    dto.setTeamId(msg.getTeamId());
                    dto.setTimestamp(msg.getTimestamp());
                    if (msg.getType() != null) {
                        dto.setType(msg.getType());
                    }
                    return dto;
                })
                .collect(Collectors.toList());
    }
}
