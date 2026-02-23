import express from 'express';
import User from '../models/userModel';
import { getToken, isAuth } from '../util';

const router = express.Router();

router.put('/:id', isAuth, async (req, res) => {
  const userId = req.params.id;
  const user = await User.findByPk(userId);
  if (user) {
    await user.update({
      name: req.body.name || user.name,
      email: req.body.email || user.email,
      password: req.body.password || user.password,
    });
    const updatedUser = await User.findByPk(userId);
    res.send({
      _id: updatedUser.id,
      name: updatedUser.name,
      email: updatedUser.email,
      isAdmin: updatedUser.isAdmin,
      token: getToken(updatedUser),
    });
  } else {
    res.status(404).send({ message: 'User Not Found' });
  }
});

router.post('/signin', async (req, res) => {
  const signinUser = await User.findOne({
    where: { email: req.body.email, password: req.body.password },
  });
  if (signinUser) {
    res.send({
      _id: signinUser.id,
      name: signinUser.name,
      email: signinUser.email,
      isAdmin: signinUser.isAdmin,
      token: getToken(signinUser),
    });
  } else {
    res.status(401).send({ message: 'Invalid Email or Password.' });
  }
});

router.post('/register', async (req, res) => {
  try {
    const newUser = await User.create({
      name: req.body.name,
      email: req.body.email,
      password: req.body.password,
    });
    res.send({
      _id: newUser.id,
      name: newUser.name,
      email: newUser.email,
      isAdmin: newUser.isAdmin,
      token: getToken(newUser),
    });
  } catch (err) {
    res.status(401).send({ message: 'Invalid User Data.' });
  }
});

router.get('/createadmin', async (req, res) => {
  try {
    const newUser = await User.create({
      name: 'Basir',
      email: 'admin@example.com',
      password: '1234',
      isAdmin: true,
    });
    res.send(newUser);
  } catch (error) {
    res.send({ message: error.message });
  }
});

export default router;
