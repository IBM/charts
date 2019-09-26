from six import string_types
import os


def test_adm_username_not_b64enc():
    username = os.environ['USERNAME']
    isinstance(username, string_types)


def test_adm_password_not_b64enc():
    password = os.environ['PASS']
    isinstance(password, string_types)
