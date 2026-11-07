# Хэзээ mock хийх вэ

Зөвхөн **системийн хил** дээр mock хий:

- Гадны API (төлбөр, email гэх мэт)
- Database (заримдаа; test DB-г илүүд үз)
- Цаг/санамсаргүй утга
- Файлын систем (заримдаа)

Mock бүү хий:

- Өөрийн class/module
- Дотоод хамтрагчид
- Өөрийн удирддаг аливаа зүйл

## Mock хийхэд хялбар байхаар зохиох

Системийн хил дээр mock хийхэд хялбар interface зохио:

**1. Dependency injection ашигла**

Гадны dependency-г дотор нь үүсгэхийн оронд гаднаас дамжуулж өг:

```typescript
// Mock хийхэд хялбар
function processPayment(order, paymentClient) {
  return paymentClient.charge(order.total);
}

// Mock хийхэд хэцүү
function processPayment(order) {
  const client = new StripeClient(process.env.STRIPE_KEY);
  return client.charge(order.total);
}
```

**2. Ерөнхий fetcher-ээс SDK маягийн interface-ийг илүүд үз**

Нөхцөлт логиктой нэг ерөнхий функцийн оронд гадны үйлдэл бүрт тусдаа функц үүсгэ:

```typescript
// САЙН: функц бүрийг тусад нь mock хийж болно
const api = {
  getUser: (id) => fetch(`/users/${id}`),
  getOrders: (userId) => fetch(`/users/${userId}/orders`),
  createOrder: (data) => fetch('/orders', { method: 'POST', body: data }),
};

// МУУ: mock дотор нөхцөлт логик бичих шаардлагатай болно
const api = {
  fetch: (endpoint, options) => fetch(endpoint, options),
};
```

SDK маягийн арга нь:
- Mock бүр нэг тодорхой хэлбэрийн утга буцаана
- Test-ийн setup-д нөхцөлт логик байхгүй
- Test аль endpoint-уудыг ашиглаж байгааг харахад хялбар
- Endpoint бүрт type safety
