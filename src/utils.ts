import { buf2hex } from "@taquito/utils";
import * as blake from "blakejs";
import bs58check from "bs58check";
const stringToHex = (payload: string): string => {
  const input = Buffer.from(payload);
  return buf2hex(input);
};

const PREFIX = {
  tz1: new Uint8Array([6]),
  edsk: new Uint8Array([13, 15, 58, 7]),
};

/**
 * Hash the string representation of the payload, returns the b58 reprensentation starting with the given prefix
 * @param prefix the prefix of your hash
 * @returns
 */
const toB58Hash = (prefix: Uint8Array, payload: string) => {
  const blakeHash = blake.blake2b(payload, undefined, 32);
  const tmp = new Uint8Array(prefix.length + blakeHash.length);
  tmp.set(prefix);
  tmp.set(blakeHash, prefix.length);
  const b58 = bs58check.encode(Buffer.from(tmp));
  return b58;
};

export const convertPrivateKey = (
  rawKeyPair: any
): string => {
  const rawPrivateKey = rawKeyPair.privateKey.split("-----")[2].trim();
  // transform to a valid secret for Deku
  const privateKey = toB58Hash(PREFIX.edsk, rawPrivateKey);
  return privateKey;
};
