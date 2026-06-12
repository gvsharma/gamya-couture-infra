"""
Daily cost scheduler: stop/start EC2 and RDS on EventBridge Scheduler triggers.

Stop order:  EC2 first, then RDS (app down before database).
Start order: RDS first (wait until available), then EC2.

Event payload: {"action": "stop" | "start"}
"""

from __future__ import annotations

import logging
import os
import time
from typing import Any

import boto3
from botocore.exceptions import ClientError

logger = logging.getLogger()
logger.setLevel(logging.INFO)

EC2 = boto3.client("ec2")
RDS = boto3.client("rds")

EC2_INSTANCE_ID = os.environ.get("EC2_INSTANCE_ID", "").strip()
DB_INSTANCE_IDENTIFIER = os.environ.get("DB_INSTANCE_IDENTIFIER", "").strip()
RDS_WAIT_MAX_SECONDS = int(os.environ.get("RDS_WAIT_MAX_SECONDS", "600"))
RDS_POLL_INTERVAL_SECONDS = int(os.environ.get("RDS_POLL_INTERVAL_SECONDS", "15"))

BENIGN_RDS_CODES = frozenset(
    {
        "InvalidDBInstanceStateFault",
        "InvalidDBInstanceState",
    }
)

BENIGN_EC2_CODES = frozenset(
    {
        "IncorrectInstanceState",
        "InvalidInstanceState",
    }
)


def lambda_handler(event: dict[str, Any], context: Any) -> dict[str, Any]:
    action = (event or {}).get("action", "").strip().lower()
    if action not in ("stop", "start"):
        raise ValueError(f"Invalid action '{action}'; expected 'stop' or 'start'.")

    if not EC2_INSTANCE_ID and not DB_INSTANCE_IDENTIFIER:
        raise ValueError("At least one of EC2_INSTANCE_ID or DB_INSTANCE_IDENTIFIER must be set.")

    logger.info(
        "Cost scheduler action=%s ec2=%s rds=%s",
        action,
        EC2_INSTANCE_ID or "(none)",
        DB_INSTANCE_IDENTIFIER or "(none)",
    )

    results: list[dict[str, Any]] = []

    if action == "stop":
        if EC2_INSTANCE_ID:
            results.append(_ec2_action("stop"))
        if DB_INSTANCE_IDENTIFIER:
            results.append(_rds_action("stop"))
    else:
        if DB_INSTANCE_IDENTIFIER:
            results.append(_rds_action("start"))
            results.append(_wait_rds_available())
        if EC2_INSTANCE_ID:
            results.append(_ec2_action("start"))

    return {"action": action, "results": results}


def _ec2_action(action: str) -> dict[str, Any]:
    try:
        if action == "stop":
            response = EC2.stop_instances(InstanceIds=[EC2_INSTANCE_ID])
            state = response["StoppingInstances"][0].get("CurrentState", {}).get("Name", "unknown")
        else:
            response = EC2.start_instances(InstanceIds=[EC2_INSTANCE_ID])
            state = response["StartingInstances"][0].get("CurrentState", {}).get("Name", "unknown")
    except ClientError as error:
        code = error.response.get("Error", {}).get("Code", "")
        if code in BENIGN_EC2_CODES:
            logger.warning("EC2 %s skipped: %s", action, error)
            return _result("ec2", action, "skipped", str(error))
        raise

    logger.info("EC2 %s completed; state=%s", action, state)
    return _result("ec2", action, "ok", state)


def _rds_action(action: str) -> dict[str, Any]:
    try:
        if action == "stop":
            response = RDS.stop_db_instance(DBInstanceIdentifier=DB_INSTANCE_IDENTIFIER)
        else:
            response = RDS.start_db_instance(DBInstanceIdentifier=DB_INSTANCE_IDENTIFIER)
    except ClientError as error:
        code = error.response.get("Error", {}).get("Code", "")
        if code in BENIGN_RDS_CODES:
            logger.warning("RDS %s skipped: %s", action, error)
            return _result("rds", action, "skipped", str(error))
        raise

    status = response.get("DBInstance", {}).get("DBInstanceStatus", "unknown")
    logger.info("RDS %s completed; status=%s", action, status)
    return _result("rds", action, "ok", status)


def _wait_rds_available() -> dict[str, Any]:
    deadline = time.monotonic() + RDS_WAIT_MAX_SECONDS

    while time.monotonic() < deadline:
        response = RDS.describe_db_instances(DBInstanceIdentifier=DB_INSTANCE_IDENTIFIER)
        status = response["DBInstances"][0].get("DBInstanceStatus", "unknown")
        logger.info("RDS wait poll; status=%s", status)

        if status == "available":
            return _result("rds", "wait", "ok", status)

        if status in ("stopped", "stopping", "failed"):
            return _result("rds", "wait", "failed", f"unexpected status: {status}")

        time.sleep(RDS_POLL_INTERVAL_SECONDS)

    return _result("rds", "wait", "timeout", f"not available within {RDS_WAIT_MAX_SECONDS}s")


def _result(resource: str, action: str, outcome: str, detail: str) -> dict[str, Any]:
    return {
        "resource": resource,
        "action": action,
        "outcome": outcome,
        "detail": detail,
    }
