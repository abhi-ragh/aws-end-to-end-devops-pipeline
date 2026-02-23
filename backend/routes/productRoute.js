import express from 'express';
import Product from '../models/productModel';
import { Review } from '../models/initModels';
import { isAuth, isAdmin } from '../util';
import { Op } from 'sequelize';

const router = express.Router();

router.get('/', async (req, res) => {
  const where = {};
  if (req.query.category) where.category = req.query.category;
  if (req.query.searchKeyword)
    where.name = { [Op.like]: `%${req.query.searchKeyword}%` };
  const order = [];
  if (req.query.sortOrder) {
    order.push(['price', req.query.sortOrder === 'lowest' ? 'ASC' : 'DESC']);
  } else {
    order.push(['id', 'DESC']);
  }
  const products = await Product.findAll({ where, order });
  res.send(products);
});

router.get('/:id', async (req, res) => {
  const product = await Product.findByPk(req.params.id, { include: [Review] });
  if (product) {
    res.send(product);
  } else {
    res.status(404).send({ message: 'Product Not Found.' });
  }
});
router.post('/:id/reviews', isAuth, async (req, res) => {
  const product = await Product.findByPk(req.params.id, { include: [Review] });
  if (product) {
    const review = await Review.create({
      name: req.body.name,
      rating: Number(req.body.rating),
      comment: req.body.comment,
      productId: product.id,
    });
    const reviews = await Review.findAll({ where: { productId: product.id } });
    const numReviews = reviews.length;
    const rating = reviews.reduce((a, c) => c.rating + a, 0) / numReviews;
    await product.update({ numReviews, rating });
    res.status(201).send({ data: review, message: 'Review saved successfully.' });
  } else {
    res.status(404).send({ message: 'Product Not Found' });
  }
});
router.put('/:id', isAuth, isAdmin, async (req, res) => {
  const productId = req.params.id;
  const product = await Product.findByPk(productId);
  if (product) {
    const updatedProduct = await product.update({
      name: req.body.name,
      price: req.body.price,
      image: req.body.image,
      brand: req.body.brand,
      category: req.body.category,
      countInStock: req.body.countInStock,
      description: req.body.description,
    });
    if (updatedProduct) {
      return res.status(200).send({ message: 'Product Updated', data: updatedProduct });
    }
  }
  return res.status(500).send({ message: ' Error in Updating Product.' });
});

router.delete('/:id', isAuth, isAdmin, async (req, res) => {
  const product = await Product.findByPk(req.params.id);
  if (product) {
    await product.destroy();
    res.send({ message: 'Product Deleted' });
  } else {
    res.send('Error in Deletion.');
  }
});

router.post('/', isAuth, isAdmin, async (req, res) => {
  try {
    const newProduct = await Product.create({
      name: req.body.name,
      price: req.body.price,
      image: req.body.image,
      brand: req.body.brand,
      category: req.body.category,
      countInStock: req.body.countInStock,
      description: req.body.description,
      rating: req.body.rating || 0,
      numReviews: req.body.numReviews || 0,
    });
    return res.status(201).send({ message: 'New Product Created', data: newProduct });
  } catch (err) {
    return res.status(500).send({ message: ' Error in Creating Product.' });
  }
});

export default router;
