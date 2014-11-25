__author__ = 'sitin'

import pandas
import json
import os
import subprocess


__dir__ = os.path.dirname(os.path.realpath(__file__))
js_loader = __dir__ + '/loader.js'
default_fields = {'EEGATT', 'EEGMED'}


def load_js(path):
    """
    Convert log file (Javascript) with Node.js script to JSON and returns it's parsed result.
    :param path: path to log file
    :return: parse result
    """
    bytes = subprocess.check_output((js_loader, path), universal_newlines=True)
    json_data = str(bytes)
    return json.loads(json_data)


def filter_events(raw_events, fields=default_fields):
    """
    The function filters events that has timestamp and 
    :param raw_events: list of raw events
    :param fields: set of fields to keep in data
    :return: list of filtered events
    """
    for entry in raw_events:
        # Keys in entry that matter (e.g. fields)
        entry_fields = (fields | {'TS'}) & set(entry.keys())
        # We do not want to process events either without timestamp or with alone timestamp:
        if 'TS' not in entry_fields or len(entry_fields) < 2:
            continue
        # Take only significant fields from event
        event = {k: v for k, v in entry.items() if k in entry_fields}
        # Yield event
        yield event


def parse(path, fields=default_fields):
    """
    Loads data from neurointerface logs and put them to Pandas data frame.
    :param path: path to quasi JSON file
    :param fields: set of fields to keep in data
    :return: data frame
    """
    data = load_js(path)
    events = filter_events(data['data'], fields=fields)
    return pandas.DataFrame(events)
