-- CreateTable
CREATE TABLE "Component" (
    "id" SERIAL NOT NULL,
    "marginLeft" TEXT DEFAULT '',
    "marginRight" TEXT DEFAULT '',
    "marginTop" TEXT DEFAULT '',
    "marginBottom" TEXT DEFAULT '',
    "paddingLeft" TEXT DEFAULT '',
    "paddingRight" TEXT DEFAULT '',
    "paddingTop" TEXT DEFAULT '',
    "paddingBottom" TEXT DEFAULT '',

    CONSTRAINT "Component_pkey" PRIMARY KEY ("id")
);
