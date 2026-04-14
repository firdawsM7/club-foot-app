package com.club.repository;

import com.club.model.Document;
import com.club.model.TypeDocument;
import com.club.model.User;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.stereotype.Repository;

import java.time.LocalDate;
import java.util.List;

@Repository
public interface DocumentRepository extends JpaRepository<Document, Long> {
    List<Document> findByUser(User user);

    List<Document> findByType(TypeDocument type);

    List<Document> findByUserAndType(User user, TypeDocument type);

    @Query("SELECT d FROM Document d WHERE d.dateExpiration <= :date AND d.dateExpiration IS NOT NULL")
    List<Document> findByDateExpirationBefore(LocalDate date);
}
