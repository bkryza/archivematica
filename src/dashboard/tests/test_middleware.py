# -*- coding: utf-8 -*-
from __future__ import absolute_import

from django.conf import settings
from django.core.urlresolvers import reverse
from django.test import TestCase
from django.test.client import Client

from components import helpers
from installer.middleware import _load_exempt_urls


class ConfigurationCheckMiddlewareTestCase(TestCase):
    fixtures = ["test_user"]

    def setUp(self):
        self.client = Client()

    def test_user_is_sent_to_installer(self):
        response = self.client.get("/")

        self.assertRedirects(response, reverse("installer:welcome"))

    def test_installer(self):
        response = self.client.get(reverse("installer:welcome"))

        self.assertEqual(response.status_code, 200)

    def test_unauthenticated_user_can_access_exempt_url(self):
        helpers.set_setting("dashboard_uuid", "test-uuid")

        with self.settings(LOGIN_EXEMPT_URLS=[r"^foobar"]):
            _load_exempt_urls()
            response = self.client.get("foobar")

        self.assertEqual(response.status_code, 404)

    def test_unauthenticated_user_is_sent_to_login_page(self):
        helpers.set_setting("dashboard_uuid", "test-uuid")

        response = self.client.get(reverse("main:main_index"))

        self.assertRedirects(response, settings.LOGIN_URL)

    def test_authenticated_user_passes(self):
        helpers.set_setting("dashboard_uuid", "test-uuid")
        self.client.login(username="test", password="test")

        response = self.client.get(reverse("transfer:transfer_index"))

        self.assertEqual(response.status_code, 200)
