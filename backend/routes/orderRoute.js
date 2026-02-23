import express from 'express';
import Order from '../models/orderModel';
import { OrderItem, User, Product } from '../models/initModels';
import { isAuth, isAdmin } from '../util';

const router = express.Router();

router.get("/", isAuth, async (req, res) => {
  const orders = await Order.findAll({ include: [{ model: User, as: 'user' }] });
  res.send(orders);
});
router.get("/mine", isAuth, async (req, res) => {
  const orders = await Order.findAll({ where: { userId: req.user._id } });
  res.send(orders);
});

router.get("/:id", isAuth, async (req, res) => {
  const order = await Order.findByPk(req.params.id, { include: [OrderItem] });
  if (order) {
    res.send(order);
  } else {
    res.status(404).send("Order Not Found.")
  }
});

router.delete("/:id", isAuth, isAdmin, async (req, res) => {
  const order = await Order.findByPk(req.params.id);
  if (order) {
    await order.destroy();
    res.send(order);
  } else {
    res.status(404).send("Order Not Found.")
  }
});

router.post("/", isAuth, async (req, res) => {
  const t = await Order.sequelize.transaction();
  try {
    const order = await Order.create({
      userId: req.user._id,
      shipping: req.body.shipping,
      payment: req.body.payment,
      itemsPrice: req.body.itemsPrice,
      taxPrice: req.body.taxPrice,
      shippingPrice: req.body.shippingPrice,
      totalPrice: req.body.totalPrice,
    }, { transaction: t });
    const items = req.body.orderItems || [];
    for (const it of items) {
      await OrderItem.create({
        name: it.name,
        qty: it.qty,
        image: it.image,
        price: it.price,
        productId: it.product,
        orderId: order.id,
      }, { transaction: t });
    }
    await t.commit();
    const created = await Order.findByPk(order.id, { include: [OrderItem] });
    res.status(201).send({ message: "New Order Created", data: created });
  } catch (err) {
    await t.rollback();
    res.status(500).send({ message: err.message });
  }
});

router.put('/:id/pay', isAuth, async (req, res) => {
  const order = await Order.findByPk(req.params.id);
  if (order) {
    await order.update({
      isPaid: true,
      paidAt: Date.now(),
      payment: {
        paymentMethod: 'paypal',
        paymentResult: {
          payerID: req.body.payerID,
          orderID: req.body.orderID,
          paymentID: req.body.paymentID,
        },
      },
    });
    const updatedOrder = await Order.findByPk(req.params.id);
    res.send({ message: 'Order Paid.', order: updatedOrder });
  } else {
    res.status(404).send({ message: 'Order not found.' })
  }
});

export default router;