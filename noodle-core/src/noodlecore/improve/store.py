"""File-based storage adapter for NIP models.

This module provides a simple file-based persistence layer for all NIP data models.
Each model type is stored in a separate directory with JSON files.
"""

import json
import os
from pathlib import Path
from typing import List, Optional, Dict, Any, TypeVar, Type
from .models import TaskSpec, Candidate, Evidence, PromotionRecord

T = TypeVar('T', TaskSpec, Candidate, Evidence, PromotionRecord)


class FileStore:
    """File-based storage for NIP models.
    
    Provides CRUD operations for all model types with JSON persistence.
    Each entity is stored as a separate JSON file in a dedicated directory.
    
    Attributes:
        base_path: Base directory for all storage
        tasks_dir: Directory for TaskSpec files
        candidates_dir: Directory for Candidate files
        evidence_dir: Directory for Evidence files
        promotions_dir: Directory for PromotionRecord files
    """
    
    def __init__(self, base_path: str = ".nip/storage"):
        """Initialize the file store.
        
        Args:
            base_path: Base directory for storage (default: .nip/storage)
        """
        self.base_path = Path(base_path)
        self.tasks_dir = self.base_path / "tasks"
        self.candidates_dir = self.base_path / "candidates"
        self.evidence_dir = self.base_path / "evidence"
        self.promotions_dir = self.base_path / "promotions"
        
        # Create directories if they don't exist
        for directory in [self.tasks_dir, self.candidates_dir, 
                         self.evidence_dir, self.promotions_dir]:
            directory.mkdir(parents=True, exist_ok=True)
    
    def _get_file_path(self, model_type: str, entity_id: str) -> Path:
        """Get the file path for a specific entity.
        
        Args:
            model_type: Type of model ('task', 'candidate', 'evidence', 'promotion')
            entity_id: ID of the entity
            
        Returns:
            Path to the entity's JSON file
        """
        dirs = {
            'task': self.tasks_dir,
            'candidate': self.candidates_dir,
            'evidence': self.evidence_dir,
            'promotion': self.promotions_dir
        }
        return dirs[model_type] / f"{entity_id}.json"
    
    def _get_model_class(self, model_type: str) -> Type:
        """Get the model class for a given type.
        
        Args:
            model_type: Type of model
            
        Returns:
            Model class
        """
        classes = {
            'task': TaskSpec,
            'candidate': Candidate,
            'evidence': Evidence,
            'promotion': PromotionRecord
        }
        return classes[model_type]
    
    def save(self, entity: T, model_type: str) -> None:
        """Save an entity to disk.
        
        Args:
            entity: The entity to save (TaskSpec, Candidate, Evidence, or PromotionRecord)
            model_type: Type of model ('task', 'candidate', 'evidence', 'promotion')
        """
        file_path = self._get_file_path(model_type, entity.id)
        with open(file_path, 'w') as f:
            f.write(entity.to_json())
    
    def load(self, entity_id: str, model_type: str) -> Optional[T]:
        """Load an entity from disk.
        
        Args:
            entity_id: ID of the entity to load
            model_type: Type of model ('task', 'candidate', 'evidence', 'promotion')
            
        Returns:
            The loaded entity, or None if not found
        """
        file_path = self._get_file_path(model_type, entity_id)
        if not file_path.exists():
            return None
        
        with open(file_path, 'r') as f:
            json_str = f.read()
        
        model_class = self._get_model_class(model_type)
        return model_class.from_json(json_str)
    
    def delete(self, entity_id: str, model_type: str) -> bool:
        """Delete an entity from disk.
        
        Args:
            entity_id: ID of the entity to delete
            model_type: Type of model ('task', 'candidate', 'evidence', 'promotion')
            
        Returns:
            True if deleted, False if not found
        """
        file_path = self._get_file_path(model_type, entity_id)
        if not file_path.exists():
            return False
        
        file_path.unlink()
        return True
    
    def list_all(self, model_type: str) -> List[str]:
        """List all entity IDs of a given type.
        
        Args:
            model_type: Type of model ('task', 'candidate', 'evidence', 'promotion')
            
        Returns:
            List of entity IDs
        """
        dirs = {
            'task': self.tasks_dir,
            'candidate': self.candidates_dir,
            'evidence': self.evidence_dir,
            'promotion': self.promotions_dir
        }
        
        directory = dirs[model_type]
        if not directory.exists():
            return []
        
        return [f.stem for f in directory.glob("*.json")]
    
    def load_all(self, model_type: str) -> List[T]:
        """Load all entities of a given type.
        
        Args:
            model_type: Type of model ('task', 'candidate', 'evidence', 'promotion')
            
        Returns:
            List of all entities of the specified type
        """
        entity_ids = self.list_all(model_type)
        entities = []
        
        for entity_id in entity_ids:
            entity = self.load(entity_id, model_type)
            if entity:
                entities.append(entity)
        
        return entities
    
    def exists(self, entity_id: str, model_type: str) -> bool:
        """Check if an entity exists.
        
        Args:
            entity_id: ID of the entity to check
            model_type: Type of model ('task', 'candidate', 'evidence', 'promotion')
            
        Returns:
            True if the entity exists, False otherwise
        """
        file_path = self._get_file_path(model_type, entity_id)
        return file_path.exists()


class TaskStore(FileStore):
    """Specialized store for TaskSpec objects."""
    
    def save_task(self, task: TaskSpec) -> None:
        """Save a task."""
        self.save(task, 'task')
    
    def load_task(self, task_id: str) -> Optional[TaskSpec]:
        """Load a task by ID."""
        return self.load(task_id, 'task')
    
    def delete_task(self, task_id: str) -> bool:
        """Delete a task by ID."""
        return self.delete(task_id, 'task')
    
    def list_tasks(self) -> List[TaskSpec]:
        """List all tasks."""
        return self.load_all('task')
    
    def task_exists(self, task_id: str) -> bool:
        """Check if a task exists."""
        return self.exists(task_id, 'task')


class CandidateStore(FileStore):
    """Specialized store for Candidate objects."""
    
    def save_candidate(self, candidate: Candidate) -> None:
        """Save a candidate."""
        self.save(candidate, 'candidate')
    
    def load_candidate(self, candidate_id: str) -> Optional[Candidate]:
        """Load a candidate by ID."""
        return self.load(candidate_id, 'candidate')
    
    def delete_candidate(self, candidate_id: str) -> bool:
        """Delete a candidate by ID."""
        return self.delete(candidate_id, 'candidate')
    
    def list_candidates(self) -> List[Candidate]:
        """List all candidates."""
        return self.load_all('candidate')
    
    def list_candidates_for_task(self, task_id: str) -> List[Candidate]:
        """List all candidates for a specific task."""
        all_candidates = self.list_candidates()
        return [c for c in all_candidates if c.task_id == task_id]
    
    def candidate_exists(self, candidate_id: str) -> bool:
        """Check if a candidate exists."""
        return self.exists(candidate_id, 'candidate')


class EvidenceStore(FileStore):
    """Specialized store for Evidence objects."""
    
    def save_evidence(self, evidence: Evidence) -> None:
        """Save evidence."""
        self.save(evidence, 'evidence')
    
    def load_evidence(self, evidence_id: str) -> Optional[Evidence]:
        """Load evidence by ID."""
        return self.load(evidence_id, 'evidence')
    
    def delete_evidence(self, evidence_id: str) -> bool:
        """Delete evidence by ID."""
        return self.delete(evidence_id, 'evidence')
    
    def list_evidence(self) -> List[Evidence]:
        """List all evidence."""
        return self.load_all('evidence')
    
    def list_evidence_for_candidate(self, candidate_id: str) -> List[Evidence]:
        """List all evidence for a specific candidate."""
        all_evidence = self.list_evidence()
        return [e for e in all_evidence if e.candidate_id == candidate_id]
    
    def evidence_exists(self, evidence_id: str) -> bool:
        """Check if evidence exists."""
        return self.exists(evidence_id, 'evidence')


class PromotionStore(FileStore):
    """Specialized store for PromotionRecord objects."""
    
    def save_promotion(self, promotion: PromotionRecord) -> None:
        """Save a promotion record."""
        self.save(promotion, 'promotion')
    
    def load_promotion(self, promotion_id: str) -> Optional[PromotionRecord]:
        """Load a promotion record by ID."""
        return self.load(promotion_id, 'promotion')
    
    def delete_promotion(self, promotion_id: str) -> bool:
        """Delete a promotion record by ID."""
        return self.delete(promotion_id, 'promotion')
    
    def list_promotions(self) -> List[PromotionRecord]:
        """List all promotion records."""
        return self.load_all('promotion')
    
    def list_promotions_for_candidate(self, candidate_id: str) -> List[PromotionRecord]:
        """List all promotions for a specific candidate."""
        all_promotions = self.list_promotions()
        return [p for p in all_promotions if p.candidate_id == candidate_id]
    
    def promotion_exists(self, promotion_id: str) -> bool:
        """Check if a promotion record exists."""
        return self.exists(promotion_id, 'promotion')
