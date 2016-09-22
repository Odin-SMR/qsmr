import unittest

from snapshot import add_jobs

PROJECT_NAME = 'testproject'
CONFIG_FILE = '/tmp/test_qsmr_snapshot_config.conf'
JOBS_FILE = '/tmp/test_qsmr_snapshot_jobs.txt'


class BaseTest(unittest.TestCase):
    def _write_config(self, cfg):
        with open(CONFIG_FILE, 'w') as out:
            out.write(cfg)


class TestConfigValidation(BaseTest):

    def test_missing_value(self):
        """Test missing config values"""
        self._write_config('ODIN_SECRET=adsfasree\n')
        self.assertEqual(add_jobs.main([PROJECT_NAME, CONFIG_FILE]), 1)

        self._write_config((
            'ODIN_SECRET=adsfasree\n'
            'ODIN_API_ROOT=http://example.com\n'
            'JOB_API_ROOT=http://example.com\n'
            'JOB_API_USERNAME=testuser\n'
            'JOB_API_PASSWORD=\n'))
        self.assertEqual(add_jobs.main([PROJECT_NAME, CONFIG_FILE]), 1)

    def test_ok_config(self):
        """Test that ok config validates"""
        self._write_config((
            'ODIN_SECRET=adsfasree\n'
            'ODIN_API_ROOT=http://example.com\n'
            'JOB_API_ROOT=http://example.com\n'
            'JOB_API_USERNAME=testuser\n'
            'JOB_API_PASSWORD=testpw\n'))
        self.assertEqual(add_jobs.main([PROJECT_NAME, CONFIG_FILE]), 0)

    def test_bad_api_root(self):
        """Test bad api root url"""
        self._write_config((
            'ODIN_SECRET=adsfasree\n'
            'ODIN_API_ROOT=example.com\n'
            'JOB_API_ROOT=http://example.com\n'
            'JOB_API_USERNAME=testuser\n'
            'JOB_API_PASSWORD=testpw\n'))
        self.assertEqual(add_jobs.main([PROJECT_NAME, CONFIG_FILE]), 1)

        self._write_config((
            'ODIN_SECRET=adsfasree\n'
            'ODIN_API_ROOT=http://example.com\n'
            'JOB_API_ROOT=http://example.com/\n'
            'JOB_API_USERNAME=testuser\n'
            'JOB_API_PASSWORD=testpw\n'))
        self.assertEqual(add_jobs.main([PROJECT_NAME, CONFIG_FILE]), 1)


class TestProjectNameValidation(BaseTest):

    def test_project_names(self):
        """Test bad and good project names"""
        self._write_config((
            'ODIN_SECRET=adsfasree\n'
            'ODIN_API_ROOT=http://example.com\n'
            'JOB_API_ROOT=http://example.com\n'
            'JOB_API_USERNAME=testuser\n'
            'JOB_API_PASSWORD=testpw\n'))
        self.assertEqual(add_jobs.main(['test_project', CONFIG_FILE]), 1)
        self.assertEqual(add_jobs.main(['1project', CONFIG_FILE]), 1)
        self.assertEqual(add_jobs.main(['123', CONFIG_FILE]), 1)
        self.assertEqual(add_jobs.main(['', CONFIG_FILE]), 1)

        self.assertEqual(add_jobs.main(['project', CONFIG_FILE]), 0)
        self.assertEqual(add_jobs.main(['p123', CONFIG_FILE]), 0)


class BaseTestAddJobs(BaseTest):

    def setUp(self):
        self._write_config((
            'ODIN_SECRET=adsfasreerfgtres\n'
            'ODIN_API_ROOT=http://example.com\n'
            'JOB_API_ROOT=http://example.com\n'
            'JOB_API_USERNAME=testuser\n'
            'JOB_API_PASSWORD=testpw\n'))

        def mock_get_token(self):
            pass

        self._mock_post_method = self._get_mock_post_method()
        self._orig_post_method = add_jobs.AddQsmrJobs._post_job
        self._orig_get_token = add_jobs.AddQsmrJobs.get_token
        add_jobs.AddQsmrJobs._post_job = self._mock_post_method
        add_jobs.AddQsmrJobs.get_token = mock_get_token

    def _get_mock_post_method(self):
        def mock_post_method(self, job):
            mock_post_method.jobs.append(job)
            return 201
        mock_post_method.jobs = []
        return mock_post_method

    def tearDown(self):
        add_jobs.AddQsmrJobs._post_job = self._orig_post_method
        add_jobs.AddQsmrJobs.get_token = self._orig_get_token

    def _write_scanids(self, scanids):
        with open(JOBS_FILE, 'w') as out:
            out.write('\n'.join(scanids) + '\n')


class TestAddJobs(BaseTestAddJobs):

    def test_add_jobs(self):
        """Test to add jobs from a scan id file"""
        self._write_scanids(map(str, range(15)))
        exit_code = add_jobs.main([
            PROJECT_NAME, CONFIG_FILE, '--freq-mode', '1',
            '--jobs-file', JOBS_FILE])
        self.assertEqual(exit_code, 0)
        self.assertEqual(len(self._mock_post_method.jobs), 15)

    def test_skip(self):
        """Test skipping of scan ids in the file"""
        self._write_scanids(map(str, range(15)))
        exit_code = add_jobs.main([
            PROJECT_NAME, CONFIG_FILE, '--freq-mode', '1',
            '--jobs-file', JOBS_FILE, '--skip', '6'])
        self.assertEqual(exit_code, 0)
        self.assertEqual(len(self._mock_post_method.jobs), 15-6)


class TestRenewToken(BaseTestAddJobs):

    def _get_mock_post_method(self):
        def mock_post_method(self, job):
            if not mock_post_method.called:
                mock_post_method.called = True
                return 401
            else:
                mock_post_method.jobs.append(job)
                return 201
        mock_post_method.jobs = []
        mock_post_method.called = False
        return mock_post_method

    def test_renew_token(self):
        """Test retry because of renewal of auth token"""
        self._write_scanids(map(str, range(15)))
        exit_code = add_jobs.main([
            PROJECT_NAME, CONFIG_FILE, '--freq-mode', '1',
            '--jobs-file', JOBS_FILE])
        self.assertEqual(exit_code, 0)
        self.assertEqual(len(self._mock_post_method.jobs), 15)


class TestFailure(BaseTestAddJobs):

    def _get_mock_post_method(self):
        def mock_post_method(self, job):
            if mock_post_method.jobs:
                raise Exception('Failed!')
            else:
                mock_post_method.jobs.append(job)
                return 201
        mock_post_method.jobs = []
        mock_post_method.called = False
        return mock_post_method

    def test_failure(self):
        """Test exception of post of job"""
        self._write_scanids(map(str, range(15)))
        exit_code = add_jobs.main([
            PROJECT_NAME, CONFIG_FILE, '--freq-mode', '1',
            '--jobs-file', JOBS_FILE])
        self.assertEqual(exit_code, 1)
        self.assertEqual(len(self._mock_post_method.jobs), 1)
