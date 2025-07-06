"use client";

import { useState } from "react";
import type { NextPage } from "next";
import { isAddress } from "viem";
import { AddressInput, IntegerInput } from "~~/components/scaffold-eth";
import { useScaffoldWriteContract } from "~~/hooks/scaffold-eth";

const Migrate: NextPage = () => {
  const [poolPartyContractAddress, setPoolPartyContractAddress] = useState("");
  const [tokenToMigrateContractAddress, setTokenToMigrateContractAddress] = useState("");
  const [amountOfTokensToMigrateInput, setAmountOfTokensToMigrateInput] = useState("");
  const [amountOfTokensToMigrateError, setAmountOfTokensToMigrateError] = useState<string | null>(null);
  const [foundPoolParty, setFoundPoolParty] = useState(false);

  const { writeContractAsync: writeYourContractAsync } = useScaffoldWriteContract({ contractName: "PoolPartyFactory" });

  const handleLookupPoolParty = (address: string) => {
    if (isAddress(address)) {
      setFoundPoolParty(true);
    } else {
      setFoundPoolParty(false);
    }
  };

  const handleMigrate = (e: React.FormEvent) => {
    e.preventDefault();
    writeYourContractAsync({
      functionName: "testy",
      args: ["f8w9fwj3fosfjslfjsod8fus0d8fus083fjs3f"],
    });
  };

  const handleDecimalsChange = (e: string) => {
    const value = e;
    setAmountOfTokensToMigrateInput(value);
    // Only validate if user has typed something
    if (value.trim() === "") {
      setAmountOfTokensToMigrateError(null);
      return;
    }

    const parsed = Number(value);

    if (isNaN(parsed)) {
      setAmountOfTokensToMigrateError("Must be a valid number.");
    } else if (!Number.isInteger(parsed)) {
      setAmountOfTokensToMigrateError("Must be an integer.");
    } else if (parsed < 0) {
      setAmountOfTokensToMigrateError("Cannot be negative.");
    } else {
      setAmountOfTokensToMigrateError(null);
    }
  };

  return (
    <div className="container mx-auto my-10 flex flex-col items-center justify-center">
      <div>
        <span className="block text-5xl font-bold mb-30 text-white">Migrate Tokens</span>
      </div>
      <form className="w-full md:w-3/4 lg:w-2/3 xl:w-1/2 bg-white text-base-content p-8 rounded-xl shadow-lg space-y-6 mb-15">
        <div className="flex items-center gap-8">
          <label className="w-40 text-right whitespace-nowrap">Contract Address</label>
          <AddressInput
            onChange={e => {
              setPoolPartyContractAddress(e);
              handleLookupPoolParty(e);
            }}
            value={poolPartyContractAddress}
            placeholder="0x..."
          />
        </div>
      </form>

      {foundPoolParty && (
        <form
          onSubmit={handleMigrate}
          className="w-full md:w-3/4 lg:w-2/3 xl:w-1/2 bg-white text-base-content p-8 rounded-xl shadow-lg space-y-6"
        >
          <div className="space-y-4">
            <div className="flex items-center gap-8">
              <label className="w-40 text-right whitespace-nowrap">Token Address</label>
              <AddressInput
                onChange={e => setTokenToMigrateContractAddress(e)}
                value={tokenToMigrateContractAddress}
                placeholder="0x..."
              />
            </div>
            <div className="flex items-center gap-8">
              <label className="w-40 text-right whitespace-nowrap">Tokens amount to burn</label>
              <IntegerInput value={amountOfTokensToMigrateInput} onChange={handleDecimalsChange} />
              {amountOfTokensToMigrateError && <p className="text-sm text-red-600">{amountOfTokensToMigrateError}</p>}
            </div>
          </div>
          <div className="flex justify-center">
            <button type="submit" className="btn btn-primary">
              Migrate
            </button>
          </div>
        </form>
      )}
    </div>
  );
};

export default Migrate;
