"""
Stop or start a single RDS instance on a daily schedule (EventBridge Scheduler → Lambda).

Event payload: {"action": "stop" | "start"}
"""

from __future__ import annotations

import logging
import os
from typing import Any

import boto3
from botocore.exceptions import ClientError

logger = logging.getLogger()
logger.setLevel(logging.INFO)

RDS = boto3.client("rds")
DB_INSTANCE_IDENTIFIER = os.environ["DB_INSTANCE_IDENTIFIER"]

# Benign when the instance is already in the desired state.
BENIGN_ERROR_CODES = frozenset(
    {
        "InvalidDBInstanceStateFault",
        "InvalidDBInstanceState",
    }
)


def lambda_handler(event: dict[str, Any], context: Any) -> dict[str, Any]:
    action = (event or {}).get("action", "").strip().lower()
    if action not in ("stop", "start"):
        raise ValueError(f"Invalid action '{action}'; expected 'stop' or 'start'.")

    logger.info(
        "RDS scheduler action=%s db=%s",
        action,
        DB_INSTANCE_IDENTIFIER,
    )

    try:
        if action == "stop":
            response = RDS.stop_db_instance(DBInstanceIdentifier=DB_INSTANCE_IDENTIFIER)
        else:
            response = RDS.start_db_instance(DBInstanceIdentifier=DB_INSTANCE_IDENTIFIER)
    except ClientError as error:
        code = error.response.get("Error", {}).get("Code", "")
        if code in BENIGN_ERROR_CODES:
            logger.warning("Skipping %s: %s", action, error)
            return _result(action, "skipped", str(error))
        raise

    status = response.get("DBInstance", {}).get("DBInstanceStatus", "unknown")
    logger.info("RDS %s completed; status=%s", action, status)
    return _result(action, "ok", status)


def _result(action: str, outcome: str, detail: str) -> dict[str, Any]:
    return {
        "action": action,
        "db_instance_identifier": DB_INSTANCE_IDENTIFIER,
        "outcome": outcome,
        "detail": detail,
    }
