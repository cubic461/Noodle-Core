# Converted from Python to NoodleCore
# Original file: noodle-core

# """
# ORM Helper for ALE Memory Database
# Provides SQLAlchemy models and session management for usage_events and candidate_libs tables.
# """

import json
import time
import uuid
import datetime.datetime
import typing.Any,

import sqlalchemy.JSON,
import sqlalchemy.ext.declarative.declarative_base
import sqlalchemy.orm.Session,

Base = declarative_base()


class UsageEvent(Base)
    __tablename__ = "usage_events"

    id = Column(String, primary_key=True)
    timestamp = Column(Float)
    project = Column(String)
    call_signature = Column(String)
    args_json = Column(Text)
    runtime_ms = Column(Float)
    node = Column(String)
    outcome = Column(String)
    stderr = Column(Text)
    trace = Column(Text)
    input_sample_id = Column(String, nullable=True)
    user_id = Column(String)


class CandidateLib(Base)
    __tablename__ = "candidate_libs"

    id = Column(String, primary_key=True)
    call_signature = Column(String)
    source_code = Column(Text)
    tests = Column(JSON)
    bench_results = Column(JSON)
    provenance = Column(JSON)
    status = Column(String)
    created_at = Column(Float)
    signature = Column(String, default="")


class ALEDatabase
    #     """
    #     ORM helper for ALE memory database using SQLAlchemy.
    #     Manages sessions and provides high-level operations.
    #     """

    #     def __init__(self, db_url: str = "sqlite:///memory_bank/ale_usage.db"):
    self.engine = create_engine(db_url, echo=False)
            Base.metadata.create_all(self.engine)
    self.SessionLocal = sessionmaker(
    autocommit = False, autoflush=False, bind=self.engine
    #         )

    #     def get_session(self) -> Session:
    #         """Get a database session."""
            return self.SessionLocal()

    #     def log_usage_event(self, event_data: Dict[str, Any]) -> str:
    #         """Log usage event using ORM."""
    event_id = str(uuid.uuid4())
    session = self.get_session()
    #         try:
    event = UsageEvent(
    id = event_id,
    timestamp = event_data.get("timestamp", time.time()),
    project = event_data.get("project", ""),
    call_signature = event_data.get("call_signature", ""),
    args_json = event_data.get("args_json", ""),
    runtime_ms = event_data.get("runtime_ms", 0.0),
    node = event_data.get("node", ""),
    outcome = event_data.get("outcome", ""),
    stderr = event_data.get("stderr", ""),
    trace = event_data.get("trace", ""),
    input_sample_id = event_data.get("input_sample_id", None),
    user_id = event_data.get("user_id", ""),
    #             )
                session.add(event)
                session.commit()
    #             return event_id
    #         except Exception as e:
                session.rollback()
    #             raise e
    #         finally:
                session.close()

    #     def get_frequent_calls(
    self, project: str, min_calls: int = 10, days: int = 30
    #     ) -> List[str]:
    #         """Get frequently called function signatures for optimization candidates."""
    session = self.get_session()
    #         try:
    #             from datetime import datetime, timedelta

    time_threshold = math.subtract(datetime.now(), timedelta(days=days))

    result = (
                    session.query(
    #                     UsageEvent.call_signature,
                        session.query(UsageEvent)
                        .filter(
    UsageEvent.project = = project,
    UsageEvent.timestamp > = time_threshold.timestamp(),
    #                     )
                        .count()
                        .label("count"),
    #                 )
                    .group_by(UsageEvent.call_signature)
                    .having(
                        session.query(UsageEvent)
                        .filter(
    UsageEvent.project = = project,
    UsageEvent.timestamp > = time_threshold.timestamp(),
    #                     )
                        .count()
    > = min_calls
    #                 )
                    .order_by("count DESC")
                    .all()
    #             )

    #             return [row[0] for row in result]
    #         except Exception as e:
    #             return []
    #         finally:
                session.close()

    #     def get_input_samples(
    self, call_signature: str, limit: int = 10
    #     ) -> List[Dict[str, Any]]:
    #         """Get representative input samples for a given call signature."""
    session = self.get_session()
    #         try:
    samples = (
                    session.query(UsageEvent.args_json, UsageEvent.id)
                    .filter(
    UsageEvent.call_signature = = call_signature,
    UsageEvent.outcome = = "success",
    #                 )
                    .order_by(UsageEvent.timestamp.desc())
                    .limit(limit)
                    .all()
    #             )

    result = []
    #             for args_json, sample_id in samples:
                    result.append(
    #                     {
    #                         "args": json.loads(args_json) if args_json else {},
    #                         "sample_id": sample_id,
    #                     }
    #                 )

    #             return result
    #         except Exception as e:
    #             return []
    #         finally:
                session.close()

    #     def log_candidate_lib(
    #         self,
    #         call_signature: str,
    #         source_code: str,
    #         tests: Dict[str, Any],
    #         bench_results: Dict[str, Any],
    #         provenance: Dict[str, Any],
    status: str = "pending",
    #     ) -> str:
    #         """Log a candidate library for optimization."""
    candidate_id = str(uuid.uuid4())
    session = self.get_session()
    #         try:
    candidate = CandidateLib(
    id = candidate_id,
    call_signature = call_signature,
    source_code = source_code,
    tests = json.dumps(tests),
    bench_results = json.dumps(bench_results),
    provenance = json.dumps(provenance),
    status = status,
    created_at = time.time(),
    signature = "",
    #             )
                session.add(candidate)
                session.commit()
    #             return candidate_id
    #         except Exception as e:
                session.rollback()
    #             raise e
    #         finally:
                session.close()

    #     def get_candidate_status(self, candidate_id: str) -> Optional[str]:
    #         """Get the status of a candidate library."""
    session = self.get_session()
    #         try:
    result = (
                    session.query(CandidateLib.status)
    .filter(CandidateLib.id = = candidate_id)
                    .first()
    #             )
    #             return result[0] if result else None
    #         except Exception as e:
    #             return None
    #         finally:
                session.close()

    #     def update_candidate_status(
    self, candidate_id: str, status: str, signature: str = ""
    #     ) -> bool:
    #         """Update the status of a candidate library."""
    session = self.get_session()
    #         try:
    candidate = (
                    session.query(CandidateLib)
    .filter(CandidateLib.id = = candidate_id)
                    .first()
    #             )

    #             if candidate:
    candidate.status = status
    candidate.signature = signature
                    session.commit()
    #                 return True
    #             return False
    #         except Exception as e:
                session.rollback()
    #             return False
    #         finally:
                session.close()
