"use client";

// import Link from "next/link";
import type { NextPage } from "next";
import { ClockIcon, GiftIcon, RocketLaunchIcon } from "@heroicons/react/24/outline";

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
            <p className="text-2xl">How to have a pool party</p>
          </div>
          <div className="flex flex-col">
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
                  <p className="mt-6">{item.number}</p> {/* Increased margin-top */}
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
                  text: "Enjoy your new token and liquidity",
                },
              ].map((item, index) => (
                <div
                  key={index}
                  className="flex flex-col bg-base-100 px-10 py-10 text-center items-center rounded-3xl w-96 h-60"
                >
                  {item.icon}
                  <p className="mt-6">{item.text}</p> {/* Increased margin-top */}
                </div>
              ))}
            </div>
          </div>
        </div>

        {/* <div className="flex justify-center items-center gap-12 flex-col md:flex-row">
          <div className="flex flex-col bg-base-100 px-10 py-10 text-center items-center max-w-xs rounded-3xl">
            <BugAntIcon className="h-8 w-8 fill-secondary" />
            <p>
              <Link href="/createmigration" passHref className="link">
                Create a new migration
              </Link>{" "}
            </p>
          </div>
          <div className="flex flex-col bg-base-100 px-10 py-10 text-center items-center max-w-xs rounded-3xl">
            <MagnifyingGlassIcon className="h-8 w-8 fill-secondary" />
            <p>Migrate tokens</p>
          </div>
        </div> */}
      </div>
    </>
  );
};

export default Home;
