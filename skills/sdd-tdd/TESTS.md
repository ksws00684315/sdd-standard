# 好测试与坏测试（Java）

示例基于 JUnit 5、AssertJ、Spring Boot Test。

## 好测试：通过公共接口验证行为

```java
// GOOD: verifies observable behavior through the public interface
@Test
void unpaidOrderIsCancelledAfterTimeout() {
    Order order = orderService.create(newOrderRequest());
    clock.advance(Duration.ofMinutes(31)); // test-controlled mutable Clock bean

    timeoutCancelJob.run();

    assertThat(orderService.get(order.getOrderNo()).getStatus())
        .isEqualTo(OrderStatus.CANCELLED);
}
```

特点：

- 测的是调用方关心的行为
- 只用公共接口
- 内部重构后依然通过
- 测试名描述"做什么"，而不是"怎么做"
- 每个测试只有一个逻辑上的断言

## 坏测试：耦合实现细节

```java
// BAD: asserts on an internal collaborator call
@Test
void cancelCallsOrderMapperUpdate() {
    timeoutCancelJob.run();
    verify(orderMapper).updateStatus(any(), eq(OrderStatus.CANCELLED));
}
```

危险信号：

- mock 本服务内部的协作者（Mapper、其他 Service）
- 测试私有方法
- 断言调用次数或调用顺序
- 只是重构、行为没变，测试就失败
- 测试名描述的是"怎么做"

## 坏测试：绕过接口验证

```java
// BAD: bypasses the interface and checks the table directly
@Test
void createOrderInsertsRow() {
    orderService.create(newOrderRequest());
    Integer count = jdbcTemplate.queryForObject(
        "SELECT COUNT(*) FROM t_order", Integer.class);
    assertThat(count).isEqualTo(1);
}

// GOOD: verifies through the interface
@Test
void createdOrderCanBeRetrieved() {
    Order order = orderService.create(newOrderRequest());
    assertThat(orderService.get(order.getOrderNo())).isNotNull();
}
```

## 坏测试：同义反复

```java
// BAD: expected value is computed the same way the code computes it
@Test
void totalAmountSumsLineItems() {
    List<LineItem> items = List.of(item("10.00"), item("5.00"));
    BigDecimal expected = items.stream()
        .map(LineItem::getPrice).reduce(BigDecimal.ZERO, BigDecimal::add);
    assertThat(pricing.total(items)).isEqualByComparingTo(expected);
}

// GOOD: expected value is an independent, known literal
@Test
void totalAmountSumsLineItems() {
    assertThat(pricing.total(List.of(item("10.00"), item("5.00"))))
        .isEqualByComparingTo("15.00");
}
```

## mock 外部服务：用 WireMock 而不是 mock 自己的客户端类

```java
// GOOD: stub the other service at the HTTP boundary
stubFor(post("/stock/release")
    .willReturn(okJson("{\"released\": true}")));
```

这样本服务的 Feign 客户端、序列化、重试逻辑都会被真实执行。

## 让外部依赖容易替换

- 外部依赖通过构造器注入，而不是在方法里 `new` 出来。
- 时间通过注入的 `Clock` 获取，测试里可以拨动时间，不要直接调用 `LocalDateTime.now()`。
- 每个外部操作一个明确的方法（`releaseStock`、`queryStock`），而不是一个通用的 `call(path, body)`。这样每个 stub 只返回一种结构，测试准备里不需要条件逻辑。
