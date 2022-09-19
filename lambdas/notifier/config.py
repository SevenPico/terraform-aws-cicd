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
    slack_channel_ids = get_required_var("SLACK_CHANNEL_IDS").split(',')
    slack_secret_arn = get_required_var("SLACK_SECRET_ARN")
    project = get_required_var("PROJECT")
