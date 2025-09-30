let nextEntity: number = 0;
let entityCount: number = 0;
let attributeStores: Map<any, GenericAttributeStore> = new Map();

const Opaque = Symbol(); // opaque type tag
export type Entity = number & { [Opaque]: never };

export abstract class Attribute {}

export function createEntity(): Entity {
  const entity = nextEntity as Entity;
  nextEntity++;
  entityCount++;
  return entity;
}

export function deleteEntity(entity: Entity) {
  // delete all attributes for this entity
  let numDeletedAttributes = 0;
  for (const store of attributeStores.values()) {
    if (store.delete(entity)) numDeletedAttributes++;
  }

  // only decrement if entity existed
  if (numDeletedAttributes > 0) entityCount--;
}

export function getEntityCount(): number {
  return entityCount;
}

export function getAttribute<T>(
  type: typeof Attribute,
  entity: Entity
): T | undefined {
  return getAttributeStore<T>(type).get(entity);
}

export function setAttribute<T>(
  type: typeof Attribute,
  entity: Entity,
  value: T
) {
  if (!attributeStores.has(type))
    registerAttribute(type, new AttributeMap<T>());
  getAttributeStore(type).set(entity, value);
}

export function deleteAttribute(type: Attribute, entity: Entity) {
  getAttributeStore(type).delete(entity);
}

export function isAttributeSet(type: Attribute, entity: Entity): boolean {
  return getAttributeStore(type).has(entity);
}

function registerAttribute<T>(type: Attribute, store: AttributeStore<T>) {
  if (attributeStores.has(type))
    throw new Error(`attribute '${(type as any).name}' already defined`);
  attributeStores.set(type, store);
}

function getGenericAttributeStore(type: object): GenericAttributeStore {
  const store = attributeStores.get(type);
  if (!store) throw new Error(`undefined attribute '${(type as any).name}'`);
  return store;
}

function getAttributeStore<T>(type: object): AttributeStore<T> {
  return getGenericAttributeStore(type) as AttributeStore<T>;
}

interface GenericAttributeStore {
  has(entity: Entity): boolean;
  delete(entity: Entity): boolean;
  count(): number;
  clear(): void;
}

interface AttributeStore<T> extends GenericAttributeStore {
  get(entity: Entity): T | undefined;
  set(entity: Entity, value: T): void;
  iterator(): Iterator<T, undefined, T>;
}

class AttributeMap<T> implements AttributeStore<T> {
  private map: Map<Entity, T> = new Map();

  get(entity: Entity): T | undefined {
    return this.map.get(entity);
  }

  set(entity: Entity, value: T) {
    return this.map.set(entity, value);
  }

  iterator(): Iterator<T, undefined, T> {
    return this.map.values();
  }

  has(entity: Entity): boolean {
    return this.map.has(entity);
  }

  delete(entity: Entity): boolean {
    return this.map.delete(entity);
  }

  count(): number {
    return this.map.size;
  }

  clear(): void {
    this.map.clear();
  }
}
