package com.club.service;

import com.club.dto.DocumentDTO;
import com.club.model.Document;
import com.club.model.TypeDocument;
import com.club.model.User;
import com.club.repository.DocumentRepository;
import com.club.repository.UserRepository;
import org.springframework.core.io.Resource;
import org.springframework.core.io.UrlResource;
import org.springframework.stereotype.Service;
import org.springframework.util.StringUtils;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.net.MalformedURLException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.nio.file.StandardCopyOption;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.List;
import java.util.Objects;
import java.util.stream.Collectors;

@Service
public class DocumentService {

    private final DocumentRepository documentRepository;
    private final UserRepository userRepository;
    private final Path fileStorageLocation;

    public DocumentService(DocumentRepository documentRepository, UserRepository userRepository) {
        this.documentRepository = documentRepository;
        this.userRepository = userRepository;
        this.fileStorageLocation = Paths.get("uploads/documents").toAbsolutePath().normalize();
        try {
            Files.createDirectories(this.fileStorageLocation);
        } catch (IOException ex) {
            throw new RuntimeException("Impossible de créer le dossier de stockage des documents.", ex);
        }
    }

    public DocumentDTO uploadDocument(MultipartFile file, Long userId, TypeDocument type,
            LocalDate dateExpiration, String adminEmail) {
        try {

            User user = userRepository.findById(userId)
                    .orElseThrow(() -> new RuntimeException("Utilisateur non trouvé"));

            String originalFileName = StringUtils.cleanPath(Objects.requireNonNull(file.getOriginalFilename()));
            String extension = originalFileName.substring(originalFileName.lastIndexOf("."));
            String fileName = user.getId() + "_" + type.name() + "_" + System.currentTimeMillis() + extension;

            Path targetLocation = this.fileStorageLocation.resolve(fileName);
            Files.copy(file.getInputStream(), targetLocation, StandardCopyOption.REPLACE_EXISTING);

            Document document = new Document();
            document.setNom(originalFileName);
            document.setType(type);
            document.setUrl(fileName);
            document.setDateExpiration(dateExpiration);
            document.setValide(false);
            document.setUser(user);
            document.setUploadDate(LocalDateTime.now());
            document.setUploadedBy(adminEmail);

            return DocumentDTO.fromEntity(documentRepository.save(document));
        } catch (IOException ex) {
            throw new RuntimeException("Impossible de stocker le fichier " + file.getOriginalFilename(), ex);
        }
    }

    public List<DocumentDTO> getAllDocuments(Long userId, TypeDocument type, Boolean expirant) {
        List<Document> documents;
        if (userId != null && type != null) {
            User user = userRepository.findById(userId).orElse(null);
            documents = documentRepository.findByUserAndType(user, type);
        } else if (userId != null) {
            User user = userRepository.findById(userId).orElse(null);
            documents = documentRepository.findByUser(user);
        } else if (type != null) {
            documents = documentRepository.findByType(type);
        } else {
            documents = documentRepository.findAll();
        }

        if (expirant != null && expirant) {
            LocalDate limit = LocalDate.now().plusDays(30);
            documents = documents.stream()
                    .filter(d -> d.getDateExpiration() != null && d.getDateExpiration().isBefore(limit))
                    .collect(Collectors.toList());
        }

        return documents.stream().map(DocumentDTO::fromEntity).collect(Collectors.toList());
    }

    public List<DocumentDTO> getExpiringDocuments() {
        LocalDate limit = LocalDate.now().plusDays(30);
        return documentRepository.findByDateExpirationBefore(limit).stream()
                .map(DocumentDTO::fromEntity)
                .collect(Collectors.toList());
    }

    public DocumentDTO validateDocument(Long id) {
        Document document = documentRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Document non trouvé"));
        document.setValide(true);
        return DocumentDTO.fromEntity(documentRepository.save(document));
    }

    public void deleteDocument(Long id) {
        Document document = documentRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Document non trouvé"));
        try {
            Path filePath = this.fileStorageLocation.resolve(document.getUrl());
            Files.deleteIfExists(filePath);
            documentRepository.delete(document);
        } catch (IOException e) {
            throw new RuntimeException("Erreur lors de la suppression du fichier", e);
        }
    }

    public Resource downloadDocument(Long id) {
        Document document = documentRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Document non trouvé"));
        try {
            Path filePath = this.fileStorageLocation.resolve(document.getUrl());
            Resource resource = new UrlResource(filePath.toUri());
            if (resource.exists()) {
                return resource;
            } else {
                throw new RuntimeException("Fichier non trouvé " + document.getUrl());
            }
        } catch (MalformedURLException ex) {
            throw new RuntimeException("Fichier non trouvé " + document.getUrl(), ex);
        }
    }
}
