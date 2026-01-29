// from-teacher/03/init-s_users.sql が実行され、
// prisma/README.md の手順で Prisma Client が生成されていることを前提としています

import type { s_users } from "@prisma/client";
import { prisma } from "@/libs/prisma";

const users: s_users[] = await prisma.s_users.findMany();
console.log(users);
