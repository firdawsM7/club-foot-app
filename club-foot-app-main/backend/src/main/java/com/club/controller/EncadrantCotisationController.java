package com.club.controller;

import com.club.dto.CotisationDTO;
import com.club.model.Cotisation;
import com.club.service.CotisationService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.stream.Collectors;

@RestController
@RequestMapping("/encadrant/cotisations")
@PreAuthorize("hasAnyRole('ENCADRANT', 'ADMIN')")
public class EncadrantCotisationController {

    @Autowired
    private CotisationService cotisationService;

    @GetMapping
    public ResponseEntity<List<CotisationDTO>> getTeamCotisations(
            @RequestParam(required = false) String saison) {

        // Pour l'instant, retourner toutes les cotisations
        // TODO: Filtrer par équipe de l'encadrant quand la relation sera établie
        List<Cotisation> cotisations = saison != null
                ? cotisationService.getCotisationsBySaison(saison)
                : cotisationService.getAllCotisations();

        List<CotisationDTO> dtos = cotisations.stream()
                .map(CotisationDTO::fromEntity)
                .collect(Collectors.toList());

        return ResponseEntity.ok(dtos);
    }

    @GetMapping("/{id}")
    public ResponseEntity<CotisationDTO> getCotisationById(@PathVariable Long id) {
        Cotisation cotisation = cotisationService.getCotisationById(id);
        return ResponseEntity.ok(CotisationDTO.fromEntity(cotisation));
    }
}
