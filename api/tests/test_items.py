from httpx import AsyncClient


async def test_health(client: AsyncClient):
    res = await client.get("/health")
    assert res.status_code == 200
    assert res.json() == {"status": "ok"}


async def test_list_items_empty(client: AsyncClient):
    res = await client.get("/api/items")
    assert res.status_code == 200
    assert res.json() == []


async def test_create_item(client: AsyncClient):
    res = await client.post(
        "/api/items", json={"name": "Test Item", "description": "A test"}
    )
    assert res.status_code == 201
    data = res.json()
    assert data["name"] == "Test Item"
    assert data["description"] == "A test"
    assert "id" in data


async def test_get_item(client: AsyncClient):
    create_res = await client.post("/api/items", json={"name": "Get Test"})
    item_id = create_res.json()["id"]
    res = await client.get(f"/api/items/{item_id}")
    assert res.status_code == 200
    assert res.json()["name"] == "Get Test"


async def test_update_item(client: AsyncClient):
    create_res = await client.post("/api/items", json={"name": "Old Name"})
    item_id = create_res.json()["id"]
    res = await client.put(f"/api/items/{item_id}", json={"name": "New Name"})
    assert res.status_code == 200
    assert res.json()["name"] == "New Name"


async def test_delete_item(client: AsyncClient):
    create_res = await client.post("/api/items", json={"name": "Delete Me"})
    item_id = create_res.json()["id"]
    res = await client.delete(f"/api/items/{item_id}")
    assert res.status_code == 204
    get_res = await client.get(f"/api/items/{item_id}")
    assert get_res.status_code == 404


async def test_get_item_not_found(client: AsyncClient):
    res = await client.get("/api/items/nonexistent-id")
    assert res.status_code == 404
