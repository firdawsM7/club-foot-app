package com.club.controller;

import com.club.dto.ChatMessageDto;
import com.club.model.ChatMessage;
import com.club.model.User;
import com.club.repository.ChatMessageRepository;
import com.club.service.UserService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.messaging.simp.SimpMessagingTemplate;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

@RestController
@RequestMapping("/admin/messages")
@PreAuthorize("hasRole('ADMIN')")
public class AdminMessageController {

    @Autowired
    private ChatMessageRepository chatMessageRepository;

    @Autowired
    private UserService userService;

    @Autowired
    private SimpMessagingTemplate messagingTemplate;

    // Envoyer un message à TOUS les utilisateurs (broadcast)
    @PostMapping("/broadcast")
    public ResponseEntity<?> broadcastMessage(
            @RequestBody Map<String, Object> request,
            Authentication authentication) {
        try {
            User sender = (User) authentication.getPrincipal();
            String content = (String) request.get("content");
            Long recipientId = request.get("recipientId") != null 
                ? Long.valueOf(request.get("recipientId").toString()) 
                : null;

            if (content == null || content.trim().isEmpty()) {
                return ResponseEntity.badRequest().body(Map.of("error", "Le message ne peut pas être vide"));
            }

            // Créer le message
            ChatMessage message = new ChatMessage();
            message.setContent(content);
            message.setSender(sender);
            message.setTimestamp(LocalDateTime.now());
            message.setType(ChatMessage.MessageType.CHAT);
            message.setTeamId(0L); // 0 = message système/admin
            message.setRecipientId(recipientId); // null = broadcast à tous

            ChatMessage saved = chatMessageRepository.save(message);

            // Envoyer via WebSocket pour notification en temps réel
            ChatMessageDto dto = ChatMessageDto.fromEntity(saved);
            messagingTemplate.convertAndSend("/topic/admin-messages", dto);

            // Si message privé, envoyer aussi au destinataire
            if (recipientId != null) {
                messagingTemplate.convertAndSend("/topic/user-" + recipientId + "/messages", dto);
            }

            return ResponseEntity.ok(Map.of(
                "message", "Message envoyé avec succès",
                "data", ChatMessageDto.fromEntity(saved)
            ));
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(Map.of("error", e.getMessage()));
        }
    }

    // Envoyer un message PRIVÉ à un utilisateur spécifique
    @PostMapping("/private/{userId}")
    public ResponseEntity<?> sendPrivateMessage(
            @PathVariable Long userId,
            @RequestBody Map<String, String> request,
            Authentication authentication) {
        try {
            User sender = (User) authentication.getPrincipal();
            String content = request.get("content");

            if (content == null || content.trim().isEmpty()) {
                return ResponseEntity.badRequest().body(Map.of("error", "Le message ne peut pas être vide"));
            }

            // Vérifier que le destinataire existe
            User recipient = userService.getUserById(userId);

            // Créer le message
            ChatMessage message = new ChatMessage();
            message.setContent(content);
            message.setSender(sender);
            message.setTimestamp(LocalDateTime.now());
            message.setType(ChatMessage.MessageType.CHAT);
            message.setTeamId(0L);
            message.setRecipientId(userId);

            ChatMessage saved = chatMessageRepository.save(message);

            // Envoyer via WebSocket au destinataire
            ChatMessageDto dto = ChatMessageDto.fromEntity(saved);
            messagingTemplate.convertAndSend("/topic/user-" + userId + "/messages", dto);

            return ResponseEntity.ok(Map.of(
                "message", "Message privé envoyé avec succès",
                "data", ChatMessageDto.fromEntity(saved)
            ));
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(Map.of("error", e.getMessage()));
        }
    }

    // Récupérer TOUS les messages admin (broadcast + privés)
    @GetMapping
    public ResponseEntity<List<ChatMessageDto>> getAllAdminMessages() {
        List<ChatMessage> messages = chatMessageRepository.findByTeamIdOrderByTimestampDesc(0L);
        
        List<ChatMessageDto> dtos = messages.stream()
            .map(ChatMessageDto::fromEntity)
            .collect(Collectors.toList());

        return ResponseEntity.ok(dtos);
    }

    // Récupérer les messages pour un utilisateur spécifique
    @GetMapping("/user/{userId}")
    public ResponseEntity<List<ChatMessageDto>> getMessagesForUser(@PathVariable Long userId) {
        // Messages broadcast OU messages privés pour cet utilisateur
        List<ChatMessage> messages = chatMessageRepository.findAdminMessagesForUser(userId);
        
        List<ChatMessageDto> dtos = messages.stream()
            .map(ChatMessageDto::fromEntity)
            .collect(Collectors.toList());

        return ResponseEntity.ok(dtos);
    }

    // Récupérer l'historique des messages envoyés par l'admin
    @GetMapping("/sent")
    public ResponseEntity<List<ChatMessageDto>> getSentMessages(Authentication authentication) {
        User admin = (User) authentication.getPrincipal();
        
        List<ChatMessage> messages = chatMessageRepository.findBySenderOrderByTimestampDesc(admin);
        
        List<ChatMessageDto> dtos = messages.stream()
            .filter(m -> m.getTeamId() == 0L) // Seulement les messages admin
            .map(ChatMessageDto::fromEntity)
            .collect(Collectors.toList());

        return ResponseEntity.ok(dtos);
    }

    // Statistiques des messages
    @GetMapping("/stats")
    public ResponseEntity<Map<String, Object>> getMessageStats() {
        List<ChatMessage> allAdminMessages = chatMessageRepository.findByTeamId(0L);
        
        long totalMessages = allAdminMessages.size();
        long broadcastMessages = allAdminMessages.stream().filter(m -> m.getRecipientId() == null).count();
        long privateMessages = allAdminMessages.stream().filter(m -> m.getRecipientId() != null).count();

        return ResponseEntity.ok(Map.of(
            "totalMessages", totalMessages,
            "broadcastMessages", broadcastMessages,
            "privateMessages", privateMessages
        ));
    }
}
