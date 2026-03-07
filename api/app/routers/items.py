import uuid
from datetime import UTC, datetime

from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from app.database import get_db
from app.models import Item
from app.schemas import ItemCreate, ItemOut, ItemUpdate

router = APIRouter()


@router.get("/items", response_model=list[ItemOut])
async def list_items(db: AsyncSession = Depends(get_db)) -> list[Item]:
    result = await db.execute(select(Item).order_by(Item.created_at.desc()))
    return list(result.scalars().all())


@router.post("/items", response_model=ItemOut, status_code=201)
async def create_item(body: ItemCreate, db: AsyncSession = Depends(get_db)) -> Item:
    item = Item(id=str(uuid.uuid4()), **body.model_dump())
    db.add(item)
    await db.commit()
    await db.refresh(item)
    return item


@router.get("/items/{item_id}", response_model=ItemOut)
async def get_item(item_id: str, db: AsyncSession = Depends(get_db)) -> Item:
    item = await db.get(Item, item_id)
    if not item:
        raise HTTPException(status_code=404, detail="Item not found")
    return item


@router.put("/items/{item_id}", response_model=ItemOut)
async def update_item(
    item_id: str, body: ItemUpdate, db: AsyncSession = Depends(get_db)
) -> Item:
    item = await db.get(Item, item_id)
    if not item:
        raise HTTPException(status_code=404, detail="Item not found")
    for key, value in body.model_dump(exclude_unset=True).items():
        setattr(item, key, value)
    item.updated_at = datetime.now(UTC)
    await db.commit()
    await db.refresh(item)
    return item


@router.delete("/items/{item_id}", status_code=204)
async def delete_item(item_id: str, db: AsyncSession = Depends(get_db)) -> None:
    item = await db.get(Item, item_id)
    if not item:
        raise HTTPException(status_code=404, detail="Item not found")
    await db.delete(item)
    await db.commit()
