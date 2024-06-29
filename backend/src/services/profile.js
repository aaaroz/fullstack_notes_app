import { prisma } from "../applications/database.js";
import { HttpException } from "../middlewares/error.js";

//Service Profile
export const getProfile = async (userId) => {
  const user = await prisma.users.findUnique({
    where: {
      id: userId,
    },
    select: {
      id: true,
      fullname: true,
      username: true,
      created_at: true,
    },
  });
  if (!user) {
    throw new HttpException(404, "User not found");
  }
  return user;
};
