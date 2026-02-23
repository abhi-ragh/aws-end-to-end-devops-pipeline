import { DataTypes } from 'sequelize';
import sequelize from '../db';

const User = sequelize.define('User', {
  id: { type: DataTypes.INTEGER, primaryKey: true, autoIncrement: true },
  name: { type: DataTypes.STRING, allowNull: false },
  email: { type: DataTypes.STRING, allowNull: false, unique: true },
  password: { type: DataTypes.STRING, allowNull: false },
  isAdmin: { type: DataTypes.BOOLEAN, defaultValue: false },
}, { timestamps: false });

const Product = sequelize.define('Product', {
  id: { type: DataTypes.INTEGER, primaryKey: true, autoIncrement: true },
  name: { type: DataTypes.STRING, allowNull: false },
  image: { type: DataTypes.STRING, allowNull: false },
  brand: { type: DataTypes.STRING, allowNull: false },
  price: { type: DataTypes.FLOAT, allowNull: false, defaultValue: 0 },
  category: { type: DataTypes.STRING, allowNull: false },
  countInStock: { type: DataTypes.INTEGER, allowNull: false, defaultValue: 0 },
  description: { type: DataTypes.TEXT, allowNull: false },
  rating: { type: DataTypes.FLOAT, defaultValue: 0 },
  numReviews: { type: DataTypes.INTEGER, defaultValue: 0 },
}, { timestamps: false });

const Review = sequelize.define('Review', {
  id: { type: DataTypes.INTEGER, primaryKey: true, autoIncrement: true },
  name: { type: DataTypes.STRING, allowNull: false },
  rating: { type: DataTypes.FLOAT, defaultValue: 0 },
  comment: { type: DataTypes.TEXT, allowNull: false },
}, { timestamps: true });

const Order = sequelize.define('Order', {
  id: { type: DataTypes.INTEGER, primaryKey: true, autoIncrement: true },
  shipping: { type: DataTypes.JSON },
  payment: { type: DataTypes.JSON },
  itemsPrice: { type: DataTypes.FLOAT },
  taxPrice: { type: DataTypes.FLOAT },
  shippingPrice: { type: DataTypes.FLOAT },
  totalPrice: { type: DataTypes.FLOAT },
  isPaid: { type: DataTypes.BOOLEAN, defaultValue: false },
  paidAt: { type: DataTypes.DATE },
  isDelivered: { type: DataTypes.BOOLEAN, defaultValue: false },
  deliveredAt: { type: DataTypes.DATE },
}, { timestamps: true });

const OrderItem = sequelize.define('OrderItem', {
  id: { type: DataTypes.INTEGER, primaryKey: true, autoIncrement: true },
  name: { type: DataTypes.STRING, allowNull: false },
  qty: { type: DataTypes.INTEGER, allowNull: false },
  image: { type: DataTypes.STRING, allowNull: false },
  price: { type: DataTypes.FLOAT, allowNull: false },
}, { timestamps: false });

// Associations
User.hasMany(Order, { foreignKey: 'userId' });
Order.belongsTo(User, { foreignKey: 'userId', as: 'user' });

Product.hasMany(Review, { foreignKey: 'productId' });
Review.belongsTo(Product, { foreignKey: 'productId' });

Product.hasMany(OrderItem, { foreignKey: 'productId' });
OrderItem.belongsTo(Product, { foreignKey: 'productId' });

Order.hasMany(OrderItem, { foreignKey: 'orderId' });
OrderItem.belongsTo(Order, { foreignKey: 'orderId' });

export { sequelize, User, Product, Review, Order, OrderItem };
