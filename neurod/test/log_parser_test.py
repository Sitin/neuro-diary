__author__ = 'sitin'

import unittest
import log_parser
import fixtures
import pandas


class LogParserTestCase(unittest.TestCase):
    def test_loads_with_node_js(self):
        data = log_parser.load_js(fixtures.path_to_sample_log_file)
        self.assertIsInstance(data, dict)
        self.assertEqual(data['versionId'], '1.8.9')
        self.assertIsInstance(data['data'], list)

    def test_events_filtering(self):
        events = log_parser.filter_events(fixtures.raw_events_sample, fields={'EEGATT', 'EEGMED'})
        for event in events:
            self.assertIn('TS', event.keys())
            self.assertTrue('EEGATT' in event.keys() or 'EEGMED' in event.keys())

    def test_parse_to_pandas(self):
        df = log_parser.parse(fixtures.path_to_sample_log_file)
        self.assertIsInstance(df, pandas.DataFrame)
        self.assertSetEqual(set(df.columns), {'TS', 'EEGATT', 'EEGMED'})


if __name__ == '__main__':
    unittest.main()
