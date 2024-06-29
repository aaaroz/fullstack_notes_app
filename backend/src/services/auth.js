import { hash } from "argon2";
import { prisma } from "../applications/database.js";
import { HttpException } from "../middlewares/error.js";
import jwt from "jsonwebtoken";
import "dotenv/config";
import { verify } from "argon2";

//Service Register
export const register = async (request) => {
  const findUser = await prisma.users.findFirst({
    where: {
      username: request.username,
    },
  });
  if (findUser) {
    throw new HttpException(409, "User already exists");
  }
  request.password = await hash(request.password);
  const user = await prisma.users.create({
    data: {
      fullname: request.fullname,
      username: request.username,
      password: request.password,
    },
    select: {
      id: true,
      fullname: true,
      username: true,
      created_at: true,
    },
  });
  return {
    message: "User created successfully",
    user,
  };
};

//Service Login
export const login = async (request) => {
  const user = await prisma.users.findUnique({
    where: {
      username: request.username,
    },
  });
  if (!user) {
    throw new HttpException(401, "Invalid credentials");
  }
  const isPasswordValid = await verify(user.password, request.password);
  if (!isPasswordValid) {
    throw new HttpException(401, "Invalid credentials");
  }
  const token = jwt.sign(
    {
      id: user.id,
    },
    process.env.JWT_KEY
  );
  return {
    message: "Login successful",
    access_token: token,
  };
};
