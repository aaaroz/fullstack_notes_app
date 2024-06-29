import { login, register } from "../services/auth.js";

export const authController = {
  //Controller Register
  register: async (req, res, next) => {
    try {
      const result = await register(req.body);
      return res.status(201).json(result);
    } catch (error) {
      next(error);
    }
  },

  //Controller Login
  login: async (req, res, next) => {
    try {
      const result = await login(req.body);
      return res.status(200).json(result);
    } catch (error) {
      next(error);
    }
  },
};
