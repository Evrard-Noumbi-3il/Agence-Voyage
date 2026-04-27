package com.adv.modules.audit.repository;

import com.adv.modules.audit.entity.JournalActivite;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.UUID;

@Repository
public interface JournalActiviteRepository extends JpaRepository<JournalActivite, UUID> {
}