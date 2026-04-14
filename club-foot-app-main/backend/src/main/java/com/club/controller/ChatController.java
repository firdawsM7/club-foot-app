package com.club.controller;

import com.club.dto.ChatMessageDto;
import com.club.model.ChatMessage;
import com.club.model.User;
import com.club.repository.ChatMessageRepository;
import com.club.repository.UserRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.messaging.handler.annotation.MessageMapping;
import org.springframework.messaging.handler.annotation.Payload;
import org.springframework.messaging.simp.SimpMessageHeaderAccessor;
import org.springframework.messaging.simp.SimpMessagingTemplate;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;
import org.springframework.web.servlet.support.ServletUriComponentsBuilder;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.HashMap;
import java.util.Map;
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

        chatMessage.setRecipientId(chatMessageDto.getRecipientId());
        chatMessage.setAttachmentUrl(chatMessageDto.getAttachmentUrl());
        chatMessage.setAttachmentName(chatMessageDto.getAttachmentName());
        chatMessage.setAttachmentContentType(chatMessageDto.getAttachmentContentType());
        chatMessage.setAttachmentSize(chatMessageDto.getAttachmentSize());

        chatMessageRepository.save(chatMessage);

        // Update DTO with server timestamp and sender name
        chatMessageDto.setTimestamp(chatMessage.getTimestamp());
        chatMessageDto.setSenderName(sender.getPrenom() + " " + sender.getNom());

        // Private message: deliver only to recipient + sender.
        if (chatMessageDto.getRecipientId() != null) {
            messagingTemplate.convertAndSend("/topic/user/" + chatMessageDto.getRecipientId(), chatMessageDto);
            messagingTemplate.convertAndSend("/topic/user/" + chatMessageDto.getSenderId(), chatMessageDto);
        } else {
            messagingTemplate.convertAndSend("/topic/team/" + chatMessageDto.getTeamId(), chatMessageDto);
        }
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
                    dto.setRecipientId(msg.getRecipientId());
                    dto.setTimestamp(msg.getTimestamp());
                    if (msg.getType() != null) {
                        dto.setType(msg.getType());
                    }
                    dto.setAttachmentUrl(msg.getAttachmentUrl());
                    dto.setAttachmentName(msg.getAttachmentName());
                    dto.setAttachmentContentType(msg.getAttachmentContentType());
                    dto.setAttachmentSize(msg.getAttachmentSize());
                    return dto;
                })
                .collect(Collectors.toList());
    }

    @PostMapping("/api/chat/attachments")
    public ResponseEntity<?> uploadChatAttachment(
            @RequestParam("teamId") Long teamId,
            @RequestParam("file") MultipartFile file) throws IOException {
        if (file.isEmpty()) {
            return ResponseEntity.badRequest().body(Map.of("message", "Fichier vide"));
        }
        // Basic size limit (5MB)
        if (file.getSize() > 5L * 1024 * 1024) {
            return ResponseEntity.badRequest().body(Map.of("message", "Le fichier dépasse 5MB"));
        }

        String baseDir = System.getProperty("user.dir");
        Path uploadDir = Paths.get(baseDir, "uploads", "chat", teamId.toString()).toAbsolutePath().normalize();
        Files.createDirectories(uploadDir);

        String original = file.getOriginalFilename();
        String safeName = original != null ? original.replaceAll("[^a-zA-Z0-9._-]", "_") : "file";
        String fileName = System.currentTimeMillis() + "_" + safeName;
        Path target = uploadDir.resolve(fileName);
        file.transferTo(target.toFile());

        String fileUrl = ServletUriComponentsBuilder.fromCurrentContextPath()
                .path("/uploads/chat/")
                .path(teamId.toString())
                .path("/")
                .path(fileName)
                .toUriString();

        Map<String, Object> out = new HashMap<>();
        out.put("url", fileUrl);
        out.put("fileName", fileName);
        out.put("originalName", original);
        out.put("contentType", file.getContentType());
        out.put("size", file.getSize());
        return ResponseEntity.ok(out);
    }
}
