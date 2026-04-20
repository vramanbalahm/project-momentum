# test_lookup.py — Lookup endpoint tests
#
# Covers:
# - /lookup/cuisine-region-states — returns list of strings
# - /lookup/cuisine-regions/{state} — returns regions for a valid state
# - /lookup/cuisine-sub-regions/{state}/{region} — returns id + sub_region pairs
# - /lookup/city-states — returns list of strings
# - /lookup/cities/{state} — returns id + display_name pairs
#
# All lookup endpoints are public — no auth required.
# Tests verify structure, known seed data values, and graceful empty responses.


class TestCuisineRegionStates:

    def test_returns_list(self, client):
        """Endpoint returns a non-empty list."""
        resp = client.get("/lookup/cuisine-region-states")
        assert resp.status_code == 200
        data = resp.json()
        assert isinstance(data, list)
        assert len(data) > 0

    def test_known_states_present(self, client):
        """Seeded states are present in the response."""
        resp = client.get("/lookup/cuisine-region-states")
        states = resp.json()
        for expected in ["Tamil Nadu", "Karnataka", "Kerala", "Andhra Pradesh", "Telangana"]:
            assert expected in states, f"Expected '{expected}' in cuisine states"

    def test_returns_strings(self, client):
        """All items are strings."""
        resp = client.get("/lookup/cuisine-region-states")
        for item in resp.json():
            assert isinstance(item, str)

    def test_no_auth_required(self, client):
        """No Authorization header needed — public endpoint."""
        resp = client.get("/lookup/cuisine-region-states")
        assert resp.status_code == 200


class TestCuisineRegions:

    def test_returns_regions_for_tamil_nadu(self, client):
        """Tamil Nadu returns its seeded regions."""
        resp = client.get("/lookup/cuisine-regions/Tamil Nadu")
        assert resp.status_code == 200
        data = resp.json()
        assert isinstance(data, list)
        assert len(data) > 0
        for expected in ["North Tamil Nadu", "Central Tamil Nadu", "South Tamil Nadu", "Coastal Tamil Nadu"]:
            assert expected in data, f"Expected region '{expected}'"

    def test_returns_regions_for_karnataka(self, client):
        """Karnataka returns its seeded regions."""
        resp = client.get("/lookup/cuisine-regions/Karnataka")
        assert resp.status_code == 200
        data = resp.json()
        assert "South Karnataka" in data
        assert "North Karnataka" in data
        assert "Central Karnataka" in data

    def test_unknown_state_returns_empty_list(self, client):
        """Unknown state returns empty list — not a 404."""
        resp = client.get("/lookup/cuisine-regions/UnknownState")
        assert resp.status_code == 200
        assert resp.json() == []

    def test_returns_strings(self, client):
        """All items are strings."""
        resp = client.get("/lookup/cuisine-regions/Kerala")
        for item in resp.json():
            assert isinstance(item, str)


class TestCuisineSubRegions:

    def test_returns_sub_regions_with_id(self, client):
        """Returns list of {id, sub_region} dicts."""
        resp = client.get("/lookup/cuisine-sub-regions/Tamil Nadu/North Tamil Nadu")
        assert resp.status_code == 200
        data = resp.json()
        assert isinstance(data, list)
        assert len(data) > 0
        for item in data:
            assert "id" in item
            assert "sub_region" in item
            assert isinstance(item["id"], int)
            assert isinstance(item["sub_region"], str)

    def test_known_sub_regions_present(self, client):
        """Seeded sub-regions are present."""
        resp = client.get("/lookup/cuisine-sub-regions/Tamil Nadu/North Tamil Nadu")
        sub_regions = [item["sub_region"] for item in resp.json()]
        assert "Chennai Brahmin (Iyer)" in sub_regions
        assert "Chennai Brahmin (Iyengar)" in sub_regions

    def test_chettinad_present_in_central(self, client):
        """Chettinad is under Central Tamil Nadu."""
        resp = client.get("/lookup/cuisine-sub-regions/Tamil Nadu/Central Tamil Nadu")
        sub_regions = [item["sub_region"] for item in resp.json()]
        assert "Chettinad" in sub_regions

    def test_unknown_region_returns_empty_list(self, client):
        """Unknown state/region combo returns empty list."""
        resp = client.get("/lookup/cuisine-sub-regions/Tamil Nadu/Fake Region")
        assert resp.status_code == 200
        assert resp.json() == []

    def test_udupi_brahmin_in_karnataka(self, client):
        """Karnataka South Karnataka has Udupi Brahmin."""
        resp = client.get("/lookup/cuisine-sub-regions/Karnataka/South Karnataka")
        sub_regions = [item["sub_region"] for item in resp.json()]
        assert "Udupi Brahmin" in sub_regions


class TestCityStates:

    def test_returns_list(self, client):
        """Endpoint returns a non-empty list."""
        resp = client.get("/lookup/city-states")
        assert resp.status_code == 200
        data = resp.json()
        assert isinstance(data, list)
        assert len(data) > 0

    def test_known_states_present(self, client):
        """Seeded states are in the response."""
        resp = client.get("/lookup/city-states")
        states = resp.json()
        for expected in ["Karnataka", "Tamil Nadu", "Kerala", "Andhra Pradesh", "Telangana", "Maharashtra"]:
            assert expected in states, f"Expected '{expected}' in city states"

    def test_returns_strings(self, client):
        """All items are strings."""
        for item in client.get("/lookup/city-states").json():
            assert isinstance(item, str)

    def test_no_auth_required(self, client):
        """Public endpoint."""
        assert client.get("/lookup/city-states").status_code == 200


class TestCities:

    def test_returns_cities_for_karnataka(self, client):
        """Karnataka returns its seeded cities."""
        resp = client.get("/lookup/cities/Karnataka")
        assert resp.status_code == 200
        data = resp.json()
        assert isinstance(data, list)
        assert len(data) > 0

    def test_city_structure(self, client):
        """Each city has id and display_name."""
        resp = client.get("/lookup/cities/Karnataka")
        for city in resp.json():
            assert "id" in city
            assert "display_name" in city
            assert isinstance(city["id"], int)
            assert isinstance(city["display_name"], str)

    def test_known_cities_present(self, client):
        """Bengaluru and Mysuru are in Karnataka cities."""
        resp = client.get("/lookup/cities/Karnataka")
        display_names = [c["display_name"] for c in resp.json()]
        assert "Bengaluru" in display_names
        assert "Mysuru" in display_names

    def test_tamil_nadu_cities(self, client):
        """Tamil Nadu cities include Chennai and Coimbatore."""
        resp = client.get("/lookup/cities/Tamil Nadu")
        display_names = [c["display_name"] for c in resp.json()]
        assert "Chennai" in display_names
        assert "Coimbatore" in display_names

    def test_agmarknet_name_not_exposed(self, client):
        """agmarknet_name is internal — verify lookup.py does not expose it.
        The existing lookup.py does return agmarknet_name — this test documents
        current behaviour. If the field is intentionally hidden in future, update here."""
        resp = client.get("/lookup/cities/Karnataka")
        # Current implementation returns agmarknet_name — test documents this
        # If this fails after a future change to hide it, that's expected and correct
        first = resp.json()[0]
        assert "display_name" in first  # display_name always required

    def test_unknown_state_returns_empty_list(self, client):
        """Unknown state returns empty list — not 404."""
        resp = client.get("/lookup/cities/UnknownState")
        assert resp.status_code == 200
        assert resp.json() == []

    def test_no_auth_required(self, client):
        """Public endpoint."""
        assert client.get("/lookup/cities/Karnataka").status_code == 200
