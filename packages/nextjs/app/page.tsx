"use client";

// import Link from "next/link";
import Link from "next/link";
import type { NextPage } from "next";
import {
  AdjustmentsHorizontalIcon,
  ClockIcon,
  GiftIcon,
  RocketLaunchIcon,
  ShoppingCartIcon,
} from "@heroicons/react/24/outline";

const Home: NextPage = () => {
  return (
    <>
      <div className="flex items-center flex-col grow pt-10">
        <div className="px-5">
          <h1 className="text-center">
            <span className="block text-7xl font-bold">Pool Party 🛟</span>
          </h1>

          <p className="text-center text-lg">Do a backflip!</p>
        </div>

        <div className="flex flex-col justify-center items-center">
          <div>
            <p className="text-2xl">How it works</p>
          </div>
          <div className="flex flex-col space-y-10">
            <div className="flex justify-center items-center gap-12 flex-col md:flex-row">
              {[
                {
                  number: "1",
                },
                {
                  number: "2",
                },
                {
                  number: "3",
                },
              ].map((item, index) => (
                <div key={index} className="flex flex-col px-10 py-10 text-center items-center rounded-3xl w-96 h-30">
                  <p className="mt-6 text-5xl">{item.number}</p> {/* Increased margin-top */}
                </div>
              ))}
            </div>
            <div className="flex justify-center items-center gap-12 flex-col md:flex-row">
              {[
                {
                  icon: <RocketLaunchIcon className="h-8 w-8 fill-secondary" />,
                  text: "Create your token migration for one or multiple coins",
                },
                {
                  icon: <ClockIcon className="h-8 w-8 fill-secondary" />,
                  text: "Burn your old tokens and wait for the migration",
                },
                {
                  icon: <GiftIcon className="h-8 w-8 fill-secondary" />,
                  text: "Enjoy your new token with extra liquidity",
                },
              ].map((item, index) => (
                <div
                  key={index}
                  className="flex flex-col bg-base-100 px-10 py-10 text-center items-center rounded-3xl w-96 h-60 border border-gray-300 transition-transform duration-300 hover:-translate-y-2"
                >
                  {item.icon}
                  <p className="mt-6">{item.text}</p>
                </div>
              ))}
            </div>
          </div>

          <div className="flex flex-col space-y-10 mt-20">
            <div className="flex justify-center items-center gap-12 flex-col md:flex-row">
              {[
                {
                  icon: <AdjustmentsHorizontalIcon className="h-8 w-8 fill-secondary" />,
                  linkto: "/createmigration",
                  text: "Create Migration",
                },
                {
                  icon: <ShoppingCartIcon className="h-8 w-8 fill-secondary" />,
                  linkto: "/migrate",
                  text: "Migrate Coins",
                },
              ].map((item, index) => (
                <Link href={item.linkto} passHref className="link" key={index}>
                  <div className="flex flex-col bg-base-300 px-10 py-10 text-center items-center rounded-3xl w-40 h-60 shine-effect transition-transform duration-300 hover:-translate-y-1 hover:scale-[1.02] hover:shadow-lg">
                    {item.icon}
                    <p className="mt-6">{item.text}</p>
                  </div>
                </Link>
              ))}
            </div>
          </div>
        </div>
      </div>
    </>
  );
};

export default Home;
