"use client";

import { useEffect, useState } from "react";
// import {Button} from '@heroui/button';
// import {Form} from "@heroui/form";
import { Input } from "@heroui/input";
import type { NextPage } from "next";
import { hardhat } from "viem/chains";
import { useFetchBlocks } from "~~/hooks/scaffold-eth";
import { useTargetNetwork } from "~~/hooks/scaffold-eth/useTargetNetwork";
import { notification } from "~~/utils/scaffold-eth";

const CreateMigraiton: NextPage = () => {
  const { error } = useFetchBlocks();
  const { targetNetwork } = useTargetNetwork();
  const [isLocalNetwork, setIsLocalNetwork] = useState(true);
  const [hasError, setHasError] = useState(false);
  const [contractAddressInputs, setContractAddressInputs] = useState([""]); // start with one input
  const [newTokenName, setNewTokenName] = useState("");
  const [newTokenTicker, setNewTokenTicker] = useState("");
  // const [newTokenDecimals, setNewTokenDecimals] = useState(0);
  // const [newTokenSupply, setNewTokenSupply] = useState(0);

  useEffect(() => {
    if (targetNetwork.id !== hardhat.id) {
      setIsLocalNetwork(false);
    }
  }, [targetNetwork.id]);

  useEffect(() => {
    if (targetNetwork.id === hardhat.id && error) {
      setHasError(true);
    }
  }, [targetNetwork.id, error]);

  useEffect(() => {
    if (!isLocalNetwork) {
      notification.error(
        <>
          <p className="font-bold mt-0 mb-1">
            <code className="italic bg-base-300 text-base font-bold"> targetNetwork </code> is not localhost
          </p>
          <p className="m-0">
            - You are on <code className="italic bg-base-300 text-base font-bold">{targetNetwork.name}</code> .This
            block explorer is only for <code className="italic bg-base-300 text-base font-bold">localhost</code>.
          </p>
          <p className="mt-1 break-normal">
            - You can use{" "}
            <a className="text-accent" href={targetNetwork.blockExplorers?.default.url}>
              {targetNetwork.blockExplorers?.default.name}
            </a>{" "}
            instead
          </p>
        </>,
      );
    }
  }, [
    isLocalNetwork,
    targetNetwork.blockExplorers?.default.name,
    targetNetwork.blockExplorers?.default.url,
    targetNetwork.name,
  ]);

  useEffect(() => {
    if (hasError) {
      notification.error(
        <>
          <p className="font-bold mt-0 mb-1">Cannot connect to local provider</p>
          <p className="m-0">
            - Did you forget to run <code className="italic bg-base-300 text-base font-bold">yarn chain</code> ?
          </p>
          <p className="mt-1 break-normal">
            - Or you can change <code className="italic bg-base-300 text-base font-bold">targetNetwork</code> in{" "}
            <code className="italic bg-base-300 text-base font-bold">scaffold.config.ts</code>
          </p>
        </>,
      );
    }
  }, [hasError]);

  const handleContractAddressChange = (index: number, value: string) => {
    const newInputs = [...contractAddressInputs];
    newInputs[index] = value;
    setContractAddressInputs(newInputs);
  };

  const addContractAddressInput = () => {
    setContractAddressInputs([...contractAddressInputs, ""]);
  };

  const removeContractAddressInput = (index: number) => {
    if (contractAddressInputs.length === 1) return; // prevent removing the last one
    const newInputs = contractAddressInputs.filter((_, i) => i !== index);
    setContractAddressInputs(newInputs);
  };

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    console.log(
      "Submitted values:",
      contractAddressInputs.filter(val => val.trim() !== ""),
    );
  };

  return (
    <div className="container mx-auto my-10">
      <p>hi</p>
      <form
        onSubmit={handleSubmit}
        className="border-primary bg-base-100 text-base-content placeholder:text-base-content/50 p-2 mr-2 w-full md:w-1/2 lg:w-1/3 rounded-md shadow-md focus:outline-hidden focus:ring-2 focus:ring-accent"
      >
        {contractAddressInputs.map((contractAddressValue, index) => (
          <div key={index} className="flex gap-2 items-center">
            <label>Contract address</label>
            <input
              type="text"
              value={contractAddressValue}
              onChange={e => handleContractAddressChange(index, e.target.value)}
              className="border p-2 rounded"
              required={index === 0} // only the first one is required
            />
            {contractAddressInputs.length > 1 && (
              <button
                type="button"
                onClick={() => removeContractAddressInput(index)}
                className="btn btn-sm btn-primary"
              >
                ✕
              </button>
            )}
          </div>
        ))}
        <button type="button" onClick={addContractAddressInput} className="btn btn-sm btn-primary">
          + Add token to migrate
        </button>
        <div className="flex gap-2 items-center">
          <label>New Token Name</label>
          <input
            type="text"
            value={newTokenName}
            onChange={e => setNewTokenName(e.target.value)}
            className="border p-2 rounded"
          />
        </div>
        <div className="flex gap-2 items-center">
          <label>New Token Ticker</label>
          <input
            type="text"
            value={newTokenTicker}
            onChange={e => setNewTokenTicker(e.target.value)}
            className="border p-2 rounded"
          />
        </div>
        <div className="flex gap-2 items-center">
          <label>New Token Decimals</label>
          <Input label="Email" placeholder="Enter your email" type="email" />
        </div>
        <button type="submit" className="btn btn-sm btn-primary">
          Submit
        </button>
      </form>
    </div>
  );
};

export default CreateMigraiton;
