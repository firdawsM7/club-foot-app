package com.club.service;

import com.club.model.Cotisation;
import com.club.repository.CotisationRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class CotisationService {
    
    @Autowired
    private CotisationRepository cotisationRepository;
    
    public Cotisation createCotisation(Cotisation cotisation) {
        return cotisationRepository.save(cotisation);
    }
    
    public Cotisation updateCotisation(Long id, Cotisation cotisationDetails) {
        Cotisation cotisation = cotisationRepository.findById(id)
            .orElseThrow(() -> new RuntimeException("Cotisation non trouvée"));
        
        cotisation.setMontant(cotisationDetails.getMontant());
        cotisation.setDatePaiement(cotisationDetails.getDatePaiement());
        cotisation.setSaison(cotisationDetails.getSaison());
        cotisation.setModePaiement(cotisationDetails.getModePaiement());
        cotisation.setStatut(cotisationDetails.getStatut());
        cotisation.setReference(cotisationDetails.getReference());
        cotisation.setNotes(cotisationDetails.getNotes());
        
        return cotisationRepository.save(cotisation);
    }
    
    public List<Cotisation> getAllCotisations() {
        return cotisationRepository.findAll();
    }
    
    public Cotisation getCotisationById(Long id) {
        return cotisationRepository.findById(id)
            .orElseThrow(() -> new RuntimeException("Cotisation non trouvée"));
    }
    
    public List<Cotisation> getCotisationsByUser(Long userId) {
        return cotisationRepository.findByUserId(userId);
    }
    
    public void deleteCotisation(Long id) {
        cotisationRepository.deleteById(id);
    }
}