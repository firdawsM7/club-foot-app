package com.club.controller;

import com.club.dto.DocumentDTO;
import com.club.model.Document;
import com.club.model.TypeDocument;
import com.club.service.DocumentService;
import lombok.RequiredArgsConstructor;
import org.springframework.core.io.Resource;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.time.LocalDate;
import java.util.List;

@RestController
@RequestMapping("/admin/documents")
@PreAuthorize("hasRole('ADMIN')")
public class DocumentController {

    private final DocumentService documentService;

    public DocumentController(DocumentService documentService) {
        this.documentService = documentService;
    }

    @PostMapping("/upload")
    public ResponseEntity<DocumentDTO> uploadDocument(
            @RequestParam("file") MultipartFile file,
            @RequestParam("userId") Long userId,
            @RequestParam("type") TypeDocument type,
            @RequestParam(value = "dateExpiration", required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate dateExpiration,
            Authentication authentication) {

        String adminEmail = authentication.getName();
        return ResponseEntity.ok(documentService.uploadDocument(file, userId, type, dateExpiration, adminEmail));
    }

    @GetMapping
    public ResponseEntity<List<DocumentDTO>> getAllDocuments(
            @RequestParam(required = false) Long userId,
            @RequestParam(required = false) TypeDocument type,
            @RequestParam(required = false) Boolean expirant) {
        return ResponseEntity.ok(documentService.getAllDocuments(userId, type, expirant));
    }

    @GetMapping("/expiring-soon")
    public ResponseEntity<List<DocumentDTO>> getExpiringDocuments() {
        return ResponseEntity.ok(documentService.getExpiringDocuments());
    }

    @PutMapping("/{id}/validate")
    public ResponseEntity<DocumentDTO> validateDocument(@PathVariable Long id) {
        return ResponseEntity.ok(documentService.validateDocument(id));
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<?> deleteDocument(@PathVariable Long id) {
        documentService.deleteDocument(id);
        return ResponseEntity.ok().build();
    }

    @GetMapping("/{id}/download")
    public ResponseEntity<Resource> downloadDocument(@PathVariable Long id) {
        Resource resource = documentService.downloadDocument(id);
        return ResponseEntity.ok()
                .contentType(MediaType.APPLICATION_OCTET_STREAM)
                .header(HttpHeaders.CONTENT_DISPOSITION, "attachment; filename=\"" + resource.getFilename() + "\"")
                .body(resource);
    }
}
