import os
import logging
from dataclasses import dataclass

def get_optional_var(name, default=None):
    try:
        return os.environ[name]
    except KeyError:
        logging.warn(f"Environment variable {name} not set. Using default: {default}")
        return default

def get_required_var(name):
    try:
        return os.environ[name]
    except KeyError:
        logging.critical(f"Environment variable {name} not set.")


@dataclass
class Config:
    deployer_artifacts_bucket_id = get_required_var('DEPLOYER_ARTIFACTS_BUCKET_ID')
    target_names = get_required_var('TARGET_NAMES').split(',')
