package com.club.repository;

import com.club.model.ChatMessage;
import com.club.model.User;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface ChatMessageRepository extends JpaRepository<ChatMessage, Long> {
    List<ChatMessage> findByTeamIdOrderByTimestampAsc(Long teamId);
    
    // Messages admin (teamId = 0) triés par date décroissante
    List<ChatMessage> findByTeamIdOrderByTimestampDesc(Long teamId);
    
    // Tous les messages admin (broadcast + privés)
    List<ChatMessage> findByTeamId(Long teamId);
    
    // Messages pour un utilisateur spécifique (broadcast OU messages privés)
    @Query("SELECT m FROM ChatMessage m WHERE m.teamId = 0 AND (m.recipientId IS NULL OR m.recipientId = :userId) ORDER BY m.timestamp DESC")
    List<ChatMessage> findAdminMessagesForUser(@Param("userId") Long userId);
    
    // Messages envoyés par un utilisateur
    List<ChatMessage> findBySenderOrderByTimestampDesc(User sender);
}
