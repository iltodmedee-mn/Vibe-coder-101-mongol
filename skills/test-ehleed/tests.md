# Сайн ба муу test

## Сайн test

**Integration маягийн**: дотоод хэсгийн mock-оор биш, бодит interface-ээр дамжуулж test хий.

```typescript
// САЙН: ажиглагдах зан төлөвийг шалгана
test("user can checkout with valid cart", async () => {
  const cart = createCart();
  cart.add(product);
  const result = await checkout(cart, paymentMethod);
  expect(result.status).toBe("confirmed");
});
```

Шинж чанар:

- Хэрэглэгч/дуудагчид чухал зан төлөвийг шалгана
- Зөвхөн public API ашиглана
- Дотоод refactor-ийг даван туулна
- ЮУГ хийхийг тайлбарлана, ЯАЖ хийхийг биш
- Test бүрт нэг логик assertion

## Муу test

**Хэрэгжүүлэлтийн нарийн ширийнийг шалгадаг test**: дотоод бүтэцтэй уясан.

```typescript
// МУУ: хэрэгжүүлэлтийн нарийн ширийнийг шалгана
test("checkout calls paymentService.process", async () => {
  const mockPayment = jest.mock(paymentService);
  await checkout(cart, payment);
  expect(mockPayment.process).toHaveBeenCalledWith(cart.total);
});
```

Анхааруулах шинж:

- Дотоод хамтрагчдыг mock хийх
- Private method-ийг test хийх
- Дуудлагын тоо/дарааллыг шалгах
- Зан төлөв өөрчлөгдөөгүй refactor хийхэд test эвдрэх
- Test-ийн нэр ЮУГ биш, ЯАЖ гэдгийг тайлбарлах
- Interface-ээр биш, гадны аргаар шалгах

```typescript
// МУУ: interface-ийг тойрч шалгана
test("createUser saves to database", async () => {
  await createUser({ name: "Alice" });
  const row = await db.query("SELECT * FROM users WHERE name = ?", ["Alice"]);
  expect(row).toBeDefined();
});

// САЙН: interface-ээр дамжуулж шалгана
test("createUser makes user retrievable", async () => {
  const user = await createUser({ name: "Alice" });
  const retrieved = await getUser(user.id);
  expect(retrieved.name).toBe("Alice");
});
```

**Тавтологи test**: хүлээгдэж буй утга нь хэрэгжүүлэлтийг давтдаг тул test бүтцээрээ давна.

```typescript
// МУУ: хүлээгдэж буй утгыг код тооцдог шигээ дахин тооцсон
test("calculateTotal sums line items", () => {
  const items = [{ price: 10 }, { price: 5 }];
  const expected = items.reduce((sum, i) => sum + i.price, 0);
  expect(calculateTotal(items)).toBe(expected);
});

// САЙН: хүлээгдэж буй утга нь бие даасан, мэдэгдэж буй literal
test("calculateTotal sums line items", () => {
  expect(calculateTotal([{ price: 10 }, { price: 5 }])).toBe(15);
});
```

**Бие биеэсээ хамааралтай test**: өмнөх test-ийн үлдээсэн өгөгдөлд найддаг тул дангаар нь ажиллуулахад унана.

```typescript
// МУУ: хоёр дахь test нь эхний test ажилласан байхыг шаардана
test("creates user", async () => {
  await createUser({ name: "Alice" });
});
test("renames user", async () => {
  const user = await findUserByName("Alice");
  await renameUser(user.id, "Bob");
  expect((await getUser(user.id)).name).toBe("Bob");
});

// САЙН: test бүр өгөгдлөө өөрөө бэлдэнэ
test("renames user", async () => {
  const user = await createUser({ name: "Alice" });
  await renameUser(user.id, "Bob");
  expect((await getUser(user.id)).name).toBe("Bob");
});
```
